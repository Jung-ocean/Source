PROGRAM roms_copy_as_initial
  USE netcdf
  IMPLICIT NONE

  Character(80) :: infile, outfile, command, command_delete
  INTEGER :: day
  INTEGER :: ncid, varid, status
  INTEGER, DIMENSION(2) :: ot

  command = 'ls avg* | tail -1 > tmpfile'
  command_delete = 'rm -f tmpfile'
  CALL system(command)

  OPEN(11, file='tmpfile', status='old')
  READ(11,'(5XI3)') day

  CALL system(command_delete)

  infile = 'rst.nc'
  outfile = 'spinup_ini.nc'

  CALL copy_nc(infile, outfile)

  status = NF90_OPEN(trim(outfile), NF90_WRITE, ncid)
  status = NF90_INQ_VARID(ncid, "ocean_time", varid)
  status = NF90_GET_VAR(ncid, varid, ot)
  status = NF90_PUT_VAR(ncid, varid, ot-60*60*24*day)
  status = NF90_CLOSE(ncid)

  WRITE(*,*) trim(infile)//' --> '//trim(outfile)

END PROGRAM roms_copy_as_initial
