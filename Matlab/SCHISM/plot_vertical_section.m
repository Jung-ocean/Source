clear; clc

base = '../';
ivs = 1; % 1 for scalar; 2 for vector
transect_bp = 'transect.bp';
varname = 'temperature';
stacks = 1;
nspool = 1:2;
test = 'y';

SCHISM_TRANSECT2(base,ivs,transect_bp,varname,stacks,nspool,test)