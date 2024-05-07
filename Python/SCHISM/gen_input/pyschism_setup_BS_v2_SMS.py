#!/usr/bin/env python
# coding: utf-8

# # Imports

# In[1]:


#imports
import os
import sys
import pytz
import time
import numpy as np
from datetime import datetime, timedelta, timezone
from pathlib import Path
from pyschism import dates
from pyschism.driver import ModelConfig
from pyschism.forcing.bctides import Bctides
from pyschism.forcing.hycom.hycom2schism import OpenBoundaryInventory
from pyschism.forcing.nws import GFS, HRRR, ERA5, BestTrackForcing
from pyschism.forcing.source_sink import NWM
from pyschism.mesh import Hgrid, gridgr3
from pyschism.mesh.vgrid import SZ
import warnings
warnings.filterwarnings("ignore")  # turn off warnings


# # Functions

# In[2]:


# ========================= Functions ========================================
# function to force symlink to an existing link:
def force_symlink(src, dst):
    if not os.path.lexists(dst):    
        os.symlink(src, dst)
    else:
        os.remove(dst)
        os.symlink(src, dst)
    
# function to read a base nml file and make changes to the parameters:
#def read_base_nml(path_to_nml):

# main function that gets path to required files and other parameters:
# and creates model driver object. The order of *args are as follows:
#               output_directory, Base_Domain, sflux_dir,
#               0, 1, 2: sim_start_date, dt, rndays
#               3, 4: NC_avg, NC_stack
#               5, 6, 7: nhot, init_opt, atm_forc_opt
def main(output_directory, Base_Domain, hgridFileName, *args, **kwargs):
    sim_start_date = args[0]
    dt = args[1]
    rnday = args[2]
    NC_avg = args[3]
    NC_stack = args[4]
    nhot = args[5]
    init_opt = args[6]
    atm_forc_opt = args[7]
    
    baro_type = kwargs.get('baro_type', 'baroclinic') # options: baroclinic (default), barotropic
    rough_type = kwargs.get('rough_type', None) # drag.gr3, or rough.gr3 or manning.gr3 (default) that corresponds to nchi=0,1,-1 
    heat_exchange_opt = kwargs.get('heat_exchange_opt', None) # Heat Exchange Option    
    hycom_elev2D_opt = kwargs.get('hycom_elev2D_opt', None) # HYCOM BC for elevation
    hycom_UV_opt = kwargs.get('hycom_UV_opt', None) # HYCOM BC for UV
    hycom_TS_opt = kwargs.get('hycom_TS_opt', None) # HYCOM BC for TS
    hycom_adjust2D_opt = kwargs.get('hycom_adjust2D_opt', None) # HYCOM BC for adjust2D
    vgrid_type=kwargs.get('vgrid_type', '2D') # vertical grid type: 2D (default), SZ, or LSC2
    nvrt=kwargs.get('nvrt', 1) # number of vertical layers for S grid
    hotstart_file = kwargs.get('hotstart_file', None)
    sflux_dir = kwargs.get('sflux_dir', None)
    PathTo_LSC2_VGRID = kwargs.get('PathTo_LSC2_VGRID', None)

    # Boundary Conditions type:
    # see links below for more details:
    
    '''
    # https://schism-dev.github.io/schism/master/input-output/bctides.html
    # https://pyschism.readthedocs.io/en/latest/api/boundary.html#hycom-type-4
    # elevation(eta):
    # 3 -> tidal, 4-> time-space varying in elev2D.th.nc, 5-> both
    iet3 = iettype.Iettype3(constituents='major', database='tpxo')
    iet4 = iettype.Iettype4()
    iet5 = iettype.Iettype5(iettype3=iet3, iettype4=iet4)
    # flow (uv):
    # 3 -> tidal, 4-> time-space varying in uv3D.th.nc, 5-> both
    ifl3 = ifltype.Ifltype3(constituents='major', database='tpxo')
    ifl4 = ifltype.Ifltype4()
    ifl5 = ifltype.Ifltype5(ifltype3=ifl3, ifltype4=ifl4)
    # salinity and temperature:
    # 3-> Relax to i.c., 4-> [MOD]_3D.th.nc, 5-> NA
    isa0 = isatype.Isatype4() # 0
    isa4 = isatype.Isatype4()
    ite0 = itetype.Itetype4() # 0
    ite4 = itetype.Itetype4()
    
    # Define type based on selected option:
    iet_sel=iet3 if (hycom_elev2D_opt is False) else iet5
    ifl_sel=ifl3 if (hycom_UV_opt is False) else ifl5
    isa_sel=isa0 if (hycom_TS_opt is False) else isa4
    ite_sel=ite0 if (hycom_TS_opt is False) else ite4
    '''

    # Read hgrid file: 
    hgrid = Hgrid.open(Base_Domain+hgridFileName, crs="epsg:4326")
    atm_bbox = hgrid.bbox
    
    # Model atmospheric forcing type:
    if (atm_forc_opt == 'None' or atm_forc_opt == 'sflux'):
        print("  → \033[1mNone or sflux\033[0m atmospheric forcing option is selected!")
    elif (atm_forc_opt == 'ERA5'):
        print("  → \033[1mERA5\033[0m atmospheric forcing option is selected!")
        #sflux_dir = output_directory+"/sflux"
        #os.mkdir(sflux_dir)
        #sflux_dir = os.path.join("r", run_directory, "sflux")
        sflux_dir = (output_directory / "sflux")
        os.makedirs(sflux_dir, exist_ok=False)

        # era5 = ERA5()
        # era5.write(
        #     outdir=sflux_dir,
        #     start_date=sim_start_date,
        #     rnday=rnday,
        #     air=True, rad=True, prc=True,
        #     bbox=atm_bbox,
        #     overwrite=True)
        
        # windrot file is needed for nws=2 option:
        windrot = gridgr3.Windrot.default(hgrid)
        windrot.write(output_directory / "windrot_geo2proj.gr3", overwrite=True)
    '''
    # Define BC configs: 
    if hycom_TS_opt is False:
        config = ModelConfig(
            Hgrid.open(Base_Domain+hgridFileName, crs="epsg:4326"),
            iettype=iet_sel, ifltype=ifl_sel,
            # source_sink=NWM() # Uncomment for hydrology forcing
        )
    elif hycom_TS_opt is True:
        config = ModelConfig(
            Hgrid.open(Base_Domain+hgridFileName, crs="epsg:4326"),
            iettype=iet_sel, ifltype=ifl_sel,
            isatype=isa_sel, itetype=ite_sel,
            # source_sink=NWM() # Uncomment for hydrology forcing
        )
    '''
    # simulation ans spinup times:
    nearest_cycle = dates.nearest_cycle()
    spinup_time = timedelta(days=1)
    
    # Model initiation type:
    if (init_opt == 'coldstart'):
        print("  → \033[1mColdstart\033[0m option is selected!")
        ihot=0    
    elif (init_opt == 'hotstart'):
        print("  → \033[1mHotstart\033[0m option is selected!")
        ihot = 1  # Switch for coldstart/hotstart
    else:
        sys.exit("Improper initilization option is selected, script is terminated!")    
        
    # Build the driver object (for now based on coldstart only):
    
    
    bctypes = [[5, 5, 4, 4], [5, 5, 4, 4]] # for elev and uv bc
    # bctypes = [[3, 3, 0, 0], [3, 3, 0, 0]] # for elev and uv barotropic
    constituents = 'major'
    database = 'tpxo'
    earth_tidal_potential = True
    sthconst = [[np.nan, np.nan]]
    tobc = [0.5, 0.5]
    sobc = [0.5, 0.5]
    
    '''
    bctides = Bctides(
        hgrid = hgrid,
        flags = bctypes,
        constituents = constituents,
        database = database,
        add_earth_tidal = earth_tidal_potential,
        sthconst = sthconst,
        tobc = tobc,
        sobc = sobc)
    '''
    
    config = ModelConfig(
        Hgrid.open(Base_Domain+hgridFileName, crs="epsg:4326"),
        flags = bctypes,
        tobc = tobc,
        sobc = sobc,
        constituents = 'major',
        database = 'tpxo')
    
    # driver = config.hotstart(
    #     hotstart: Union[Hotstart, ModelDriver],
    #     timestep=dt,
    #     end_date: nearest_cycle, # will be overwitten by rnday
    #     nspool: timedelta(hours=1),
    #     ihfskip: int = None,
    #     nhot_write: None,
    #     stations = None,
    #     server_config: ServerConfig = None,
    #     **surface_outputs,
    # )
    
    driver = config.coldstart(
                    # start_date= sim_start_date.astimezone(pytz.utc), # = nearest_cycle - spinup_time,
                    start_date= sim_start_date.replace(tzinfo=timezone.utc), 
                    end_date=nearest_cycle, # will be overwitten by rnday
                    timestep=dt,
                    dramp=spinup_time,
                    dramp_ss=spinup_time,
                    drampwind=spinup_time,
                    nspool=timedelta(hours=1),
                    elev=True,
                    dahv=True
                    )
            
    # driver options:
    driver.param.core.rnday = rnday
    driver.param.core.nspool = int(NC_avg/dt)
    driver.param.core.ihfskip = int(NC_stack * 3600 / dt)
    driver.param.opt.ihot = ihot
    driver.param.opt.ncor = 1
    driver.param.schout.nhot = nhot
    driver.param.schout.nhot_write = int(rnday * 24 * 3600 / dt)  # write only at the end of silumations
    # if sflux or ERA5 option is selected:
    driver.param.opt.nws=2 if (atm_forc_opt == 'sflux' or atm_forc_opt == 'ERA5') else 0
    # if heat exchange option is selected:
    driver.param.opt.ihconsv=1 if (heat_exchange_opt is True) else 0
    # if roughness type is drag:
    driver.param.opt.nchi=0 if (rough_type == 'drag') else -1
    # if roughness type is mannings_manual:
    driver.param.opt.nchi=-1 if (rough_type == 'mannings_manual') else -1
    # if baroclinisity type is barotropic (baroclinic  is default):
    if (baro_type == 'barotropic'):
        driver.param.core.ibtp=1
        driver.param.core.ibc=0
        driver.param.opt.flag_ic=0
        
    # write output files:
    driver.write(output_directory, overwrite=True)
    
    # if baroclinisity type is barotropic (baroclinic  is default):
    if (baro_type == 'barotropic'):
        from pyschism.mesh.prop import Tvdflag
        Tvdflag_prop = Tvdflag.default(hgrid)
        '''
        inner_value = 0
        outer_value = 1
        region = poly1
        Tvdflag_prop = Tvdflag.from_geometry(hgrid, region, inner_value, outer_value)
        '''
        Tvdflag_prop.write(str(output_directory) +'/tvd.prop', overwrite=True)
    
    # if roughness type is manning-manual or drag:
    if (rough_type == 'drag'):
        from pyschism.mesh.fgrid import DragCoefficient
        depth1=200
        depth2=50
        # bfric_river=0.05
        bfric_river=0.0 # below the depth1 would be this value
        bfric_land=0.0025 # above the depth2 would be this value
        fgrid=DragCoefficient.linear_with_depth(hgrid, depth1, depth2, bfric_river, bfric_land)
        '''
        #modify values in regions
        regions=['GoME+0.001.reg', 'Lake_Charles_0.reg']
        values=[0.001, 0.0]
        flags=[1, 0] # 0: reset to given value, 1: add given value to the current value
        for reg, value, flag in zip(regions, values, flags):
            fgrid.modify_by_region(hgrid, f'./{reg}', value, depth1, flag)
        '''
        fgrid.write(str(output_directory) +'/drag.gr3', overwrite=True)
        
    if (rough_type == 'mannings_manual'):
        from pyschism.mesh.fgrid import ManningsN
        min_value=0.020
        max_value=0.025
        min_depth='None'
        max_depth='None'
        fgrid=ManningsN.linear_with_depth(hgrid, min_value=min_value, max_value=max_value)
        '''
        #modify values in regions
        regions=['GoME+0.001.reg', 'Lake_Charles_0.reg']
        values=[0.001, 0.0]
        flags=[1, 0] # 0: reset to given value, 1: add given value to the current value
        for reg, value, flag in zip(regions, values, flags):
            fgrid.modify_by_region(hgrid, f'./{reg}', value, depth1, flag)
        '''
        fgrid.write(str(output_directory) +'/manning.gr3', overwrite=True)
        
    # if heat exchange option is selected:
    if heat_exchange_opt is True:
        if (atm_forc_opt == 'None'):
            sys.exit("Heat exchange is slected while atm. forcing is none (nws <=2)!")
        else:
            # watertype.gr3 file:
            watertype = gridgr3.Watertype.default(hgrid)
            watertype.write(output_directory / "watertype.gr3", overwrite=True)
            # albedo.gr3 file:        
            albedo = gridgr3.Albedo.default(hgrid)
            albedo.write(output_directory / "albedo.gr3", overwrite=True)
    
    # if sflux option is selected link to sflux directory and windrot file:
    if (atm_forc_opt == 'sflux'):
        print("  → Creating \033[1msflux\033[0m directory and linking to:")
        print(C_BLUE,"    *" , sflux_dir, C_CLEAR)
        
        # sflux directory:
        link_dir = output_directory +"/sflux"
        force_symlink(sflux_dir, link_dir)
        
        # windrot file:
        link_file = output_directory+"/windrot_geo2proj.gr3"
        base_file = Base_Domain+"windrot_geo2proj.gr3"
        force_symlink(base_file, link_file)

    # if hotstart option is selected link to a hotstart file:
    if (init_opt == 'hotstart'):    
        # link_file = output_directory+"/hotstart.nc"
        link_file = str(run_directory) + "/hotstart.nc"
        base_file = hotstart_file
        force_symlink(base_file, link_file)
    
    # define vgrid based on 2D or 3D:
    # rename 2D vgrid file form "vgrid.in" to "vgrid.in.2D":
    os.rename(str(output_directory) + '/vgrid.in',str(output_directory) + '/vgrid.in.2D') # rename 2D vgird
    
    # create SZ vgrid with more than 1 layer:
    if vgrid_type=='SZ':
        layer_dist = np.linspace(-1, 0, nvrt)   # for uneven distribution use: -np.linspace(1, 0, nvrt) ** 0.6
        gd = SZ(h_s=1.e6, ztot=[-1.e6], h_c=40, theta_b=1, theta_f=0.00001, sigma=layer_dist)
        # Linlin's default values:
        #gd = SZ(h_s=1.e6, ztot=[-1.e6], h_c=30, theta_b=0.7, theta_f=5., sigma=layer_dist)
        gd.write(str(output_directory) + '/vgrid.in.SZ', overwrite=True)
    
    # link "vgrid.in" to "vgrid.in.2D", "vgrid.in.S", "vgrid.in.LSC2":
    if vgrid_type=='2D':
        base_Vgrid='vgrid.in.2D'
    elif vgrid_type=='SZ':
        base_Vgrid='vgrid.in.SZ'
    elif vgrid_type=='LSC2':
        base_Vgrid=PathTo_LSC2_VGRID
    # Link "vgrid.in"
    link_Vgrid=str(output_directory) + '/vgrid.in'
    force_symlink(base_Vgrid, link_Vgrid)   
    vgrid = link_Vgrid
# ========================== [End of Functions] ==========================


# # Simulations:

# In[3]:


# ========================== Globals ========================== #
# Main Paths:
RunDir = '/data/jungjih/Models/SCHISM/test_schism/v2_SMS/'
# Path to inputs:
Base_Domain = RunDir
hgridFileName =  'hgrid.gr3'
# Path to outputs:
SCHISM_RunDir = RunDir+'/gen_input/'
case_tag = 'v2_SMS'

# Secondary Paths:
# SFLUX_SrcDir = RunDir+'/alaska_domain/' # used only if forcing option is sflux
# HOTSTART_File = RunDir+'/alaska_domain/hotstart/hotstart_it=25920.nc' # used only if hotstart
# VGRID_3DPath = SCHISM_RunDir+'vgrid.in'
VGRID_LSC2Path = RunDir+'/vgrid.in'

# sample mesh_file = "https://raw.githubusercontent.com/geomesh/test-data/main/NWM/hgrid.ll"
# NOTE: Make sure you have TPXO files (h_tpxo9.v1.nc and u_tpxo9.v1.nc)
# under ~/.local/share/tpxo/

model_start_date = datetime(2018, 7, 1, 0, 0, 0) #Simulation start date in param.nml
dt = 120.0  # time step in sec
rnday = 153  # simulation length in days

init_opt = 'hotstart'  # initialization option, can be: coldstart, hotstart
hotstart_file = '/data/sdurski/HYCOM_extract/Bering_Sea/2018/Time_Filtered/HYCOM_glbvBeringSea_20180701.nc'

# THe atmospheric forcing will be generated seperately
atm_forc_opt = 'ERA5'  # forcing option, can be: GFS, HRRR, ERA5, sflux, None


vgrid_type = 'LSC2'  # vertical coordinate case (2D, SZ, or LSC2)
N_vert_lyr = 45  # number of vertical layers if 3D

baro_type = 'baroclinic' # options: baroclinic (default), barotropic
rough_type = 'drag' # options: drag, mannings_manual, none [drag.gr3, or rough.gr3 or manning.gr3 (default) that corresponds to nchi=0,1,-1] 

heat_exchange_opt=True # heat exchange option (ihconsv = 1)
hycom_elev2D_opt=True  # HYCOM BC for elevation
hycom_UV_opt=True  # HYCOM BC for UV
hycom_TS_opt=True  # HYCOM BC for TS
hycom_adjust2D_opt=True  # HYCOM BC for adjust2D

nhot = 0  # Switch for writing hotstart file

NC_avg = 3600  # average variables in output file every NC_avg seconds
NC_stack = 24  # average variables in output file every NC_stack hours

# COLOR Coding:
C_RED   = '\33[3;1;31m'
C_BLUE  = '\33[3;1;34m'
C_BOLD  = '\33[1m'
C_CLEAR = '\33[0m'
# ====================== End of Globals ======================= #

# Call main and write output files:
if __name__ == "__main__":
    print(C_RED+"☑ Script started ... "+C_CLEAR)
    start_time = time.time()

    # Date string to tag output folder name
    name_string = datetime.now().strftime("%Y.%m.%d-%H:%M:%S")+'___'+case_tag
    run_directory = os.path.join("r", SCHISM_RunDir, name_string) # SCHISM_RunDir+name_string
    run_directory = Path(SCHISM_RunDir+name_string)
    print("  → Run directory:")
    print(C_BLUE,"    *" , name_string, C_CLEAR)
    
    # Run the main:
    #   def main(output_directory, Base_Domain, sflux_dir,
    #               sim_start_date, dt, rndays,
    #               NC_avg, NC_stack,
    #               nhot, init_opt, atm_forc_opt,
    #               hotstart_file=None or path/to/hotstart/file)
    # main(run_directory, Base_Domain, hgridFileName,
    #      model_start_date, dt, rnday,
    #      NC_avg, NC_stack,
    #      nhot, init_opt, atm_forc_opt,
    #      baro_type = baro_type, rough_type = rough_type, heat_exchange_opt = heat_exchange_opt,
    #      hycom_elev2D_opt = hycom_elev2D_opt, hycom_UV_opt = hycom_UV_opt, 
    #      hycom_TS_opt = hycom_TS_opt, hycom_adjust2D_opt = hycom_adjust2D_opt,
    #      vgrid_type = vgrid_type, nvrt = N_vert_lyr, PathTo_LSC2_VGRID = VGRID_LSC2Path,
    #      hotstart_file = None)
    
    main(run_directory, Base_Domain, hgridFileName,
         model_start_date, dt, rnday,
         NC_avg, NC_stack,
         nhot, init_opt, atm_forc_opt,
         baro_type = baro_type, rough_type = rough_type, heat_exchange_opt = heat_exchange_opt,
         hycom_elev2D_opt = hycom_elev2D_opt, hycom_UV_opt = hycom_UV_opt, 
         hycom_TS_opt = hycom_TS_opt, hycom_adjust2D_opt = hycom_adjust2D_opt,
         vgrid_type = vgrid_type, nvrt = N_vert_lyr, PathTo_LSC2_VGRID = VGRID_LSC2Path,
         hotstart_file = hotstart_file)
    
    # write a text file with main model options:
    ReadMeFile = open(run_directory / "RunCase_Options.txt","w")
    L = ["Grid file used ............ "+hgridFileName+"\n",
         "Initialization option ..... "+init_opt+"\n",
         "Start date ................ "+str(model_start_date)+"\n",
         "Simulation period (day) ... "+str(rnday)+"\n",
         "Time step (s) ............. "+str(dt)+"\n",
         "Vertical grid type ........ "+vgrid_type+"\n",
         "Number of SZ layers ....... "+str(N_vert_lyr)+"\n",
         "Baroclinicity type ........ "+baro_type+"\n",
         "Roughness type ............ "+rough_type+"\n",
         "Atmospheric forcing ....... "+atm_forc_opt+"\n",
         "Heat exchange option ...... "+str(heat_exchange_opt)+"\n",
         "HYCOM BC options: \n",
         "      elev2D .............. "+str(hycom_elev2D_opt)+"\n",
         "      UV .................. "+str(hycom_UV_opt)+"\n",
         "      adjust2D ............ "+str(hycom_adjust2D_opt)+"\n",
         "      TS .................. "+str(hycom_TS_opt)+"\n"]
    ReadMeFile.writelines(L)
    ReadMeFile.close()
           
    # Print outputs location and list of files:
    print("  → Domain files are generated in:")
    print(C_BLUE,"    *" , run_directory, C_CLEAR)
    
    filenames = os.listdir(run_directory)
    for i in range(len(filenames)):
        print(C_BLUE,'      -', filenames[i],  C_CLEAR)
    
    checkpoint_time = time.time()
    print('☑ Total time to generate domain files:',C_BOLD, int(checkpoint_time - start_time), 'seconds!',C_CLEAR)
    print(C_RED+"☑ Script completed!"+C_CLEAR)

# Subtidal Boundary Conditions (if defined):
# if hycom_elev2D_opt is True or hycom_UV_opt is True or hycom_TS_opt is True:
#     print("  → \033[1mSubtidal\033[0m option is selected, this section may take a long time to complete ...")
#     hgrid = Hgrid.open(str(run_directory) + '/hgrid.gr3', crs='epsg:4326')
#     vgrid = str(run_directory) + '/vgrid.in'
    
    # create BC object:
    # bnd = OpenBoundaryInventory(hgrid, vgrid)
    # bnd.fetch_data(run_directory, model_start_date, rnday, elev2D=True, TS=False, UV=False, adjust2D=False, ocean_bnd_ids=[0,1])
    # bnd.fetch_data(run_directory, model_start_date, rnday,
    #                elev2D=hycom_elev2D_opt, UV=hycom_UV_opt, TS=hycom_TS_opt, adjust2D=hycom_adjust2D_opt,
    #                ocean_bnd_ids=[0,1])
