      subroutine duWaveGen2d2ccOLD( 
     *   nd1a,nd1b,nd2a,nd2b,
     *   n1a,n1b,n2a,n2b,
     *   ndf4a,ndf4b,nComp,addForcing,
     *   u,ut,unew,utnew,
     *   rx,src,
     *   dx,dy,dt,cc,
     *   useWhereMask,mask )
c
      implicit real (t)
c
c.. declarations of incoming variables
      integer nd1a,nd1b,nd2a,nd2b
      integer n1a,n1b,n2a,n2b
      integer ndf4a,ndf4b,nComp,addForcing
      integer useWhereMask
      integer mask(nd1a:nd1b,nd2a:nd2b)

      real u    (nd1a:nd1b,nd2a:nd2b,*)
      real ut   (nd1a:nd1b,nd2a:nd2b,*)
      real unew (nd1a:nd1b,nd2a:nd2b)
      real utnew(nd1a:nd1b,nd2a:nd2b)
      real rx   (nd1a:nd1b,nd2a:nd2b,0:1,0:1)
      real src  (nd1a:nd1b,nd2a:nd2b,ndf4a:ndf4b,1:*)
      real dx,dy,dt,cc
c
c.. declarations of local variables
      integer i,j,n
c
      real cg(2,1)

      n = 1

      if( n1a-nd1a .lt. 2 ) then
        write(6,*)'Grid not made with enough ghost cells'
        write(6,*)nd1a,n1a
        stop
      end if
c
      if( addForcing.eq.0 )then
        if( useWhereMask.ne.0 ) then
          do j = n2a,n2b
          do i = n1a,n1b
          if( mask(i,j).gt.0 ) then
c
            include 'secondOrderCurvilinear2DOLD.h'
c     
            unew(i,j)  = cg(1,1)
            utnew(i,j) = cg(2,1)
c
          end if
          end do
          end do
c
        else
          do j = n2a,n2b
          do i = n1a,n1b
c
            include 'secondOrderCurvilinear2DOLD.h'

            unew(i,j)  = cg(1,1)
            utnew(i,j) = cg(2,1)

          end do
          end do
        end if
c
      else 
      ! add forcing flag is set to true
        if( useWhereMask.ne.0 ) then
          do j = n2a,n2b
          do i = n1a,n1b
          if( mask(i,j).gt.0 ) then

            call duStepWaveGen2d2cc_tzOLD( 
     *         nd1a,nd1b,nd2a,nd2b,
     *         n1a,n1b,n2a,n2b,
     *         ndf4a,ndf4b,nComp,
     *         u,ut,unew,utnew,
     *         rx,src,
     *         dx,dy,dt,cc,
     *         i,j,n )
c     
          end if
          end do
          end do

        else
          ! no mask
          do j = n2a,n2b
          do i = n1a,n1b

            call duStepWaveGen2d2cc_tzOLD( 
     *         nd1a,nd1b,nd2a,nd2b,
     *         n1a,n1b,n2a,n2b,
     *         ndf4a,ndf4b,nComp,
     *         u,ut,unew,utnew,
     *         rx,src,
     *         dx,dy,dt,cc,
     *         i,j,n )
c     
          end do
          end do
        end if
      end if
c
      return
      end
