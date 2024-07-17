!======================================================
! update_metafile from Ensemble Kalman Filter
! Programmed by Y.H. KIM in Apri., 2006
! mailto:yhkim@ocean.snu.ac.kr
! Note : To prepare the Ensemble Kalman Filter
!======================================================

 subroutine update_metafile
 implicit none

 character(256) :: string
 character(80)  :: infile,tfile,iinum,command

 integer        :: status,itstep,nn

 do nn=1,16
 write(iinum,'(I2.2)') nn
 infile='ocean_ens'//trim(iinum)//'.in'
 tfile='tfile'//trim(iinum)//'.in'

 command = 'cp '//trim(infile)//' '//trim(tfile)

 call system(command)

 open(11,file=tfile,status='old')
 open(12,file=infile,status='unknown')

 do
  read(11,'(a)',IOSTAT=status) string
  if(status == -1) exit
  if(string(7:12)=='NTIMES') then
   read(string,'(16X,I8)') itstep
   itstep = itstep + 3360 
   if(itstep<100000) then
     write(12,'(A16,I5)') string(1:16),itstep
   else if(itstep<1000000) then
     write(12,'(A16,I6)') string(1:16),itstep
   else if(itstep<10000000) then
     write(12,'(A16,I7)') string(1:16),itstep
   else if(itstep<100000000) then
     write(12,'(A16,I8)') string(1:16),itstep
   endif
  else
   write(12,'(A)') trim(string)
  endif
 enddo
 command ='rm -f '//trim(tfile) 
 call system(command)

enddo
 end subroutine update_metafile

