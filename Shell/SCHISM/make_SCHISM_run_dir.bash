#!/bin/bash

casename='noshapiro_dt30_kkl'

source='/scratch1/09793/jjung/v1_SMS_min_5m_3D'

mkdir -p ${casename}/outputs

ln -s ${source}/*.gr3 ./${casename}/
ln -s ${source}/*.in ./${casename}/
ln -s ${source}/*.nc ./${casename}/
ln -s ${source}/*.prop ./${casename}/
ln -s ${source}/sflux ./${casename}/
cp ${source}/myjobscript.bash ./${casename}/
cp ${source}/pschism_FRONTERA_EVAP_VL ./${casename}/
cp ${source}/param_control.nml ./${casename}/

ln -s /scratch1/09793/jjung/${casename}/hgrid.gr3 ./${casename}/hgrid.ll
ln -s /scratch1/09793/jjung/${casename}/param_control.nml ./${casename}/param.nml

