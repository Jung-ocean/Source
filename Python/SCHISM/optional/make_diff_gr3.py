import numpy as np

filename = 'hgrid.gr3'

min_value = 1e-6
max_value = 1.0

f1 = open(filename, 'r')
fmin = open('diffmin.gr3', 'w')
fmax = open('diffmax.gr3', 'w')
for line in f1:
    
    tmp = line
    tmp_array = tmp.split()
    if len(tmp_array) == 4:
        tmp_array[3] = str(min_value)
        tmp_string = ' '.join(tmp_array)+'\n'
        print(tmp_string)
        fmin.write(tmp_string)
        
        tmp_array[3] = str(max_value)
        tmp_string = ' '.join(tmp_array)+'\n'
        print(tmp_string)
        fmax.write(tmp_string)
    else:
        fmin.write(line)
        fmax.write(line)
    
f1.close()
fmin.close()
fmax.close()

