!======================================================
! Save Initial before Ensemble Kalman Filter
! Note : To prepare the Ensemble Kalman Filter
!======================================================

 subroutine save_ini
 use kalman, only : istep, Nens

 implicit none

 character(80) :: initial_file,next_file, ini_file,zip_file, before_file , ttext, ntext,command1
 integer :: ii
 ini_file = 'ocean_rst_ens'
 zip_file = 'before_ens'
 write(ntext,'(I2.2)') istep
 do ii=1,Nens
   write(ttext,'(I2.2)') ii
   initial_file = trim(ini_file)//trim(ttext)//'_out.nc'
   next_file = trim(zip_file)//trim(ttext)//'_step'//trim(ntext)//'_ini.nc' 
   call copy_nc(initial_file, next_file)
 enddo

 before_file ='ini_bg'
 before_file = trim(before_file)//trim(ntext)//'step.tar.gz'
 command1='tar zcvf '//trim(before_file)//' *_ini.nc'
 call system(command1)

 end subroutine save_ini


