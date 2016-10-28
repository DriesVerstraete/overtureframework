! This file automatically generated from opcoeff.bf with bpp.
! coeffOperator2ndOrder(tt)
       subroutine ttCoeff2ndOrder( nd, nd1a,nd1b,nd2a,nd2b,nd3a,nd3b,
     & ndc1a,ndc1b,ndc2a,ndc2b,ndc3a,ndc3b, nds1a,nds1b,nds2a,nds2b,
     & nds3a,nds3b,n1a,n1b,n2a,n2b,n3a,n3b, ndc, nc, ns, ea,eb, ca,cb,
     & dx,dr, rsxy,coeff, derivOption, derivType, gridType, order, s, 
     & jac, averagingType, dir1, dir2,a11,a22,a12,a21,a33,a13,a23,a31,
     & a32 )
       ! ===============================================================
       !  Derivative Coefficients
       !  
       !  nd : number of range spatial dimensions 
       !  nd1a,nd1b : mesh dimensions axis 1
       !  nd2a,nd2b : mesh dimensions axis 2
       !  nd3a,nd3b : mesh dimensions axis 3
       !
       !  ndc : number of coefficients/mesh point
       !  nc1a,nd1b : coefficient array dimensions axis 1
       !  nc2a,nd2b : coefficient array dimensions axis 2
       !  nc3a,nd3b : coefficient array dimensions axis 3
       !
       !  nc1a,nd1b : subset for evaluating tt, axis 1
       !  nc2a,nd2b : subset for evaluating tt, axis 2
       !  nc3a,nd3b : subset for evaluating tt, axis 3
       !
       !  nc : number of components
       !  ns : stencil size
       !  ca,cb : assign components c=ca,..,cb (base 0)
       !  ea,eb : assign equations e=ea,..eb   (base 0)
       !
       !  d11 : 1/dr
       !
       !  h11 : 1/h    :  for rectangular   
       !
       !  rsxy : jacobian information, not used if rectangular
       !  coeff : coefficient matrix
       !  gridType: 0=rectangular, 1=non-rectangular
       !  order : 2 or 4
       ! nc : number of components
       ! ns : stencil size
       ! ca,cb : assign components c=ca,..,cb (base 0)
       ! ea,eb : assign equations e=ea,..eb   (base 0)
       ! gridType: 0=rectangular, 1=non-rectangular
       ! order : 2 or 4
       ! rsxy : not used if rectangular
       ! ===============================================================
       !      implicit none
       integer nd, nd1a,nd1b,nd2a,nd2b,nd3a,nd3b,n1a,n1b,n2a,n2b,n3a,
     & n3b, ndc, nc,ns, ca,cb,ea,eb, gridType, order
       integer ndc1a,ndc1b,ndc2a,ndc2b,ndc3a,ndc3b,nds1a,nds1b,nds2a,
     & nds2b,nds3a,nds3b
       integer derivOption, derivType, averagingType, dir1, dir2
       real dx(3),dr(3)
       real rsxy(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b,1:nd,1:nd)
       real coeff(1:ndc,ndc1a:ndc1b,ndc2a:ndc2b,ndc3a:ndc3b)
       ! *wdh* 2016/08/27 real s(nds1a:nds1b,nds2a:nds2b,nds3a:nds3b)
       real s(nds1a:nds1b,nds2a:nds2b,nds3a:nds3b,0:*)
       real jac(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a11(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a12(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a13(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a21(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a22(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a23(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a31(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a32(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       real a33(nd1a:nd1b,nd2a:nd2b,nd3a:nd3b)
       ! real rx,ry,rz,sx,sy,sz,tx,ty,tz,d
       ! real rxSq,rxx,sxSq,sxx,rsx,rxx2,ryy2,sxx2,syy2
       ! real rxt2,ryt2,rzz23,sxt2,syt2,szz23,txr2,txs2
       ! real txt2,tyr2,tys2,tyt2,tzz23,rzr2,rzs2,rzt2
       ! real szr2,szs2,szt2,tzr2,tzs2,tzt2
       ! real rxr2,rxs2,ryr2,rys2,sxr2,sxs2,syr2,sys2
       ! real txx,txSq,rtx,stx,rxx23,ryy23,sxx23,syy23,txx23,tyy23
       !..... added by kkc 1/2/02 for g77 unsatisfied reference
       real u(1,1,1,1)
       real h21(3),d22(3),d12(3),h22(3)
       integer i1,i2,i3,kd3,kd,c,e,ec
       integer m12,m22,m32
       integer m(-1:1,-1:1),m3(-1:1,-1:1,-1:1)
       integer laplace,divScalarGrad,derivativeScalarDerivative
       parameter(laplace=0,divScalarGrad=1,
     & derivativeScalarDerivative=2)
       integer arithmeticAverage,harmonicAverage
       parameter( arithmeticAverage=0,harmonicAverage=1 )
       integer symmetric
       parameter( symmetric=2 )
       !.......statement functions for jacobian
       rx(i1,i2,i3)=rsxy(i1,i2,i3,  1,  1)
       ry(i1,i2,i3)=rsxy(i1,i2,i3,  1,  2)
       rz(i1,i2,i3)=rsxy(i1,i2,i3,  1,kd3)
       sx(i1,i2,i3)=rsxy(i1,i2,i3,  2,  1)
       sy(i1,i2,i3)=rsxy(i1,i2,i3,  2,  2)
       sz(i1,i2,i3)=rsxy(i1,i2,i3,  2,kd3)
       tx(i1,i2,i3)=rsxy(i1,i2,i3,kd3,  1)
       ty(i1,i2,i3)=rsxy(i1,i2,i3,kd3,  2)
       tz(i1,i2,i3)=rsxy(i1,i2,i3,kd3,kd3)
       include 'cgux2af.h'
       rxx1(i1,i2,i3)=rx(i1,i2,i3)*rxr2(i1,i2,i3)
       !.....end statement functions
       if( order.ne.2 )then
         write(*,*) 'laplacianCoeff:ERROR: order!=2 '
         stop
       end if
       do n=1,3
         d12(n)=1./(2.*dr(n))
         d22(n)=1./(dr(n)**2)
         h21(n)=1./(2.*dx(n))
         h22(n)=1./(dx(n)**2)
       end do
       kd3=nd
       if( nd .eq. 2 )then
       !       ************************
       !       ******* 2D *************      
       !       ************************
!   #If "tt" == "identity"
!   #Elif "tt" == "r"
!   #Elif "tt" == "s"
!   #Elif "tt" == "rr"
!   #Elif "tt" == "ss"
!   #Elif "tt" == "rs"
         if( gridType .eq. 0 )then
       !   rectangular
!     #If "tt" == "divScalarGrad"
!     #Else
! beginLoops()
             ! ***** loop over equations and components *****
             do e=ea,eb
             do c=ca,cb
             ec=ns*(c+nc*e)
             ! ** it did not affect performance to use an array to index coeff ***
             if( nd.eq.2 )then
             do i2=-1,1
               do i1=-1,1
                m(i1,i2)=i1+1+3*(i2+1) +1 + ec
               end do
             end do
             else if( nd.eq.3 )then
             do i3=-1,1
               do i2=-1,1
                 do i1=-1,1
                   m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
                 end do
               end do
             end do
             else
             m12=1 + ec
             m22=2 + ec
             m32=3 + ec
             endif
             do i3=n3a,n3b
             do i2=n2a,n2b
             do i1=n1a,n1b
!       #If "tt" == "laplacian"
!       #Elif "tt" == "x"
!       #Elif "tt" == "y"
!       #Elif "tt" == "xx"
!       #Elif "tt" == "yy"
!       #Elif "tt" == "xy"
! endLoops()
             end do
             end do
             end do
             end do
             end do
         else
       !  ***** not rectangular *****
!     #If "tt" == "divScalarGrad"
!     #Else
! beginLoops()
             ! ***** loop over equations and components *****
             do e=ea,eb
             do c=ca,cb
             ec=ns*(c+nc*e)
             ! ** it did not affect performance to use an array to index coeff ***
             if( nd.eq.2 )then
             do i2=-1,1
               do i1=-1,1
                m(i1,i2)=i1+1+3*(i2+1) +1 + ec
               end do
             end do
             else if( nd.eq.3 )then
             do i3=-1,1
               do i2=-1,1
                 do i1=-1,1
                   m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
                 end do
               end do
             end do
             else
             m12=1 + ec
             m22=2 + ec
             m32=3 + ec
             endif
             do i3=n3a,n3b
             do i2=n2a,n2b
             do i1=n1a,n1b
!       #If "tt" == "laplacian"
!       #Elif "tt" == "x"
!       #Elif "tt" == "y"
!       #Elif "tt" == "xx"
!       #Elif "tt" == "yy"
!       #Elif "tt" == "xy"
! endLoops()
             end do
             end do
             end do
             end do
             end do
         endif
       elseif( nd.eq.3 )then
       !       ************************
       !       ******* 3D *************      
       !       ************************
!   #If "tt" == "identity"
!    #Elif "tt" == "r"
!    #Elif "tt" == "s"
!    #Elif "tt" == "t"
!    #Elif "tt" == "rr"
!    #Elif "tt" == "ss"
!    #Elif "tt" == "tt"
! beginLoops()
           ! ***** loop over equations and components *****
           do e=ea,eb
           do c=ca,cb
           ec=ns*(c+nc*e)
           ! ** it did not affect performance to use an array to index coeff ***
           if( nd.eq.2 )then
           do i2=-1,1
             do i1=-1,1
              m(i1,i2)=i1+1+3*(i2+1) +1 + ec
             end do
           end do
           else if( nd.eq.3 )then
           do i3=-1,1
             do i2=-1,1
               do i1=-1,1
                 m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
               end do
             end do
           end do
           else
           m12=1 + ec
           m22=2 + ec
           m32=3 + ec
           endif
           do i3=n3a,n3b
           do i2=n2a,n2b
           do i1=n1a,n1b
! rr2ndOrder3dRectangular(z,3)
! loopBody2ndOrder3dSwitchxz(0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,d22(3),-2.*d22(3),d22(3),0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.)
! loopBody2ndOrder3d(0.,0.,0.,0.,d22(3),0.,0.,0.,0.,0.,0.,0.,0.,-2.*d22(3),0.,0.,0.,0.,0.,0.,0.,0.,d22(3),0.,0.,0.,0.)
              coeff(m3(-1,-1,-1),i1,i2,i3)=0.
              coeff(m3( 0,-1,-1),i1,i2,i3)=0.
              coeff(m3(+1,-1,-1),i1,i2,i3)=0.
              coeff(m3(-1, 0,-1),i1,i2,i3)=0.
              coeff(m3( 0, 0,-1),i1,i2,i3)=d22(3)
              coeff(m3(+1, 0,-1),i1,i2,i3)=0.
              coeff(m3(-1,+1,-1),i1,i2,i3)=0.
              coeff(m3( 0,+1,-1),i1,i2,i3)=0.
              coeff(m3(+1,+1,-1),i1,i2,i3)=0.
              coeff(m3(-1,-1, 0),i1,i2,i3)=0.
              coeff(m3( 0,-1, 0),i1,i2,i3)=0.
              coeff(m3(+1,-1, 0),i1,i2,i3)=0.
              coeff(m3(-1, 0, 0),i1,i2,i3)=0.
              coeff(m3( 0, 0, 0),i1,i2,i3)=-2.*d22(3)
              coeff(m3(+1, 0, 0),i1,i2,i3)=0.
              coeff(m3(-1,+1, 0),i1,i2,i3)=0.
              coeff(m3( 0,+1, 0),i1,i2,i3)=0.
              coeff(m3(+1,+1, 0),i1,i2,i3)=0.
              coeff(m3(-1,-1,+1),i1,i2,i3)=0.
              coeff(m3( 0,-1,+1),i1,i2,i3)=0.
              coeff(m3(+1,-1,+1),i1,i2,i3)=0.
              coeff(m3(-1, 0,+1),i1,i2,i3)=0.
              coeff(m3( 0, 0,+1),i1,i2,i3)=d22(3)
              coeff(m3(+1, 0,+1),i1,i2,i3)=0.
              coeff(m3(-1,+1,+1),i1,i2,i3)=0.
              coeff(m3( 0,+1,+1),i1,i2,i3)=0.
              coeff(m3(+1,+1,+1),i1,i2,i3)=0.
! endLoops()
           end do
           end do
           end do
           end do
           end do
           return
         if( gridType .eq. 0 )then
       !   rectangular
!     #If "tt" == "divScalarGrad"
!     #Else
! beginLoops()
            ! ***** loop over equations and components *****
            do e=ea,eb
            do c=ca,cb
            ec=ns*(c+nc*e)
            ! ** it did not affect performance to use an array to index coeff ***
            if( nd.eq.2 )then
            do i2=-1,1
              do i1=-1,1
               m(i1,i2)=i1+1+3*(i2+1) +1 + ec
              end do
            end do
            else if( nd.eq.3 )then
            do i3=-1,1
              do i2=-1,1
                do i1=-1,1
                  m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
                end do
              end do
            end do
            else
            m12=1 + ec
            m22=2 + ec
            m32=3 + ec
            endif
            do i3=n3a,n3b
            do i2=n2a,n2b
            do i1=n1a,n1b
!      #If "tt" == "laplacian"
!      #Elif "tt" == "x"
!      #Elif "tt" == "y"
!      #Elif "tt" == "z"
!      #Elif "tt" == "xx"
!      #Elif "tt" == "yy"
!      #Elif "tt" == "zz"
!      #Elif "tt" == "xy"
!      #Elif "tt" == "xz"
!      #Elif "tt" == "yz"
! endLoops()
            end do
            end do
            end do
            end do
            end do
         else
       !  ***** not rectangular *****
!     #If "tt" == "divScalarGrad"
!     #Else
! beginLoops()
            ! ***** loop over equations and components *****
            do e=ea,eb
            do c=ca,cb
            ec=ns*(c+nc*e)
            ! ** it did not affect performance to use an array to index coeff ***
            if( nd.eq.2 )then
            do i2=-1,1
              do i1=-1,1
               m(i1,i2)=i1+1+3*(i2+1) +1 + ec
              end do
            end do
            else if( nd.eq.3 )then
            do i3=-1,1
              do i2=-1,1
                do i1=-1,1
                  m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
                end do
              end do
            end do
            else
            m12=1 + ec
            m22=2 + ec
            m32=3 + ec
            endif
            do i3=n3a,n3b
            do i2=n2a,n2b
            do i1=n1a,n1b
!      #If "tt" == "laplacian"
!      #Elif "tt" == "x"
!      #Elif "tt" == "y"
!      #Elif "tt" == "z"
!      #Elif "tt" == "xx"
!      #Elif "tt" == "yy"
!      #Elif "tt" == "zz"
!      #Elif "tt" == "xy"
!      #Elif "tt" == "xz"
!      #Elif "tt" == "yz"
! endLoops()
            end do
            end do
            end do
            end do
            end do
         end if
       elseif( nd.eq.1 )then
       !       ************************
       !       ******* 1D *************      
       !       ************************
!   #If "tt" == "identity"
!   #Elif "tt" == "rr"
!   #Elif "tt" == "r"
         if( gridType .eq. 0 )then
       !   rectangular
!     #If "tt" == "divScalarGrad"
!     #Else
! beginLoops()
            ! ***** loop over equations and components *****
            do e=ea,eb
            do c=ca,cb
            ec=ns*(c+nc*e)
            ! ** it did not affect performance to use an array to index coeff ***
            if( nd.eq.2 )then
            do i2=-1,1
              do i1=-1,1
               m(i1,i2)=i1+1+3*(i2+1) +1 + ec
              end do
            end do
            else if( nd.eq.3 )then
            do i3=-1,1
              do i2=-1,1
                do i1=-1,1
                  m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
                end do
              end do
            end do
            else
            m12=1 + ec
            m22=2 + ec
            m32=3 + ec
            endif
            do i3=n3a,n3b
            do i2=n2a,n2b
            do i1=n1a,n1b
!      #If "tt" == "laplacian" || "tt" == "xx"
!      #Elif "tt" == "x"
! endLoops()
            end do
            end do
            end do
            end do
            end do
         else
       !  ***** not rectangular *****
!     #If "tt" == "divScalarGrad"
!     #Else
! beginLoops()
            ! ***** loop over equations and components *****
            do e=ea,eb
            do c=ca,cb
            ec=ns*(c+nc*e)
            ! ** it did not affect performance to use an array to index coeff ***
            if( nd.eq.2 )then
            do i2=-1,1
              do i1=-1,1
               m(i1,i2)=i1+1+3*(i2+1) +1 + ec
              end do
            end do
            else if( nd.eq.3 )then
            do i3=-1,1
              do i2=-1,1
                do i1=-1,1
                  m3(i1,i2,i3)=i1+1+3*(i2+1+3*(i3+1)) +1 + ec
                end do
              end do
            end do
            else
            m12=1 + ec
            m22=2 + ec
            m32=3 + ec
            endif
            do i3=n3a,n3b
            do i2=n2a,n2b
            do i1=n1a,n1b
!      #If "tt" == "laplacian" || "tt" == "xx"
!      #Elif "tt" == "x"
! endLoops()
            end do
            end do
            end do
            end do
            end do
         end if
         else if( nd.eq.0 )then
       !       *** add these lines to avoid warnings about unused statement functions
           include "cgux2afNoWarnings.h"
           temp=rxx1(i1,i2,i3)
         end if
       return
       end
