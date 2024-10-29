function fld3d = interp_to_transect_u3d_nc_monthly(Seg,iss,time_ind,ncfile,Gdims,varname,Fld_intrp_u3d)
ln_scl=Seg.ln_scl;
lt_scl=Seg.lt_scl;
Rcount_u3d=[length(Seg(iss).iLu) length(Seg(iss).iMu) Gdims(3) 1];
fld3d=zeros([length(Seg(iss).lonsec) Gdims(3) length(time_ind(1):time_ind(end))]);
fieldv3d=zeros([Gdims(1)-1 Gdims(2) Gdims(3)+2]);
for itt=time_ind(1):time_ind(end),
    it=itt-time_ind(1)+1;

    ystr = num2str(ncfile.yyyy);
    mstr = num2str(itt, '%02i');

%     file_t=char(sprintf('%s/%s',ncfile.dir,char(ncfile.name(ncfile.num(itt)))));
    file_t = [ncfile.filepath, ncfile.exp, '_', ystr, mstr, '.nc'];
%    load(file_t,varname);
    Rstart3d=[Seg(iss).iLu(1) Seg(iss).iMu(1) 1 ncfile.recnum(itt)];
%    eval(sprintf('tmpv=%s;',varname));
%   fieldv3d(Seg(iss).iLu,Seg(iss).iMu,2:end-1)=tmpv(Seg(iss).iLu,Seg(iss).iMu,:);
    fieldv3d(Seg(iss).iLu,Seg(iss).iMu,2:end-1)=double(ncread(file_t,varname,Rstart3d,Rcount_u3d));
    fieldv3d(:,:,1)=fieldv3d(:,:,2);
    fieldv3d(:,:,end)=fieldv3d(:,:,end-1);
    Fld_intrp_u3d.Values=fieldv3d(Seg(iss).Rindx_nearby_up)';
    fld3d(:,:,it)=Fld_intrp_u3d(Seg(iss).lonseca'.*ln_scl,Seg(iss).latseca'.*lt_scl,Seg(iss).zseca')';
end
