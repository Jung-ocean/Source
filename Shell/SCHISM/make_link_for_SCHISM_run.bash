#!/bin/bash

path_grid='/data/jungjih/Models/SCHISM/test_schism/v2_JZ'
path_gen_input='../2024.04.17-16:16:02___v1_SMS_min_5m_3D'

ln -s ${path_grid}/hgrid.gr3 .
ln -s ${path_grid}/hgrid.gr3 ./hgrid.ll
ln -s ${path_grid}/vgrid.in .

ln -s ${path_gen_input}/albedo.gr3 .
ln -s ${path_gen_input}/drag.gr3 .
ln -s ${path_gen_input}/watertype.gr3 .
ln -s ${path_gen_input}/windrot_geo2proj.gr3 .
ln -s ${path_gen_input}/bctides.in .
ln -s ${path_gen_input}/RunCase_Options.txt .

ln -s ../Hot/hotstart.nc .

ln -s ../3Dth/elev2D.th.nc .
ln -s ../3Dth/TEM_3D.th.nc .
ln -s ../3Dth/SAL_3D.th.nc .
ln -s ../3Dth/uv3D.th.nc .

ln -s ../Nudge/include3.gr3 .
ln -s ../Nudge/nudge.gr3 ./TEM_nudge.gr3
ln -s ../Nudge/nudge.gr3 ./SAL_nudge.gr3
ln -s ../Nudge/TEM_nu.nc .
ln -s ../Nudge/SAL_nu.nc .

ln -s ../optional/diffmax.gr3 .
ln -s ../optional/diffmin.gr3 .
ln -s ../optional/shapiro.gr3 .
ln -s ../optional/tvd.prop .
