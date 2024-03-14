# From FariborzDaneshvar-NOAA (https://github.com/FariborzDaneshvar-NOAA/SCHISM_validation_plot/blob/main/notebooks/COOPS_Validation.ipynb)

import os
import numpy as np
import pandas as pd
import scipy as sp
import xarray as xr
import matplotlib.pyplot as plt
import shapely
import geopandas

os.environ['USE_PYGEOS'] = '0'
import geopandas as gpd

from pathlib import Path 
from datetime import datetime,timedelta
from matplotlib.dates import DateFormatter
from cartopy.feature import NaturalEarthFeature
from searvey.coops import coops_product_within_region, coops_stations_within_region
from pyschism.mesh import Hgrid
from stormevents import StormEvent
from shapely.geometry import MultiPolygon
from shapely.ops import polygonize

def get_storm_track_date(storm_track, advisory):
    for idx in storm_track.linestrings[advisory]:
        track_date = idx
    return track_date

def format_datetime_for_coops(storm_datetime):
    return datetime(storm_datetime.year, storm_datetime.month, storm_datetime.day, storm_datetime.hour, storm_datetime.minute)
def plot_isobar_domains(storm_track, track_date, gdf_countries):
    figure, axis = plt.subplots(1, 1)
    figure.set_size_inches(12, 12 / 1.618)
    
    # track_date = get_storm_track_date(storm_track, 'BEST')

    axis.plot(*storm_track.wind_swaths(wind_speed=34)['BEST'][track_date].exterior.xy, 
              c='limegreen', label='34 kt')
    axis.plot(*storm_track.wind_swaths(wind_speed=50)['BEST'][track_date].exterior.xy, 
              c='blue', label='50 kt')
    axis.plot(*storm_track.wind_swaths(wind_speed=64)['BEST'][track_date].exterior.xy, 
              c='red', label='64 kt')
    axis.plot(*storm_track.linestrings['BEST'][track_date].xy, 
              c='black',label='BEST track')
    
    xlim = axis.get_xlim()
    ylim = axis.get_ylim()
    
    gdf_countries.plot(color='lightgrey', ax=axis, zorder=-1)
    
    axis.set_xlim(xlim)
    axis.set_ylim(ylim)
    axis.legend()
    axis.set_title(f'{storm_track.name}_{storm_track.year} BEST track windswatch')
    figure.savefig(f'{storm_track.name}_{storm_track.year}_BEST_track_windswatch.png')
def plot_coops_stations(storm_name, storm_year, coops_product, gdf_countries):
    x_vals = coops_product['x'].values
    y_vals = coops_product['y'].values
    nos_ids = coops_product['nos_id'].values
    
    figure, axis = plt.subplots(1, 1)
    figure.set_size_inches(12, 12 / 1.618)

    for idx in range(len(nos_ids)):
        axis.scatter(x_vals[idx],y_vals[idx], label=nos_ids[idx])
    
    xlim = axis.get_xlim()
    ylim = axis.get_ylim()
    
    gdf_countries.plot(color='lightgrey', ax=axis, zorder=-1)
    
    axis.set_xlim(xlim)
    axis.set_ylim(ylim)
    axis.legend()
    # axis.set_title(f'COOPS stations within 50kt isotach of {storm_name}_{storm_year}')
    axis.set_title(f'COOPS stations of {storm_name} {storm_year}')
    figure.savefig(f'{storm_name}_{storm_year}_COOPS_stations.png')
def coops_dataset_to_dataframe(coops_dataset):
    df_coops, ij = [], 0
    for idx in coops_dataset.coords['nos_id'].values:
        df_temp = pd.DataFrame({'date': coops_dataset.coords['t'].values,
                                idx: coops_dataset.v.values[ij,:],
                               }).set_index('date')
        df_coops.append(df_temp)
        ij = ij+1
    df_coops = pd.concat(df_coops, axis=1)       
    return df_coops
def adjust_coops(df_coops):
    df_coops_adjusted = pd.DataFrame()
    for coops_idx in df_coops.columns:
        df_coops_adjusted[coops_idx] = df_coops[coops_idx] - df_coops[coops_idx].values.mean()
    return df_coops_adjusted
def get_stations_coordinates(coops_dataset):
    coord_x = coops_dataset.x.values
    coord_y = coops_dataset.y.values
    coord_combined = np.column_stack([coord_x, coord_y])
    return coord_combined
def find_stations_indices(coordinates, hgrid):
    longitude = hgrid.x.T
    latitude = hgrid.y.T
    long_lat = np.column_stack((longitude.ravel(),latitude.ravel()))
    tree = sp.spatial.cKDTree(long_lat)
    dist,idx = tree.query(coordinates,k=1)
    ind = np.column_stack(np.unravel_index(idx,longitude.shape))
    return [i for i in ind]
def get_schism_elevation_df(ds_schism, station_indices, station_ids):
    time_array = ds_schism.time.values
    var_name = 'elevation'
    
    df, ij = [], 0
    for idx in station_ids:
        df_temp = pd.DataFrame({'date': time_array,
                                idx: ds_schism[var_name][:,int(station_indices[ij])].values,
                               }).set_index('date')
        df.append(df_temp)
        ij = ij+1 
    df = pd.concat(df, axis=1)
    return df
def get_common_dates(df_1, df_2):
    return df_1.index.intersection(df_2.index)
# def plot_timeseries(df_coops, df_schism_1, df_schism_2, mid_date, domain_stations, schism_labels, storm_name, storm_year):
def plot_timeseries(df_coops, df_schism_1, from_date, to_date, domain_stations, schism_labels, storm_name, storm_year):
    
    # plot date range:
    # from_date = mid_date + timedelta(days=-2)
    # to_date = mid_date + timedelta(days=+2)
    
    # No. of plots and spacings:
    n_plots = len(df_coops.columns)

    fig_wspace, fig_hspace = 0.2, 0.2
    
    if n_plots <= 4:
        row, col = n_plots, 1
    else:
        row, col = int(np.ceil(n_plots/2)), 2

    fig_width = 8*(col) + fig_wspace *(col-1)
    fig_height = 2*(row) + fig_hspace *(row-1)
    
    fig, axis = plt.subplots(row , col, figsize=(fig_width, fig_height), facecolor='w', edgecolor='k')
    fig.subplots_adjust(hspace = fig_hspace, wspace=fig_wspace)
    axis = axis.ravel()
    idx_plt = 0
    
    for idx in df_coops.columns: 
        # axis[idx_plt].plot(df_coops[idx].loc[from_date:end_date], linestyle='solid',linewidth=1.0, label='COOPS')
        # axis[idx_plt].plot(df_schism_1[idx].loc[from_date:end_date], linestyle='dashed', linewidth=1.0, label=schism_labels[0])
        axis[idx_plt].plot(df_coops[idx].loc[from_date:to_date], linestyle='solid',linewidth=1.0, label='COOPS')
        axis[idx_plt].plot(df_schism_1[idx].loc[from_date:to_date], linestyle='dashed', linewidth=1.0, label=schism_labels[0])
        # if df_schism_2 is not None:
            # axis[idx_plt].plot(df_schism_2[idx].loc[from_date:end_date], linestyle='dotted', linewidth=1.2, label=schism_labels[1])

        axis[idx_plt].grid(axis = 'both', color = 'gray', linestyle = '-', linewidth = 0.75, alpha=0.15)
        axis[idx_plt].tick_params(axis="both",direction="in")  #, pad=0
        plt.setp(axis[idx_plt].xaxis.get_majorticklabels(), rotation=90)
                
        # format x-labels
        plt.gcf().autofmt_xdate()
        date_form = DateFormatter("%b-%d") #DateFormatter("%b-%d, %H:%M")
        axis[idx_plt].xaxis.set_major_formatter(date_form)        
        # axis[idx_plt].set_ylim([-2.5,2.5])
        axis[idx_plt].set_ylim([-2,2])
    
        station_label = f'{idx} ({domain_stations[domain_stations.nos_id==int(idx)].name.values[0]})'
        axis[idx_plt].text(0.5, 0.975, station_label,
                           horizontalalignment='center', verticalalignment='top',
                           transform=axis[idx_plt].transAxes, size=9,weight='bold')        
        idx_plt +=1

    # add legend:
    # axis[-1].legend(loc="lower right", ncol=5)
    axis[0].legend(loc="lower left", ncol=5)
    
    fig.add_subplot(111, frame_on=False)
    plt.tick_params(labelcolor="none", bottom=False, left=False)
    plt.ylabel('Sea level elevation [m]', size=11,weight='bold')
    # plt.title(f'{storm_name}_{storm_year} Water Level \n From {df_coops.index[0]} To {df_coops.index[-1]}', size=15)
    plt.title(f'{storm_name} {storm_year} \n From {df_coops.index[0]} to {df_coops.index[-1]}', size=15)
    
    plt.savefig(f'{storm_name}_{storm_year}_timeseries.png')#, dpi=250)
def plot_scatter(df_coops, df_schism_1, df_schism_2, mid_date, domain_stations, schism_labels, storm_name, storm_year):
    
    # plot date range:
    from_date = mid_date + timedelta(days=-2)
    to_date = mid_date + timedelta(days=+2)
    
    # No. of plots and spacings:
    n_plots = len(df_coops.columns)
    row, col = int(np.ceil(n_plots/3)), 3
    fig_wspace, fig_hspace = 0.2, 0.2
    fig_width = 5*(col) + fig_wspace *(col-1)
    fig_height = 5*(row) + fig_hspace *(row-1)
    
    fig, axis = plt.subplots(row , col, figsize=(fig_width, fig_height), facecolor='w', edgecolor='k')
    fig.subplots_adjust(hspace = fig_hspace, wspace=fig_wspace)
    
    axis = axis.ravel()
    idx_plt = 0
    
    for idx in df_coops.columns: 
        axis[idx_plt].scatter(df_coops[idx], df_schism_1[idx], s=4, label=schism_labels[0])
        if df_schism_2 is not None:
            axis[idx_plt].scatter(df_coops[idx], df_schism_2[idx], s=4, marker='*', label=schism_labels[1])

        axis[idx_plt].axline((-0.50,-0.50), (0.50,0.50), linestyle='--', color='grey')       
        # axis[idx_plt].legend(loc="upper left")
        axis[idx_plt].tick_params(axis="both",direction="in")  #, pad=0
        plt.setp(axis[idx_plt].xaxis.get_majorticklabels(), rotation=0)
        
        station_label = f'{idx} ({domain_stations[domain_stations.nos_id==int(idx)].name.values[0]})'
        axis[idx_plt].text(0.5, 0.975, station_label,
                   horizontalalignment='center', verticalalignment='top',
                   transform=axis[idx_plt].transAxes, size=9,weight='bold')
        
        axis[idx_plt].set_xlim([-1.5,1.5])
        axis[idx_plt].set_ylim([-1.5,1.5])
        
        axis[idx_plt].legend(loc="lower right")
        axis[idx_plt].set_ylabel('SCHISM simulation [m]')
        axis[idx_plt].set_xlabel('COOPS observation [m]')
                   
        idx_plt +=1
    
    fig.add_subplot(111, frame_on=False)
    plt.tick_params(labelcolor="none", bottom=False, left=False)
    plt.title(f'{storm_name}_{storm_year} COOPS Water Level Validation \n From {df_coops.index[0]} To {df_coops.index[-1]}', size=15)
    plt.savefig(f'{storm_name}_{storm_year}_COOPS_scatters_with_stats.png')#, dpi=250)
def get_corr(obs,sim):
    return obs.corr(sim)

def get_mae(obs,sim):
    mae = ((np.abs(obs-sim)).sum()) / len(obs)
    # mae = (np.abs(obs-sim)).mean()
    return mae

def get_r2(obs,sim):
    nom = ((obs-obs.mean()) * (sim-sim.mean())).sum()
    den_1 = np.sqrt(((obs-obs.mean())**2).sum())
    den_2 = np.sqrt(((sim-sim.mean())**2).sum())
    return (nom/(den_1*den_2))**2

def get_rmse(obs,sim):
    # rmse = np.sqrt(((obs-sim)**2).mean())
    dif = (obs-sim)**2
    rmse = np.sqrt(dif.sum()/len(obs))
    return rmse

def get_bias(obs,sim):
    return (sim-obs).mean()

def get_rel_bias(obs,sim):
    rel_bias = get_bias(obs,sim) / obs.mean()
    return rel_bias

def calc_stats(obs,sim,mid_date):
    from_date = mid_date + timedelta(days=-2)
    to_date = mid_date + timedelta(days=+2)
    
    obs = obs.loc[from_date:to_date]
    sim = sim.loc[from_date:to_date]
    
    df_stats = pd.DataFrame(columns=['NOS_ID', 'STD_OBS', 'STD_SIM', 'CORR', 'MAE', 'R2', 'RMSE', 'BIAS', 'R_BIAS'])
    
    for idx in obs.columns:
        std_obs = '%.2f' % round(obs[idx].std(ddof=1),2)
        std_sim = '%.2f' % round(sim[idx].std(ddof=1),2)
        corr = '%.2f' % round(get_corr(obs[idx],sim[idx]),2)
        mae = '%.2f' % round(get_mae(obs[idx],sim[idx]),2)
        r2 = '%.2f' % round(get_r2(obs[idx],sim[idx]),2)
        rmse = '%.2f' % round(get_rmse(obs[idx],sim[idx]),2)
        bias = '%.2f' % round(get_bias(obs[idx],sim[idx]),2)
        rel_bias = '%.2f' % round(get_rel_bias(obs[idx],sim[idx]),2)
        
        df_temp = pd.DataFrame([[idx, std_obs, std_sim, corr, mae, r2, rmse, bias, rel_bias]],
                               columns=['NOS_ID', 'STD_OBS', 'STD_SIM', 'CORR', 'MAE', 'R2', 'RMSE', 'BIAS', 'R_BIAS'])
        df_stats = pd.concat([df_stats,df_temp], axis=0, ignore_index=True)
    return df_stats

#### user defined
gdf_countries = gpd.GeoSeries(NaturalEarthFeature(category='physical', scale='10m', name='land').geometries(), crs=4326)

exp_name = 'v1_SMS'
exp_year = 2018

hgrid_path = Path('../hgrid.gr3')
num_output = 30
output_path = '../outputs/'
schism_labels = ['SCHISM']

Bering_Sea = shapely.geometry.box(-205.9832, 49.1090, -156.8640, 66.3040)
Bering_Sea_stations = coops_stations_within_region(region=Bering_Sea)
Bering_Sea_stations

water_levels = coops_product_within_region(
    'water_level',
    region=Bering_Sea,
    start_date=datetime(2018, 7, 1, 0),
    end_date=datetime(2018, 7, 31, 23),
    datum='MSL',
    interval='h',
)

water_levels = water_levels.drop_vars(['f','s','q'])  # Remove unwanted/NaN variables

station_ids = water_levels['nos_id'].values

domain_stations = coops_stations_within_region(region=Bering_Sea)
domain_stations = domain_stations.reset_index()
domain_stations = domain_stations[domain_stations['nos_id'].isin(water_levels.nos_id.values.astype('int'))] # stations that have data records during the storm

plot_coops_stations(exp_name,exp_year,water_levels,gdf_countries)

# convert COOPS nc to df
df_coops = coops_dataset_to_dataframe(water_levels)

# Adjust water level (if needed)
# df_coops = adjust_coops(df_coops)

# Read hgrid and find indices corresponding to COOPS stations
hgrid = Hgrid.open(hgrid_path, crs=4326)
stations_coordinates = get_stations_coordinates(water_levels)
for i in range(0,len(stations_coordinates)):
    if stations_coordinates[i,0] < 0:
        stations_coordinates[i,0] = stations_coordinates[i,0] + 360
            
stations_indices = find_stations_indices(stations_coordinates, hgrid)

# Read SCHISM outputs
df_schism_all = []
for i in range(1,num_output+1):
    ds_schism = xr.open_dataset(output_path+'out2d_'+str(i)+'.nc')
    df_schism = get_schism_elevation_df(ds_schism, stations_indices, station_ids)
    df_schism_all.append(df_schism)
    
df_schism_all = pd.concat(df_schism_all)

common_dates = get_common_dates(df_coops, df_schism_all)

df_coops = df_coops.loc[common_dates]
df_schism_all = df_schism_all.loc[common_dates]

from_date = datetime(2018,7,1,1)
to_date = datetime(2018,7,31,0)

plot_timeseries(df_coops=df_coops, 
                df_schism_1=df_schism_all, 
                from_date=from_date,
                to_date=to_date,
                domain_stations=domain_stations,
                schism_labels=schism_labels,
                storm_name=exp_name,
                storm_year=exp_year)







