#
# A dropping cylinder -- compare to the results frm Glowinski, Pan, et.al.dropping cylinders
# Usage:
#    cgins [-noplot] cylDrop -g=<name> -tp=<f> -tp=<f> -density=<f> -ts=[pc|im|...]  ...
#          -bcOption=[walls|inflowOutflow|pressure|rampedPressure|rampedInflow] ...
#        -sep=<f> -vIn=<f> -forceLimit=<f> -rampGravity=[0|1] -go[halt|go|og]
#  
#  -sep : separation distance for collisions
#
# -bcOption : walls : noSlipWall's all around
#             inflowOutflow : inflow on bottom, outflow on top
#             pressure : time dependent pressure on bottom
#
# Example: 
#  cgins cylDrop -g=cylDropGride2.order2.s3.hdf -tf=1. -tp=.05 -nu=.1 -density=1.25 -dtMax=.75e-3 -go=halt 
# 
#
$model="ins"; $solver = "best"; $show=" "; $ts="pc"; $noplot=""; $move=1; 
$density=1.25; 
$inertia="-1"; # set this to over-ride computed inertia, -1=auto-compute 
$nu = .1; $dtMax=.05; $newts=0; $movingWall=0; 
# for nu=.005 the terminal velocity of one drop is about .9 -- for low Re the velocity is prop. to Re
$inflowVelocity=.9;
$d=.2; # parabolic inflow distance 
$tFinal=10.; $tPlot=.1; $cfl=.9; $debug=0; $go="halt"; $project=0; $refactorFrequency=100;  
$recomputeDt=2; # 10 
$sep=3.; $forceLimit=30.; $cdv=1.; $flush=5; $ad21=2.; $ad22=2.; 
$restart=""; 
#
$radius=.125; $dropName="drop"; $channelName="channel"; 
$gravity = "-981.";   # cm/s^2   -9.81 acceleration due to gravity standard value: 9.80665 m/s^2.
$rampGravity=0; 
#
$numberOfCorrections=1; 
$addedMass=0; $useTP=0;  $useProvidedAcceleration=1; 
$addedDamping=0;  $addedDampingCoeff=1.; $scaleAddedDampingWithDt=0; $addedDampingProjectVelocity=0; 
$omega=.5; $rtolc=1.e-4; $atolc=1.e-7; 
# 
$freqFullUpdate=10; # frequency for using full ogen update in moving grids 
$cdv=1.; $ad2=1; $ad21=1; $ad22=1;  $ad4=0; $ad41=2.; $ad42=2.; 
$psolver="best"; $solver="best"; 
$iluLevels=1; $ogesDebug=0; 
$rtolp=1.e-3; $atolp=1.e-4;  # tolerances for the pressure solve
$rtol=1.e-4; $atol=1.e-5;    # tolerances for the implicit solver
# -- for Kyle's AF scheme:
$afit = 20;  # max iterations for AFS
$aftol=1e-2;
$filter=0; $filterFrequency=1; $filterOrder=6; $filterStages=2; 
$vIn=.0;
$bcOption="walls"; 
$inflowPressure=.1; # inflow pressure for $bcOption eq "rampedPressure"
$cp0=.1; $cpn=1.; # coefficients in pressure outflow BC
$option=""; 
$flushFrequency=10; 
#
$ampSinusoidalPressure=1.; $freqSinusoidalPressure=1.; # for sinusoidal pressure option
#
# ----------------------------- get command line arguments ---------------------------------------
GetOptions( "g=s"=>\$grid,"tf=f"=>\$tFinal,"model=s"=>\$model,"inflowVelocity=f"=>\$inflowVelocity,"move=i"=>\$move,\
 "tp=f"=>\$tPlot,"solver=s"=>\$solver,"psolver=s"=>\$psolver,"show=s"=>\$show,"debug=i"=>\$debug,"d=f"=>\$d, \
 "ts=s"=>\$ts,"nu=f"=>\$nu,"cfl=f"=>\$cfl,"go=s"=>\$go,"numDrops=i"=> \$numDrops,"newts=i"=> \$newts,\
 "noplot=s"=>\$noplot,"project=i"=>\$project,"rf=i"=> \$refactorFrequency,"bcOption=s"=>\$bcOption,\
 "dtMax=f"=>\$dtMax,"freqFullUpdate=i"=>\$freqFullUpdate,"density=f"=>\$density,"movingWall=i"=>\$movingWall,\
 "rtol=f"=>\$rtol,"atol=f"=>\$atol,"rtolp=f"=>\$rtolp,"atolp=f"=>\$atolp,"restart=s"=>\$restart,\
 "forceLimit=f"=>\$forceLimit,"sep=f"=>\$sep,"flush=i"=>\$flush,"gravity=f"=>\$gravity,"vIn=f"=>\$vIn,\
 "ad2=i"=>\$ad2,"ad21=f"=>\$ad21,"ad22=f"=>\$ad22,"ad4=i"=>\$ad4,"ad41=f"=>\$ad41,"ad42=f"=>\$ad42,\
 "freqFullUpdate=i"=>\$freqFullUpdate,"radius=f"=>\$radius,"dropName=s"=>\$dropName,"channelName=s"=>\$channelName,\
 "numberOfCorrections=i"=>\$numberOfCorrections,"omega=f"=>\$omega,"addedMass=f"=>\$addedMass,"useTP=i"=>\$useTP,\
 "rtolc=f"=>\$rtolc,"atolc=f"=>\$atolc,"option=s"=>\$option,"useProvidedAcceleration=i"=>\$useProvidedAcceleration,\
 "inertia=f"=>\$inertia,"ampSinusoidalPressure=f"=>\$ampSinusoidalPressure,"inflowPressure=f"=>\$inflowPressure,\
 "freqSinusoidalPressure=f"=>\$freqSinusoidalPressure, "flushFrequency=f"=>\$flushFrequency,\
 "addedDamping=f"=>\$addedDamping,"addedDampingCoeff=f"=>\$addedDampingCoeff,"rampGravity=i"=>\$rampGravity,\
 "scaleAddedDampingWithDt=f"=>\$scaleAddedDampingWithDt,"addedDampingProjectVelocity=f"=>\$addedDampingProjectVelocity,\
 "cp0=f"=>\$cp0,"cpn=f"=>\$cpn  );
# -------------------------------------------------------------------------------------------------
if( $solver eq "best" ){ $solver="choose best iterative solver"; }
if( $solver eq "mg" ){ $solver="multigrid"; }
if( $psolver eq "best" ){ $psolver="choose best iterative solver"; }
if( $psolver eq "mg" ){ $psolver="multigrid"; }
if( $model eq "ins" ){ $model = "incompressible Navier Stokes"; }else\
                     { $model = "incompressible Navier Stokes\n Boussinesq model"; }
# 
if( $ts eq "fe" ){ $ts="forward Euler";  }
if( $ts eq "be" ){ $ts="backward Euler"; }
if( $ts eq "im" ){ $ts="implicit";       }
if( $ts eq "pc" ){ $ts="adams PC";       }
if( $ts eq "mid"){ $ts="midpoint";       }  
if( $ts eq "pc4" ){ $ts="adams PC order 4"; $useNewImp=0; } # NOTE: turn off new implicit for fourth order
if( $ts eq "afs"){ $ts="approximate factorization"; $newts=1;  $useNewImp=0;}
if( $implicitVariation eq "viscous" ){ $implicitVariation = "implicitViscous"; }\
elsif( $implicitVariation eq "adv" ){ $implicitVariation = "implicitAdvectionAndViscous"; }\
elsif( $implicitVariation eq "full" ){ $implicitVariation = "implicitFullLinearized"; }\
else{ $implicitVariation = "implicitFullLinearized"; }
if( $project eq "1" ){ $project = "project initial conditions"; }else{ $project = "do not project initial conditions"; }
if( $newts eq "1" ){ $newts = "use new advanceSteps versions"; }else{ $newts = "#"; }
if( $go eq "halt" ){ $go = "break"; }
if( $go eq "og" ){ $go = "open graphics"; }
if( $go eq "run" || $go eq "go" ){ $go = "movie mode\n finish"; }
#
#
$grid
#
  incompressible Navier Stokes
  exit
#
  show file options
    open
     $show
    frequency to flush
      $flushFrequency
  exit  
  turn off twilight zone
#************************************
  final time $tFinal
  times to plot $tPlot
  cfl $cfl
  dtMax $dtMax 
#
  recompute dt every $recomputeDt
#
  plot and always wait
#
#************************************
  $ts
  $newts
  ## first order predictor
  # -- for the AFS scheme:
  compact finite difference
  # -- convergence parameters for the af scheme
  max number of AF corrections $afit
  AF correction relative tol $aftol
  # optionally turn this on to improve stability of the high-order AF scheme by using 2nd-order dissipation at the boundary
  OBPDE:use boundary dissipation in AF scheme 1
# 
  number of PC corrections $numberOfCorrections
  # -- for added mass algorithm:
  use added mass algorithm $addedMass
  # for now we let the solver know that the added mass algorithm needed predicted values for the pressure:
  predicted pressure needed $addedMass
  # for added damping algorithm: 
  added damping coefficient: $addedDampingCoeff
  use added damping algorithm $addedDamping
  scale added damping with dt $scaleAddedDampingWithDt
  added damping project velocity $addedDampingProjectVelocity
  # -- CHECK ME: 
  use moving grid sub-iterations $useTP
  # TEMP FIX: 
  # Use a single vector implicit system for the velocity components even if multiple scalar systems may be used: 
  if( $bcOption eq "sinusoidalPressure" ){ $cmd = "use vector implicit system 1"; }else{ $cmd="#"; }
  $cmd
# 
  # useNewImplicitMethod 
  choose grids for implicit
     all=implicit
     ## *** TURN OFF for TESTING
     ## channel=explicit
    done
# 
  frequency for full grid gen update $freqFullUpdate
# 
  pde parameters
   nu  $nu
   #   -- specify the fluid density
   fluid density
     1. 
   #  turn on gravity
   $gravityVector="0. $gravity 0.";
   if( $option eq "horizontalDrop" ){ $gravityVector="$gravity 0. 0."; }
   gravity
     $gravityVector
     # 0. $gravity 0.
   # optionally ramp gravity 
   $taGravity=0; $tbGravity=1.; 
   $rampOrder=3; 
   if( $rampGravity eq 1 ){ $cmd ="OBPDE:set gravity time dependence\n ramp end values: 0,1 (start,end)\n ramp times: $taGravity,$tbGravity (start,end)\n ramp order: $rampOrder\n ramp function\n   exit"; }else{ $cmd="#"; }
   $cmd
   #  turn on 2nd-order AD here:
   OBPDE:second-order artificial diffusion $ad2
   OBPDE:ad21,ad22 $ad21, $ad22
   OBPDE:fourth-order artificial diffusion $ad4
   OBPDE:ad41,ad42 $ad41, $ad42
   OBPDE:divergence damping  $cdv
   # OBPDE:check for inflow at outflow
   # OBPDE:expect inflow at outflow
   # Nov. 5, 2016:  *wdh*
   $outflowOption="neumann";
   if( $outflowOption eq "neumann" ){ $cmd = "use Neumann BC at outflow"; }else{ $cmd="use extrapolate BC at outflow"; }
   $cmd
#
  done
#*************************************
  if( $move eq 1 ){ $cmd="turn on moving grids"; } else{ $cmd="#"; }
  $cmd
#*************************
  detect collisions 1
  minimum separation for collisions $sep
#************************
  specify grids to move
   # Moving grids debug:
   debug: $debug
   #
   #      improve quality of interpolation
   ## print moving body info 1
   # limit forces
   #  $forceLimit $forceLimit
   #
 #
   rigid body
     # mass
     #   .25
     density
       $density
     #
     $pi=4.*atan2(1.,1.);
     $volume=$pi*$radius**2; $mass=$density*$volume;
     $momentOfInertia=.5*$mass*$radius**2;
     if( $inertia eq "" ){ $inertia=$momentOfInertia; }
     # inertia=-1 : means auto compute inertia
     if( $inertia eq "-1" ){ $cmd="#"; }else{ $cmd="moments of inertia\n $inertia"; }
     $cmd
# 
    # relaxation is used for light bodies to stabilize the time stepping
    relax correction steps $useTP
    # -- indicate if we are using the direct projection AMP scheme ---
    direct projection added mass $addedMass
    use provided acceleration $useProvidedAcceleration
    # tolerences for TP-SI 
    force relaxation parameter: $omega
    force relative tol: $rtolc
    force absolute tol: $atolc
    $beta=$omega; 
    torque relaxation parameter: $beta
    torque relative tol: $rtolc
    torque absolute tol: $atolc
   done
    $dropName
  done
   # pause
   #
  done
#
  boundary conditions
    all=noSlipWall
    $cmd="#";
    if( $bcOption eq "inflowOutflow" ){ $cmd="$channelName(0,1)=inflowWithVelocityGiven,  parabolic(d=$d,p=1,v=$vIn)\n $channelName(1,1)=outflow , pressure(1.*p+0.*p.n=0.)"; }
    if( $option eq "horizontalDrop" ){ $cmd="$channelName(0,0)=inflowWithVelocityGiven,  parabolic(d=$d,p=1,u=$vIn)\n $channelName(1,0)=outflow , pressure(1.*p+0.*p.n=0.)"; }
    #
    # Sinusoidal pressure option:
    #   f(t)=b0*sin(2.*Pi*f0*(t-t0));
    if( $bcOption eq "sinusoidalPressure" ){ \
      $cmd="$channelName=slipWall\n" . \
           "$channelName(1,1)=outflow , pressure(1.*p+0.*p.n=0.)\n" . \
           "$channelName(0,1)=inflowWithPressureAndTangentialVelocityGiven, uniform(u=0.,v=0.,p=1)\n" . \
           "$channelName(0,1)=inflowWithPressureAndTangentialVelocityGiven, userDefinedBoundaryData\n" . \
           "  time function option\n" . \
           "    sinusoid parameters: $ampSinusoidalPressure, $freqSinusoidalPressure, 0 (b0,f0,t0)\n" . \
           "    sinusoidal function\n" . \
           "  exit\n" . \
           "done\n" };
    #
    # inflow with Pressure given   
    #    Inflow pressure : $inflowPressure
    #    Outflow pressure = 0
    if( $bcOption eq "inflowGivenPressure" ){ \
      $cmd="bcNumber4=inflowWithPressureAndTangentialVelocityGiven, uniform(u=0.,v=0.,p=$inflowPressure)\n";}
    #
    #
    # Ramped pressure   
    #    Inflow pressure : $inflowPressure
    #    Outflow pressure = 0
    if( $bcOption eq "rampedPressure" ){ \
      $cmd="all=noSlipWall\n" . \
           "bcNumber3=outflow , pressure($cp0*p+$cpn*p.n=0.)\n" . \
           "bcNumber4=inflowWithPressureAndTangentialVelocityGiven, uniform(u=0.,v=0.,p=1)\n" . \
           "bcNumber4=inflowWithPressureAndTangentialVelocityGiven, userDefinedBoundaryData\n" . \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,$inflowPressure (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n" };
    #
    # ramped pressure assuming three grids on inflow
    #
    # NOTE: set BC=inflowWithPressureAndTangentialVelocityGiven twice, first to give p value
    if( $bcOption eq "rampedPressureThreeSide" ){ \
      $cmd="bcNumber3=outflow , pressure(1.*p+0.*p.n=0.)\n" . \
           "bcNumber4=inflowWithPressureAndTangentialVelocityGiven, uniform(u=0.,v=0.,p=1)\n" . \
           "bcNumber4=inflowWithPressureAndTangentialVelocityGiven, userDefinedBoundaryData\n" . \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,$inflowPressure (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n" . \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,$inflowPressure (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n" .  \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,$inflowPressure (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n"; };
    #
    #
    # ramped velocity:
    #
    if( $bcOption eq "rampedVelocity" ){ \
      $cmd="bcNumber3=outflow , pressure(1.*p+0.*p.n=0.)\n" . \
           "bcNumber4=inflowWithVelocityGiven, parabolic(d=$d,p=1,v=$inflowVelocity), userDefinedBoundaryData\n" . \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,1 (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n"; };
    #
    if( $bcOption eq "rampedVelocityThreeSide" ){ \
      $cmd="bcNumber3=outflow , pressure(1.*p+0.*p.n=0.)\n" . \
           "bcNumber4=inflowWithVelocityGiven, parabolic(d=$d,p=1,v=$inflowVelocity), userDefinedBoundaryData\n" . \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,1 (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n" . \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,1 (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n" .  \
           "time function option\n" . \
           " ramp function\n" . \
           "   ramp end values: 0,1 (start,end)\n". \
           "   ramp times: $taGravity,$tbGravity (start,end)\n" .\
           "   ramp order: 3\n" . \
           "  exit\n" . \
           "done\n"; };
    #
    $cmd 
    #
    # $channel(0,1)=inflowWithVelocityGiven,  parabolic(d=$d,p=1,v=$vIn)
    # $channel(0,1)=inflowWithVelocityGiven,  uniform(u=0.,v=$vIn)
    # $channel(1,1)=outflow , pressure(1.*p+0.*p.n=0.)
   done
#
  maximum number of iterations for implicit interpolation
     10 
#***************************************************
#
echo to terminal 1 
  pressure solver options
   # $ogesDebug=$debug; 
   # define petscOption -mat_view ::asci_info
   #
   $ogesSolver=$psolver; $ogesRtol=$rtolp; $ogesAtol=$atolp; $ogesIluLevels=$iluLevels;  $ogesDtol=1e20; 
   include $ENV{CG}/ins/cmd/ogesOptions.h
  exit
#
  implicit time step solver options
   $ogesSolver=$solver; $ogesRtol=$rtol; $ogesAtol=$atol; 
   include $ENV{CG}/ins/cmd/ogesOptions.h
  exit
echo to terminal 1
#
#***************************************************
#
$project
# 
 initial conditions
   uniform flow
    p=0., u=0., v=$vIn
 exit
#  initial conditions
#     read from a show file
#      twoDropNew2.show
#       24 48  -1 35 -1 1 4 -1 10 18  -1
#  exit
#
  debug
    $debug
  continue
#
    plot:v
#
#
  $go



