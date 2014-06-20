! This file was generated by fib/codes/viscous/exactViscous.maple
! Exact solution for a viscous incompressible flow and an Elastic bulk solid

! ---------------------------------------------------------------------------------- 
! wr,wi  (input) : real and imag parts of omega. 
! rho,mu,H  (input) : fluid parameters. 
! rhos,cp,cs,Hs (input) : solid parameters. 
! detr,deti (output) real and imag parts of the dispersion relation (determinant).
! u1Varies=0 : u1==0,  u1Varies=1 : u1 is allowed to vary.
! ---------------------------------------------------------------------------------- 
      subroutine dispersionViscousElastic(wr,wi, detr,deti,
     &               rho,mu,H,k,rhos,cp,cs,Hs,u1Varies )
      implicit none 
      complex II,w,a,as,det,Ca,Sa,Cas,Sas,bs,Cbs,Sbs
      complex a11,a12,a13,a14, a21,a22,a23,a24 
      complex a31,a32,a33,a34, a41,a42,a43,a44 
      complex aH,asHs,bsHs,z,cosh,sinh 
      real rho,mu,H,k,rhos,Hs,cp,rcp2,cs,rcs2,u1Varies
      real wr,wi,detr,deti,Ck,Sk,lambdas,mus
      ! cosh(z) =(exp(z)+exp(-z))*.5
      ! sinh(z) =(exp(z)-exp(-z))*.5
      cosh(z) = cmplx(dcosh(real(z))*cos(imag(z)),
     &                dsinh(real(z))*sin(imag(z)))
      sinh(z) = cmplx(dsinh(real(z))*cos(imag(z)),
     &                dcosh(real(z))*sin(imag(z)))
      w=cmplx(wr,wi)
      rcp2=rhos*cp**2
      rcs2=rhos*cs**2
      mus=rhos*cs**2
      lambdas=rhos*cp**2 - 2.*mus
      II=(0.,1.)
      a = sqrt(k ** 2 - II * rho * w / mu)
      Ck=dcosh(k*H)
      Sk=dsinh(k*H)
      aH=a*H
      Ca=cosh(aH)
      Sa=sinh(aH)
      as = sqrt(k ** 2 - w ** 2 / cp ** 2)
      asHs=as*Hs
      Cas=cosh(asHs)
      Sas=sinh(asHs)
      bs = sqrt(k ** 2 - w ** 2 / cs ** 2)
      bsHs=bs*Hs
      Cbs=cosh(bsHs)
      Sbs=sinh(bsHs)
      a11 = II * (k * Sa - a * Sk + (a * Ca * Sk - k * Ck * Sa) * Ck)
      a12 = II / k * a * (k * Sa - a * Sk + (a * Ca * Sk - k * Ck * Sa) 
     #* Ca)
      a13 = II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cb
     #s * Sas) + Cas + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * C
     #bs * Sas))
      a14 = II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cb
     #s * Sas) + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * S
     #as) + Cbs)
      a21 = (a * Ca * Sk - k * Ck * Sa) * Sk
      a22 = (a * Ca * Sk - k * Ck * Sa) * Sa
      a23 = -w * as / k * Sas
      a24 = -w * k / bs * Sbs
      a31 = -2 * II * mu * k * (a * Ca * Sk - k * Ck * Sa) * Sk
      a32 = -mu * (II / k * a ** 2 * (a * Ca * Sk - k * Ck * Sa) * Sa + 
     #II * k * (a * Ca * Sk - k * Ck * Sa) * Sa)
      a33 = -2 * mus * as * Sas
      a34 = mus * (-bs * Sbs - k ** 2 / bs * Sbs)
      a41 = II * rho * w / k * (k * Sa + (a * Ca * Sk - k * Ck * Sa) * C
     #k) - 2 * mu * (k ** 2 * Sa - k * a * Sk + (a * Ca * Sk - k * Ck * 
     #Sa) * k * Ck)
      a42 = II * rho * w / k * a * Sa - 2 * mu * (a * k * Sa - a ** 2 * 
     #Sk + (a * Ca * Sk - k * Ck * Sa) * a * Ca)
      a43 = -II * (lambdas + 2 * mus) * (-as ** 2 * k * Sbs / (k ** 2 * 
     #Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 / k * Cas + k * as * bs
     # * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas)) + II * lambda
     #s * k * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas
     #) + Cas + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sa
     #s))
      a44 = -II * (lambdas + 2 * mus) * (-as ** 2 * k * Sbs / (k ** 2 * 
     #Cas * Sbs - as * bs * Cbs * Sas) + k * as * bs * Sas / (k ** 2 * C
     #as * Sbs - as * bs * Cbs * Sas) + k * Cbs) + II * lambdas * k * (-
     #k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + as * b
     #s * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + Cbs)
      det = a11 * a22 * a33 * a44 - a11 * a22 * a34 * a43 - a11 * a32 * 
     #a23 * a44 + a11 * a32 * a24 * a43 + a11 * a42 * a23 * a34 - a11 * 
     #a42 * a24 * a33 - a21 * a12 * a33 * a44 + a21 * a12 * a34 * a43 + 
     #a21 * a32 * a13 * a44 - a21 * a32 * a14 * a43 - a21 * a42 * a13 * 
     #a34 + a21 * a42 * a14 * a33 + a31 * a12 * a23 * a44 - a31 * a12 * 
     #a24 * a43 - a31 * a22 * a13 * a44 + a31 * a22 * a14 * a43 + a31 * 
     #a42 * a13 * a24 - a31 * a42 * a14 * a23 - a41 * a12 * a23 * a34 + 
     #a41 * a12 * a24 * a33 + a41 * a22 * a13 * a34 - a41 * a22 * a14 * 
     #a33 - a41 * a32 * a13 * a24 + a41 * a32 * a14 * a23
      detr=real(det)
      deti=imag(det)
      return
      end

! 
! ---------------------------------------------------------------------------------- 
! wr,wi  (input) : real and imag parts of omega. 
! rho,mu,H  (input) : fluid parameters. 
! rhos,cp,cs,Hs (input) : solid parameters. 
! dwr,dwi (output) real and imag parts of d(det)/d(w), det=dispersion relation.
! u1Varies=0 : u1==0,  u1Varies=1 : u1 is allowed to vary.
! ---------------------------------------------------------------------------------- 
      subroutine dispersionViscousElasticDeriv(wr,wi, dwr,dwi,
     &             rho,mu,H,k,rhos,cp,cs,Hs,u1Varies )
      implicit none 
      complex II,w,G,a,as,asHs,dw,Ca,Sa,Cas,Sas,dadw,dasdw,dw0,dw1 
      complex bs,Cbs,Sbs,dbsdw,bsHs 
      complex dCadw,dSadw,dCasdw,dSasdw,aH,z,cosh,sinh,dCbsdw,dSbsdw 
      complex a11,a12,a13,a14, a21,a22,a23,a24 
      complex a31,a32,a33,a34, a41,a42,a43,a44 
      complex da11,da12,da13,da14, da21,da22,da23,da24 
      complex da31,da32,da33,da34, da41,da42,da43,da44 
      real rho,mu,H,k,rhos,Hs,cp,rcp2,cs,rcs2,u1Varies
      real wr,wi, dwr,dwi,Ck,Sk,lambdas,mus
      ! cosh(z) =(exp(z)+exp(-z))*.5
      ! sinh(z) =(exp(z)-exp(-z))*.5
      cosh(z) = cmplx(dcosh(real(z))*cos(imag(z)),
     &                dsinh(real(z))*sin(imag(z)))
      sinh(z) = cmplx(dsinh(real(z))*cos(imag(z)),
     &                dcosh(real(z))*sin(imag(z)))
      w=cmplx(wr,wi)
      rcp2=rhos*cp**2
      rcs2=rhos*cs**2
      mus=rhos*cs**2
      lambdas=rhos*cp**2 - 2.*mus
      II=(0.,1.)
      a = sqrt(k ** 2 - II * rho * w / mu)
      Ck=dcosh(k*H)
      Sk=dsinh(k*H)
      aH=a*H
      Ca=cosh(aH)
      Sa=sinh(aH)
      as = sqrt(k ** 2 - w ** 2 / cp ** 2)
      asHs=as*Hs
      Cas=cosh(asHs)
      Sas=sinh(asHs)
      dCasdw = Sas * Hs * dasdw
      bs = sqrt(k ** 2 - w ** 2 / cs ** 2)
      bsHs=bs*Hs
      Cbs=cosh(bsHs)
      Sbs=sinh(bsHs)
      dadw = -II * rho / mu / a / 0.2D1
      dasdw = -w / cp ** 2 / as
      dbsdw = -w / cs ** 2 / bs
      dCadw = Sa * H * dadw
      dSadw = Ca * H * dadw
      dCasdw = Sas * Hs * dasdw
      dSasdw = Cas * Hs * dasdw
      dCbsdw = Sbs * Hs * dbsdw
      dSbsdw = Cbs * Hs * dbsdw
      ! Note: daij = d(aij)/d(w)
      a11 = II * (k * Sa - a * Sk + (a * Ca * Sk - k * Ck * Sa) * Ck)
      da11 = II * (-Sk + Ca * Sk * Ck) * dadw + II * a * Sk * Ck * dCadw
     # + II * (k - k * Ck ** 2) * dSadw
      a12 = II / k * a * (k * Sa - a * Sk + (a * Ca * Sk - k * Ck * Sa) 
     #* Ca)
      da12 = (II / k * (k * Sa - a * Sk + (a * Ca * Sk - k * Ck * Sa) * 
     #Ca) + II / k * a * (-Sk + Ca ** 2 * Sk)) * dadw + II / k * a * (2 
     #* a * Ca * Sk - k * Ck * Sa) * dCadw + II / k * a * (k - k * Ck * 
     #Ca) * dSadw
      a13 = II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cb
     #s * Sas) + Cas + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * C
     #bs * Sas))
      da13 = II * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs *
     # Sas) + Cas + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs 
     #* Sas)) + II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs 
     #* Cbs * Sas) ** 2 * bs * Cbs * Sas + bs * Sas / (k ** 2 * Cas * Sb
     #s - as * bs * Cbs * Sas) + as * bs ** 2 * Sas ** 2 / (k ** 2 * Cas
     # * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs) * dasdw + II * w * (k **
     # 4 * Sbs ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 + 
     #1 - as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 
     #2 * k ** 2 * Sbs) * dCasdw + II * w * (-k ** 2 * Sbs / (k ** 2 * C
     #as * Sbs - as * bs * Cbs * Sas) ** 2 * as * bs * Cbs + as * bs / (
     #k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 * bs ** 2 * Sa
     #s / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs) * dSasd
     #w + II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs 
     #* Sas) ** 2 * as * Cbs * Sas + as * Sas / (k ** 2 * Cas * Sbs - as
     # * bs * Cbs * Sas) + as ** 2 * bs * Sas ** 2 / (k ** 2 * Cas * Sbs
     # - as * bs * Cbs * Sas) ** 2 * Cbs) * dbsdw + II * w * (-as * bs *
     # Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 * 
     #Sbs + as ** 2 * bs ** 2 * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs
     # * Cbs * Sas) ** 2) * dCbsdw + II * w * (-k ** 2 / (k ** 2 * Cas *
     # Sbs - as * bs * Cbs * Sas) + k ** 4 * Sbs / (k ** 2 * Cas * Sbs -
     # as * bs * Cbs * Sas) ** 2 * Cas - as * bs * Sas / (k ** 2 * Cas *
     # Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 * Cas) * dSbsdw
      a14 = II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cb
     #s * Sas) + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * S
     #as) + Cbs)
      da14 = II * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs *
     # Sas) + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas)
     # + Cbs) + II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs 
     #* Cbs * Sas) ** 2 * bs * Cbs * Sas + bs * Sas / (k ** 2 * Cas * Sb
     #s - as * bs * Cbs * Sas) + as * bs ** 2 * Sas ** 2 / (k ** 2 * Cas
     # * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs) * dasdw + II * w * (k **
     # 4 * Sbs ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 - 
     #as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * 
     #k ** 2 * Sbs) * dCasdw + II * w * (-k ** 2 * Sbs / (k ** 2 * Cas *
     # Sbs - as * bs * Cbs * Sas) ** 2 * as * bs * Cbs + as * bs / (k **
     # 2 * Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 * bs ** 2 * Sas / 
     #(k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs) * dSasdw + 
     #II * w * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sa
     #s) ** 2 * as * Cbs * Sas + as * Sas / (k ** 2 * Cas * Sbs - as * b
     #s * Cbs * Sas) + as ** 2 * bs * Sas ** 2 / (k ** 2 * Cas * Sbs - a
     #s * bs * Cbs * Sas) ** 2 * Cbs) * dbsdw + II * w * (-as * bs * Sas
     # / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 * Sbs 
     #+ as ** 2 * bs ** 2 * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs * C
     #bs * Sas) ** 2 + 1) * dCbsdw + II * w * (-k ** 2 / (k ** 2 * Cas *
     # Sbs - as * bs * Cbs * Sas) + k ** 4 * Sbs / (k ** 2 * Cas * Sbs -
     # as * bs * Cbs * Sas) ** 2 * Cas - as * bs * Sas / (k ** 2 * Cas *
     # Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 * Cas) * dSbsdw
      a21 = (a * Ca * Sk - k * Ck * Sa) * Sk
      da21 = Ca * Sk ** 2 * dadw + a * Sk ** 2 * dCadw - k * Ck * Sk * d
     #Sadw
      a22 = (a * Ca * Sk - k * Ck * Sa) * Sa
      da22 = Ca * Sk * Sa * dadw + a * Sk * Sa * dCadw + (-2 * k * Ck * 
     #Sa + a * Ca * Sk) * dSadw
      a23 = -w * as / k * Sas
      da23 = -as / k * Sas - w / k * Sas * dasdw - w * as / k * dSasdw
      a24 = -w * k / bs * Sbs
      da24 = -k / bs * Sbs + w * k / bs ** 2 * Sbs * dbsdw - w * k / bs 
     #* dSbsdw
      a31 = -2 * II * mu * k * (a * Ca * Sk - k * Ck * Sa) * Sk
      da31 = -2 * II * mu * k * Ca * Sk ** 2 * dadw - 2 * II * mu * k * 
     #a * Sk ** 2 * dCadw + 2 * II * mu * k ** 2 * Ck * Sk * dSadw
      a32 = -mu * (II / k * a ** 2 * (a * Ca * Sk - k * Ck * Sa) * Sa + 
     #II * k * (a * Ca * Sk - k * Ck * Sa) * Sa)
      da32 = -mu * (2 * II / k * a * (a * Ca * Sk - k * Ck * Sa) * Sa + 
     #II / k * a ** 2 * Ca * Sk * Sa + II * k * Ca * Sk * Sa) * dadw - m
     #u * (II / k * a ** 3 * Sk * Sa + II * k * a * Sk * Sa) * dCadw - m
     #u * (-II * a ** 2 * Ck * Sa + II / k * a ** 2 * (a * Ca * Sk - k *
     # Ck * Sa) - II * k ** 2 * Ck * Sa + II * k * (a * Ca * Sk - k * Ck
     # * Sa)) * dSadw
      a33 = -2 * mus * as * Sas
      da33 = -2 * mus * Sas * dasdw - 2 * mus * as * dSasdw
      a34 = mus * (-bs * Sbs - k ** 2 / bs * Sbs)
      da34 = mus * (-Sbs + k ** 2 / bs ** 2 * Sbs) * dbsdw + mus * (-bs 
     #- k ** 2 / bs) * dSbsdw
      a41 = II * rho * w / k * (k * Sa + (a * Ca * Sk - k * Ck * Sa) * C
     #k) - 2 * mu * (k ** 2 * Sa - k * a * Sk + (a * Ca * Sk - k * Ck * 
     #Sa) * k * Ck)
      da41 = II * rho / k * (k * Sa + (a * Ca * Sk - k * Ck * Sa) * Ck) 
     #+ (II * rho * w / k * Ca * Sk * Ck - 2 * mu * (-k * Sk + Ca * Sk *
     # k * Ck)) * dadw + (II * rho * w / k * a * Sk * Ck - 2 * mu * a * 
     #Sk * k * Ck) * dCadw + (II * rho * w / k * (k - k * Ck ** 2) - 2 *
     # mu * (k ** 2 - k ** 2 * Ck ** 2)) * dSadw
      a42 = II * rho * w / k * a * Sa - 2 * mu * (a * k * Sa - a ** 2 * 
     #Sk + (a * Ca * Sk - k * Ck * Sa) * a * Ca)
      da42 = II * rho / k * a * Sa + (II * rho * w / k * Sa - 2 * mu * (
     #k * Sa - 2 * a * Sk + Ca ** 2 * Sk * a + (a * Ca * Sk - k * Ck * S
     #a) * Ca)) * dadw - 2 * mu * (a ** 2 * Sk * Ca + (a * Ca * Sk - k *
     # Ck * Sa) * a) * dCadw + (II * rho * w / k * a - 2 * mu * (a * k -
     # k * Ck * a * Ca)) * dSadw
      a43 = -II * (lambdas + 2 * mus) * (-as ** 2 * k * Sbs / (k ** 2 * 
     #Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 / k * Cas + k * as * bs
     # * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas)) + II * lambda
     #s * k * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas
     #) + Cas + as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sa
     #s))
      da43 = (-II * (lambdas + 2 * mus) * (-2 * as * k * Sbs / (k ** 2 *
     # Cas * Sbs - as * bs * Cbs * Sas) - as ** 2 * k * Sbs / (k ** 2 * 
     #Cas * Sbs - as * bs * Cbs * Sas) ** 2 * bs * Cbs * Sas + 2 * as / 
     #k * Cas + k * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas
     #) + k * as * bs ** 2 * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs * 
     #Cbs * Sas) ** 2 * Cbs) + II * lambdas * k * (-k ** 2 * Sbs / (k **
     # 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * bs * Cbs * Sas + bs *
     # Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + as * bs ** 2 *
     # Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs)
     #) * dasdw + (-II * (lambdas + 2 * mus) * (as ** 2 * k ** 3 * Sbs *
     #* 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 + as ** 2 / 
     #k - k ** 3 * as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs *
     # Sas) ** 2 * Sbs) + II * lambdas * k * (k ** 4 * Sbs ** 2 / (k ** 
     #2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 + 1 - as * bs * Sas / (k
     # ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 * Sbs)) * d
     #Casdw + (-II * (lambdas + 2 * mus) * (-as ** 3 * k * Sbs / (k ** 2
     # * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * bs * Cbs + k * as * bs 
     #/ (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + k * as ** 2 * bs **
     # 2 * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs) 
     #+ II * lambdas * k * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * b
     #s * Cbs * Sas) ** 2 * as * bs * Cbs + as * bs / (k ** 2 * Cas * Sb
     #s - as * bs * Cbs * Sas) + as ** 2 * bs ** 2 * Sas / (k ** 2 * Cas
     # * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs)) * dSasdw + (-II * (lamb
     #das + 2 * mus) * (-as ** 3 * k * Sbs / (k ** 2 * Cas * Sbs - as * 
     #bs * Cbs * Sas) ** 2 * Cbs * Sas + k * as * Sas / (k ** 2 * Cas * 
     #Sbs - as * bs * Cbs * Sas) + k * as ** 2 * bs * Sas ** 2 / (k ** 2
     # * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs) + II * lambdas * k
     # * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 
     #2 * as * Cbs * Sas + as * Sas / (k ** 2 * Cas * Sbs - as * bs * Cb
     #s * Sas) + as ** 2 * bs * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs
     # * Cbs * Sas) ** 2 * Cbs)) * dbsdw + (-II * (lambdas + 2 * mus) * 
     #(-as ** 3 * k * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) *
     #* 2 * bs * Sas + k * as ** 2 * bs ** 2 * Sas ** 2 / (k ** 2 * Cas 
     #* Sbs - as * bs * Cbs * Sas) ** 2) + II * lambdas * k * (-as * bs 
     #* Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 *
     # Sbs + as ** 2 * bs ** 2 * Sas ** 2 / (k ** 2 * Cas * Sbs - as * b
     #s * Cbs * Sas) ** 2)) * dCbsdw + (-II * (lambdas + 2 * mus) * (-as
     # ** 2 * k / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 *
     # k ** 3 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * 
     #Cas - k ** 3 * as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs
     # * Sas) ** 2 * Cas) + II * lambdas * k * (-k ** 2 / (k ** 2 * Cas 
     #* Sbs - as * bs * Cbs * Sas) + k ** 4 * Sbs / (k ** 2 * Cas * Sbs 
     #- as * bs * Cbs * Sas) ** 2 * Cas - as * bs * Sas / (k ** 2 * Cas 
     #* Sbs - as * bs * Cbs * Sas) ** 2 * k ** 2 * Cas)) * dSbsdw
      a44 = -II * (lambdas + 2 * mus) * (-as ** 2 * k * Sbs / (k ** 2 * 
     #Cas * Sbs - as * bs * Cbs * Sas) + k * as * bs * Sas / (k ** 2 * C
     #as * Sbs - as * bs * Cbs * Sas) + k * Cbs) + II * lambdas * k * (-
     #k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + as * b
     #s * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + Cbs)
      da44 = (-II * (lambdas + 2 * mus) * (-2 * as * k * Sbs / (k ** 2 *
     # Cas * Sbs - as * bs * Cbs * Sas) - as ** 2 * k * Sbs / (k ** 2 * 
     #Cas * Sbs - as * bs * Cbs * Sas) ** 2 * bs * Cbs * Sas + k * bs * 
     #Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + k * as * bs ** 
     #2 * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * C
     #bs) + II * lambdas * k * (-k ** 2 * Sbs / (k ** 2 * Cas * Sbs - as
     # * bs * Cbs * Sas) ** 2 * bs * Cbs * Sas + bs * Sas / (k ** 2 * Ca
     #s * Sbs - as * bs * Cbs * Sas) + as * bs ** 2 * Sas ** 2 / (k ** 2
     # * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs)) * dasdw + (-II * 
     #(lambdas + 2 * mus) * (as ** 2 * k ** 3 * Sbs ** 2 / (k ** 2 * Cas
     # * Sbs - as * bs * Cbs * Sas) ** 2 - k ** 3 * as * bs * Sas / (k *
     #* 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Sbs) + II * lambdas 
     #* k * (k ** 4 * Sbs ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * S
     #as) ** 2 - as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * S
     #as) ** 2 * k ** 2 * Sbs)) * dCasdw + (-II * (lambdas + 2 * mus) * 
     #(-as ** 3 * k * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) *
     #* 2 * bs * Cbs + k * as * bs / (k ** 2 * Cas * Sbs - as * bs * Cbs
     # * Sas) + k * as ** 2 * bs ** 2 * Sas / (k ** 2 * Cas * Sbs - as *
     # bs * Cbs * Sas) ** 2 * Cbs) + II * lambdas * k * (-k ** 2 * Sbs /
     # (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * as * bs * Cbs +
     # as * bs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 * 
     #bs ** 2 * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * 
     #Cbs)) * dSasdw + (-II * (lambdas + 2 * mus) * (-as ** 3 * k * Sbs 
     #/ (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs * Sas + k 
     #* as * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) + k * as *
     #* 2 * bs * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) *
     #* 2 * Cbs) + II * lambdas * k * (-k ** 2 * Sbs / (k ** 2 * Cas * S
     #bs - as * bs * Cbs * Sas) ** 2 * as * Cbs * Sas + as * Sas / (k **
     # 2 * Cas * Sbs - as * bs * Cbs * Sas) + as ** 2 * bs * Sas ** 2 / 
     #(k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cbs)) * dbsdw + 
     #(-II * (lambdas + 2 * mus) * (-as ** 3 * k * Sbs / (k ** 2 * Cas *
     # Sbs - as * bs * Cbs * Sas) ** 2 * bs * Sas + k * as ** 2 * bs ** 
     #2 * Sas ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 + k
     #) + II * lambdas * k * (-as * bs * Sas / (k ** 2 * Cas * Sbs - as 
     #* bs * Cbs * Sas) ** 2 * k ** 2 * Sbs + as ** 2 * bs ** 2 * Sas **
     # 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 + 1)) * dCbsd
     #w + (-II * (lambdas + 2 * mus) * (-as ** 2 * k / (k ** 2 * Cas * S
     #bs - as * bs * Cbs * Sas) + as ** 2 * k ** 3 * Sbs / (k ** 2 * Cas
     # * Sbs - as * bs * Cbs * Sas) ** 2 * Cas - k ** 3 * as * bs * Sas 
     #/ (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 * Cas) + II * la
     #mbdas * k * (-k ** 2 / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) 
     #+ k ** 4 * Sbs / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) ** 2 *
     # Cas - as * bs * Sas / (k ** 2 * Cas * Sbs - as * bs * Cbs * Sas) 
     #** 2 * k ** 2 * Cas)) * dSbsdw
      dw = -da41 * a22 * a14 * a33 + da41 * a22 * a13 * a34 + da41 * a12
     # * a24 * a33 - da41 * a12 * a23 * a34 - da31 * a42 * a14 * a23 + d
     #a31 * a42 * a13 * a24 + da31 * a22 * a14 * a43 - da31 * a22 * a13 
     #* a44 - da31 * a12 * a24 * a43 + da31 * a12 * a23 * a44 + da21 * a
     #42 * a14 * a33 - da21 * a42 * a13 * a34 - da21 * a32 * a14 * a43 +
     # da21 * a32 * a13 * a44 + da21 * a12 * a34 * a43 - da21 * a12 * a3
     #3 * a44 - da11 * a42 * a24 * a33 + da11 * a42 * a23 * a34 + da11 *
     # a32 * a24 * a43 - da11 * a32 * a23 * a44 + a21 * a32 * a13 * da44
     # - a21 * a32 * a14 * da43 - a21 * a42 * da13 * a34 - a11 * da32 * 
     #a23 * a44 - a11 * da22 * a34 * a43 + a11 * da22 * a33 * a44 + da41
     # * a32 * a14 * a23 + a21 * a12 * a34 * da43 + a21 * a32 * da13 * a
     #44 - a21 * a12 * da33 * a44 - da41 * a32 * a13 * a24 + a11 * da42 
     #* a23 * a34 - a31 * a42 * a14 * da23 - a41 * a12 * da23 * a34 + a3
     #1 * a22 * a14 * da43 + a31 * a42 * da13 * a24 - a31 * a12 * a24 * 
     #da43 - a31 * a22 * da13 * a44 + a11 * da32 * a24 * a43 + a21 * a42
     # * a14 * da33 + a31 * a12 * da23 * a44 + a41 * a12 * a24 * da33 + 
     #a41 * a22 * da13 * a34 - a11 * da42 * a24 * a33 - a41 * a22 * a14 
     #* da33 - a41 * a32 * da13 * a24 + a41 * a32 * a14 * da23 - a31 * d
     #a42 * a14 * a23 - a21 * da12 * a33 * a44 + a31 * da22 * a14 * a43 
     #+ a21 * da32 * a13 * a44 + a21 * da12 * a34 * a43 - a41 * da22 * a
     #14 * a33 - a41 * da32 * a13 * a24 + a41 * da12 * a24 * a33 + a41 *
     # da22 * a13 * a34 - a41 * da12 * a23 * a34 - a21 * da42 * a13 * a3
     #4 - a21 * da32 * a14 * a43 + a41 * da32 * a14 * a23 + a21 * da42 *
     # a14 * a33 + a31 * da12 * a23 * a44 - a31 * da12 * a24 * a43 - a31
     # * da22 * a13 * a44 - a21 * a32 * da14 * a43 - a21 * a42 * a13 * d
     #a34 - a21 * a12 * a33 * da44 + a21 * a12 * da34 * a43 + a11 * a32 
     #* da24 * a43 + a11 * a42 * a23 * da34 - a11 * a42 * da24 * a33 + a
     #11 * a22 * a33 * da44 - a11 * a22 * da34 * a43 - a11 * a32 * a23 *
     # da44 - a41 * a22 * da14 * a33 - a41 * a32 * a13 * da24 + a41 * a3
     #2 * da14 * a23 + a41 * a12 * da24 * a33 + a41 * a22 * a13 * da34 +
     # a31 * a42 * a13 * da24 - a31 * a42 * da14 * a23 - a41 * a12 * a23
     # * da34 - a31 * a22 * a13 * da44 + a31 * a22 * da14 * a43 + a21 * 
     #a42 * da14 * a33 + a31 * a12 * a23 * da44 - a31 * a12 * da24 * a43
     # + a31 * da42 * a13 * a24 - a11 * a22 * a34 * da43 - a11 * a32 * d
     #a23 * a44 + a11 * a22 * da33 * a44 - a11 * a42 * a24 * da33 + a11 
     #* a32 * a24 * da43 + a11 * a42 * da23 * a34 - da11 * a22 * a34 * a
     #43 + da11 * a22 * a33 * a44
      dwr=real(dw)
      dwi=imag(dw)
      return
      end