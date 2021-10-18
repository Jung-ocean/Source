!======================================================
! Save Analysis from Ensemble Kalman Filter
! Programmed by Y.H. KIM in Apri., 2006
! mailto:yhkim@ocean.snu.ac.kr
! Note : To prepare the Ensemble Kalman Filter
!======================================================

 subroutine copy_nc(infile,outfile)

 character(80) :: infile,outfile
 character(256) :: command

 command = 'cp '//trim(infile)//' '//trim(outfile)

 call system(command)
 end subroutine copy_nc

 subroutine copy_nc1(infile,outfile)

 use netcdf

 implicit none

 character(10)      :: var_name,dim_name

 character(80), intent(in) :: infile,outfile

 integer            :: i,t,status
 integer            :: ncin,ncout,tvarid,tdimid
 integer            :: num_dim,num_var,num_att,num_unlvar,num_form
 integer            :: xlen, ylen, zlen, tlen
 integer            :: xtype,ndims,nAtts
 integer,allocatable,dimension(:) :: varid, var_att
 integer,allocatable,dimension(:) :: dimid, dim_len, dimids
 character(len=80) :: att_name
 character(len=256)                     :: var_char
 real(8),allocatable,dimension(:)       :: var_double_1d
 real(8),allocatable,dimension(:,:,:,:) :: var_double
 integer,allocatable,dimension(:,:,:,:) :: var_int

 status = NF90_OPEN(infile,NF90_NOWRITE,ncin)
 call handle_err(status) 

 status = NF90_CREATE(outfile,NF90_NOCLOBBER,ncout)

 status = NF90_INQUIRE(ncin,num_dim,num_var,num_att,num_unlvar)

 allocate(varid(num_var),var_att(num_var),dimid(num_dim),dim_len(num_dim))

 do i=1,num_dim
  status = NF90_INQUIRE_DIMENSION(ncin,i,dim_name,dim_len(i))
  call handle_err(status)
  tdimid = i
  if(i==num_unlvar) status = NF90_DEF_DIM(ncout,dim_name,NF90_UNLIMITED,tdimid)
  status = NF90_DEF_DIM(ncout,dim_name,dim_len(i),tdimid)
  write(*,*) i,tdimid,dim_name,dim_len(i),status,NF90_NOERR
  call handle_err(status)
 enddo

 do i=1,num_var
  status = NF90_INQUIRE_VARIABLE(ncin, i, var_name, xtype, ndims)
  allocate(dimids(ndims))
  status = NF90_INQUIRE_VARIABLE(ncin, i, var_name, xtype, ndims, dimids, nAtts)
  status = NF90_DEF_VAR(ncout,var_name,xtype,dimids,tvarid)
  write(*,*) var_name,tvarid
  do t=1,nAtts
    status = NF90_INQ_ATTNAME(ncin,i,t,att_name)
    status = NF90_COPY_ATT(ncin,i,trim(att_name),ncout,varid(i))
  enddo
  deallocate(dimids)
 enddo
 status = NF90_INQUIRE_VARIABLE(ncin,NF90_GLOBAL,nAtts=nAtts)
 do t=1,nAtts
    status = NF90_INQ_ATTNAME(ncin,NF90_GLOBAL,t,att_name)
    status = NF90_COPY_ATT(ncin,NF90_GLOBAL,trim(att_name),ncout,NF90_GLOBAL)
 enddo

 status = NF90_ENDDEF(ncout)

 do i=1,num_var
  status = NF90_INQUIRE_VARIABLE(ncin, i, var_name, xtype, ndims)

  allocate(dimids(ndims))
  status = NF90_INQUIRE_VARIABLE(ncin, i, var_name, xtype, ndims, dimids, nAtts)

  xlen = 1
  ylen = 1
  zlen = 1
  tlen = 1
  if(ndims == 0) then
  else if(ndims == 1) then
    xlen = dim_len(dimids(1))
  else if(ndims == 2) then
    xlen = dim_len(dimids(1))
    ylen = dim_len(dimids(2))
  else if(ndims == 3) then
    xlen = dim_len(dimids(1))
    ylen = dim_len(dimids(2))
    zlen = dim_len(dimids(3))
  else if(ndims == 4) then
    xlen = dim_len(dimids(1))
    ylen = dim_len(dimids(2))
    zlen = dim_len(dimids(3))
    tlen = dim_len(dimids(4))
  else
    write(*,*) 'Too many dims'
    exit
  endif

  status = NF90_INQUIRE_VARIABLE(ncin, i, var_name, xtype, ndims, dimids, nAtts)
  if(xtype == NF90_CHAR) then
!    write(*,*) var_name, 'Char_Type'
    status = NF90_GET_VAR(ncin,i,var_char)
    status = NF90_PUT_VAR(ncout,varid(i),trim(var_char))
  else if(xtype == NF90_DOUBLE) then
    allocate(var_double(xlen,ylen,zlen,tlen))
    status = NF90_GET_VAR(ncin,i,var_double)
    status = NF90_PUT_VAR(ncout,varid(i),var_double)
    if(ndims == 2) write(*,*) var_name,i,varid(i)
    deallocate(var_double)
  else if(xtype == NF90_INT) then
!    write(*,*) var_name, 'Int_Type'
    allocate(var_int(xlen,ylen,zlen,tlen))
    status = NF90_GET_VAR(ncin,i,var_int)
    status = NF90_PUT_VAR(ncout,varid(i),var_int)
    deallocate(var_int)
  else
     write(*,*) 'There is no data type, Please code again!!!'
     exit
  endif
  deallocate(dimids)
!  write(*,*) var_name, xtype
 enddo

 status = NF90_CLOSE(ncin)
 status = NF90_CLOSE(ncout)

 end subroutine copy_nc1

 subroutine handle_err(status)
   use netcdf
   integer, intent ( in) :: status
     
   if(status /= nf90_noerr) then
     print *, trim(nf90_strerror(status))
     stop "Stopped"
   end if
 end subroutine handle_err

