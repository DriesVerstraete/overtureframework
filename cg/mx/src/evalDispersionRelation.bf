! Evaluate the dispersion relation for a dispersion material
!
! Drude-Lorentz model
!
!  Input:
!      c0,eps,gam,omegap,k : 
! Output:
!      omegar,omegai 
!
      subroutine evalDispersionRelation( c0,eps,gam,omegap,k, omegar,omegai )


      implicit none

      real c0,eps,gam,omegap,k, ck2, epsi, om2, det
      real omegar,omegai
      complex*16 ai, c, s

      ck2=(c0*k)**2
      epsi=1./eps
      om2=omegap**2

       ! ai=cmplx(0.,1.)  ! i 
       c = cmplx(c0,0.) ! convert c to complex to force complex arithmetic below
! File generated by overtureFramework/cg/mx/codes/dispersion.maple
! Here is root 3 from the dispersion relation exp( i*k*x + s*t) .
! s = -1/12*(36*epsi*gam*om2-72*ck2*gam-8*gam^3+12*(12*epsi^3*om2^3-3*epsi^2*gam^2*om2^2+36*ck2*epsi^2*om2^2-60*ck2*epsi*gam^2*om2+12*ck2*gam^4+36*ck2^2*epsi*om2+24*ck2^2*gam^2+12*ck2^3)^(1/2))^(1/3)+3*(1/3*epsi*om2+1/3*ck2-1/9*gam^2)/(36*epsi*gam*om2-72*ck2*gam-8*gam^3+12*(12*epsi^3*om2^3-3*epsi^2*gam^2*om2^2+36*ck2*epsi^2*om2^2-60*ck2*epsi*gam^2*om2+12*ck2*gam^4+36*ck2^2*epsi*om2+24*ck2^2*gam^2+12*ck2^3)^(1/2))^(1/3)-1/3*gam+1/2*I*3^(1/2)*(1/6*(36*epsi*gam*om2-72*ck2*gam-8*gam^3+12*(12*epsi^3*om2^3-3*epsi^2*gam^2*om2^2+36*ck2*epsi^2*om2^2-60*ck2*epsi*gam^2*om2+12*ck2*gam^4+36*ck2^2*epsi*om2+24*ck2^2*gam^2+12*ck2^3)^(1/2))^(1/3)+6*(1/3*epsi*om2+1/3*ck2-1/9*gam^2)/(36*epsi*gam*om2-72*ck2*gam-8*gam^3+12*(12*epsi^3*om2^3-3*epsi^2*gam^2*om2^2+36*ck2*epsi^2*om2^2-60*ck2*epsi*gam^2*om2+12*ck2*gam^4+36*ck2^2*epsi*om2+24*ck2^2*gam^2+12*ck2^3)^(1/2))^(1/3))
      s = -(((36*epsi*gam*om2)-(72*ck2*gam)-(8*gam ** 3)+12.*sqrt((12*epsi ** 3*om2 ** 3-3*epsi ** 2*om2 ** 2*gam ** 2+36*epsi ** 2*om2 ** 2*ck2-60*epsi*om2*ck2*gam ** 2+12*ck2*gam ** 4+36*epsi*om2*ck2 ** 2+24*ck2 ** 2*gam ** 2+12*ck2 ** 3))) ** (1./3.)/12.)+(3.*((epsi*om2)/3.+(ck2)/3.-(gam ** 2)/0.9E1)*((36*epsi*gam*om2)-(72*ck2*gam)-(8*gam ** 3)+12.*sqrt((12*epsi ** 3*om2 ** 3-3*epsi ** 2*om2 ** 2*gam ** 2+36*epsi ** 2*om2 ** 2*ck2-60*epsi*om2*ck2*gam ** 2+12*ck2*gam ** 4+36*epsi*om2*ck2 ** 2+24*ck2 ** 2*gam ** 2+12*ck2 ** 3))) ** (-1./3.))-((gam)/3.)+cmplx(0, 1./2.)*sqrt(3.)*(((36*epsi*gam*om2)-(72*ck2*gam)-(8*gam ** 3)+12.*sqrt((12*epsi ** 3*om2 ** 3-3*epsi ** 2*om2 ** 2*gam ** 2+36*epsi ** 2*om2 ** 2*ck2-60*epsi*om2*ck2*gam ** 2+12*ck2*gam ** 4+36*epsi*om2*ck2 ** 2+24*ck2 ** 2*gam ** 2+12*ck2 ** 3))) ** (1./3.)/6.+6.*((epsi*om2)/3.+(ck2)/3.-(gam ** 2)/0.9E1)*((36*epsi*gam*om2)-(72*ck2*gam)-(8*gam ** 3)+12.*sqrt((12*epsi ** 3*om2 ** 3-3*epsi ** 2*om2 ** 2*gam ** 2+36*epsi ** 2*om2 ** 2*ck2-60*epsi*om2*ck2*gam ** 2+12*ck2*gam ** 4+36*epsi*om2*ck2 ** 2+24*ck2 ** 2*gam ** 2+12*ck2 ** 3))) ** (-1./3.))

      ! check root:
      det = cabs((s**2 + ck2)*(s**2 + gam*s) + om2*s**2*epsi)
      write(*,'(" dispersion: eps=",e12.4," gam=",e12.4," |det|=",e12.4)') eps,gam,det

      ! ss = -i*omega = -i*( omegar + i omegai ) = omegai - i*oemgar 
      omegar= aimag(s) ! flip sign for right traveling 
      omegai= real(s)

      return
      end   
