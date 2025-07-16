function fld2d = interp_to_transect_v2d_nc_monthly(Seg,iss,time_ind,ncfile,Gdims,varname,Fld_intrp_v2d)
ln_scl=Seg.ln_scl;
lt_scl=Seg.lt_scl;
Rcount_v2d=[length(Seg(iss).iLv) length(Seg(iss).iMv) 1];
fld2d=zeros([length(Seg(iss).lonsec) length(time_ind(1):time_ind(end))]);
fieldv2d=zeros([Gdims(1) Gdims(2)-1]);
for itt=time_ind(1):time_ind(end),
    it=itt-time_ind(1)+1;

    ystr = num2str(ncfile.yyyy);
    mstr = num2str(itt, '%02i');

%     file_t=char(sprintf('%s/%s',ncfile.dir,char(ncfile.name(ncfile.num(itt)))));
    file_t = [ncfile.filepath, ncfile.exp, '_', ystr, mstr, '.nc'];
%    load(file_t,varname);
    Rstart2d=[Seg(iss).iLv(1) Seg(iss).iMv(1) ncfile.recnum(itt)];
%    eval(sprintf('tmpv=%s;',varname));
%   fieldv3d(Seg(iss).iLu,Seg(iss).iMu,2:end-1)=tmpv(Seg(iss).iLu,Seg(iss).iMu,:);
    fieldv2d(Seg(iss).iLv,Seg(iss).iMv)=double(ncread(file_t,varname,Rstart2d,Rcount_v2d));
    Fld_intrp_v2d.Values=fieldv2d(Seg(iss).Rindx_nearby_v2d);
    fld2d(:,it)=Fld_intrp_v2d(Seg(iss).lonsec'.*ln_scl,Seg(iss).latsec'.*lt_scl)';
end
