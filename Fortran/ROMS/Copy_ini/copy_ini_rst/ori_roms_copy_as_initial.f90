PROGRAM roms_copy_as_initial
  USE netcdf
  IMPLICIT NONE

  Character(80) :: infile, outfile, command, command_delete
  INTEGER :: zero = 0
  INTEGER :: ncid, varid, status

  command = 'ls avg* | tail -1 > tmpfile'
  command_delete = 'rm -f tmpfile'
  CALL system(command)
  
  OPEN(11, file='tmpfile', status='old')
  READ(11,'(A11)') infile
  outfile = 'spinup_ini.nc'

  CALL copy_nc(infile, outfile)

  status = NF90_OPEN(trim(outfile), NF90_WRITE, ncid)
  status = NF90_INQ_VARID(ncid, "ocean_time", varid)
  status = NF90_PUT_VAR(ncid, varid, zero)
  status = NF90_CLOSE(ncid)

  CALL system(command_delete)
  WRITE(*,*) trim(infile)//' --> '//trim(outfile)

END PROGRAM roms_copy_as_initial
