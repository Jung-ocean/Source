import pyschism
from pyschism.mesh import Hgrid
import copy

hgrid = Hgrid.open('hgrid.gr3', crs='EPSG:4326')
gridh = hgrid.values  # depth values from hgrid file

depth_threshold = -5 # Note that the sign of depth is inverted in the above process
gridh[gridh>depth_threshold] = depth_threshold

hgrid_new = copy.deepcopy(hgrid)
hgrid_new.values[:] = gridh
hgrid_new.make_plot(show=True)

hgrid_new.write('./hgrid_new.gr3', overwrite=True)
