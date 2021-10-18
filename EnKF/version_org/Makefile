#
F90	= pgf90 
# for Sparc and Ultrasparc
DBG	=  -O
#DBG	= -q32 -O3 -qarch=pwr5 -qtune=pwr5 -qstrict -bmaxdata:0x80000000#
LDFLAGS = ${DBG}
CFLAGS = ${DBG} -I/usr/local/netcdf/432_pgi1510/include
#
KLMOBJS   = copy_nc.o kalman.o get_observation_all.o get_background_new.o  distance.o  save_anal.o main_all.o update_init.o  cubic_spline.o save_ini.o
#
#IBM
llibs=  -L/usr/local/netcdf/432_pgi1510/lib -lnetcdff -lnetcdf
#
.SUFFIXES: .o .f .F
#
.f.o: 
	${F90} -c ${CFLAGS} $*.f
#
.F.o:
	${F90} -Mfreeform ${CFLAGS} -c $<
#
main: ${KLMOBJS}
	${F90} ${LDFLAGS} -o enkf_10km_ana ${KLMOBJS} $(llibs) 
#
clean: 
	rm -f *.o *.mod *~

