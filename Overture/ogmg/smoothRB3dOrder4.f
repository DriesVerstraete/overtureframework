! This file automatically generated from smoothOpt.bf with bpp.
! SMOOTH_SUBROUTINE(smoothRB3dOrder4,3,4)
        subroutine smoothRB3dOrder4( nd, nd1a,nd1b,nd2a,nd2b,nd3a,nd3b,
     & n1a,n1b,n1c,n2a,n2b,n2c,n3a,n3b,n3c, ndc, f, c, u, v, mask, 
     & option, order, sparseStencil, cc, s, dx, omega, 
     & useLocallyOptimalOmega,variableOmegaScaleFactor, ipar, rpar )
c ===================================================================================
c  Optimised Red-black smooth
c
c  option:  0 : red-points
c           1 : black-points
c
c
c  cc(m) : constant coefficients
c  sparseStencil : general=0, sparse=1, constantCoefficients=2, sparseConstantCoefficients=3
c ===================================================================================
        implicit none
        integer nd, nd1a,nd1b,nd2a,nd2b,nd3a,nd3b, n1a,n1b,n1c,n2a,n2b,
     & n2c,n3a,n3b,n3c, ndc, option, sparseStencil,order,
     & useLocallyOptimalOmega
        integer mask(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
        real u(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
        real v(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
        real f(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
        real c(1:ndc,nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
        real s(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
        real cc(1:*),dx(*),omega,variableOmegaScaleFactor
        integer ipar(0:*)
        real rpar(0:*)
c..........local
        real c1,c2,c3,cmin,cmax,variableOmegaFactor
        integer numberOfSmooths,cycleType
        integer i1,i2,i3,i1s,i2s,i3s,j1,j2,j3,n1d,n
        integer m11,m12,m13,m14,m15, m21,m22,m23,m24,m25, m31,m32,m33,
     & m34,m35, m41,m42,m43,m44,m45, m51,m52,m53,m54,m55
        integer    m111,m211,m311,m411,m511, m121,m221,m321,m421,m521, 
     & m131,m231,m331,m431,m531, m141,m241,m341,m441,m541, m151,m251,
     & m351,m451,m551, m112,m212,m312,m412,m512, m122,m222,m322,m422,
     & m522, m132,m232,m332,m432,m532, m142,m242,m342,m442,m542, m152,
     & m252,m352,m452,m552, m113,m213,m313,m413,m513, m123,m223,m323,
     & m423,m523, m133,m233,m333,m433,m533, m143,m243,m343,m443,m543, 
     & m153,m253,m353,m453,m553, m114,m214,m314,m414,m514, m124,m224,
     & m324,m424,m524, m134,m234,m334,m434,m534, m144,m244,m344,m444,
     & m544, m154,m254,m354,m454,m554, m115,m215,m315,m415,m515, m125,
     & m225,m325,m425,m525, m135,m235,m335,m435,m535, m145,m245,m345,
     & m445,m545, m155,m255,m355,m455,m555
        integer    m11n,m21n,m31n,m41n,m51n, m12n,m22n,m32n,m42n,m52n, 
     & m13n,m23n,m33n,m43n,m53n, m14n,m24n,m34n,m44n,m54n, m15n,m25n,
     & m35n,m45n,m55n
        real eps
        integer general, sparse, constantCoefficients,  
     & sparseConstantCoefficients,sparseVariableCoefficients, 
     & variableCoefficients
        parameter( general=0,  sparse=1,  constantCoefficients=2, 
     & sparseConstantCoefficients=3, sparseVariableCoefficients=4, 
     & variableCoefficients=5 )
        !     *** statement functions ***
        real update2dSparse,update2d,update3dSparse,update3d
        real update2dSparseCC,update2dCC,update3dSparseCC,update3dCC
        real update2dSparseVC,update2dVC,update3dSparseVC, update3dVC
        real update2dSparse4,update2d4,update3dSparse4,update3d4, 
     & update3d4a
        real update2dSparseCC4,update2dCC4,update3dSparseCC4,
     & update3dCC4, update3dCC4a
        real a1,a2,a3,a22,a222,a12
        real a1m,a1p,a2m,a2p,a3m,a3p,ad
        real dx2i,dy2i,dz2i
c ===========  2nd order ===========================
!  #If "3" == "2"
! #If "3" == "3"
        update3dSparse(i1,i2,i3) = u(i1,i2,i3) + omega*(f(i1,i2,i3)-(  
     &       c(m221,i1,i2,i3)*u(i1  ,i2  ,i3-1)+ c(m212,i1,i2,i3)*u(
     & i1  ,i2-1,i3  )+ c(m122,i1,i2,i3)*u(i1-1,i2  ,i3  )+ c(m222,i1,
     & i2,i3)*u(i1  ,i2  ,i3  )+ c(m322,i1,i2,i3)*u(i1+1,i2  ,i3  )+ 
     & c(m232,i1,i2,i3)*u(i1  ,i2+1,i3  )+ c(m223,i1,i2,i3)*u(i1  ,i2 
     &  ,i3+1) ))/(c(m222,i1,i2,i3)+eps)
        update3d(i1,i2,i3)=u(i1,i2,i3)+ omega*(f(i1,i2,i3)-(        c(
     & m111,i1,i2,i3)*u(i1-1,i2-1,i3-1)+ c(m211,i1,i2,i3)*u(i1  ,i2-1,
     & i3-1)+ c(m311,i1,i2,i3)*u(i1+1,i2-1,i3-1)+ c(m121,i1,i2,i3)*u(
     & i1-1,i2  ,i3-1)+ c(m221,i1,i2,i3)*u(i1  ,i2  ,i3-1)+ c(m321,i1,
     & i2,i3)*u(i1+1,i2  ,i3-1)+ c(m131,i1,i2,i3)*u(i1-1,i2+1,i3-1)+ 
     & c(m231,i1,i2,i3)*u(i1  ,i2+1,i3-1)+ c(m331,i1,i2,i3)*u(i1+1,i2+
     & 1,i3-1)+ c(m112,i1,i2,i3)*u(i1-1,i2-1,i3  )+ c(m212,i1,i2,i3)*
     & u(i1  ,i2-1,i3  )+ c(m312,i1,i2,i3)*u(i1+1,i2-1,i3  )+ c(m122,
     & i1,i2,i3)*u(i1-1,i2  ,i3  )+ c(m222,i1,i2,i3)*u(i1  ,i2  ,i3  )
     & + c(m322,i1,i2,i3)*u(i1+1,i2  ,i3  )+ c(m132,i1,i2,i3)*u(i1-1,
     & i2+1,i3  )+ c(m232,i1,i2,i3)*u(i1  ,i2+1,i3  )+ c(m332,i1,i2,
     & i3)*u(i1+1,i2+1,i3  )+ c(m113,i1,i2,i3)*u(i1-1,i2-1,i3+1)+ c(
     & m213,i1,i2,i3)*u(i1  ,i2-1,i3+1)+ c(m313,i1,i2,i3)*u(i1+1,i2-1,
     & i3+1)+ c(m123,i1,i2,i3)*u(i1-1,i2  ,i3+1)+ c(m223,i1,i2,i3)*u(
     & i1  ,i2  ,i3+1)+ c(m323,i1,i2,i3)*u(i1+1,i2  ,i3+1)+ c(m133,i1,
     & i2,i3)*u(i1-1,i2+1,i3+1)+ c(m233,i1,i2,i3)*u(i1  ,i2+1,i3+1)+ 
     & c(m333,i1,i2,i3)*u(i1+1,i2+1,i3+1) ))/(c(m222,i1,i2,i3)+eps)
! #If "3" == "2"
! #If "3" == "3"
        update3dSparseCC(i1,i2,i3) = u(i1,i2,i3) + omega*(f(i1,i2,i3)-(
     &         cc(m221)*u(i1  ,i2  ,i3-1)+ cc(m212)*u(i1  ,i2-1,i3  )+
     &  cc(m122)*u(i1-1,i2  ,i3  )+ cc(m222)*u(i1  ,i2  ,i3  )+ cc(
     & m322)*u(i1+1,i2  ,i3  )+ cc(m232)*u(i1  ,i2+1,i3  )+ cc(m223)*
     & u(i1  ,i2  ,i3+1) ))/(cc(m222))
        update3dCC(i1,i2,i3)=u(i1,i2,i3)+ omega*(f(i1,i2,i3)-(        
     & cc(m111)*u(i1-1,i2-1,i3-1)+ cc(m211)*u(i1  ,i2-1,i3-1)+ cc(
     & m311)*u(i1+1,i2-1,i3-1)+ cc(m121)*u(i1-1,i2  ,i3-1)+ cc(m221)*
     & u(i1  ,i2  ,i3-1)+ cc(m321)*u(i1+1,i2  ,i3-1)+ cc(m131)*u(i1-1,
     & i2+1,i3-1)+ cc(m231)*u(i1  ,i2+1,i3-1)+ cc(m331)*u(i1+1,i2+1,
     & i3-1)+ cc(m112)*u(i1-1,i2-1,i3  )+ cc(m212)*u(i1  ,i2-1,i3  )+ 
     & cc(m312)*u(i1+1,i2-1,i3  )+ cc(m122)*u(i1-1,i2  ,i3  )+ cc(
     & m222)*u(i1  ,i2  ,i3  )+ cc(m322)*u(i1+1,i2  ,i3  )+ cc(m132)*
     & u(i1-1,i2+1,i3  )+ cc(m232)*u(i1  ,i2+1,i3  )+ cc(m332)*u(i1+1,
     & i2+1,i3  )+ cc(m113)*u(i1-1,i2-1,i3+1)+ cc(m213)*u(i1  ,i2-1,
     & i3+1)+ cc(m313)*u(i1+1,i2-1,i3+1)+ cc(m123)*u(i1-1,i2  ,i3+1)+ 
     & cc(m223)*u(i1  ,i2  ,i3+1)+ cc(m323)*u(i1+1,i2  ,i3+1)+ cc(
     & m133)*u(i1-1,i2+1,i3+1)+ cc(m233)*u(i1  ,i2+1,i3+1)+ cc(m333)*
     & u(i1+1,i2+1,i3+1) ))/(cc(m222))
! #If "3" == "2"
! #If "3" == "3"
        update3dSparse4(i1,i2,i3) = u(i1,i2,i3) + omega*(f(i1,i2,i3)-( 
     &        c(m331,i1,i2,i3)*u(i1  ,i2  ,i3-2)+ c(m332,i1,i2,i3)*u(
     & i1  ,i2  ,i3-1)+ c(m313,i1,i2,i3)*u(i1  ,i2-2,i3  )+ c(m323,i1,
     & i2,i3)*u(i1  ,i2-1,i3  )+ c(m133,i1,i2,i3)*u(i1-2,i2  ,i3  )+ 
     & c(m233,i1,i2,i3)*u(i1-1,i2  ,i3  )+ c(m333,i1,i2,i3)*u(i1  ,i2 
     &  ,i3  )+ c(m433,i1,i2,i3)*u(i1+1,i2  ,i3  )+ c(m533,i1,i2,i3)*
     & u(i1+2,i2  ,i3  )+ c(m343,i1,i2,i3)*u(i1  ,i2+1,i3  )+ c(m353,
     & i1,i2,i3)*u(i1  ,i2+2,i3  )+ c(m334,i1,i2,i3)*u(i1  ,i2  ,i3+1)
     & + c(m335,i1,i2,i3)*u(i1  ,i2  ,i3+2) ))/(c(m333,i1,i2,i3)+eps)
        update3d4a(i1,i2,i3,n, m11n,m21n,m31n,m41n,m51n, m12n,m22n,
     & m32n,m42n,m52n, m13n,m23n,m33n,m43n,m53n, m14n,m24n,m34n,m44n,
     & m54n, m15n,m25n,m35n,m45n,m55n)= c(m11n,i1,i2,i3)*u(i1-2,i2-2,
     & i3+n)+ c(m21n,i1,i2,i3)*u(i1-1,i2-2,i3+n)+ c(m31n,i1,i2,i3)*u(
     & i1  ,i2-2,i3+n)+ c(m41n,i1,i2,i3)*u(i1+1,i2-2,i3+n)+ c(m51n,i1,
     & i2,i3)*u(i1+2,i2-2,i3+n)+ c(m12n,i1,i2,i3)*u(i1-2,i2-1,i3+n)+ 
     & c(m22n,i1,i2,i3)*u(i1-1,i2-1,i3+n)+ c(m32n,i1,i2,i3)*u(i1  ,i2-
     & 1,i3+n)+ c(m42n,i1,i2,i3)*u(i1+1,i2-1,i3+n)+ c(m52n,i1,i2,i3)*
     & u(i1+2,i2-1,i3+n)+ c(m13n,i1,i2,i3)*u(i1-2,i2  ,i3+n)+ c(m23n,
     & i1,i2,i3)*u(i1-1,i2  ,i3+n)+ c(m33n,i1,i2,i3)*u(i1  ,i2  ,i3+n)
     & + c(m43n,i1,i2,i3)*u(i1+1,i2  ,i3+n)+ c(m53n,i1,i2,i3)*u(i1+2,
     & i2  ,i3+n)+ c(m14n,i1,i2,i3)*u(i1-2,i2+1,i3+n)+ c(m24n,i1,i2,
     & i3)*u(i1-1,i2+1,i3+n)+ c(m34n,i1,i2,i3)*u(i1  ,i2+1,i3+n)+ c(
     & m44n,i1,i2,i3)*u(i1+1,i2+1,i3+n)+ c(m54n,i1,i2,i3)*u(i1+2,i2+1,
     & i3+n)+ c(m15n,i1,i2,i3)*u(i1-2,i2+2,i3+n)+ c(m25n,i1,i2,i3)*u(
     & i1-1,i2+2,i3+n)+ c(m35n,i1,i2,i3)*u(i1  ,i2+2,i3+n)+ c(m45n,i1,
     & i2,i3)*u(i1+1,i2+2,i3+n)+ c(m55n,i1,i2,i3)*u(i1+2,i2+2,i3+n)
        update3d4(i1,i2,i3)=u(i1,i2,i3)+ omega*(f(i1,i2,i3)-(        
     & update3d4a(i1,i2,i3,-2, m111,m211,m311,m411,m511, m121,m221,
     & m321,m421,m521, m131,m231,m331,m431,m531, m141,m241,m341,m441,
     & m541, m151,m251,m351,m451,m551) +update3d4a(i1,i2,i3,-1, m112,
     & m212,m312,m412,m512, m122,m222,m322,m422,m522, m132,m232,m332,
     & m432,m532, m142,m242,m342,m442,m542, m152,m252,m352,m452,m552) 
     & +update3d4a(i1,i2,i3,0, m113,m213,m313,m413,m513, m123,m223,
     & m323,m423,m523, m133,m233,m333,m433,m533, m143,m243,m343,m443,
     & m543, m153,m253,m353,m453,m553) +update3d4a(i1,i2,i3,1, m114,
     & m214,m314,m414,m514, m124,m224,m324,m424,m524, m134,m234,m334,
     & m434,m534, m144,m244,m344,m444,m544, m154,m254,m354,m454,m554) 
     & +update3d4a(i1,i2,i3,2, m115,m215,m315,m415,m515, m125,m225,
     & m325,m425,m525, m135,m235,m335,m435,m535, m145,m245,m345,m445,
     & m545, m155,m255,m355,m455,m555) ))/(c(m333,i1,i2,i3)+eps)
! #If "3" == "2"
! #If "3" == "3"
        update3dSparseCC4(i1,i2,i3) = u(i1,i2,i3) + omega*(f(i1,i2,i3)-
     & (        cc(m331)*u(i1  ,i2  ,i3-2)+ cc(m332)*u(i1  ,i2  ,i3-1)
     & + cc(m313)*u(i1  ,i2-2,i3  )+ cc(m323)*u(i1  ,i2-1,i3  )+ cc(
     & m133)*u(i1-2,i2  ,i3  )+ cc(m233)*u(i1-1,i2  ,i3  )+ cc(m333)*
     & u(i1  ,i2  ,i3  )+ cc(m433)*u(i1+1,i2  ,i3  )+ cc(m533)*u(i1+2,
     & i2  ,i3  )+ cc(m343)*u(i1  ,i2+1,i3  )+ cc(m353)*u(i1  ,i2+2,
     & i3  )+ cc(m334)*u(i1  ,i2  ,i3+1)+ cc(m335)*u(i1  ,i2  ,i3+2) )
     & )/(cc(m333)+eps)
        update3dCC4a(i1,i2,i3,n, m11n,m21n,m31n,m41n,m51n, m12n,m22n,
     & m32n,m42n,m52n, m13n,m23n,m33n,m43n,m53n, m14n,m24n,m34n,m44n,
     & m54n, m15n,m25n,m35n,m45n,m55n)= cc(m11n)*u(i1-2,i2-2,i3+n)+ 
     & cc(m21n)*u(i1-1,i2-2,i3+n)+ cc(m31n)*u(i1  ,i2-2,i3+n)+ cc(
     & m41n)*u(i1+1,i2-2,i3+n)+ cc(m51n)*u(i1+2,i2-2,i3+n)+ cc(m12n)*
     & u(i1-2,i2-1,i3+n)+ cc(m22n)*u(i1-1,i2-1,i3+n)+ cc(m32n)*u(i1  ,
     & i2-1,i3+n)+ cc(m42n)*u(i1+1,i2-1,i3+n)+ cc(m52n)*u(i1+2,i2-1,
     & i3+n)+ cc(m13n)*u(i1-2,i2  ,i3+n)+ cc(m23n)*u(i1-1,i2  ,i3+n)+ 
     & cc(m33n)*u(i1  ,i2  ,i3+n)+ cc(m43n)*u(i1+1,i2  ,i3+n)+ cc(
     & m53n)*u(i1+2,i2  ,i3+n)+ cc(m14n)*u(i1-2,i2+1,i3+n)+ cc(m24n)*
     & u(i1-1,i2+1,i3+n)+ cc(m34n)*u(i1  ,i2+1,i3+n)+ cc(m44n)*u(i1+1,
     & i2+1,i3+n)+ cc(m54n)*u(i1+2,i2+1,i3+n)+ cc(m15n)*u(i1-2,i2+2,
     & i3+n)+ cc(m25n)*u(i1-1,i2+2,i3+n)+ cc(m35n)*u(i1  ,i2+2,i3+n)+ 
     & cc(m45n)*u(i1+1,i2+2,i3+n)+ cc(m55n)*u(i1+2,i2+2,i3+n)
        update3dCC4(i1,i2,i3)=u(i1,i2,i3)+ omega*(f(i1,i2,i3)-(        
     & update3dCC4a(i1,i2,i3,-2, m111,m211,m311,m411,m511, m121,m221,
     & m321,m421,m521, m131,m231,m331,m431,m531, m141,m241,m341,m441,
     & m541, m151,m251,m351,m451,m551) +update3dCC4a(i1,i2,i3,-1, 
     & m112,m212,m312,m412,m512, m122,m222,m322,m422,m522, m132,m232,
     & m332,m432,m532, m142,m242,m342,m442,m542, m152,m252,m352,m452,
     & m552) +update3dCC4a(i1,i2,i3,0, m113,m213,m313,m413,m513, m123,
     & m223,m323,m423,m523, m133,m233,m333,m433,m533, m143,m243,m343,
     & m443,m543, m153,m253,m353,m453,m553) +update3dCC4a(i1,i2,i3,1, 
     & m114,m214,m314,m414,m514, m124,m224,m324,m424,m524, m134,m234,
     & m334,m434,m534, m144,m244,m344,m444,m544, m154,m254,m354,m454,
     & m554) +update3dCC4a(i1,i2,i3,2, m115,m215,m315,m415,m515, m125,
     & m225,m325,m425,m525, m135,m235,m335,m435,m535, m145,m245,m345,
     & m445,m545, m155,m255,m355,m455,m555) ))/(cc(m333)+eps)
! #If "3" == "2"
! #If "3" == "3"
        update3dSparseVC(i1,i2,i3) = u(i1,i2,i3) + omega*(f(i1,i2,i3)-(
     &         a3m*u(i1  ,i2  ,i3-1)+ a2m*u(i1  ,i2-1,i3  )+ a1m*u(i1-
     & 1,i2  ,i3  )+ ad*u(i1  ,i2  ,i3  )+ a1p*u(i1+1,i2  ,i3  )+ a2p*
     & u(i1  ,i2+1,i3  )+ a3p*u(i1  ,i2  ,i3+1) ))/(ad)
c   *** end statement functions
        eps=1.e-30 ! *****
c$$$      ipar(0)=order
c$$$      ipar(1)=sparseStencil
c$$$      ipar(2)=useLocallyOptimalOmega
c$$$      ipar(3)=boundaryLayers ! number of layers of boundary points to smooth
c$$$      rpar(0)=omega
c$$$      rpar(1)=variableOmegaScaleFactor
        numberOfSmooths=ipar(4) ! total number of smooths per cycle -- used to determine omega
        cycleType=ipar(5)       ! cycleType: 0=F, 1=V, 2+W, ...
        if( order.ne.2 .and. order.ne.4 )then
          write(*,*) 'smoothOpt:ERROR: invalid order=',order
          stop 1
        end if
        dx2i=.5/dx(1)**2
        dy2i=.5/dx(2)**2
        dz2i=.5/dx(3)**2
        ! scale factor for the locally optimal omega
        if( order.eq.2 )then
          variableOmegaFactor=2.*variableOmegaScaleFactor*.98 ! NOTE
        else
          variableOmegaFactor=variableOmegaScaleFactor
        end if
        if( omega.lt.0. )then
          ! choose defaults
          if( order.eq.2 )then
            if( nd.eq.2 )then
              ! 030721 omega=1.1   ! 1.07
              omega=1.09 ! 1.085  ! W[2,1]
            else
              cmax=1.-1./3.
              omega=variableOmegaFactor/(1.+sqrt(1.-cmax**2))
              ! write(*,'("redBlack: 3D: omega=",f6.4)') omega
              ! omega=1.15 ! for 3d
            end if
          else ! fourth-order accurate
            if( nd.eq.2 )then
              omega=1.15   !
            else
              omega=1.20 ! what should this be ?
              ! experimentally determined for V(1,1) rbj  *wdh* 100722
              omega=1.15 ! NOTE change other value too
            end if
          end if
        end if
        ! write(*,*) 'smoothRB: omega=',omega
!  #If "3" == "2"
!  #Elif "3" == "3"
c     ****************       
c     ***** 3D *******       
c     ****************       
          if( option .eq. 0 )then
            !  **** red points *****
            i1s=1
            i2s=1
            i3s=1
            n1d=n1b
          else
            !   **** black points *****
            i1s=-1
            i2s=1
            i3s=1
            n1d=n1b-1
          end if
!    #If "4" == "2"
!    #Elif "4" == "4"
            !  ***** 4th order ****
            m111=1
            m211=2
            m311=3
            m411=4
            m511=5
            m121=6
            m221=7
            m321=8
            m421=9
            m521=10
            m131=11
            m231=12
            m331=13
            m431=14
            m531=15
            m141=16
            m241=17
            m341=18
            m441=19
            m541=20
            m151=21
            m251=22
            m351=23
            m451=24
            m551=25
            m112=26
            m212=27
            m312=28
            m412=29
            m512=30
            m122=31
            m222=32
            m322=33
            m422=34
            m522=35
            m132=36
            m232=37
            m332=38
            m432=39
            m532=40
            m142=41
            m242=42
            m342=43
            m442=44
            m542=45
            m152=46
            m252=47
            m352=48
            m452=49
            m552=50
            m113=51
            m213=52
            m313=53
            m413=54
            m513=55
            m123=56
            m223=57
            m323=58
            m423=59
            m523=60
            m133=61
            m233=62
            m333=63
            m433=64
            m533=65
            m143=66
            m243=67
            m343=68
            m443=69
            m543=70
            m153=71
            m253=72
            m353=73
            m453=74
            m553=75
            m114=76
            m214=77
            m314=78
            m414=79
            m514=80
            m124=81
            m224=82
            m324=83
            m424=84
            m524=85
            m134=86
            m234=87
            m334=88
            m434=89
            m534=90
            m144=91
            m244=92
            m344=93
            m444=94
            m544=95
            m154=96
            m254=97
            m354=98
            m454=99
            m554=100
            m115=101
            m215=102
            m315=103
            m415=104
            m515=105
            m125=106
            m225=107
            m325=108
            m425=109
            m525=110
            m135=111
            m235=112
            m335=113
            m435=114
            m535=115
            m145=116
            m245=117
            m345=118
            m445=119
            m545=120
            m155=121
            m255=122
            m355=123
            m455=124
            m555=125
            if( sparseStencil.eq.sparse )then
              !      Here we can assume that the operator is a 7-point  operator
! updateLoops3d(update3dSparse4)
              do i3=n3a,n3b,n3c
                do i2=n2a,n2b,n2c
                  do i1=n1a,n1b,n1c
                    if( mask(i1,i2,i3).gt.0 .and. i1.le.n1d )then
                      v(i1,i2,i3)=update3dSparse4(i1,i2,i3)
                    end if
                    j1=i1+i1s
                    j2=i2+i2s
                    j3=i3
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b)then
                      v(j1,j2,j3)=update3dSparse4(j1,j2,j3)
                    end if
                    j1=i1+i1s
                    j2=i2
                    j3=i3+i3s
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j3.le.n3b)then
                      v(j1,j2,j3)=update3dSparse4(j1,j2,j3)
                    end if
                    j1=i1
                    j2=i2+i2s
                    j3=i3+i3s
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b  .and. j3.le.n3b )then
                      v(j1,j2,j3)=update3dSparse4(j1,j2,j3)
                    end if
                  end do
                end do
              end do
            else if( sparseStencil.eq.sparseConstantCoefficients )then
              ! write(*,*) 'smoothOpt: sparseConstantCoefficients'
! updateLoops3d(update3dSparseCC4)
              do i3=n3a,n3b,n3c
                do i2=n2a,n2b,n2c
                  do i1=n1a,n1b,n1c
                    if( mask(i1,i2,i3).gt.0 .and. i1.le.n1d )then
                      v(i1,i2,i3)=update3dSparseCC4(i1,i2,i3)
                    end if
                    j1=i1+i1s
                    j2=i2+i2s
                    j3=i3
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b)then
                      v(j1,j2,j3)=update3dSparseCC4(j1,j2,j3)
                    end if
                    j1=i1+i1s
                    j2=i2
                    j3=i3+i3s
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j3.le.n3b)then
                      v(j1,j2,j3)=update3dSparseCC4(j1,j2,j3)
                    end if
                    j1=i1
                    j2=i2+i2s
                    j3=i3+i3s
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b  .and. j3.le.n3b )then
                      v(j1,j2,j3)=update3dSparseCC4(j1,j2,j3)
                    end if
                  end do
                end do
              end do
            else if( sparseStencil.eq.general )then
              !       general defect
              if( useLocallyOptimalOmega.ne.0 )then
! updateLoops3dVariableOmegaFourthOrder(update3d4)
                do i3=n3a,n3b,n3c
                  do i2=n2a,n2b,n2c
                    do i1=n1a,n1b,n1c
                      if( mask(i1,i2,i3).gt.0 .and. i1.le.n1d )then
! computeOmega3dFourthOrder(i1,i2,i3)
                         c1=abs(c(m233,i1,i2,i3)+c(m433,i1,i2,i3))
                         c2=abs(c(m323,i1,i2,i3)+c(m343,i1,i2,i3))
                         c3=abs(c(m332,i1,i2,i3)+c(m334,i1,i2,i3))
                         cmin=min(c1,c2,c3)/(c1+c2+c3)
                         omega=(1.23-.16*cmin)*variableOmegaFactor ! w(.5)=1.15 w(.25)=1.19 -- this is for a W[2,1] ***
                        ! write(*,'(''i1,i2,i3='',3i3,'' cmax,omega='',2(f7.4,1x))') i1,i2,i3,cmax,omega
                        v(i1,i2,i3)=update3d4(i1,i2,i3)
                      end if
                      j1=i1+i1s
                      j2=i2+i2s
                      j3=i3
                      if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b)then
! computeOmega3dFourthOrder(j1,j2,j3)
                         c1=abs(c(m233,j1,j2,j3)+c(m433,j1,j2,j3))
                         c2=abs(c(m323,j1,j2,j3)+c(m343,j1,j2,j3))
                         c3=abs(c(m332,j1,j2,j3)+c(m334,j1,j2,j3))
                         cmin=min(c1,c2,c3)/(c1+c2+c3)
                         omega=(1.23-.16*cmin)*variableOmegaFactor ! w(.5)=1.15 w(.25)=1.19 -- this is for a W[2,1] ***
                        v(j1,j2,j3)=update3d4(j1,j2,j3)
                      end if
                      j1=i1+i1s
                      j2=i2
                      j3=i3+i3s
                      if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j3.le.n3b)then
! computeOmega3dFourthOrder(j1,j2,j3)
                         c1=abs(c(m233,j1,j2,j3)+c(m433,j1,j2,j3))
                         c2=abs(c(m323,j1,j2,j3)+c(m343,j1,j2,j3))
                         c3=abs(c(m332,j1,j2,j3)+c(m334,j1,j2,j3))
                         cmin=min(c1,c2,c3)/(c1+c2+c3)
                         omega=(1.23-.16*cmin)*variableOmegaFactor ! w(.5)=1.15 w(.25)=1.19 -- this is for a W[2,1] ***
                        v(j1,j2,j3)=update3d4(j1,j2,j3)
                      end if
                      j1=i1
                      j2=i2+i2s
                      j3=i3+i3s
                      if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b  .and. j3.le.n3b )then
! computeOmega3dFourthOrder(j1,j2,j3)
                         c1=abs(c(m233,j1,j2,j3)+c(m433,j1,j2,j3))
                         c2=abs(c(m323,j1,j2,j3)+c(m343,j1,j2,j3))
                         c3=abs(c(m332,j1,j2,j3)+c(m334,j1,j2,j3))
                         cmin=min(c1,c2,c3)/(c1+c2+c3)
                         omega=(1.23-.16*cmin)*variableOmegaFactor ! w(.5)=1.15 w(.25)=1.19 -- this is for a W[2,1] ***
                        v(j1,j2,j3)=update3d4(j1,j2,j3)
                      end if
                    end do
                  end do
                end do
              else
! updateLoops3d(update3d4)
                do i3=n3a,n3b,n3c
                  do i2=n2a,n2b,n2c
                    do i1=n1a,n1b,n1c
                      if( mask(i1,i2,i3).gt.0 .and. i1.le.n1d )then
                        v(i1,i2,i3)=update3d4(i1,i2,i3)
                      end if
                      j1=i1+i1s
                      j2=i2+i2s
                      j3=i3
                      if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b)then
                        v(j1,j2,j3)=update3d4(j1,j2,j3)
                      end if
                      j1=i1+i1s
                      j2=i2
                      j3=i3+i3s
                      if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j3.le.n3b)then
                        v(j1,j2,j3)=update3d4(j1,j2,j3)
                      end if
                      j1=i1
                      j2=i2+i2s
                      j3=i3+i3s
                      if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b  .and. j3.le.n3b )then
                        v(j1,j2,j3)=update3d4(j1,j2,j3)
                      end if
                    end do
                  end do
                end do
              end if
            else if( sparseStencil.eq.constantCoefficients )then
               !   constant coeff
               !   write(*,*) 'cc=',(cc(i1),i1=1,125)
! updateLoops3d(update3dCC4)
              do i3=n3a,n3b,n3c
                do i2=n2a,n2b,n2c
                  do i1=n1a,n1b,n1c
                    if( mask(i1,i2,i3).gt.0 .and. i1.le.n1d )then
                      v(i1,i2,i3)=update3dCC4(i1,i2,i3)
                    end if
                    j1=i1+i1s
                    j2=i2+i2s
                    j3=i3
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b)then
                      v(j1,j2,j3)=update3dCC4(j1,j2,j3)
                    end if
                    j1=i1+i1s
                    j2=i2
                    j3=i3+i3s
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j3.le.n3b)then
                      v(j1,j2,j3)=update3dCC4(j1,j2,j3)
                    end if
                    j1=i1
                    j2=i2+i2s
                    j3=i3+i3s
                    if( mask(j1,j2,j3) .gt. 0 .and. j1.le.n1d .and. 
     & j2.le.n2b  .and. j3.le.n3b )then
                      v(j1,j2,j3)=update3dCC4(j1,j2,j3)
                    end if
                  end do
                end do
              end do
            else
              write(*,*) 'smoothRedBlackOpt: ERROR invalid 
     & sparseStencil'
              stop 1
            end if
        return
        end
