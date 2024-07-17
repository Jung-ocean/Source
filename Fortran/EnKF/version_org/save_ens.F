!======================================================
! Save Initial before Ensemble Kalman Filter
! Note : To prepare the Ensemble Kalman Filter
!======================================================

 subroutine save_ens

 use kalman, only : istep, Nens

 implicit none

 character(80) :: ini_file,re_file,rzip_file, zip_file, after_file , ttext, ntext,command2
 integer :: ii

 ini_file = 'ocean_rst_ens'
 zip_file = 'after_ens'
 write(ntext,'(I2.2)') istep
 do ii=1,Nens
   write(ttext,'(I2.2)') ii
   re_file = trim(ini_file)//trim(ttext)//'_in.nc'
   rzip_file = trim(zip_file)//trim(ttext)//'_step'//trim(ntext)//'_result.nc' 
   call copy_nc(re_file, rzip_file)
 enddo

 after_file ='result_bg'
 after_file = trim(after_file)//trim(ntext)//'step.tar.gz'
 command2='tar zcvf '//trim(after_file)//' *_result.nc'
 call system(command2)

 end subroutine save_ens


