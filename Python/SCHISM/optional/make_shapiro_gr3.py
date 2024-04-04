import numpy as np

filename = 'hgrid.gr3'

coefficient = 1.e3 # the coefficient in tanh(). Experiences so far suggest 100 to 1.e3

f1 = open(filename, 'r')
f2 = open('shapiro.gr3', 'w')
for line in f1:
    
    tmp = line
    tmp_array = tmp.split()
    
    if tmp_array[0] == 'EPSG:4326':
        tmp_array = coefficient
        tmp_string = str(tmp_array)+'\n'
        print(tmp_string)
        f2.write(tmp_string)
    
    elif len(tmp_array) == 4:
        tmp_array[3] = str(coefficient)
        tmp_string = ' '.join(tmp_array)+'\n'
        print(tmp_string)
        f2.write(tmp_string)
        
    else:
        f2.write(line)
    
f1.close()
f2.close()

