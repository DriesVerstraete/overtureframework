#include "SmParameters.h"
#include "FlowSolutions.h"
#include "GenericGraphicsInterface.h"
#include "FluidPiston.h"
#include "PistonMotion.h"
#include "ParallelUtility.h"
#include "TimeFunction.h"
#include "BeamModel.h"

#define rotatingDiskSVK   EXTERN_C_NAME(rotatingdisksvk)
#define evalFibShearSolid EXTERN_C_NAME(evalfibshearsolid)
#define evalFibShearSolidFull EXTERN_C_NAME(evalfibshearsolidfull)
#define evalFibCartWaveSolid EXTERN_C_NAME(evalfibcartwavesolid)

extern "C"
{
  // rotating disk (SVK) exact solution:
  void rotatingDiskSVK( const real & t, const int & numberOfGridPoints, real & uDisk, real & param,
                        const int & nrwk, real & rwk );

  // exact fsi solution for shearing solid
  void evalFibShearSolid( const real & ksr, const real & ksi,
			  const real & ar, const real & ai,
			  const real & br, const real & bi,
			  const real & y, 
			  real & ur, real & ui, real & uyr, real & uyi);

  void evalFibShearSolidFull( const real & ksr, const real & ksi,
                              const real & ar, const real & ai,
                              const real & br, const real & bi,
                              const real & y, const real & t,
                              real & ur, real & ui, 
                              real & vr, real & vi, 
                              real & uyr, real & uyi,
                              const real & omegar, const real & omegai);

  void evalFibCartWaveSolid( const real & omegar, const real & omegai,
                             const real & k, const real & mubar,
                             const real & rhobar, const real & lambdabar,
                             const real & k1r, const real & k1i,
                             const real & k2r, const real & k2i,
                             const real & amp, const real & x,
                             const real & y, const real & t,
                             const real & Hbar, 
                             real & u1barr, real & u2barr, real & v1barr, 
                             real & v2barr, real & s11barr, 
                             real & s12barr, real & s22barr);
  
}

#define FOR_3D(i1,i2,i3,I1,I2,I3) \
int I1Base =I1.getBase(),   I2Base =I2.getBase(),  I3Base =I3.getBase();  \
int I1Bound=I1.getBound(),  I2Bound=I2.getBound(), I3Bound=I3.getBound(); \
for(i3=I3Base; i3<=I3Bound; i3++) \
for(i2=I2Base; i2<=I2Bound; i2++) \
for(i1=I1Base; i1<=I1Bound; i1++)

// Macro to get the vertex array
#define GET_VERTEX_ARRAY(x)                                     \
mg.update(MappedGrid::THEvertex | MappedGrid::THEcenter);       \
OV_GET_SERIAL_ARRAY_CONST(real,mg.vertex(),x);


int SmParameters::
getUserDefinedKnownSolution(real t, CompositeGrid & cg, int grid, RealArray & ua, 
			    const Index & I1, const Index &I2, const Index &I3, 
                            int numberOfTimeDerivatives /* = 0 */  )
// ==========================================================================================
///  \brief Evaluate a user defined known solution.
// ==========================================================================================
{
  MappedGrid & mg = cg[grid];

  if( ! dbase.get<DataBase >("modelData").has_key("userDefinedKnownSolutionData") )
  {
    printf("getUserDefinedKnownSolution:ERROR: sub-directory `userDefinedKnownSolutionData' not found!\n");
    Overture::abort("error");
  }
  DataBase & db =  dbase.get<DataBase >("modelData").get<DataBase>("userDefinedKnownSolutionData");

  const aString & userKnownSolution = db.get<aString>("userKnownSolution");

  real *rpar = db.get<real[20]>("rpar");
  int *ipar = db.get<int[20]>("ipar");

  const real dt = dbase.get<real>("dt");
  const real & rho    = dbase.get<real>("rho");
  const real & mu     = dbase.get<real>("mu");
  const real & lambda = dbase.get<real>("lambda");

  const real cp=sqrt((2.*mu+lambda)/rho);
  const real cs =sqrt(mu/rho);

  // Here are the comopnents for displacement velocity and stress
  const int v1c = dbase.get<int >("v1c");
  const int v2c = dbase.get<int >("v2c");

  const int u1c = dbase.get<int >("uc");
  const int u2c = dbase.get<int >("vc");

  const int s11c = dbase.get<int >("s11c");
  const int s12c = dbase.get<int >("s12c");
  const int s21c = dbase.get<int >("s21c");
  const int s22c = dbase.get<int >("s22c");

  const bool assignVelocity = v1c>=0 ;
  const bool assignStress   = s11c>=0 ;

  assert( numberOfTimeDerivatives==0 );  // for now we don't use this in Cgsm

  if( userKnownSolution=="rotatingDisk" )
  {
    // ---- return the exact solution for the rotating disk ---
    printF(" userDefinedKnownSolution: rotatingDisk: t=%9.3e\n",t);

    assert( v1c>=0 && u1c>=0 && s22c >=0 );

    MappedGrid & mg = cg[grid];
    mg.update(MappedGrid::THEvertex | MappedGrid::THEcenter);

    const realArray & center = mg.center();
    RealArray & u = ua;

    
    // tDisk : solution has been computed at this time
    real & tDisk = db.get<real>("tDisk");

    const int & numberOfGridPoints = db.get<int>("numberOfGridPointsDisk");

    const real & omega = db.get<real>("omegaDisk");

    const real & innerRadius = db.get<real>("innerRadiusDisk");
    const real & outerRadius = db.get<real>("outerRadiusDisk");


    const real dr = (outerRadius-innerRadius)/(numberOfGridPoints-1.);

    RealArray & uDisk = db.get<RealArray>("uDisk"); // exact solution is stored here

    if( t!=tDisk )
    {
      // Compute the exact solution at time t
      tDisk=t;


      int numberOfComponents=8;  // number of components needed in 1D solution: we compute u, v, and sigma 
      if( uDisk.getLength(0)!=numberOfGridPoints )
      {
	uDisk.redim(numberOfGridPoints,numberOfComponents);
      }
      
      // call the fortran routine here to evaluate the solution at time t and return the result in uDisk     

      int nrwk=10*numberOfGridPoints+6;
      RealArray rwk(nrwk);
      int npar=10;
      RealArray param(npar);

      param(0)=innerRadius;
      param(1)=outerRadius;
      param(2)=omega;
      param(3)=1.;   // this is lambda
      param(4)=1.;   // this mu

      rotatingDiskSVK( t, numberOfGridPoints, *uDisk.getDataPointer(), *param.getDataPointer(), nrwk, *rwk.getDataPointer() );

    }
    

    const real twopi=6.283185307179586;
    const real x0=0., y0=0.;  // center of the disk 

    int i1,i2,i3;
    FOR_3D(i1,i2,i3,I1,I2,I3)
    {
      // Reference coordinates:
      real x= center(i1,i2,i3,0);
      real y= center(i1,i2,i3,1);

      real r = sqrt( SQR(x-x0) + SQR(y-y0) );

      // closest point in uDisk less than or equal to r:
      int i = int( (r-innerRadius)/dr );  
      i = max(0,min(i,numberOfGridPoints-2));
      
      // linear interpolation
      real alpha = (r-innerRadius)/dr - i;
      real c1=1.-alpha, c2=alpha;

      // radial and angular displacements
      real w=c1*uDisk(i,0)+c2*uDisk(i+1,0);
      real p=c1*uDisk(i,1)+c2*uDisk(i+1,1);

      // angular position
      real theta=0.;
      if (r>0.)
      {
        if (y<0.)
        {
          theta=twopi-acos((x-x0)/r);
        }
        else
        {
          theta=acos((x-x0)/r);
        }
      }

//      printF("rotatingDisk: i=%i, uDisk(i,0)=%9.3e, uDisk(i+1,0)=%9.3e, uDisk(i,1)=%9.3e, uDisk(i+1,1)=%9.3e\n",i,uDisk(i,0),uDisk(i+1,0),uDisk(i,1),uDisk(i+1,1));
//      printF("rotatingDisk: i=%i, alpha=%9.3e, c1=%9.3e, c2=%9.3e, w=%9.3e, p=%9.3e, theta=%9.3e\n",i,alpha,c1,c2,w,p,theta);

      // displacements
      real thbar=theta+p;
      u(i1,i2,i3,u1c)=(r+w)*cos(thbar)-x;
      u(i1,i2,i3,u2c)=(r+w)*sin(thbar)-y;

      // velocities
      real wt=c1*uDisk(i,2)+c2*uDisk(i+1,2);
      real pt=c1*uDisk(i,3)+c2*uDisk(i+1,3);
      u(i1,i2,i3,v1c)=wt*cos(thbar)-pt*(r+w)*sin(thbar);
      u(i1,i2,i3,v2c)=wt*sin(thbar)+pt*(r+w)*cos(thbar);

      // stresses
      real pbar11=c1*uDisk(i,4)+c2*uDisk(i+1,4);
      real pbar12=c1*uDisk(i,5)+c2*uDisk(i+1,5);
      real pbar21=c1*uDisk(i,6)+c2*uDisk(i+1,6);
      real pbar22=c1*uDisk(i,7)+c2*uDisk(i+1,7);
      real pt11=pbar11*cos(thbar)-pbar12*sin(thbar);
      real pt12=pbar11*sin(thbar)+pbar12*cos(thbar);
      real pt21=pbar21*cos(thbar)-pbar22*sin(thbar);
      real pt22=pbar21*sin(thbar)+pbar22*cos(thbar);
      u(i1,i2,i3,s11c)=cos(theta)*pt11-sin(theta)*pt21;
      u(i1,i2,i3,s12c)=cos(theta)*pt12-sin(theta)*pt22;
      u(i1,i2,i3,s21c)=sin(theta)*pt11+cos(theta)*pt21;
      u(i1,i2,i3,s22c)=sin(theta)*pt12+cos(theta)*pt22;

    }


  }
  else if( userKnownSolution=="linearBeamExactSolution" )
  {
 
    MappedGrid & mg = cg[grid];
    mg.update(MappedGrid::THEvertex | MappedGrid::THEcenter);

    OV_GET_SERIAL_ARRAY_CONST(real,mg.vertex(),vertex);

    RealArray & u = ua;

    const int & uc = dbase.get<int >("uc");   //  u velocity component =u(all,all,all,uc)
    const int & vc = dbase.get<int >("vc");  
    const int & pc = dbase.get<int >("pc");  
    double E=1.4e6;
    double rhos=10000.0;
    double h=0.02;
    double Ioverb=6.6667e-7;
    double rhof=1000;
    double nu=0.001;
    double L=0.3;
    double H=0.3;
    double k=2.0*3.141592653589/L;
    double omega0=sqrt(E*Ioverb*k*k*k*k/(rhos*h));
    double what = 0.00001;
    //double beta=1.0/nu*sqrt(E*Ioverb/(rhos*h));
    //std::complex<double> omegatilde(1.065048891,-5.642079778e-4);
    std::cout << "t = " << t << std::endl;
    double omegar = 0.8907148069, omegai = -0.9135887123e-2;
    for ( int i3=I3.getBase(); i3<=I3.getBound(); i3++ ) {
      for ( int i2=I2.getBase(); i2<=I2.getBound(); i2++ ) {
	for ( int i1=I1.getBase(); i1<=I1.getBound(); i1++ ) {
	  
	  double y = vertex(i1,i2,i3,1);
	  double x = vertex(i1,i2,i3,0);
	  
	  BeamModel::exactSolutionVelocity(x,y,t,k,H,
					   omegar,omegai, 
					   omega0,nu,
					   what,u(i1,i2,i3,uc),
					   u(i1,i2,i3,vc));

	  BeamModel::exactSolutionPressure(x,y,t,k,H,
					   omegar,omegai, 
					   omega0,nu,
					   what,u(i1,i2,i3,pc));

	  //std::cout << x << " " << y << " " << u(i1,i2,i3,uc) << " " << u(i1,i2,i3,vc) << std::endl;
	}
      }
    }   
  }

  else if( userKnownSolution=="bulkSolidPiston" )
  {
    // ---- return the exact solution for the FSI INS+elastic piston ---
    //     y_I(t) = F(t + Hbar/cp) - F(t - Hbar/cp)
    //        F(z) = amp * R(z) * sin( 2*Pi*k(t-t0) )
    //        R(z) = ramp function that smoothly transitions from 0 to 1 

    // assert( v1c>=0 && u1c>=0 && s22c >=0 );

    const real & H        = rpar[0];
    const real & Hbar     = rpar[1];
    const real & rhoFluid = rpar[2];
    const real & rhoBar   = rpar[3];
    const real & lambdaBar= rpar[4];
    const real & muBar    = rpar[5];

    const real cp2 = sqrt((lambdaBar+2.*muBar)/rhoBar);
    assert( cp==cp2 ); // sanity check
    
    if( t<= 2.*dt )
    {
      printF("--SM-- userDefinedKnownSolution: bulkSolidPiston, Hbar=%g, t=%9.3e\n",Hbar,t);
      printF("--SM-- lambda   =%g mu   =%g rho   =%g\n",lambda,mu,rho);
      printF("--SM-- lambdaBar=%g muBar=%g rhoBar=%g\n",lambdaBar,muBar,rhoBar);
      
    }
    assert( lambda==lambdaBar && mu==muBar && rho==rhoBar );
    assert( numberOfTimeDerivatives==0 );

    TimeFunction & bsp = db.get<TimeFunction>("timeFunctionBSP");

    MappedGrid & mg = cg[grid];
    mg.update(MappedGrid::THEvertex | MappedGrid::THEcenter);

    const realArray & center = mg.center();
    RealArray & u = ua;

    int i1,i2,i3;
    FOR_3D(i1,i2,i3,I1,I2,I3)
    {
      // Reference coordinates:
      // real x= center(i1,i2,i3,0);
      const real y= center(i1,i2,i3,1);

      real xim,xip, fm,fp, fmd,fpd;
      xim=t-(y+Hbar)/cp;
      xip=t+(y+Hbar)/cp;  
        
      bsp.eval(xim, fm,fmd );  // fmd = d(fm(xi))/d(xi)
      bsp.eval(xip, fp,fpd );

      u(i1,i2,i3,u1c)=0.;
      u(i1,i2,i3,u2c)= fp - fm;

      // velocities
      if( assignVelocity )
      {
        u(i1,i2,i3,v1c)=0.;
        u(i1,i2,i3,v2c)= fpd - fmd;
      }
      
      // stresses
      real u2y;
      if( assignStress )
      {
        u2y = (fpd + fmd)/cp; // note "+" sign
        
	u(i1,i2,i3,s11c)=lambda*u2y;
	u(i1,i2,i3,s12c)=0.;
	u(i1,i2,i3,s21c)=0.;
	u(i1,i2,i3,s22c)=(lambda+2.*mu)*u2y;
      }
      
    }

  }

  else if( userKnownSolution=="radialElasticPiston" )
  {
    // ---- return the exact solution for radial elastic piston ----

    // -- we could avoid building the vertex array on Cartesian grids ---
    GET_VERTEX_ARRAY(xLocal);
    const real & R        = rpar[0];
    const real & Rbar     = rpar[1];
    const real & rho      = rpar[2];
    const real & rhoBar   = rpar[3];
    const real & lambdaBar= rpar[4];
    const real & muBar    = rpar[5];
    const real & k        = rpar[6];

    const real cp = sqrt((lambdaBar+2.*muBar)/rhoBar);
    
    // uI = uI(t) =  interface displacement in the radial direction 
    // eval uI and vI = uI_t 
    real uI,vI;
    TimeFunction & bsp = db.get<TimeFunction>("timeFunctionREP");
    bsp.eval(t, uI,vI );  

    if( t <= 2.*dt )
    {
      printF("--SM-- getUserDefinedDeformingBodyKnownSolution: radialElasticPiston, t=%9.3e uI=%9.3e vI=%9.3e, Rbar=%6.3f\n",
             t,uI,vI,Rbar );
    }

    RealArray & u = ua;
    const real eps = 10.*REAL_EPSILON;
    const real sqrtEps = sqrt(REAL_EPSILON);
    
    int i1,i2,i3;
    FOR_3D(i1,i2,i3,I1,I2,I3)
    {
      // Reference coordinates:
      real x= xLocal(i1,i2,i3,0);
      real y= xLocal(i1,i2,i3,1);
      real r = sqrt( SQR(x) + SQR(y) );
      real ct,st;
      if( r>eps )
      {
        ct=x/r; st=y/r;
      }
      else
      {
        ct=1.; st=0.;  // at the origin we just pick an angle, should not matter
      }
      
      
      real kr=k*r;
      real jnkr = jn(1,kr);
      real ur = uI*jnkr;    // radial displacement 
      real vr = vI*jnkr;    // radial velocity

      u(i1,i2,i3,u1c)=ur*ct;
      u(i1,i2,i3,u2c)=ur*st;

      // velocities
      if( assignVelocity )
      {
        u(i1,i2,i3,v1c)=vr*ct;
        u(i1,i2,i3,v2c)=vr*st;
      }
      
      // stresses
      if( assignStress )
      {
        real jnkrp = .5*k*(jn(0,kr)-jn(2,kr));  // Jn' = .5*( J(n-1) - J(n+1) ) check me 
        // real jnkrp = (jn(0,kr)-jnkr)/r;  // J1'(z) = (J0(z)-J1(z))/z
        
        // ur = amp*J_1(k*r)* ...
        real urr=uI*jnkrp;      // r-derivative of the radial displacement
        
        real urByr;
        if( fabs(r)>sqrtEps )
          urByr=ur/r;
        else
        {
          urByr=urr;  // for r small, ur/r = (ur(r)-ur(0))/r =  urr(r) + ...
          // printF(" --UDKDBS: i=(%i,%i) r=%8.2e urr=%9.3e ur=%9.3e ct=%9.3e st=%9.3e\n",i1,i2,r,urr,ur,ct,st);
        }
        
        real sigmarr = (lambdaBar+2.*muBar)*urr + lambdaBar*urByr;
        real sigmart=0.;
        real sigmatt = lambdaBar*urr +  (lambdaBar+2.*muBar)*urByr;

        // Cartesian components of the stress tensor:
        //  [ s11 s12 ] = srr rHat rHat^T + srt rHat thetaHat^T + str thetaHat^t rHat + stt thetaHat thetaHat^T
        //  [ s21 s22 ]
        // where
        //   rHat=[cos,sin], thetaHat=[-sin,cos]
        /// **CHECK ME**
	u(i1,i2,i3,s11c)= sigmarr*ct*ct - 2.*sigmart*ct*st + sigmatt*st*st;
	u(i1,i2,i3,s12c)= sigmarr*ct*st + sigmart*(ct*ct-st*st) - sigmatt*ct*st ;
	u(i1,i2,i3,s21c)= u(i1,i2,i3,s12c);
	u(i1,i2,i3,s22c)= sigmarr*st*st + 2.*sigmart*ct*st + sigmatt*ct*ct;
      }
      
    }
    
  }
  else if ( userKnownSolution == "fibShear" ) {
    // --------------------------------------------------------------------------------
    // ------ Exact solution for a parallel flow shearing a bulk elastic solid --------
    //  \bar{u}_1(y,t) = amp         exp(i omega t) (A cos(ks y) + B sin( ks y))
    //      {v}_1(y,t) = amp i omega exp(i omega t) (C exp(kf y) + D exp(-kf y))
    //              ks = omega / cs
    //              kf = sqrt(i rho omega / mu)
    //  Parameters:
    //  amp    : maximum amplitude of the displacement 
    //  omega  : time frequency of solution 
    //  H,Hbar : Height of fluid and solid domains
    //  rhoBar,lambaBar,muBar : solid density and Lame parameters
    // --------------------------------------------------------------------------------

    const real & omegar = rpar[0];
    const real & omegai = rpar[1];
    const real & ar     = rpar[2];
    const real & ai     = rpar[3];
    const real & br     = rpar[4];
    const real & bi     = rpar[5];
    const real & cr     = rpar[6];
    const real & ci     = rpar[7];
    const real & dr     = rpar[8];
    const real & di     = rpar[9];
    const real & ksr    = rpar[10];
    const real & ksi    = rpar[11];
    const real & kfr    = rpar[12];
    const real & kfi    = rpar[13];
    const real & amp    = rpar[14];

    printF("--SM-- userDefinedKnownSolution: fibShear, t=%9.3e, "
	   "rhoBar=%9.3e, muBar=%9.3e\n",t,rho,mu);

    // const real cs2 = sqrt((muBar)/rhoBar);

    // sanity checks
    // assert( cs==cs2 ); 
    // assert( mu==muBar );
    assert( numberOfTimeDerivatives==0 );


    // fill in the solution
    MappedGrid & mg = cg[grid];
    mg.update(MappedGrid::THEvertex | MappedGrid::THEcenter);

    const realArray & center = mg.center();
    RealArray & u = ua;

    real u0_r = amp*exp(-omegai*t)*cos(omegar*t);
    real u0_i = amp*exp(-omegai*t)*sin(omegar*t);
    real v0_r =  omegai*u0_r + omegar*u0_i;
    real v0_i = -omegar*u0_r + omegai*u0_i;

    int i1,i2,i3;
    FOR_3D(i1,i2,i3,I1,I2,I3)
    {
      // Reference coordinates:
      // const real x= center(i1,i2,i3,0);
      const real y= center(i1,i2,i3,1);
      
      // Evaluate the solution for shear flow (FSI)
      //
      // u1  = amp    ( A cos(ks y) + B sin(ks y)) exp(-i omega t)
      // u1y = amp ks (-A sin(ks y) + B cos(ks y)) exp(-i omega t)
      //
      // Return:
      //  ur  = real( A cos(ks y) + B sin(ks y) )
      //  ui  = imag( A cos(ks y) + B sin(ks y) )
      //  uyr = real( ks (-A sin(ks y) + B cos(ks y)) )
      //  uyi = imag( ks (-A sin(ks y) + B cos(ks y)) )

      real ur,ui,vr,vi,uyr,uyi;
      // evalFibShearSolid(ksr,ksi,ar,ai,br,bi,y,ur,ui,uyr,uyi);
      evalFibShearSolidFull(ksr,ksi,ar,ai,br,bi,y,t,ur,ui,vr,vi,uyr,uyi,omegar,omegai);

      // u(i1,i2,i3,u1c)=u0_r*ur-u0_i*ui;
      u(i1,i2,i3,u1c)=amp*ur;
      u(i1,i2,i3,u2c)=0.0;


      // velocities
      if( assignVelocity )
      {
        // u(i1,i2,i3,v1c)=v0_r*ur-v0_i*ui;
        u(i1,i2,i3,v1c)=amp*vr;
        u(i1,i2,i3,v2c)=0.;
      }
      
      // stresses
      if( assignStress )
      {
	u(i1,i2,i3,s11c)=0.;
	// u(i1,i2,i3,s12c)=mu*(u0_r*uyr-u0_i*uyi);
	// u(i1,i2,i3,s21c)=mu*(u0_r*uyr-u0_i*uyi);
	u(i1,i2,i3,s22c)=0.;

	u(i1,i2,i3,s12c)=amp*mu*uyr;
	u(i1,i2,i3,s21c)=amp*mu*uyr;
      }
      
    }


  }
  else if (userKnownSolution=="fibCartWave") 
  {
    // -- traveling wave solution for elastic solid and linearized fluid --
    // 
    // linearized fluid: 0 < x < L,      0 < y < H
    // solid reference:  0 < x < L,  -Hbar < y < 0

    const real & omegar = rpar[0];
    const real & omegai = rpar[1];
    const real & k      = rpar[2];
    const real & k1r    = rpar[3];
    const real & k1i    = rpar[4];
    const real & k2r    = rpar[5];
    const real & k2i    = rpar[6];
    const real & Ar     = rpar[7];
    const real & Ai     = rpar[8];
    const real & Br     = rpar[9];
    const real & Bi     = rpar[10];
    const real & amp    = rpar[11];
    const real & mu     = rpar[12];
    const real & rho    = rpar[13];
    const real & muBar  = rpar[14];
    const real & lambdaBar = rpar[15];
    const real & rhoBar = rpar[16];
    const real & H      = rpar[17];
    const real & HBar   = rpar[18];

    printF("--SM-- userDefinedKnownSolution: fibCartWave, t=%9.3e, "
	   "rhoBar=%9.3e, muBar=%9.3e\n",t,rho,mu);

    assert( numberOfTimeDerivatives==0 );

    // fill in the solution
    MappedGrid & mg = cg[grid];
    mg.update(MappedGrid::THEvertex | MappedGrid::THEcenter);

    const realArray & center = mg.center();
    RealArray & u = ua;

    int i1,i2,i3;
    FOR_3D(i1,i2,i3,I1,I2,I3)
      {
        // Reference coordinates:
        const real x= center(i1,i2,i3,0);
        const real y= center(i1,i2,i3,1);

        real u1Barr, u2Barr, v1Barr, v2Barr, s11Barr, s12Barr, s22Barr;

        evalFibCartWaveSolid(omegar, omegai, k, muBar,
                             rhoBar, lambdaBar, k1r, k1i,
                             k2r, k2i, amp, x, y, t, HBar, 
                             u1Barr, u2Barr, v1Barr, 
                             v2Barr, s11Barr, 
                             s12Barr, s22Barr);

        u(i1,i2,i3,u1c)=u1Barr;
        u(i1,i2,i3,u2c)=u2Barr;


        // velocities
        if( assignVelocity )
          {
            u(i1,i2,i3,v1c)=v1Barr;
            u(i1,i2,i3,v2c)=v2Barr;
          }
      
        // stresses
        if( assignStress )
          {
            u(i1,i2,i3,s11c)=s11Barr;
            u(i1,i2,i3,s12c)=s12Barr;
            u(i1,i2,i3,s21c)=s12Barr;
            u(i1,i2,i3,s22c)=s22Barr;
          }
      
      }



  }
  else 
  {
    // look for a solution in the base class
    Parameters::getUserDefinedKnownSolution( t, cg, grid, ua, I1,I2,I3 );
  }
  
  // else
  // {
  //   printF("getUserDefinedKnownSolution:ERROR: unknown value for userDefinedKnownSolution=%s\n",
  // 	   (const char*)userKnownSolution);
  //   OV_ABORT("ERROR");
  // }
  
  return 0;
}



int SmParameters::
updateUserDefinedKnownSolution(GenericGraphicsInterface & gi, CompositeGrid & cg)
// ==========================================================================================
/// \brief This function is called to set the user defined know solution.
/// 
/// \return   >0 : known solution was chosen, 0 : no known solution was chosen
///
// ==========================================================================================
{
  // Make  dbase.get<real >("a") sub-directory in the data-base to store variables used here
  if( ! dbase.get<DataBase >("modelData").has_key("userDefinedKnownSolutionData") )
    dbase.get<DataBase >("modelData").put<DataBase>("userDefinedKnownSolutionData");
  DataBase & db =  dbase.get<DataBase >("modelData").get<DataBase>("userDefinedKnownSolutionData");

  if( !db.has_key("userKnownSolution") )
  {
    db.put<aString>("userKnownSolution");
    db.get<aString>("userKnownSolution")="unknownSolution";
    
    db.put<real[20]>("rpar");
    db.put<int[20]>("ipar");
  }
  aString & userKnownSolution = db.get<aString>("userKnownSolution");
  real *rpar = db.get<real[20]>("rpar");
  int *ipar = db.get<int[20]>("ipar");


  const aString menu[]=
    {
      "no known solution",
      "rotating disk",  // for cgsm SVK model
      "linear beam exact solution",
      "choose a common known solution",
      "done",
      ""
    }; 

  gi.appendToTheDefaultPrompt("userDefinedKnownSolution>");
  aString answer;
  for( ;; ) 
  {

    int response=gi.getMenuItem(menu,answer,"Choose a known solution");
    
    if( answer=="done" || answer=="exit" )
    {
      break;
    }
    else if( answer=="choose a common known solution" )
    {
      // Look for a known solution from the base class (in common/src)
      Parameters::updateUserDefinedKnownSolution(gi,cg);
    }
    else if( answer=="no known solution" )
    {
      userKnownSolution="unknownSolution";
    }
    else if( answer=="exact solution from a file" )
    {
      userKnownSolution="exactSolutionFromAFile";
      dbase.get<bool>("knownSolutionIsTimeDependent")=false;  // known solution does NOT depend on time

      printF("The exact solution can be defined by a solution in a show file (e.g. from a fine grid solution)\n");
      
      gi.inputString(answer,"Enter the the name of the file holding the exact solution");

      // sScanF(answer,"%e %e",&rpar[0],&rpar[1]);
      // printF("forced piston: mass=%e, height=%e\n",rpar[0],rpar[1]);

    }
    else if( answer=="rotating disk" )
    {
      userKnownSolution="rotatingDisk";
      dbase.get<bool>("knownSolutionIsTimeDependent")=true;  // known solution IS time dependent

      if( !db.has_key("tDisk") )
      { // Create parameters for the rotating disk solution
	db.put<real>("tDisk");
	db.put<int>("numberOfGridPointsDisk");
	db.put<real>("omegaDisk");
	db.put<real>("innerRadiusDisk");
	db.put<real>("outerRadiusDisk");
	db.put<RealArray>("uDisk"); // exact solution is stored here
      }
      

      real & tDisk = db.get<real>("tDisk");
      int & numberOfGridPoints = db.get<int>("numberOfGridPointsDisk");
      real & omega = db.get<real>("omegaDisk");
      real & innerRadius = db.get<real>("innerRadiusDisk");
      real & outerRadius = db.get<real>("outerRadiusDisk");
      RealArray & uDisk = db.get<RealArray>("uDisk"); // exact solution is stored here

      // Defaults:
      tDisk=-1.;  // this will cause the solution to be computed 
      numberOfGridPoints=101;
      omega=.5;
      innerRadius=0.;
      outerRadius=1.;

      // Prompt for input:
      printF("--- The rotating disk exact solution requires: ---\n"
	     " n : number of points to use when computing the exact solution\n"
	     " omega : rotation rate\n"
	     " ra,rb : radial bounds\n");
      gi.inputString(answer,"Enter n,omega,ra,rb for the exact solution");
      sScanF(answer,"%i %e %e %e",&numberOfGridPoints,&omega,&innerRadius,&outerRadius);

      printF("rotatingDisk: setting n=%i, omega=%9.3e, ra=%9.3e, rb=%9.3e\n",
	     numberOfGridPoints,omega,innerRadius,outerRadius);

//       // We need to keep a FlowSolutions object around
//       db.put<FlowSolutions*>("flowSolutions",NULL);

//       db.get<FlowSolutions*>("flowSolutions")=new FlowSolutions;

//       FlowSolutions & flowSolutions = *db.get<FlowSolutions*>("flowSolutions");

    }
    
    else if( answer=="linear beam exact solution" ) 
    {

      userKnownSolution="linearBeamExactSolution";
      dbase.get<bool>("knownSolutionIsTimeDependent")=true;  // known solution IS time dependent 
      double omega;
      gi.inputString(answer,"Enter omega");
      sScanF(answer,"%e",&omega);
    }


    else
    {
      printF("unknown response=[%s]\n",(const char*)answer);
      gi.stopReadingCommandFile();
    }
    
  }

  gi.unAppendTheDefaultPrompt();
  bool knownSolutionChosen = userKnownSolution!="unknownSolution";
  return knownSolutionChosen;
}
