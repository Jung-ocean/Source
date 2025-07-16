import searvey
import geopandas
import shapely
import pandas
from matplotlib import pyplot
from datetime import datetime
from searvey.coops import coops_stations, coops_stations_within_region, coops_product_within_region

countries = geopandas.read_file(geopandas.datasets.get_path('naturalearth_lowres'))

US_west = shapely.geometry.box(-129.9873, 40.6590, -122.1182, 49.9874)
US_west_stations = coops_stations_within_region(region=US_west)
US_west_stations

figure, axis = pyplot.subplots(1, 1)
figure.set_size_inches(12, 12 / 1.61803398875)

US_west_stations.plot(ax=axis)

xlim = axis.get_xlim()
ylim = axis.get_ylim()
countries.plot(color='lightgrey', ax=axis, zorder=-1)
axis.set_xlim(xlim)
axis.set_ylim(ylim)
axis.set_title(f'CO-OPS stations on the US west coast')

water_levels = coops_product_within_region(
    'water_level',
    region=US_west,
    start_date=datetime(2023, 1, 1, 0),
    end_date=datetime(2024, 12, 31, 23),
    datum='MSL',
    interval='h',
)
water_levels