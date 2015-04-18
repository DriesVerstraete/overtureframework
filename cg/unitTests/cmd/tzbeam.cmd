#
# cmd file for tbm : test beam models
#         tbm -cmd=tzbeam.cmd -bc=[p|c|per|cf] -tz=[poly|trig|sw|twfsi] -standingFSI=[0|1]
#
#  -tz=sw : standing wave
#  -tz=twfsi : traveling wave FSI-INS
#  -standingFSI =1 : use standing traveling wave FSI-INS solution
# 
$nElem=11; $tf=.5; $tp=.05; $cfl=.5; $Em=1.; $tension=0.; $K0=0.; $Kt=0.;  $Kxxt=0.; 
$degreex=2; $degreet=2; $bc="c"; $tz="poly"; $useNewTri=1;
$fx=2.; $ft=2; $debug=0; $orderOfProjection=2; 
$rhos=100.; $hs=.1; $mu=.001; $standingFSI=0; 
$go="halt";
GetOptions( "nElem=i"=>\$nElem,"cfl=f"=>\$cfl,"Em=f"=>\$Em,"tension=f"=>\$tension,"degreet=i"=>\$degreet,\
            "degreex=i"=>\$degreex, "bc=s"=>\$bc, "tz=s"=>\$tz, "useNewTri=i"=>\$useNewTri,"standingFSI=i"=>\$standingFSI,\
            "tf=f"=>\$tf,"tp=f"=>\$tp,"fx=f"=>\$fx,"ft=f"=>\$ft,"rhos=f"=>\$rhos,"hs=f"=>\$hs,"debug=i"=>\$debug,\
            "K0=f"=>\$K0,"Kt=f"=>\$Kt,"Kxxt=f"=>\$Kxxt,"orderOfProjection=i"=>\$orderOfProjection,"go=s"=>\$go );
# 
if( $go eq "halt" ){ $go = "#"; }
if( $go eq "og" ){ $go = "open graphics"; }
if( $go eq "run" || $go eq "go" ){ $go = "movie mode\n exit\n exit"; }
#
linear beam model
# 
tFinal: $tf
tPlot: $tp
cfl: $cfl
# 
change beam parameters
#
#
if( $bc eq "p" ){ $cmd = "bc left:pinned\n bc right:pinned"; }
if( $bc eq "c" ){ $cmd = "bc left:clamped\n bc right:clamped"; }
if( $bc eq "f" ){ $cmd = "bc left:free\n bc right:free"; }
if( $bc eq "cf" ){ $cmd = "bc left:clamped\n bc right:free"; }
if( $bc eq "per" ){ $cmd = "bc left:periodic\n bc right:periodic"; }
$cmd
#
name: beam
number of elements: $nElem
# momOfIntertia=1., E=1., rho=100., beamLength=1., thickness=.1, pnorm=10.,  x0=0., y0=0.;
area moment of inertia: 1.
elastic modulus: $Em
tension: $tension
K0: $K0
Kt: $Kt
Kxxt: $Kxxt
density: $rhos
thickness: $hs
length: 1
debug: $debug 
#
use new tridiagonal solver $useNewTri
#
order of Galerkin projection: $orderOfProjection
#
degree in space: $degreex
degree in time: $degreet
trig frequencies: $ft, $fx, $fx, $fx (ft,fx,fy,fz)
#
if( $tz eq "poly" || $tz eq "trig" ){ $tzToggle=1; }else{ $tzToggle=0; }
twilight-zone $tzToggle
if( $tz eq "poly" ){ $cmd="Twilight-zone: polynomial"; }elsif( $tz eq "trig" ){ $cmd="Twilight-zone: trigonometric"; }else{ $cmd="#"; }
$cmd
# 
# Exact solution:
exact solution...
  $rhosHs=$rhos*$hs;
  $Ts=$tension; # *$hs; 
  $cmd="#"; 
  if( $tzToggle eq 1 ){ $cmd="Exact solution:twilight zone"; }
  if( $tz eq "twfsi" ){ $cmd="Exact solution:traveling wave FSI"; }
  if( $tz eq "sw" ){ $cmd="Exact solution:standing wave\n  amplitude: 0.1\n wave number: 1"; }
  if( $tz eq "twfsi" ){ $cmd="Exact solution:traveling wave FSI-INS\n  height: 1\n  length: 1\n kx: 1\n  amp, x0, t0: 0.1, 0, 0\n elastic shell density: $rhosHs\n  elastic shell tension: $Ts\n fluid density: 1\n fluid viscosity: $mu\n normal motion only 1\n standing wave solution $standingFSI\n# pause\n exit"; }
  $cmd
exit
#
initial conditions...
  if( $tz eq "poly" || $tz eq "trig" || $tz eq "sw" || $tz eq "twfsi" ){ $cmd="Initial conditions:exact solution"; }else{  $cmd="#"; }
  $cmd 
#
  exit
#
exit
solve
$go


   exit