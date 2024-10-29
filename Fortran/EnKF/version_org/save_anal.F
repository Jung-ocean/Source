!======================================================
! Save Analysis from Ensemble Kalman Filter
! Programmed by Y.H. KIM in Apri., 2006
! mailto:yhkim@kordi.re.kr
! Note : To prepare the Ensemble Kalman Filter
!======================================================

 subroutine save_anal

 use netcdf
 use background, only : index_back,len_xi_rho,len_eta_rho,len_xi_u &
                           ,len_eta_u,len_xi_v,len_eta_v,len_s_rho &
                           ,cs_w,hdepth,iu,iv,izeta,itemp,isalt
 use kalman, only : old_ens,Nsta,Nens,istep

 implicit none

 character(10)      :: var_name

 character(80)      :: enafile,bg_file,outfile,ttext,new_outfile

 integer            :: i,j,k,t,status
 integer            :: ncout
 integer            :: dim_ocean_time
 integer            :: varid_ocean_time, varid_zeta, varid_ubar, varid_vbar
 integer            :: varid_u, varid_v, varid_temp,varid_salt
 integer            :: len_ocean_time
 !real(kind=8),dimension(:) :: ocean_time
 !real(kind=8),allocatable,dimension(:,:,:)  :: zeta_r,ubar_r,vbar_r
 !real(kind=8),allocatable,dimension(:,:,:,:)  :: u_r,v_r,temp_r,salt_r
 !real(kind=8) :: tu,tv,dh_rho,hdepth_u,hdepth_v
 real(kind=8),dimension(len_xi_rho, len_eta_rho           ) :: zeta_r
 real(kind=8),dimension(len_xi_u  , len_eta_u             ) :: ubar_r
 real(kind=8),dimension(len_xi_v  , len_eta_v             ) :: vbar_r
 real(kind=8),dimension(len_xi_rho, len_eta_rho, len_s_rho) :: temp_r, salt_r
 real(kind=8),dimension(len_xi_u  , len_eta_u  , len_s_rho) :: u_r
 real(kind=8),dimension(len_xi_v  , len_eta_v  , len_s_rho) :: v_r
 real(kind=8) :: tu,tv,dh_rho,hdepth_u,hdepth_v,ocean_time

enafile = "ocean_rst_ens_step"
 write(ttext,'(I2.2)') istep
enafile = trim(enafile)//trim(ttext)//'.nc' 

bg_file = "ocean_rst_ens"
 write(ttext,'(I2.2)') 1
 bg_file = trim(bg_file)//trim(ttext)//'_out.nc'
call copy_nc(bg_file, enafile) 

! allocate(ocean_time(Nens))
! allocate(zeta_r(len_xi_rho,len_eta_rho,Nens), &
!          ubar_r(len_xi_u,len_eta_u,Nens), &
!          vbar_r(len_xi_v,len_eta_v,Nens), &
!          u_r(len_xi_u,len_eta_u,len_s_rho,Nens), &
!          v_r(len_xi_v,len_eta_v,len_s_rho,Nens), &
!          temp_r(len_xi_rho,len_eta_rho,len_s_rho,Nens),&
!          salt_r(len_xi_rho,len_eta_rho,len_s_rho,Nens))
 
do t=1,Nens
  do i=1,Nsta
   if(index_back(i,1)==izeta) then
    zeta_r(index_back(i,2),index_back(i,3)) = old_ens(i,t)
   else if(index_back(i,1)==itemp) then
    temp_r(index_back(i,2),index_back(i,3),index_back(i,4))=old_ens(i,t)
   else if(index_back(i,1)==isalt) then
    salt_r(index_back(i,2),index_back(i,3),index_back(i,4))=old_ens(i,t)
   else if(index_back(i,1)==iu) then
    u_r(index_back(i,2),index_back(i,3),index_back(i,4))=old_ens(i,t)
   else if(index_back(i,1)==iv) then
    v_r(index_back(i,2),index_back(i,3),index_back(i,4))=old_ens(i,t)
   endif  
  enddo

  do i=1,len_xi_u
   do j=1,len_eta_u
    tu = 0.0
    hdepth_u = (zeta_r(i,j)+zeta_r(i+1,j))/2.0+(hdepth(i,j)+hdepth(i+1,j))/2.0
    do k=1,len_s_rho
     dh_rho = (cs_w(k+1)-cs_w(k))*hdepth_u
     tu = tu+u_r(i,j,k)*dh_rho
    enddo
    ubar_r(i,j) = tu/hdepth_u
   enddo
  enddo

  do i=1,len_xi_v
   do j=1,len_eta_v
    tv = 0.0
    hdepth_v = (zeta_r(i,j)+zeta_r(i,j+1))/2.0+(hdepth(i,j)+hdepth(i,j+1))/2.0
    do k=1,len_s_rho
     dh_rho = (cs_w(k+1)-cs_w(k))*hdepth_v
     tv = tv+v_r(i,j,k)*dh_rho
    enddo
    vbar_r(i,j) = tv/hdepth_v
   enddo
  enddo

ocean_time = t

  status = NF90_OPEN(enafile,NF90_WRITE,ncout)
  var_name='ocean_time'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_ocean_time)
  status = NF90_PUT_VAR(ncout,varid_ocean_time,ocean_time,start=(/t/))
  var_name='zeta'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_zeta)
  status = NF90_PUT_VAR(ncout,varid_zeta,zeta_r(:,:),start=(/1,1,t/),count=(/len_xi_rho,len_eta_rho,1/))
  var_name='ubar'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_ubar)
  status = NF90_PUT_VAR(ncout,varid_ubar,ubar_r(:,:),start=(/1,1,t/),count=(/len_xi_u,len_eta_u,1/))
  var_name='vbar'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_vbar)
  status = NF90_PUT_VAR(ncout,varid_vbar,vbar_r(:,:),start=(/1,1,t/),count=(/len_xi_v,len_eta_v,1/))
  var_name='u'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_u)
  status = NF90_PUT_VAR(ncout,varid_u,u_r(:,:,:),start=(/1,1,1,t/),count=(/len_xi_u,len_eta_u,len_s_rho,1/))
  var_name='v'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_v)
  status = NF90_PUT_VAR(ncout,varid_v,v_r(:,:,:),start=(/1,1,1,t/),count=(/len_xi_v,len_eta_v,len_s_rho,1/))
  var_name='temp'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_temp)
  status = NF90_PUT_VAR(ncout,varid_temp,temp_r(:,:,:),start=(/1,1,1,t/),count=(/len_xi_rho,len_eta_rho,len_s_rho,1/))
 var_name='salt'
  status = NF90_INQ_VARID(ncout,trim(var_name),varid_salt)
  status = NF90_PUT_VAR(ncout,varid_salt,salt_r(:,:,:),start=(/1,1,1,t/),count=(/len_xi_rho,len_eta_rho,len_s_rho,1/))
  status = NF90_CLOSE(ncout)

!do i=1,Nens
  outfile='ocean_rst_ens'
  write(ttext,'(I2.2)') t
  outfile=trim(outfile)//trim(ttext)//'_in.nc'
  
call copy_nc(bg_file,outfile)

  status = NF90_OPEN(outfile,NF90_WRITE,ncout)
  status = NF90_INQ_DIMID(ncout,"ocean_time",dim_ocean_time)
  status = NF90_INQUIRE_DIMENSION(ncout,dim_ocean_time,var_name,len_ocean_time)
  status = NF90_CLOSE(ncout)
do i=1,len_ocean_time
 status = NF90_OPEN(outfile,NF90_WRITE,ncout)
 ! status = NF90_INQ_VARID(ncout,"ocean_time",varid_ocean_time)
  status = NF90_INQ_VARID(ncout,"zeta",varid_zeta)
  status = NF90_INQ_VARID(ncout,"ubar",varid_ubar)
  status = NF90_INQ_VARID(ncout,"vbar",varid_vbar)
  status = NF90_INQ_VARID(ncout,"u",varid_u)
  status = NF90_INQ_VARID(ncout,"v",varid_v)
  status = NF90_INQ_VARID(ncout,"temp",varid_temp)
  status = NF90_INQ_VARID(ncout,"salt",varid_salt)
  
!do t=1,len_ocean_time
  status = NF90_PUT_VAR(ncout,varid_zeta,zeta_r(:,:),start=(/1,1,i/),count=(/len_xi_rho,len_eta_rho,1/))
  status = NF90_PUT_VAR(ncout,varid_ubar,ubar_r(:,:),start=(/1,1,i/),count=(/len_xi_u,len_eta_u,1/))
  status = NF90_PUT_VAR(ncout,varid_vbar,vbar_r(:,:),start=(/1,1,i/),count=(/len_xi_v,len_eta_v,1/))
  status = NF90_PUT_VAR(ncout,varid_u,u_r(:,:,:),start=(/1,1,1,i/),count=(/len_xi_u,len_eta_u,len_s_rho,1/))
  status = NF90_PUT_VAR(ncout,varid_v,v_r(:,:,:),start=(/1,1,1,i/),count=(/len_xi_v,len_eta_v,len_s_rho,1/))
  status = NF90_PUT_VAR(ncout,varid_temp,temp_r(:,:,:),start=(/1,1,1,i/),count=(/len_xi_rho,len_eta_rho,len_s_rho,1/))
  status = NF90_PUT_VAR(ncout,varid_salt,salt_r(:,:,:),start=(/1,1,1,i/),count=(/len_xi_rho,len_eta_rho,len_s_rho,1/))
!enddo
  status = NF90_CLOSE(ncout)
enddo 
!write(*,*)ocean_time
  new_outfile='ocean_rst_ens'
  write(ttext,'(I2.2)') t
  new_outfile=trim(new_outfile)//trim(ttext)//'_out.nc'
  call copy_nc(outfile,new_outfile)
enddo
!write(*,*)"1"
!deallocate(zeta_r,ubar_r, vbar_r, u_r, v_r, temp_r, salt_r)
!write(*,*)"2"
end subroutine save_anal

 subroutine handle_err(status)

 use netcdf

 integer, intent ( in) :: status
     
  if(status /= nf90_noerr) then
   print *, trim(nf90_strerror(status))
   stop "Stopped"
  end if
 end subroutine handle_err

