#
F90 = pgf90
#
DBG = -O
LDFLAGS = ${DBG}
CFLAGS = ${DBG} -I/usr/local/netcdf/432_pgi1510/include
#
KLMOBJS = copy_nc.o roms_copy_as_initial.o
#
llibs = -L/usr/local/netcdf/432_pgi1510/lib -lnetcdf -lnetcdff
#
.SUFFIXES: .o .F .f90
#
.F.o:
	${F90} -Mfreeform ${CFLAGS} -c $<
#
.f90.o:
	${F90} ${CFLAGS} -c $<
#
main: ${KLMOBJS}
	${F90} ${LDFLAGS} -o copy2ROMSini ${KLMOBJS} ${llibs}
#
clean:
	rm -f *.o *.mod *~
