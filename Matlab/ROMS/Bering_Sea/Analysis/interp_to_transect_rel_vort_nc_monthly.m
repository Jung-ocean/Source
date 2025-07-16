function fld3d = interp_to_transect_rel_vort_nc_monthly(Seg,iss,time_ind,ncfile,Gdims,dxp,dyp,Fld_intrp_p)
ln_scl=Seg.ln_scl;
lt_scl=Seg.lt_scl;

Rcount_u=[length(Seg(iss).iLu) length(Seg(iss).iMu)+2 Gdims(3) 1];
Rcount_v=[length(Seg(iss).iLv)+2 length(Seg(iss).iMv) Gdims(3) 1];
fld3d=zeros([length(Seg(iss).lonsec) Gdims(3) length(time_ind(1):time_ind(end))]);
fieldutmp=zeros([Gdims(1)-1 Gdims(2) Gdims(3)+2]);
fieldvtmp=zeros([Gdims(1) Gdims(2)-1 Gdims(3)+2]);
indMu=Seg(iss).iMu(1)-1:Seg(iss).iMu(end)+1;
indLv=Seg(iss).iLv(1)-1:Seg(iss).iLv(end)+1;

for itt=time_ind,
    it=itt-time_ind(1)+1;

    ystr = num2str(ncfile.yyyy);
    mstr = num2str(itt, '%02i');

%     file_t=char(sprintf('%s/%s',ncfile.dir,char(ncfile.name(ncfile.num(itt)))));
    file_t = [ncfile.filepath, ncfile.exp, '_', ystr, mstr, '.nc'];
    Rstart_u=[Seg(iss).iLu(1) Seg(iss).iMu(1) 1 ncfile.recnum(itt)];
    Rstart_v=[Seg(iss).iLv(1) Seg(iss).iMv(1) 1 ncfile.recnum(itt)];
    
    fieldutmp(Seg(iss).iLu,indMu,2:end-1)=ncread(file_t,'u',Rstart_u,Rcount_u);
    fieldutmp(:,:,1)=fieldutmp(:,:,2);
    fieldutmp(:,:,end)=fieldutmp(:,:,end-1);
    
    fieldvtmp(indLv,Seg(iss).iMv,2:end-1)=ncread(file_t,'v',Rstart_v,Rcount_v);
    fieldvtmp(:,:,1)=fieldvtmp(:,:,2);
    fieldvtmp(:,:,end)=fieldvtmp(:,:,end-1);
    
    du_dy=diff(fieldutmp,1,2)./repmat(dyp,[1 1 Gdims(3)+2]);
    dv_dx=diff(fieldvtmp,1,1)./repmat(dxp,[1 1 Gdims(3)+2]);
    rel_vort=dv_dx-du_dy;
    
    Fld_intrp_p.Values=rel_vort(Seg(iss).Rindx_nearby_pp)';
    fld3d(:,:,it)=Fld_intrp_p(Seg(iss).lonseca'.*ln_scl,Seg(iss).latseca'.*lt_scl,Seg(iss).zseca')';
    it
end
