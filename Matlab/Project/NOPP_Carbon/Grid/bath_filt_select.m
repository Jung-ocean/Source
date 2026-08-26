function [h_filt,it,rmx,fmx] = bath_filt_select(h_in, fmsku, fmskv, r_crit, f_crit)
% This function selectively filters bathymetry. It takes in bathymetry, 
% mask information, and filtering stopping criteria. It uses roifilt 
% to selectively only filter regions where r-factors exceed the required
% criteria (r_crit). Filtering is considered complete when only f_crit
% fraction of the grid points exceed r_crit, or when the maximum number of
% iterations is exceeded. 
% The routine returns the smoothed bathymetry, the number of iterations
% taken, and final values of maximum r_crit(rmx) and f_crit(fmx).

% % So let's say we want to filter until 99% of data points
% % have an r-factor in both the x and y direction less than 0.25.
% r_crit=0.25;
% f_crit=0.01;

%Hfilt=fspecial('average',30);
% The last parameter here controls how 'hard' the filter is. I have not
% tested extensively if a gaussian is the best filter to use.
Hfilt=fspecial('gaussian',[3 3],0.4);
%Hfilt=fspecial('laplacian',0.2);


% I am allowing the depths at land masked coastal points to change so that
% coastal ocean points have more ability to change with the filtering?

fixed_mask=ones(size(h_in));
% Should we hold the edge of the box fixed?
fixed_mask(1,:)=0;fmsku(1,:)=0;fmskv(1,:)=0;
fixed_mask(end,:)=0;fmsku(end,:)=0; fmskv(end,:)=0;
fixed_mask(:,1)=0;fmsku(:,1)=0;fmskv(:,1)=0;
fixed_mask(:,end)=0;fmsku(:,end)=0; fmskv(:,end)=0;

fieldt=h_in;
field_min=min(min(fieldt));
field_range=(max(max(fieldt)-min(min(fieldt))));
% Create a normalized depth field for the image filter.
fieldtI=((fieldt-min(min(fieldt)))./(max(max(fieldt)-min(min(fieldt))))*1000)+1;
[L,M]=size(fieldtI);
Lm=L-1;Mm=M-1;
rx0tr=zeros(size(fieldtI));
ry0tr=zeros(size(fieldtI));

% Determine initial r-factors
it=1;
h_filt=(fieldtI-1)*field_range./1000.0+field_min;
[rx0t, ry0t] = rfactor0(h_filt);
% get the average rfactors at the interior rho-points and mask
% those rho points if rfactor criteria is met.
rx0tr(2:Lm,:)=Cgrd_avg(rx0t.*fmsku,1);
ry0tr(:,2:Mm)=Cgrd_avg(ry0t.*fmskv,2);
rxrmp = max(rx0tr,ry0tr);
rmask1 = (rxrmp>r_crit/2);
% our adaptive mask must at least include points surrounding any point
% that has an r-factor that's too high.
rmask2 = rmask1;
rmask2(2:end-1,2:end-1)=rmask1(1:end-2,2:end-1)+rmask1(2:end-1,2:end-1) ...
    +rmask1(3:end,2:end-1);
rmask2(2:end-1,2:end-1)=rmask2(2:end-1,1:end-2)+rmask2(2:end-1,2:end-1) ...
    +rmask2(2:end-1,3:end);
rmask3 =(rmask2>0);
sum_rmsk =sum(rmask3);
fr_mask=fixed_mask .*rmask3;
% the fmsku and fmskv don't need to be updated because all newly masked
% values should already be less than the r-criteria.
rxchk(it)=max(max(rx0t.*fmsku));
rychk(it)=max(max(ry0t.*fmskv));
frx(it) = sum(rx0t(:)>r_crit)./(Lm*Mm);
fry(it) = sum(ry0t(:)>r_crit)./(Lm*Mm);

%rmx=max(rxchk(it),rychk(it));
%rmx_old=rmx+0.1;
it = it+1;
rxchk(it)=max(max(rx0t.*fmsku));
rychk(it)=max(max(ry0t.*fmskv));
frx(it) = sum(rx0t(:)>r_crit)./(Lm*Mm);
fry(it) = sum(ry0t(:)>r_crit)./(Lm*Mm);
fmx = max(frx(it),fry(it));

rmx=max(rxchk(it),rychk(it));
no_better = 1;
unmasked_points =1;
while  it < 300 && rmx> r_crit && fmx>f_crit
    while no_better && unmasked_points
        it = it +1;
        nhNans = sum(sum(isnan(fieldtI))); 
        fieldtI=roifilt2(Hfilt,fieldtI,fr_mask);
        h_filt=(fieldtI-1)*field_range./1000.0+field_min;

        [rx0t, ry0t] = rfactor0(h_filt);
        rx0tr(2:Lm,:)=Cgrd_avg(rx0t.*fmsku,1);
        ry0tr(:,2:Mm)=Cgrd_avg(ry0t.*fmskv,2);
        rxrmp = max(rx0tr,ry0tr);
        rxchk(it)=max(max(rx0t.*fmsku));
        rychk(it)=max(max(ry0t.*fmskv));
        rmx=max(rxchk(it),rychk(it));
        frx(it) = sum(rx0t(:)>r_crit)./(Lm*Mm);
        fry(it) = sum(ry0t(:)>r_crit)./(Lm*Mm);
        fmx = max(frx(it),fry(it));
        rmask1 = (rxrmp>r_crit/2);
        rmask2 = rmask1;
        rmask2(2:end-1,2:end-1)=rmask1(1:end-2,2:end-1)+rmask1(2:end-1,2:end-1) ...
            +rmask1(3:end,2:end-1)+rmask1(2:end-1,1:end-2)+rmask1(2:end-1,3:end);
        % IF the filtering is stuck because of mask limits, broaden the
        % filtered area.
        if (rxchk(it)>=rxchk(it-1) || rychk(it)>=rychk(it-1) ) && no_better<20
            no_better = no_better+1;
            for in = 1:no_better
                rmask2(2:end-1,2:end-1)=rmask2(1:end-2,2:end-1)+rmask2(2:end-1,2:end-1) ...
                    +rmask2(3:end,2:end-1)+rmask2(2:end-1,1:end-2)+rmask2(2:end-1,3:end);
            end
        else
            no_better = 0;
        end
        rmask3 = (rmask2>0);
        if max(max(rmask3))==0
            unmasked_points=0;
        end
        fr_mask=fixed_mask.*rmask3;
        %no_better,rmx,
    end
    no_better=1;
end

end