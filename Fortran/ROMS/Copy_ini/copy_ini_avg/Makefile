#
F90 = ifort
#
DBG = -O
LDFLAGS = ${DBG}
CFLAGS = ${DBG} -I/${NETCDF}/include
#
KLMOBJS = copy_nc.o roms_copy_as_initial.o
#
llibs = -L/${NETCDF}/lib -lnetcdf -lnetcdff
#
.SUFFIXES: .o .F .f90
#
.F.o:
	${F90} -free ${CFLAGS} -c $<
#
.f90.o:
	${F90} ${CFLAGS} -c $<
#
main: ${KLMOBJS}
	${F90} ${LDFLAGS} -o copy2ROMSini ${KLMOBJS} ${llibs}
#
clean:
	rm -f *.o *.mod *~
