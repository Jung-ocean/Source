!======================================================
! module observation
! Programmed by Y.H. KIM in Apri., 2006
! Note : To prepare the Ensemble Kalman Filter
! Edit : GHSEO in CNU // seogwangho@gmail.com
!======================================================

 module observation
 use kalman, only : Nens
 implicit none
 save
 integer :: Nobs, Nloc
 real(8),allocatable,dimension(:) :: lon_obs,lat_obs,depth_obs,obsdata,obserr
 integer,allocatable,dimension(:) :: ind_obs
 
 contains
 
 subroutine get_observation(tindex,idx_loof)

 use netcdf

 implicit none

 character(10)      :: var_name
 character(32)      :: infile
 character(14)      :: inpath
 character(10)      :: cidx,bidx

 integer, intent(in) :: tindex,idx_loof
 integer            :: i,k
 integer            :: ncgin, status
 integer            :: dim_xi_rho
 integer            :: len_x
 integer            :: varid_obsdata,varid_ind,varid_ndata
 integer            :: varid_rlon, varid_rlat, varid_rdepth, varid_obserr
 integer,allocatable,dimension(:) :: len_xx

 allocate(len_xx(1))

 !infile = 'observation.nc'
 write(cidx,'(i3.3)') tindex
 write(bidx,'(i3.3)') idx_loof
 inpath = './observation/'
 infile = inpath//'all_obs_'//trim(cidx)//'_'//trim(bidx)//'.nc'
 write(*,*) infile
 
 !ttindex=tindex/tindex
 
 status = NF90_OPEN(infile,NF90_NOWRITE,ncgin)
 if(status/=nf90_noerr) call handle_err(status) 

 !status = NF90_INQ_DIMID(ncgin,"rlon",dim_xi_rho)
 !status = NF90_INQUIRE_DIMENSION(ncgin,dim_xi_rho,var_name,len_x)

 status = NF90_INQ_VARID(ncgin,"ndata",varid_ndata)
 
 status = NF90_INQ_VARID(ncgin,"rlon",varid_rlon)
 status = NF90_INQ_VARID(ncgin,"rlat",varid_rlat)
 status = NF90_INQ_VARID(ncgin,"rdepth",varid_rdepth)
 status = NF90_INQ_VARID(ncgin,"obsdata",varid_obsdata)
 status = NF90_INQ_VARID(ncgin,"obserr",varid_obserr)
 status = NF90_INQ_VARID(ncgin,"dindex",varid_ind)

 !status = NF90_GET_VAR(ncgin,varid_ndata,len_xx,start=(/ttindex/),count=(/1/))
 status = NF90_GET_VAR(ncgin,varid_ndata,len_xx,start=(/1/),count=(/1/))

 len_x = len_xx(1)

 write(6,*) 'Number of Observation : ', len_x
 
 Nobs = len_x
 Nloc = len_x 

 allocate(lon_obs(Nobs),lat_obs(Nobs),depth_obs(Nobs),obsdata(Nobs),obserr(Nobs),ind_obs(Nobs))
 ! 2D
 !status = NF90_GET_VAR(ncgin,varid_rlon,lon_obs,start=(/1,ttindex/),count=(/len_x,1/))
 !status = NF90_GET_VAR(ncgin,varid_rlat,lat_obs,start=(/1,ttindex/),count=(/len_x,1/))
 !status = NF90_GET_VAR(ncgin,varid_rdepth,depth_obs,start=(/1,ttindex/),count=(/len_x,1/))
 !status = NF90_GET_VAR(ncgin,varid_obsdata,obsdata,start=(/1,ttindex/),count=(/len_x,1/))
 !status = NF90_GET_VAR(ncgin,varid_ind,ind_obs,start=(/1,ttindex/),count=(/len_x,1/))

 ! 1D
 status = NF90_GET_VAR(ncgin,varid_rlon,lon_obs,start=(/1/),count=(/len_x/))
 status = NF90_GET_VAR(ncgin,varid_rlat,lat_obs,start=(/1/),count=(/len_x/))
 status = NF90_GET_VAR(ncgin,varid_rdepth,depth_obs,start=(/1/),count=(/len_x/))
 status = NF90_GET_VAR(ncgin,varid_obsdata,obsdata,start=(/1/),count=(/len_x/))
 status = NF90_GET_VAR(ncgin,varid_obserr,obserr,start=(/1/),count=(/len_x/))
 status = NF90_GET_VAR(ncgin,varid_ind,ind_obs,start=(/1/),count=(/len_x/))
 
 status = NF90_CLOSE(ncgin)
 
 ! write(*,'(10f6.2)')  obsdata
 end subroutine get_observation
 
 subroutine handle_err(status)

 use netcdf

 integer, intent (in) :: status
     
  if(status /= nf90_noerr) then
   print *, trim(nf90_strerror(status))
   stop "Stopped"
  end if
 end subroutine handle_err

 end module observation
