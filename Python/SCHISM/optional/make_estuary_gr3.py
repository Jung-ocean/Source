import numpy as np

filename = 'hgrid.gr3'

f1 = open(filename, 'r')
f2 = open('estuary.gr3', 'w')
for line in f1:
    
    tmp = line
    tmp_array = tmp.split()
    if len(tmp_array) == 4:
        tmp_array[3] = str('0.00000000')
        tmp_string = ' '.join(tmp_array)+'\n'
        print(tmp_string)
        f2.write(tmp_string)
    else:
        f2.write(line)
    
f1.close()
f2.close()

