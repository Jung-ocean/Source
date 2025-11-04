function [PHI_p C PHI_w]=MODES_FS(dz,N2,Nm,FS_flag,Nm0)
% USAGE: [PHI C PHI2]=MODES_FS(dz,N2,Nm)
% Obtain vertical modes for arbitrary stratification with (or without) a free surface
%
% INPUTS:
% dz  [1  x 1]   vertical spacing (must be uniform)
% N2  [Nz x 1]   stratification 
% Nm  [1  x 1]   number of modes to extract 
% FS_flag [1 x 1]  1 = free surface boundary conditions, 0 = rigid-lid boundary conditions 
% Nm0 [1  x 1]   number of modes to use as the basis for the spectral method 
%
% OUTPUTS:
% PHI_p  [Nz x Nm]  pressure and velocity structure eigenfunctions 
% C      [Nm x 1 ]  eigenspeeds 
% PHI_w  [Nz x Nm]  vertical velocity structure eigenfunctions 
%
% A good reference for spectral and pseudo-spectral methods is:
% J. P. Boyd (2001) Chebyshev and Fourier Spectral Methods: Second Revised Edition, Dover, 688p.
%
% Sam Kelly, June 2016 (smkelly@d.umn.edu)
%
% February 2017: updated to allow Nm0 as an input and to use fzero with a search interval instead of a single start point. 



% Default values are free surface boundary conditions and 10 modes
if nargin<5
    Nm0=max([64 2*Nm]); % Number of basis functions should be at least 2xNm (this may need to be modified when N2 only has entries at <64 depths)
    if nargin<4
        FS_flag=1;
        if nargin<3
            Nm=10;
        end
    end
end

% Define some constants
g=9.81;          % Gravity 
N=length(N2);    % Number of vertical grid points
z=[1:N]*dz-dz/2; % The z grid is define in the center of the dz sections
H=dz*N;          % Water depth
N20=mean(N2);    % Average buoyancy frequency squared

% Define spectral basis functions (i.e., free-surface functions in constant stratification)
if FS_flag % include surface mode for free surface
    alpha_RL=[0 [1:Nm0-1]*pi]; % alpha = HN/c 
else
    Nm=Nm-1;   % The surface mode will be added at the end...
    Nm0=Nm0-1; % Also omit the surface mode from the basis functions
    alpha_RL=[1:Nm0]*pi; 
end

phi_w=zeros([N Nm0]);
phi_w_surf=zeros([1 Nm0]);
phi_p=zeros([N Nm0]);
alpha0=alpha_RL;
for i=1:Nm0 
    if FS_flag
        % Find free-surface alpha via the roots of "func". Use rigid-lid alpha as starting guess
        func=@(alpha) alpha*sin(alpha)-N20*H/g*cos(alpha); % This is a re-statement of the surface boundary condition
        if i==1;
            alpha0(i)=fzero(func,alpha_RL(i));           
        else            
            alpha0(i)=fzero(func,[-pi/4 pi/4]+alpha_RL(i)); 
        end
    end
    
    % Define constant-N modes (alpha0_n = n*pi only for a rigid lid)
    phi_w(:,i)=sin(alpha0(i)*(1-z/H));
    phi_w_surf(i)=sin(alpha0(i));
    phi_p(:,i)=-alpha0(i)/H*cos(alpha0(i)*(1-z/H));
    
    % Normalize constant-N modes
    c20=N20*H^2/alpha0(i)^2; 
    A=sqrt(abs((mean(phi_w(:,i).^2*N20)+g/H*phi_w_surf(i).^2)/c20));
    phi_w(:,i)=phi_w(:,i)/A;
    phi_w_surf(i)=phi_w_surf(i)/A;

    A=sqrt(abs(mean(phi_p(:,i).^2)));
    phi_p(:,i)=phi_p(:,i)/A;
end

% Define A matrix (depth-varying stratification couples the constant N2 modes); Note: Although the typical finite-difference matrix is sparse (banded), this matrix of coupling coefficients is typically dense.
for i=1:Nm0
    for j=i:Nm0;
        A(i,j)=mean(N2.*phi_w(:,i).*phi_w(:,j))+g/H*phi_w_surf(i)*phi_w_surf(j);
        A(j,i)=A(i,j);
    end
end

% Solve eigenvalue problem ("x" are the expansion coefficients for the spectral basis functions)
[x,c2]=eig(A);

% Sort modes by eigenspeed and retain Nm fastest modes
c2=diag(c2);
c2(c2<0)=0;
C=sqrt(c2); % eigenspeed
[C,ind]=sort(C,1,'descend');
x=x(:,ind);
C=C(1:Nm);

% Reconstruct modes using expansion coefficients
PHI_w=zeros([N Nm]);
PHI_w_surf=zeros([1 Nm]);
PHI_p=zeros([N Nm]);
for i=1:Nm
    PHI_w(:,i)=sum(repmat(x(:,i),[1 N]).*phi_w');
    PHI_w_surf(i)=sum(x(:,i).*phi_w_surf');
    PHI_p(:,i)=sum(repmat(x(:,i),[1 N]).*phi_p');
end

% Normalize the w modes (Note: this integral is weighted by N2)
A=repmat((mean(PHI_w.^2.*repmat(N2,[1 Nm]))+g/H*PHI_w_surf.^2)./(C.^2).',[N 1]).^(1/2);
A(A==0)=Inf;
PHI_w=PHI_w./A;

% Normalize the p modes
A=repmat(mean(PHI_p.^2),[N 1]).^(1/2);
A(A==0)=Inf;
PHI_p=PHI_p./A;

% Define the p modes as positive at the surface (also flip the w modes when the p modes are flipped)
PHI_w(:,PHI_p(1,:)<0)=-PHI_w(:,PHI_p(1,:)<0);
PHI_p(:,PHI_p(1,:)<0)=-PHI_p(:,PHI_p(1,:)<0);

% Add in surface mode a posteriori if a rigid-lid was used
if FS_flag==0
    C=[sqrt(g*H); C];
    PHI_w=[zeros([N 1]) PHI_w];
    PHI_p=[ones([N 1]) PHI_p];
end

return



