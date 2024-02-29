import pathlib
import numpy as np
import geopandas as gpd
import matplotlib.pyplot as plt
import pyproj
from pyproj import CRS
from shapely.geometry import Point
from ocsmesh import Raster, Geom, Hfun, Mesh, JigsawDriver, utils
from shapely.geometry import Polygon, box

# %matplotlib qt
# %matplotlib inline

DEM_file = '/home/jungjih/DEM/ideal.tif'

geom_rasters = list()
raster_for_geom = Raster(DEM_file)
geom_rasters.append(raster_for_geom)

# lon, lat = 163, 59
# custom_crs = CRS.from_string(f'proj=aeqd +lat_0={lat} +lon_0={lon} +datum=WGS84 +units=m')
# base_gs = gpd.GeoSeries(Point([0, 0]).buffer(55e3), crs=custom_crs)
# geom = Geom(geom_rasters,base_shape=base_gs.unary_union,base_shape_crs=base_gs.crs,zmax=-10)

min_lat = 55
max_lat = 60
min_lon = -165
max_lon = -160

poly = Polygon([[min_lon+0.1, min_lat+0.1], [min_lon+0.1, max_lat-0.1], 
                [max_lon-0.1, max_lat-0.1], [max_lon-0.1, min_lat+0.1]])
# base_gs = gpd.GeoSeries(poly, crs='WGS84')
base_gs = gpd.GeoDataFrame(index=[0], crs='WGS84', geometry=[poly])
geom = Geom(geom_rasters,base_shape=base_gs.unary_union,base_shape_crs=base_gs.crs,zmax=0)

# geom = Geom(raster_for_geom, zmax=0)
# poly = Polygon([[162.1, 58.1], [162.1, 59.9], [163.9, 59.9], [163.9, 58.1]])
# geom = Geom(poly, crs='WGS84')

multipolygon = geom.get_multipolygon()
gpd.GeoSeries(multipolygon, crs=geom.crs).plot()

# raster_for_hfun = Raster(DEM_file)
# hfun = Hfun(raster_for_hfun, hmin=500, hmax=5000)

hfun_rasters = list()
raster_for_hfun = Raster(DEM_file)
hfun_rasters.append(raster_for_hfun)
hfun = Hfun(hfun_rasters, base_shape=base_gs.unary_union,base_shape_crs=base_gs.crs, hmin=500, hmax=5000, method='fast')

# Constant value of 100 meters for elevations above 0 meter msl
# hfun.add_constant_value(value=100, lower_bound=0)

# Value of 100 meters for 0 meter msl contour and 200m for -10m msl with
# expansion rate of 1/1000
hfun.add_contour(level=0, expansion_rate=0.0001, target_size=500)

hfun_msh_t = hfun.msh_t()
utils.tricontourf(hfun_msh_t, colorbar=True, show=True)

driver = JigsawDriver(geom=geom, hfun=hfun)
mesh = driver.run()
utils.triplot(mesh)

# raster_for_interp = Raster(DEM_file)
# mesh.interpolate(raster_for_interp, method = 'linear')

interp_rasters = list()
raster_for_interp = Raster(DEM_file)
interp_rasters.append(raster_for_interp)
mesh.interpolate(interp_rasters)

mesh_value = mesh.msh_t.value
# print(mesh_value)

mesh.boundaries.auto_generate(threshold=-1)

# poly_land = Polygon([[160, 58], [160, 58], [164, 60], [164, 60]])
# mesh.boundaries.set_land(poly_land, merge=True)

# mesh.write('/home/jungjih/OCSMesh/output/hgrid.gr3', format='grd', overwrite=True)
mesh.write('/home/jungjih/OCSMesh/output/hgrid.ll', format='grd', overwrite=True)