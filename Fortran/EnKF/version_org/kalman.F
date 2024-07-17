!
! Common blocks for Kalman filter program
!
! dimensions of model state vector

    module kalman
     implicit none
     save

      real(kind=8), parameter :: KLM_TLRNC=1.e-4

      integer, parameter :: Nens = 16, ss_dim=Nens
      integer, parameter :: Nobsmax=70

      integer            :: istep
      integer            :: Imean=1, Irms=2, Indq1=1
      integer            :: Delta_ass, ass_start, delta_lin
      integer            :: Nsta

      integer :: nceofid, vareofid(5),varrefid(5),exit_flag,ncrefid,&
             nceofid2,vareofid2(5),nceofid3,vareofid3(5),ncrefid2,&
             varrefid2(5)

      real(kind=8),parameter    :: cinf=100000.0d0,hinf=500.0d0
      real(kind=8), allocatable, dimension(:,:) :: old_ens
      real(kind=8), allocatable, dimension(:) :: stmean,stgref,strms
             
      character(80) ::  eofname,refname,refname2
      character(45) ::  vname_kalm(5,3)
      character(45) ::  vname_ref(5)

    end module kalman

