function [Q,A]=aave(q,dxdy,mask_ave)

% 3/10/2021: computes the area averaged field in the area defined by
% mask_ave
% INPUTS:
% T: the 2D field, size [xi_rho,eta_rho]
% dxdy: the area of each cell, size [xi_rho,eta_rho]
% mask_ave: 1 where averaging is done, 0 otherwise

[xi_rho,eta_rho,N]=size(q);
q(mask_ave==0)=0; % zero out cells that are not needed, also fills nan spots

QA=sum(q.*dxdy,'all');
A=sum(dxdy,'all');
Q=QA/A;

