import searvey
import geopandas
import shapely
import pandas
from matplotlib import pyplot
from datetime import datetime
from searvey.coops import coops_stations, coops_stations_within_region, coops_product_within_region

countries = geopandas.read_file(geopandas.datasets.get_path('naturalearth_lowres'))

Bering_Sea = shapely.geometry.box(-205.9832, 49.1090, -156.8640, 66.3040)
Bering_Sea_stations = coops_stations_within_region(region=Bering_Sea)
Bering_Sea_stations

figure, axis = pyplot.subplots(1, 1)
figure.set_size_inches(12, 12 / 1.61803398875)

Bering_Sea_stations.plot(ax=axis)

xlim = axis.get_xlim()
ylim = axis.get_ylim()
countries.plot(color='lightgrey', ax=axis, zorder=-1)
axis.set_xlim(xlim)
axis.set_ylim(ylim)
axis.set_title(f'CO-OPS stations on the Bering Sea')

water_levels = coops_product_within_region(
    'water_level',
    region=Bering_Sea,
    start_date=datetime(2018, 7, 1, 0),
    end_date=datetime(2018, 7, 31, 23),
    datum='MSL',
    interval='h',
)
water_levels