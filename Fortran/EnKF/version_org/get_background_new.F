!======================================================
! module background
! Programmed by Y.H. KIM in Apri., 2006
! Modified by G H SEO in JUNE., 2009
! Note : To prepare the Ensemble Kalman Filter
!======================================================

 module background
 use kalman, only : Nens,old_ens,Nsta
 implicit none
 save
 integer,parameter  :: num_zlen=4
 integer,parameter  :: izeta=1,itemp=2,isalt=3,iu=4,iv=5
 logical, parameter :: ana = .false.
 integer, allocatable, dimension(:,:) :: index_back
 integer            :: len_xi_rho,len_eta_rho,len_ocean_time,len_xi_u,hc
 integer            :: len_eta_u,len_xi_v,len_eta_v,len_s_rho,len_s_w
 real(kind=8),allocatable,dimension(:)   :: cs_r,cs_w,s_rho
 real(kind=8),allocatable,dimension(:,:) :: hdepth
 real(kind=8),allocatable,dimension(:,:) :: zeta_r
 real(kind=8),allocatable,dimension(:,:) :: lon_rho,lat_rho,lon_u,lat_u,lon_v,lat_v 

!============================================================
! Background field at Observation Position
!------------------------------------------------------------
 real(8),allocatable,dimension(:,:) :: bdata_obs
!============================================================


 contains
 
 subroutine get_background_new

 use netcdf

!============================================================
! Use module observation
!------------------------------------------------------------
 use observation, only : lon_obs,lat_obs,depth_obs,ind_obs &
                         ,Nobs
!============================================================

 implicit none

 character(10)      :: var_name
 character(30)      :: grd_name
 character(80)      :: infile, gfile, ttext, bg_file

 integer            :: i,j,k,inum
 integer            :: ncgin, ncgrd, ncrin, status, t, tt
 integer            :: dim_xi_rho,dim_eta_rho,dim_ocean_time,dim_xi_u
 integer            :: dim_eta_u, dim_xi_v, dim_eta_v, dim_s_rho,dim_s_w
 integer            :: varid_s_rho,varid_s_w
 integer            :: varid_zeta,varid_ubar,varid_vbar,varid_u,varid_v
 integer            :: varid_temp,varid_salt,varid_rho,varid_h
 integer            :: varid_mask_u, varid_mask_v, varid_mask_rho
 integer            :: varid_lon_rho,varid_lon_u,varid_lon_v
 integer            :: varid_lat_rho,varid_lat_u,varid_lat_v
 integer            :: varid_csr,varid_csw,varid_hc

 real(kind=8),allocatable,dimension(:,:,:)  :: u_r,v_r,temp_r,salt_r
 real(kind=8),allocatable,dimension(:,:)    :: zeta_t
 integer, allocatable, dimension(:,:) :: mask_rho, mask_u, mask_v

!============================================================
! Define variable for Interpolation routine
!------------------------------------------------------------

real(kind=8)             :: interp
integer             :: len_x, len_y, len_z
real(kind=8)             :: aa, t1, t2, t3_11, t3_12, t3_21, t3_22
real(kind=8)             :: sigma, h11, h12, h21, h22, z11, z12, z21, z22
integer             :: n
integer             :: lat_1, lat_2, lon_1, lon_2, s_11u, s_12u
integer             :: s_21u, s_22u, s_11d, s_12d, s_21d, s_22d
integer             :: mask11,mask12,mask21,mask22
real(kind=8)             :: s11, s12, s21, s22, d11u, d11d, d12u, d12d, d21u, d21d, d22u, d22d

!============================================================
 grd_name = 'roms_grid_10km.nc'
 gfile = 'ocean_rst_ens'
 write(ttext,'(I2.2)') 1
 gfile = trim(gfile)//trim(ttext)//'_out.nc'
 write(*,*) grd_name,gfile 
 status = NF90_OPEN(gfile,NF90_NOWRITE,ncgin)
 if(status/=nf90_noerr) call handle_err(status) 

 status = NF90_INQ_DIMID(ncgin,"xi_rho",dim_xi_rho)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_xi_rho,var_name,len_xi_rho)
 status = NF90_INQ_DIMID(ncgin,"eta_rho",dim_eta_rho)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_eta_rho,var_name,len_eta_rho)
 status = NF90_INQ_DIMID(ncgin,"xi_u",dim_xi_u)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_xi_u,var_name,len_xi_u)
 status = NF90_INQ_DIMID(ncgin,"eta_u",dim_eta_u)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_eta_u,var_name,len_eta_u)
 status = NF90_INQ_DIMID(ncgin,"xi_v",dim_xi_v)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_xi_v,var_name,len_xi_v)
 status = NF90_INQ_DIMID(ncgin,"eta_v",dim_eta_v)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_eta_v,var_name,len_eta_v)
 status = NF90_INQ_DIMID(ncgin,"s_rho",dim_s_rho)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_s_rho,var_name,len_s_rho)
 status = NF90_INQ_DIMID(ncgin,"s_w",dim_s_w)
 status = NF90_INQUIRE_DIMENSION(ncgin,dim_s_w,var_name,len_s_w)

 status = NF90_INQ_VARID(ncgin,"Cs_r",varid_csr)
 status = NF90_INQ_VARID(ncgin,"Cs_w",varid_csw)
 status = NF90_INQ_VARID(ncgin,"hc",varid_hc)
 status = NF90_INQ_VARID(ncgin,"s_rho",varid_s_rho)
 if(status/=nf90_noerr) then
 status = NF90_INQ_VARID(ncgin,"sc_r",varid_s_rho)
 if(status/=nf90_noerr) call handle_err(status)
 endif
 
 allocate(cs_r(len_s_rho),cs_w(len_s_w),s_rho(len_s_rho))
 
 status = NF90_GET_VAR(ncgin,varid_csr,cs_r)
 status = NF90_GET_VAR(ncgin,varid_csw,cs_w)
 status = NF90_GET_VAR(ncgin,varid_hc,hc)
 status = NF90_GET_VAR(ncgin,varid_s_rho,s_rho)

 if(.not.ana) then

  status = NF90_OPEN(grd_name,NF90_NOWRITE,ncgrd)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"lon_rho",varid_lon_rho)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"lat_rho",varid_lat_rho)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"lon_u",varid_lon_u)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"lat_u",varid_lat_u)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"lon_v",varid_lon_v)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"lat_v",varid_lat_v)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"h",varid_h)
if(status/=nf90_noerr) call handle_err(status)

  status = NF90_INQ_VARID(ncgrd,"mask_rho",varid_mask_rho)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"mask_u",varid_mask_u)
if(status/=nf90_noerr) call handle_err(status)
  status = NF90_INQ_VARID(ncgrd,"mask_v",varid_mask_v)
if(status/=nf90_noerr) call handle_err(status)

  allocate(lon_rho(len_xi_rho,len_eta_rho),lat_rho(len_xi_rho,len_eta_rho),&
           lon_u(len_xi_u,len_eta_u),lat_u(len_xi_u,len_eta_u),&
           lon_v(len_xi_v,len_eta_v),lat_v(len_xi_v,len_eta_v),&
           hdepth(len_xi_rho,len_eta_rho))
  allocate(mask_rho(len_xi_rho,len_eta_rho), &
          mask_u(len_xi_u,len_eta_u), &
          mask_v(len_xi_v,len_eta_v))
 
  status = NF90_GET_VAR(ncgrd,varid_lon_rho,lon_rho)
  status = NF90_GET_VAR(ncgrd,varid_lat_rho,lat_rho)
  status = NF90_GET_VAR(ncgrd,varid_lon_u,lon_u)
  status = NF90_GET_VAR(ncgrd,varid_lat_u,lat_u)
  status = NF90_GET_VAR(ncgrd,varid_lon_v,lon_v)
  status = NF90_GET_VAR(ncgrd,varid_lat_v,lat_v)
  status = NF90_GET_VAR(ncgrd,varid_h,hdepth)    
  status = NF90_GET_VAR(ncgrd,varid_mask_rho,mask_rho)
  status = NF90_GET_VAR(ncgrd,varid_mask_u,mask_u)
  status = NF90_GET_VAR(ncgrd,varid_mask_v,mask_v)

  status = NF90_CLOSE(ncgrd)
 endif
 
 status = NF90_CLOSE(ncgin)


Nsta = 0
 if(ana) then
    Nsta = len_xi_rho*len_eta_rho+len_s_rho*(len_xi_u*len_eta_u+len_xi_v*len_eta_v+len_xi_rho*len_eta_rho+len_xi_rho*len_eta_rho)

 else
    inum = 0
    Nsta = 0
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        inum = inum + mask_rho(i,j)
      enddo
    enddo
    Nsta = Nsta + inum*(len_s_rho+1)
    
    inum = 0
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        inum = inum + mask_rho(i,j)
      enddo
    enddo
    Nsta = Nsta + inum*len_s_rho
    
    inum = 0
    do i=1,len_xi_u
      do j=1,len_eta_u
        inum = inum + mask_u(i,j)
      enddo
    enddo
    Nsta = Nsta + inum*len_s_rho
    
    inum = 0
    do i=1,len_xi_v
      do j=1,len_eta_v
        inum = inum + mask_v(i,j)
      enddo
    enddo
    Nsta = Nsta + inum*len_s_rho
 endif
    
 write(6,*) 'Size of State Vectoer : ', Nsta
 write(6,*) 'Size of Ensemble : ', Nens
 allocate(index_back(Nsta,4))
 allocate(old_ens(Nsta,Nens))

 inum = 0
 if(ana) then
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        inum = inum + 1
        index_back(inum,1) = izeta
        index_back(inum,2) = i
        index_back(inum,3) = j
        index_back(inum,4) = len_s_rho
      enddo
    enddo
    do i=1,len_xi_u
      do j=1,len_eta_u
        do k=1,len_s_rho
          inum = inum + 1
          index_back(inum,1) = iu
          index_back(inum,2) = i
          index_back(inum,3) = j
          index_back(inum,4) = k
        enddo
      enddo
    enddo
    do i=1,len_xi_v
      do j=1,len_eta_v
        do k=1,len_s_rho
          inum = inum + 1
          index_back(inum,1) = iv
          index_back(inum,2) = i
          index_back(inum,3) = j
          index_back(inum,4) = k
        enddo
      enddo
    enddo
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        do k=1,len_s_rho
          inum = inum + 1
          index_back(inum,1) = itemp
          index_back(inum,2) = i
          index_back(inum,3) = j
          index_back(inum,4) = k
        enddo
      enddo
    enddo
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        do k=1,len_s_rho
          inum = inum + 1
          index_back(inum,1) = isalt
          index_back(inum,2) = i
          index_back(inum,3) = j
          index_back(inum,4) = k
        enddo
      enddo
    enddo
 else

    inum = 0
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        if(mask_rho(i,j) == 1) then
          inum = inum + 1
          index_back(inum,1) = izeta
          index_back(inum,2) = i
          index_back(inum,3) = j
          index_back(inum,4) = 20
        endif
      enddo
    enddo
    do i=1,len_xi_u
      do j=1,len_eta_u
        do k=1,len_s_rho
          if(mask_u(i,j) == 1) then
            inum = inum + 1
            index_back(inum,1) = iu
            index_back(inum,2) = i
            index_back(inum,3) = j
            index_back(inum,4) = k
          endif
        enddo
      enddo
    enddo
    do i=1,len_xi_v
      do j=1,len_eta_v
        do k=1,len_s_rho
          if(mask_v(i,j) == 1) then
            inum = inum + 1
            index_back(inum,1) = iv
            index_back(inum,2) = i
            index_back(inum,3) = j
            index_back(inum,4) = k
          endif
        enddo
      enddo
    enddo
    do i=1,len_xi_rho
      do j=1,len_eta_rho
        do k=1,len_s_rho
          if(mask_rho(i,j) == 1) then
            inum = inum + 1
            index_back(inum,1) = itemp
            index_back(inum,2) = i
            index_back(inum,3) = j
            index_back(inum,4) = k
          endif
        enddo
      enddo
    enddo
     do i=1,len_xi_rho
      do j=1,len_eta_rho
        do k=1,len_s_rho
          if(mask_rho(i,j) == 1) then
            inum = inum + 1
            index_back(inum,1) = isalt
            index_back(inum,2) = i
            index_back(inum,3) = j
            index_back(inum,4) = k
          endif
        enddo
      enddo
    enddo

 endif
!====================================================
! Allocation the state vector at observation position
!----------------------------------------------------
    allocate(bdata_obs(Nobs,Nens))
!====================================================

 do t=1,Nens
    bg_file = "ocean_rst_ens"
    write(ttext,'(I2.2)') t
    bg_file =trim(bg_file)//trim(ttext)//'_out.nc'
    status = NF90_OPEN(bg_file,NF90_NOWRITE,ncrin)
    if(status/=nf90_noerr) call handle_err(status) 

    status = NF90_INQ_DIMID(ncrin,"xi_rho",dim_xi_rho)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_xi_rho,var_name,len_xi_rho)
    status = NF90_INQ_DIMID(ncrin,"eta_rho",dim_eta_rho)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_eta_rho,var_name,len_eta_rho)
    status = NF90_INQ_DIMID(ncrin,"ocean_time",dim_ocean_time)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_ocean_time,var_name,len_ocean_time)
    status = NF90_INQ_DIMID(ncrin,"xi_u",dim_xi_u)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_xi_u,var_name,len_xi_u)
    status = NF90_INQ_DIMID(ncrin,"eta_u",dim_eta_u)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_eta_u,var_name,len_eta_u)
    status = NF90_INQ_DIMID(ncrin,"xi_v",dim_xi_v)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_xi_v,var_name,len_xi_v)
    status = NF90_INQ_DIMID(ncrin,"eta_v",dim_eta_v)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_eta_v,var_name,len_eta_v)
    status = NF90_INQ_DIMID(ncrin,"s_rho",dim_s_rho)
    status = NF90_INQUIRE_DIMENSION(ncrin,dim_s_rho,var_name,len_s_rho)

    status = NF90_INQ_VARID(ncrin,"zeta",varid_zeta)
    status = NF90_INQ_VARID(ncrin,"u",varid_u)
    status = NF90_INQ_VARID(ncrin,"v",varid_v)
    status = NF90_INQ_VARID(ncrin,"temp",varid_temp)
    status = NF90_INQ_VARID(ncrin,"salt",varid_salt)
    status = NF90_INQ_VARID(ncrin,"rho",varid_rho)
    if(.not.allocated(zeta_r)) then
      allocate(zeta_r(len_xi_rho,len_eta_rho), &
            zeta_t(len_xi_rho,len_eta_rho), &
            u_r(len_xi_u,len_eta_u,len_s_rho), &
            v_r(len_xi_v,len_eta_v,len_s_rho), &
            temp_r(len_xi_rho,len_eta_rho,len_s_rho), &
            salt_r(len_xi_rho,len_eta_rho,len_s_rho))
    endif

    status = NF90_GET_VAR(ncrin,varid_zeta,zeta_t(:,:) &
        ,start=(/1,1,len_ocean_time/),count=(/len_xi_rho,len_eta_rho,1/))
    status = NF90_GET_VAR(ncrin,varid_u,u_r,start=(/1,1,1,len_ocean_time/) &
        ,count=(/len_xi_u,len_eta_u,len_s_rho,1/))
    status = NF90_GET_VAR(ncrin,varid_v,v_r,start=(/1,1,1,len_ocean_time/) &
        ,count=(/len_xi_v,len_eta_v,len_s_rho,1/))
    status = NF90_GET_VAR(ncrin,varid_temp,temp_r(:,:,:),start=(/1,1,1,len_ocean_time/) &
        ,count=(/len_xi_rho,len_eta_rho,len_s_rho,1/))
    status = NF90_GET_VAR(ncrin,varid_salt,salt_r(:,:,:),start=(/1,1,1,len_ocean_time/) &
        ,count=(/len_xi_rho,len_eta_rho,len_s_rho,1/))
    
    status = NF90_CLOSE(ncrin)

    do i=1,Nsta
      if(index_back(i,1) == izeta) then
        old_ens(i,t) = zeta_t(index_back(i,2),index_back(i,3))
      else if(index_back(i,1) == iu) then
        old_ens(i,t) = u_r(index_back(i,2),index_back(i,3),index_back(i,4))
      else if(index_back(i,1) == iv) then
        old_ens(i,t) = v_r(index_back(i,2),index_back(i,3),index_back(i,4))
      else if(index_back(i,1) == itemp) then
        old_ens(i,t) = temp_r(index_back(i,2),index_back(i,3),index_back(i,4))
      else if(index_back(i,1) == isalt) then
        old_ens(i,t) = salt_r(index_back(i,2),index_back(i,3),index_back(i,4))
      endif
    enddo
    zeta_r = zeta_r + zeta_t

!====================================================
! Interpolation routine
!----------------------------------------------------
!      write(*,*) "Interpolation"
    
    do n=1,Nobs
      if (ind_obs(n) == iu) then
        len_x = len_xi_u
        len_y = len_eta_u
        len_z = len_s_rho

      elseif (ind_obs(n) == iv) then
        len_x = len_xi_v
        len_y = len_eta_v
        len_z = len_s_rho

      else
        len_x = len_xi_rho
        len_y = len_eta_rho
        len_z = len_s_rho

        if (ind_obs(n) == izeta) len_z = 0

       endif

      do i=1,len_x
        if (lon_rho(i,1) <= lon_obs(n)) then
 
              lon_1 = i
              lon_2 = i+1
       endif
      enddo
      do j=1,len_y
        if (lat_rho(1,j) <= lat_obs(n)) then
              lat_1 = j
              lat_2 = j+1
        endif
      enddo
!     write(*,*) "End of Interpolartion"
!------------------------------- initial -------------------------------      
         z11 = zeta_r(lon_1,lat_1)
         z12 = zeta_r(lon_1,lat_2)
         z21 = zeta_r(lon_2,lat_1)
         z22 = zeta_r(lon_2,lat_2)
         h11 = hdepth(lon_1,lat_1)
         h12 = hdepth(lon_1,lat_2)
         h21 = hdepth(lon_2,lat_1)
         h22 = hdepth(lon_2,lat_2)
	 i=1
         d11u = -cs_r(i+1)*(h11-hc) -s_rho(i+1)*hc +z11*(1+s_rho(i+1))
         d11d = -cs_r(i)*(h11-hc) -s_rho(i)*hc +z11*(1+s_rho(i))
         d12u = -cs_r(i+1)*(h12-hc) -s_rho(i+1)*hc +z12*(1+s_rho(i+1))
         d12d = -cs_r(i)*(h12-hc) -s_rho(i)*hc +z12*(1+s_rho(i))
         d21u = -cs_r(i+1)*(h21-hc) -s_rho(i+1)*hc +z21*(1+s_rho(i+1))
         d21d = -cs_r(i)*(h21-hc) -s_rho(i)*hc +z21*(1+s_rho(i))
         d22u = -cs_r(i+1)*(h22-hc) -s_rho(i+1)*hc +z22*(1+s_rho(i+1))
         d22d = -cs_r(i)*(h22-hc) -s_rho(i)*hc +z22*(1+s_rho(i))

         s_11u = i+1
         s_11d = i
         t3_11 = (depth_obs(n) - d11u) / (d11d - d11u)
         s_12u = i+1
         s_12d = i
         t3_12 = (depth_obs(n) - d12u) / (d12d - d12u)
         s_21u = i+1
         s_21d = i
         t3_21 = (depth_obs(n) - d21u) / (d21d - d21u)
         s_22u = i+1
         s_22d = i
         t3_22 = (depth_obs(n) - d22u) / (d22d - d22u)

!--------------------------------------------------------------------------
if (ind_obs(n) == izeta) then
        t1 = (lon_obs(n) - lon_rho(lon_1,1)) / (lon_rho(lon_2,1) - lon_rho(lon_1,1))
        t2 = (lat_obs(n) - lat_rho(1,lat_1)) / (lat_rho(1,lat_2) - lat_rho(1,lat_1))
        interp = (1-t1)*(1-t2)*zeta_r(lon_1,lat_1) &
           + t1*(1-t2)*zeta_r(lon_2,lat_1) &
           + t1*t2*zeta_r(lon_2,lat_2) &
           + (1-t1)*t2*zeta_r(lon_1,lat_2)

elseif (ind_obs(n) == itemp) then
do i=1,len_z-1
         d11u = -cs_r(i+1)*(h11-hc) -s_rho(i+1)*hc +z11*(1+s_rho(i+1))
         d11d = -cs_r(i)*(h11-hc) -s_rho(i)*hc +z11*(1+s_rho(i))
         d12u = -cs_r(i+1)*(h12-hc) -s_rho(i+1)*hc +z12*(1+s_rho(i+1))
         d12d = -cs_r(i)*(h12-hc) -s_rho(i)*hc +z12*(1+s_rho(i))
         d21u = -cs_r(i+1)*(h21-hc) -s_rho(i+1)*hc +z21*(1+s_rho(i+1))
         d21d = -cs_r(i)*(h21-hc) -s_rho(i)*hc +z21*(1+s_rho(i))
         d22u = -cs_r(i+1)*(h22-hc) -s_rho(i+1)*hc +z22*(1+s_rho(i+1))
         d22d = -cs_r(i)*(h22-hc) -s_rho(i)*hc +z22*(1+s_rho(i))
           if (d11d >= depth_obs(n)) then
                      s_11u = i+1
                      s_11d = i
                      t3_11 = (depth_obs(n) - d11u) / (d11d - d11u)
              endif
              if (d12d >= depth_obs(n)) then
                      s_12u = i+1
                      s_12d = i
                      t3_12 = (depth_obs(n) - d12u) / (d12d - d12u) 
              endif
              if (d21d >= depth_obs(n)) then
                      s_21u = i+1
                      s_21d = i
                      t3_21 = (depth_obs(n) - d21u) / (d21d - d21u)
              endif
              if (d22d >= depth_obs(n)) then
                      s_22u = i+1
                      s_22d = i
                      t3_22 = (depth_obs(n) - d22u) / (d22d - d22u) 
              endif
 enddo
       s11 = t3_11*temp_r(lon_1,lat_1,s_11d)+(1-t3_11)*temp_r(lon_1,lat_1,s_11u)
       s12 = t3_12*temp_r(lon_1,lat_2,s_12d)+(1-t3_12)*temp_r(lon_1,lat_2,s_12u)
       s21 = t3_21*temp_r(lon_2,lat_1,s_21d)+(1-t3_21)*temp_r(lon_2,lat_1,s_21u)
       s22 = t3_22*temp_r(lon_2,lat_2,s_22d)+(1-t3_22)*temp_r(lon_2,lat_2,s_22u)
       if (depth_obs(n) == 0) then
        s11 = temp_r(lon_1,lat_1,len_z)
        s12 = temp_r(lon_1,lat_2,len_z)
        s21 = temp_r(lon_2,lat_1,len_z)
        s22 = temp_r(lon_2,lat_2,len_z)
       endif
        t1 = (lon_obs(n) - lon_rho(lon_1,1)) / (lon_rho(lon_2,1) - lon_rho(lon_1,1))
        t2 = (lat_obs(n) - lat_rho(1,lat_1)) / (lat_rho(1,lat_2) - lat_rho(1,lat_1))
        interp = (1-t1)*(1-t2)*s11 + t1*(1-t2)*s21 + t1*t2*s22 + (1-t1)*t2*s12
elseif (ind_obs(n) == isalt) then
        do i=1,len_z-1
           z11 = zeta_r(lon_1,lat_1)
           z12 = zeta_r(lon_1,lat_2)
           z21 = zeta_r(lon_2,lat_1)
           z22 = zeta_r(lon_2,lat_2)
           h11 = hdepth(lon_1,lat_1)
           h12 = hdepth(lon_1,lat_2)
           h21 = hdepth(lon_2,lat_1)
           h22 = hdepth(lon_2,lat_2)
           d11u = -cs_r(i+1)*(h11-hc) -s_rho(i+1)*hc +z11*(1+s_rho(i+1))
           d11d = -cs_r(i)*(h11-hc) -s_rho(i)*hc +z11*(1+s_rho(i))
           d12u = -cs_r(i+1)*(h12-hc) -s_rho(i+1)*hc +z12*(1+s_rho(i+1))
           d12d = -cs_r(i)*(h12-hc) -s_rho(i)*hc +z12*(1+s_rho(i))
           d21u = -cs_r(i+1)*(h21-hc) -s_rho(i+1)*hc +z21*(1+s_rho(i+1))
           d21d = -cs_r(i)*(h21-hc) -s_rho(i)*hc +z21*(1+s_rho(i))
           d22u = -cs_r(i+1)*(h22-hc) -s_rho(i+1)*hc +z22*(1+s_rho(i+1))
           d22d = -cs_r(i)*(h22-hc) -s_rho(i)*hc +z22*(1+s_rho(i))
              if (d11d >= depth_obs(n)) then
                      s_11u = i+1
                      s_11d = i
                      t3_11 = (depth_obs(n) - d11u) / (d11d - d11u)
              endif

              if (d12d >= depth_obs(n)) then
                      s_12u = i+1
                      s_12d = i
                      t3_12 = (depth_obs(n) - d12u) / (d12d - d12u) 
              endif

              if (d21d >= depth_obs(n)) then
                      s_21u = i+1
                      s_21d = i
                      t3_21 = (depth_obs(n) - d21u) / (d21d - d21u)
              endif

              if (d22d >= depth_obs(n)) then
                      s_22u = i+1
                      s_22d = i
                      t3_22 = (depth_obs(n) - d22u) / (d22d - d22u) 
              endif
        enddo
        s11 = t3_11*salt_r(lon_1,lat_1,s_11d)+(1-t3_11)*salt_r(lon_1,lat_1,s_11u)
        s12 = t3_12*salt_r(lon_1,lat_2,s_12d)+(1-t3_12)*salt_r(lon_1,lat_2,s_12u)
        s21 = t3_21*salt_r(lon_2,lat_1,s_21d)+(1-t3_21)*salt_r(lon_2,lat_1,s_21u)
        s22 = t3_22*salt_r(lon_2,lat_2,s_22d)+(1-t3_22)*salt_r(lon_2,lat_2,s_22u)
        
        if (depth_obs(n) == 0) then
        s11 = salt_r(lon_1,lat_1,len_z)
        s12 = salt_r(lon_1,lat_2,len_z)
        s21 = salt_r(lon_2,lat_1,len_z)
        s22 = salt_r(lon_2,lat_2,len_z)
        endif
        
        t1 = (lon_obs(n) - lon_rho(lon_1,1)) / (lon_rho(lon_2,1) - lon_rho(lon_1,1))
        t2 = (lat_obs(n) - lat_rho(1,lat_1)) / (lat_rho(1,lat_2) - lat_rho(1,lat_1))
        interp = (1-t1)*(1-t2)*s11 + t1*(1-t2)*s21 + t1*t2*s22 + (1-t1)*t2*s12
      endif
      bdata_obs(n,t) = interp
    enddo
!====================================================
 enddo
 zeta_r = zeta_r/Nens
 deallocate(u_r, v_r, temp_r, salt_r, zeta_t)

 if(.not.ana) deallocate(mask_rho,mask_u,mask_v)
 end subroutine get_background_new
 
 subroutine handle_err(status)

 use netcdf

 integer, intent ( in) :: status
     
  if(status /= nf90_noerr) then
   print *, trim(nf90_strerror(status))
   stop "Stopped"
  end if
 end subroutine handle_err

 end module background

