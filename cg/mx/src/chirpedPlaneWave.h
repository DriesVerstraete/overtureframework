! -*- mode: f90; -*-


! ==============================================================================================
! ======================  Macros for the chirped plane wave  ===================================
! ==============================================================================================

! ----------------------------------------------------------------------------------
! Macro: Utility function used in computing zero or more derivatives of the chirp 
! ---------------------------------------------------------------------------------
!- #beginMacro getChirp( chirp )
!-  ! phi = phase
!-  phi = cc*xi + cpwAlpha*xi**2
!- 
!-  ! amplitude: approx. equal to 1 over the interval [ta,tb]
!-  tanha = tanh(cpwBeta*(t-cpwTa)) 
!-  tanhb = tanh(cpwBeta*(t-cpwTb)) 
!-  amp = cpwAmp*.5*( tanha - tanhb )
!- 
!-  if( numberOfTimeDerivatives.eq.0 )then
!- 
!-    ! -- chirp function --
!-    chirp = amp*sin(twoPi*phi)
!- 
!-  else if(  numberOfTimeDerivatives.eq.1 )then
!-    ! get 1st time derivative  *check me*
!- 
!-    ! d(phi)/dt:  (plus a factor of twoPi)
!-    phip = twoPi*(cc+2.*cpwAlpha*xi) 
!-    ! d(amp)/dt: 
!-    tanhap = cpwBeta*(1.-tanha**2) 
!-    tanhbp = cpwBeta*(1.-tanhb**2) 
!-    ampp =  cpwAmp*.5*( tanhap - tanhbp )
!- 
!-    ! -- d(chirp)/dt --
!-    chirp = amp*phip*cos(twoPi*phi) + ampp*sin(twoPi*phi)
!- 
!-  else if(  numberOfTimeDerivatives.eq.2 )then
!-    ! get 2nd time derivative  *check me*
!- 
!-    ! d(phi)/dt: 
!-    phip = twoPi*(cc+2.*cpwAlpha*xi) 
!-    ! d^2(phi)/dt^2 : 
!-    phipp = twoPi*(2.*cpwAlpha) 
!- 
!-    ! d(amp)/dt: 
!-    tanhap = cpwBeta*(1.-tanha**2) 
!-    tanhbp = cpwBeta*(1.-tanhb**2) 
!-    ampp =  cpwAmp*.5*( tanhap - tanhbp )
!-   
!-    ! d^2(amp)/dt^2: 
!-    tanhapp = -2.*(cpwBeta**2)*tanha*tanhap
!-    tanhbpp = -2.*(cpwBeta**2)*tanhb*tanhbp
!-    amppp =  cpwAmp*.5*( tanhapp - tanhbpp )
!- 
!-    sinp=sin(twoPi*phi)
!-    cosp=cos(twoPi*phi)
!- 
!-    ! -- d^2(chirp)/dt^2 --
!-    chirp = amp*( -(phip**2)*sinp + phipp*cosp ) \
!-          + 2.*ampp*phip*cosp + amppp*sinp
!- 
!-  else
!-    write(*,'(" getChirp:ERROR: too many derivatives requested")')
!-    stop 4927
!-  end if
!- #endMacro 

! --------------------------------------------------------------------
! Evaluate the chirped plane wave in 2D
! 
!  x,y,t (input) : point to evaluate at 
!  numberOfTimeDerivatives : evaluate this time derivative
!  ubc(.)  (output) : ubc(ex), etc. 
! --------------------------------------------------------------------
#beginMacro getChirpedPlaneWave2D(x,y,t,numberOfTimeDerivatives,ubv)

 xi0 = .5*(cpwTa+cpwTb)
 xi = t - (kx*(x-cpwX0)+ky*(y-cpwY0))/cc -xi0
 cpwTau=cpwTb-cpwTa  ! tau = tb -ta

 ! include files generated by the maple code mx/codes/chirpedPlaneWave.maple 
 if( numberOfTimeDerivatives.eq.0 )then
   #Include "../codes/chirpedPlaneWave2D0T.h"
 else if(  numberOfTimeDerivatives.eq.1 )then
   #Include "../codes/chirpedPlaneWave2D1T.h"
 else if(  numberOfTimeDerivatives.eq.2 )then
   #Include "../codes/chirpedPlaneWave2D2T.h"
 else if(  numberOfTimeDerivatives.eq.3 )then
   #Include "../codes/chirpedPlaneWave2D3T.h"
 else if(  numberOfTimeDerivatives.eq.4 )then
   #Include "../codes/chirpedPlaneWave2D4T.h"

 else
   write(*,'(" getChirp2D:ERROR: too many derivatives requested")')
   stop 4927
 end if

 ubv(ex) = chirp*pwc(0)
 ubv(ey) = chirp*pwc(1)
 ubv(hz) = chirp*pwc(5)

#endMacro

! --------------------------------------------------------------------
! Evaluate the chirped plane wave in 3D
! 
!  x,y,z,t (input) : point to evaluate at 
!  numberOfTimeDerivatives : evaluate this time derivative
!  ubc(.)  (output) : ubc(ex), etc. 
! --------------------------------------------------------------------
#beginMacro getChirpedPlaneWave3D(x,y,z,t,numberOfTimeDerivatives,ubv)

 ! xi = kx*(x)+ky*(y)-cc*(t) - xi0 
 xi0 = .5*(cpwTa+cpwTb)
 xi = t - (kx*(x-cpwX0)+ky*(y-cpwY0)+kz*(z-cpwZ0))/cc -xi0 
 cpwTau=cpwTb-cpwTa  ! tau = tb -ta

 ! include files generated by the maple code mx/codes/chirpedPlaneWave.maple 
 if( numberOfTimeDerivatives.eq.0 )then
   #Include "../codes/chirpedPlaneWave3D0T.h"
 else if(  numberOfTimeDerivatives.eq.1 )then
   #Include "../codes/chirpedPlaneWave3D1T.h"
 else if(  numberOfTimeDerivatives.eq.2 )then
   #Include "../codes/chirpedPlaneWave3D2T.h"
 else if(  numberOfTimeDerivatives.eq.3 )then
   #Include "../codes/chirpedPlaneWave3D3T.h"
 else if(  numberOfTimeDerivatives.eq.4 )then
   #Include "../codes/chirpedPlaneWave3D4T.h"

 else
   write(*,'(" getChirp3D:ERROR: too many derivatives requested")')
   stop 4927
 end if

 ubv(ex) = chirp*pwc(0)
 ubv(ey) = chirp*pwc(1)
 ubv(ez) = chirp*pwc(2)

#endMacro


