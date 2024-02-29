import numpy as np

rnday = 10
dt = 60

timestep = dt*int(rnday*24*60*60/dt) + 2*dt

uwind = 10
vwind = 0

f = open('wind.th', 'w')
for i in range(0,timestep,dt):
    # if int(i) < 360:
        tmp_string = str(i) + ' ' + str(uwind) + ' ' + str(vwind) + ' \n'
        f.write(tmp_string)
    # else:
        # tmp_string = str(i) + ' ' + str(vwind) + ' ' + str(vwind) + ' \n'
        # f.write(tmp_string)
    
f.close()

