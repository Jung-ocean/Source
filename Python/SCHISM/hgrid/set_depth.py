import pyschism
from pyschism.mesh import Hgrid
import copy

hgrid = Hgrid.open('hgrid.gr3', crs='EPSG:4326')
gridh = hgrid.values  # depth values from hgrid file

depth_threshold = -5
gridh[gridh>depth_threshold] = 0

hgrid_new = copy.deepcopy(hgrid)
hgrid_new.values[:] = gridh
hgrid_new.make_plot(show=True)

hgrid_new.write('./hgrid_new.gr3', overwrite=True)
