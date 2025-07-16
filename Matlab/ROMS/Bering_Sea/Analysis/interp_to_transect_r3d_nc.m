function fld3d = interp_to_transect_r3d_nc(Seg,iss,time_ind,ncfile,Gdims,varname,Fld_intrp_r3d)
ln_scl=Seg.ln_scl;
lt_scl=Seg.lt_scl;

Rcount_r3d=[length(Seg(iss).iLr) length(Seg(iss).iMr) Gdims(3) 1];
fld3d=zeros([length(Seg(iss).lonsec) Gdims(3) length(time_ind(1):time_ind(end))]);
fieldv3d=zeros([Gdims(1) Gdims(2) Gdims(3)+2]);
for itt=time_ind(1):time_ind(end),
    it=itt-time_ind(1)+1;
%     file_t=char(sprintf('%s/%s',ncfile.dir,char(ncfile.name(ncfile.num(itt)))));
    file_t = [ncfile.dir, '/', ncfile.prefix, '_', num2str(itt, '%04i'), '.nc'];
%     Rstart3d=[Seg(iss).iLr(1) Seg(iss).iMr(1) 1 ncfile.recnum(itt)];        
    Rstart3d=[Seg(iss).iLr(1) Seg(iss).iMr(1) 1 1];        
%    load(file_t,varname);
%    eval(sprintf('tmpv=%s;',varname));
%    fieldv3d(Seg(iss).iLr,Seg(iss).iMr,2:end-1)=tmpv(Seg(iss).iLr,Seg(iss).iMr,:);
    fieldv3d(Seg(iss).iLr,Seg(iss).iMr,2:end-1)=double(ncread(file_t,varname,Rstart3d,Rcount_r3d));
    fieldv3d(:,:,1)=fieldv3d(:,:,2);
    fieldv3d(:,:,end)=fieldv3d(:,:,end-1);
    Fld_intrp_r3d.Values=fieldv3d(Seg(iss).Rindx_nearby_rp)';
    fld3d(:,:,it)=Fld_intrp_r3d(Seg(iss).lonseca'.*ln_scl,Seg(iss).latseca'.*lt_scl,Seg(iss).zseca')';
end
