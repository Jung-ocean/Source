import numpy as np

filename = 'elev.ic'

f1 = open(filename, 'r')
f2 = open('elev_1m.ic', 'w')
for line in f1:
    
    tmp = line
    tmp_array = tmp.split()
    if len(tmp) > 37 and -50 < float(tmp_array[1]) < 50 and float(tmp_array[2]) < 2.5:
        tmp_array[3] = str('1.00000000')
        tmp_string = ' '.join(tmp_array)+'\n'
        print(tmp_string)
        f2.write(tmp_string)
    else:
        f2.write(line)
    
f1.close()
f2.close()

