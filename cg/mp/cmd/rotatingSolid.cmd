#
# cgmp: rotating elastic or SVK solid 
# 
# Usage:
#    cgmp [-noplot] rotatingSolid -g=<name> -method=[ins|cns] -nu=<> -mu=<> -kappa=<num> -tf=<tFinal> -tp=<tPlot> ...
#           -solver=<yale/best> -ktcFluid=<> -ktcFluid=<> -tz=[poly/trig/none] -bg=<backGroundGrid> ...
#           -degreex=<num> -degreet=<num> -ts=[fe|be|im|pc] -nc=[] -d1=<> -d2=<> -smVariation=[nc|c|g|h] 
#           -godunovType=[0|2] -rotationRate=<>
# 
#  -godunovType : 0=linear, 2=SVK
#  -ktcFluid -ktcSolid : thermal conductivities 
#  -ts = time-stepping-method, be=backward-Euler, fe=forward-Euler, im=implicit-multistep
#  -d1, -d2 : names for domains
# 
# Examples:
# 
# ROTATING SVK disk: OK
# cgmp rotatingSolid -method=cns -cnsVariation=godunov -smVariation=g -godunovType=2 -rotationRate=1. -g=diskDeformBig2e -scf=10. -tp=.05 -tf=5 -nc=1 -d1="outerDomain" -d2="innerDomain" -fic=shock -pOffset=1. -lambdaSolid=1. -muSolid=1. -diss=1. -cnsGodunovOrder=1 -debug=1 -flushFrequency=50 -pi=0 -multiDomainAlgorithm=1  -bcOption=4 -go=halt
#
# ROTATING ELASTIC disk: OK
# cgmp rotatingSolid -method=cns -cnsVariation=godunov -smVariation=g -rotationRate=1. -g=diskDeformBig2e -scf=10. -tp=.05 -tf=2 -nc=1 -d1="outerDomain" -d2="innerDomain" -fic=shock -pOffset=1. -lambdaSolid=1. -muSolid=1. -diss=1. -cnsGodunovOrder=1 -debug=1 -flushFrequency=50 -pi=0 -multiDomainAlgorithm=1  -bcOption=4 -go=halt
# 
# --- set default values for parameters ---
# 
$grid="twoSquaresInterfacee1.order2.hdf"; $domain1="outerDomain"; $domain2="innerDomain";
$method="ins"; $probeFile="probeFile"; $multiDomainAlgorithm=0;  $pi=0; 
$tFinal=20.; $tPlot=.1;  $cfl=.9; $show="";  $pdebug=0; $debug=0; $go="halt"; 
$muFluid=0.; $rhoFluid=1.4; $pFluid=1.; $TFluid=$pFluid/$rhoFluid; 
$nu=.1; $rhoSolid=1.; $prandtl=.72; $cnsVariation="godunov";  $godunovType=0; $ktcFluid=-1.; $u0=0.; $xShock=-1.5; $uShock=1.25; 
$cnsEOS="ideal"; 
$cnsGammaStiff=1.4; $cnsPStiff=0.;   # for stiffened EOS -- by default make it look like an ideal gas
#
$lambdaSolid=1.; $muSolid=1.; $rotationRate=.5; 
$scf=1.; # solidScaleFactor : scale rho,mu and lambda by this amount 
$thermalExpansivity=1.; $T0=1.; $Twall=1.;  $kappa=.01; $ktcSolid=-1.; $diss=.1;  $smVariation = "non-conservative";
$tz="none"; $degreeSpace=1; $degreeTime=1;
$gravity = "0 0. 0."; $boundaryPressureOffset=0.; $cnsGodunovOrder=2; 
$fic = "uniform";  # fluid initial condition
$solver="best"; 
$backGround="outerSquare"; $deformingGrid="interface"; 
$ts="pc"; $numberOfCorrections=1;  # mp solver
$coupled=0; $iTol=1.e-3; $iOmega=1.; $flushFrequency=10; $useNewInterfaceTransfer=0; 
# 
$solver="best"; 
$ksp="bcgs"; $pc="bjacobi"; $subksp="preonly"; $subpc="ilu"; $iluLevels=3;
#
# ----------------------------- get command line arguments ---------------------------------------
GetOptions( "g=s"=>\$grid,"tf=f"=>\$tFinal,"nu=f"=>\$nu,"muFluid=f"=>\$muFluid,"kappa=f"=>\$kappa, "bg=s"=>\$backGround,\
 "tp=f"=>\$tPlot, "solver=s"=>\$solver, "tz=s"=>\$tz,"degreex=i"=>\$degreex, "degreet=i"=>\$degreet,\
 "show=s"=>\$show,"method=s"=>\$method,"ts=s"=>\$ts,"noplot=s"=>\$noplot,"ktcFluid=f"=>\$ktcFluid,\
  "ktcSolid=f"=>\$ktcSolid,"muSolid=f"=>\$muSolid,"lambdaSolid=f"=>\$lambdaSolid, "T0=f"=>\$T0,"Twall=f"=>\$Twall,\
  "nc=i"=> \$numberOfCorrections,"coupled=i"=>\$coupled,"rhoFluid=f"=>\$rhoFluid,"pFluid=f"=>\$pFluid,\
  "d1=s"=>\$domain1,"d2=s"=>\$domain2,"dg=s"=>\$deformingGrid,"debug=i"=>\$debug,"kThermalFluid=f"=>\$kThermalFluid,\
  "cfl=f"=>\$cfl,"rhoSolid=f"=>\$rhoSolid,"cnsVariation=s"=>\$cnsVariation,"diss=f"=>\$diss,"fic=s"=>\$fic,"go=s"=>\$go,\
   "smVariation=s"=>\$smVariation,"scf=f"=>\$scf,"probeFile=s"=>\$probeFile,"pOffset=f"=>\$boundaryPressureOffset,\
   "cnsGodunovOrder=f"=>\$cnsGodunovOrder,"flushFrequency=i"=>\$flushFrequency,"godunovType=i"=>\$godunovType,\
   "cnsEOS=s"=>\$cnsEOS,"cnsGammaStiff=f"=>\$cnsGammaStiff,"cnsPStiff=f"=>\$cnsPStiff,\
   "useNewInterfaceTransfer=i"=>\$useNewInterfaceTransfer,"multiDomainAlgorithm=i"=>\$multiDomainAlgorithm,\
   "pi=i"=>\$pi,"xShock=f"=>\$xShock,"rotationRate=f"=>\$rotationRate );
# -------------------------------------------------------------------------------------------------
if( $solver eq "best" ){ $solver="choose best iterative solver"; }
if( $ts eq "fe" ){ $ts="forward Euler"; }
if( $ts eq "be" ){ $ts="backward Euler"; }
if( $ts eq "im" ){ $ts="implicit"; }
if( $ts eq "pc" ){ $ts="adams PC"; }
if( $tz eq "none" ){ $tz="turn off twilight zone"; }
if( $tz eq "poly" ){ $tz="turn on twilight zone\n turn on polynomial"; $cdv=0.; }
if( $tz eq "trig" ){ $tz="turn on twilight zone\n turn on trigonometric"; $cdv=0.; }
if( $go eq "halt" ){ $go = "break"; }
if( $go eq "og" ){ $go = "open graphics"; }
if( $go eq "run" || $go eq "go" ){ $go = "movie mode\n finish"; }
#
# 
if( $smVariation eq "nc" ){ $smVariation = "non-conservative"; }
if( $smVariation eq "c" ){ $smVariation = "conservative"; $cons=1; }
if( $smVariation eq "g" ){ $smVariation = "godunov"; }
if( $smVariation eq "h" ){ $smVariation = "hemp"; }
#
if( $method eq "ins" && $kThermalFluid eq "" ){ $kThermalFluid=$nu/$prandtl; }
if( $method eq "cns" && $kThermalFluid eq "" ){ $kThermalFluid=$muFluid/$prandtl; }
if( $ktcFluid < 0. ){ $ktcFluid=$kThermalFluid;} if( $ktcSolid < 0. ){ $ktcSolid=$kappa; }
# 
$grid
# ----------  define deforming bodies by a share flag of 100 ----
# ----------  NOTE: we parameterize the boundary by index so grid points match! ---
$moveCmds = \
  "turn on moving grids\n" . \
  "specify grids to move\n" . \
  "    deforming body\n" . \
  "      user defined deforming body\n" . \
  "        interface deform\n" . \
  "        boundary parameterization\n  1  \n" . \
  "        debug\n $debug \n" . \
  "      done\n" . \
  "      choose grids by share flag\n" . \
  "         100 \n" . \
  "   done\n" . \
  "done";
# 
#$probeFileName = $probeFile . "Fluid.dat";
#$extraCmds = \
#    "frequency to save probes 1\n" . \
#    "create a probe\n" . \
#    "  file name $probeFileName\n" . \
#    "  nearest grid point to 0. .5 0.\n" . \
#    "  exit";
# ------- specify fluid domain ----------
$domainName=$domain1; $solverName="fluid"; 
$ic = "uniform flow\n p=1., u=$u0";
$bc = "all=noSlipWall";
$bc = "all=noSlipWall\n bcNumber100=noSlipWall\n bcNumber100=tractionInterface";
$ktc=$ktcFluid; $rtolp=1.e-4; $atolp=1.e-6; 
if( $method eq "ins" ){ $cmd = "include insDomain.h"; }else{ $cmd ="*"; };
$cmd
#
#  Cgcns:
# $bc = "all=slipWall\n $backGround=superSonicOutflow\n $backGround(0,0)=superSonicInflow uniform(r=1.,u=0.,T=1.)\n bcNumber100=slipWall\n bcNumber100=tractionInterface";
$bc = "all=slipWall\n $backGround=superSonicOutflow\n bcNumber100=slipWall\n bcNumber100=tractionInterface";
# ---- shock: use T instead of e for non-ideal EOS
# $ic="OBIC:step: a*x+b*y+c*z=d 1, 0, 0, $xShock, (a,b,c,d)\n OBIC:state behind r=2.6667 u=1.25 e=10.119\n OBIC:state ahead r=1. e=1.786\n OBIC:assign step function\n"; 
# $ic="OBIC:step: a*x+b*y+c*z=d 1, 0, 0, $xShock, (a,b,c,d)\n OBIC:state behind r=2.6667 u=$uShock T=1.205331\n OBIC:state ahead r=1. T=.7144\n OBIC:assign step function\n"; 
# $ic="OBIC:uniform state r=1., u=0, v=0, T=1.\n";
# $ic="uniform flow\n  r=1. u=0. T=1.\n";
$Tfluid=$pFluid/$rhoFluid;
$ic="uniform flow\n  r=$rhoFluid u=0. T=$Tfluid\n";
# ----
# $ic="pause"; 
# ----
if( $method eq "cns" ){ $mu=$muFluid; $kThermal=$muFluid/$prandtl; $cmd = "include $ENV{CG}/mp/cmd/cnsDomain.h"; }else{ $cmd ="*"; };
$cmd
# 
# ------- specify elastic solid domain ----------
$domainName=$domain2; $solverName="solid"; 
$bcCommands="all=displacementBC\n bcNumber100=tractionBC\n bcNumber100=tractionInterface"; 
$bcCommands="all=displacementBC\n bcNumber2=slipWall\n bcNumber100=tractionBC\n bcNumber100=tractionInterface"; 
$exponent=10.; $x0=.5; $y0=.5; $z0=.5;  $rhoSolid=$rhoSolid*$scf; $lambda=$lambdaSolid*$scf; $mu=$muSolid*$scf; 
# $initialConditionCommands="gaussianPulseInitialCondition\n Gaussian pulse: 10 2 $exponent $x0 $y0 $z0 (beta,scale,exponent,x0,y0,z0)";
# $initialConditionCommands="zeroInitialCondition";
$initialConditionCommands="initial conditions options...\n OBIC:user defined...\n rotation\n 0. 0. $rotationRate\n exit";
if( $smVariation eq "hemp" ){ $initialConditionCommands="hempInitialCondition\n OBIC:Hemp initial condition option: default\n"; }
#
$initialConditionCommands="pause"; 
#
if( $smVariation eq "hemp" ){ $tsSM= "improvedEuler"; }
# $probeFileName = $probeFile . "Solid.dat";
# $extraCmds = \
#     "frequency to save probes 1\n" . \
#     "create a probe\n" . \
#     "  file name $probeFileName\n" . \
#     "  nearest grid point to 0. .5 0.\n" . \
#     "  exit";
# 
include $ENV{CG}/mp/cmd/smDomain.h
# 
continue
#
# -- set parameters for cgmp ---
# 
  final time $tFinal
  times to plot $tPlot
  cfl $cfl
  dtMax .1
  $ts
  number of PC corrections $numberOfCorrections
  OBPDE:interface tolerance $iTol
  OBPDE:interface omega $iOmega
  OBPDE:solve coupled interface equations $coupled
  OBPDE:use new interface transfer $useNewInterfaceTransfer
 # -- for testing solve the domains in reverse order: 
  OBPDE:domain order 1 0
  OBPDE:project interface $pi
  if( $multiDomainAlgorithm eq 1 ){ $cmd="OBPDE:step all then match advance"; }else{ $cmd="#"; }
  $cmd 
  $tz
  debug $debug
  show file options
    compressed
      open
       $show
    frequency to flush
      $flushFrequency
    exit
  continue
#
continue
# --
        erase
        plot domain: fluid
        contour
 # ghost lines 1
          plot:p
          wire frame
          exit
        plot domain: solid
        displacement
          displacement scale factor 1
 # displacement scale factor 10
          exit this menu
        plot all
$go


   erase
   plot domain: fluid
   grid
     exit this menu
   plot domain: solid
   displacement
     exit this menu
   plot all




          OBIC:user defined...
            bubble with shock
            r=1 T=1 u=0 v=0
            .2 .5 0.
            r=2. T=2. 
            -5.
            r=2 T=2
            exit


