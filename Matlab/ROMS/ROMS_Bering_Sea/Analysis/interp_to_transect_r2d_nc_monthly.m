function fld2d = interp_to_transect_r2d_nc_monthly(Seg,iss,time_ind,ncfile,Gdims,varname,Fld_intrp_r2d)
ln_scl=Seg.ln_scl;
lt_scl=Seg.lt_scl;

Rcount_r2d=[length(Seg(iss).iLr) length(Seg(iss).iMr) 1];
fld2d=zeros([length(Seg(iss).lonsec) length(time_ind(1):time_ind(end))]);
fieldv2d=zeros([Gdims(1) Gdims(2)]);
for itt=time_ind(1):time_ind(end),
    it=itt-time_ind(1)+1;

    ystr = num2str(ncfile.yyyy);
    mstr = num2str(itt, '%02i');

%     file_t=char(sprintf('%s/%s',ncfile.dir,char(ncfile.name(ncfile.num(itt)))));
    file_t = [ncfile.filepath, ncfile.exp, '_', ystr, mstr, '.nc'];
    Rstart2d=[Seg(iss).iLr(1) Seg(iss).iMr(1) ncfile.recnum(itt)];        
%    load(file_t,varname);
%    eval(sprintf('tmpv=%s;',varname));
%    fieldv2d(Seg(iss).iLr,Seg(iss).iMr,2:end-1)=tmpv(Seg(iss).iLr,Seg(iss).iMr,:);
    try
       fieldv2d(Seg(iss).iLr,Seg(iss).iMr)=double(ncread(file_t,varname,Rstart2d,Rcount_r2d));
    catch
       fieldv2d(Seg(iss).iLr,Seg(iss).iMr)=zeros(Rcount_r2d);
    end
    Fld_intrp_r2d.Values=fieldv2d(Seg(iss).Rindx_nearby_r2d);
    fld2d(:,it)=Fld_intrp_r2d(Seg(iss).lonsec.*ln_scl,Seg(iss).latsec.*lt_scl)';
end
