import numpy as np
from pyschism.mesh.vgrid import SZ

nvrt = 10
kz = 5

gd = SZ(h_s=100, ztot=[-500,-400,-300,-200,-100], h_c=10, theta_b=0.7, theta_f=5., sigma=np.linspace(-1, 0, nvrt-kz))
gd.nvrt = nvrt

gd.write('./vgrid.in', overwrite=True)
