#!/bin/bash

SCHISM_PATH='/data/jungjih/Models/SCHISM/schism/src/Utility/UtilLib/'
NETCDF='/opt/netcdf-4.7.4-intel/'

ifort -c ${SCHISM_PATH}/schism_geometry.f90
ifort -c ${SCHISM_PATH}/extract_mod.f90
ifort -c ${SCHISM_PATH}/compute_zcor.f90
ifort -c ${SCHISM_PATH}/pt_in_poly_test.f90
ifort -c ${SCHISM_PATH}/stripesearch_unstr.f90

ifort -O0 -mcmodel=medium -assume byterecl -CB -g -debug all -traceback -o gen_hot_from_hycom gen_hot_from_hycom.f90 ${SCHISM_PATH}/schism_geometry.f90 ${SCHISM_PATH}/extract_mod.f90 ${SCHISM_PATH}/compute_zcor.f90 ${SCHISM_PATH}/pt_in_poly_test.f90 ${SCHISM_PATH}/stripesearch_unstr.f90 -I$NETCDF/include -I$NETCDF_FORTRAN/include -L$NETCDF_FORTRAN/lib -L$NETCDF/lib -lnetcdf -lnetcdff

rm -f *.o *.mod
