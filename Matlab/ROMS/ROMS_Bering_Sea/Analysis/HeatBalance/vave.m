function [Tave,V]=vave(T,Hz,dxdy,mask_ave)

% 3/10/2021: computes the volume averaged field in the area defined by
% mask_ave
% INPUTS:
% T: the 3D field, size [xi_rho,eta_rho,N]
% Hz: the depth of each layer, same size as T
% dxdy: the area of each cell, size [xi_rho,eta_rho]
% mask_ave: 1 where averaging is done, 0 otherwise

[xi_rho,eta_rho,N]=size(T);
mask3d=repmat(mask_ave,[ 1 1 N]);

T(mask3d==0)=0; % zero out cells that are not needed, also fills nan spots
Hz(mask3d==0)=0;

A3d=repmat(dxdy,[1 1 N]);
TV=sum(T.*Hz.*A3d,'all');
V=sum(Hz.*A3d,'all');
Tave=TV/V;

