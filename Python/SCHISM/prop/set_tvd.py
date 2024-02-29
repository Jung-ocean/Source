import numpy as np

filename = 'hgrid.gr3'

f1 = open(filename, 'r')
lines = f1.readlines()
lines_array = lines[1].split()
nelement = int(lines_array[0])

f2 = open('tvd.prop', 'w')
for i in range(nelement):
    
    tmp_string = str(i+1) + ' 1 \n' 
    f2.write(tmp_string)
    
f1.close()
f2.close()

