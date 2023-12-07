function [ NEAMP NEPH  NUAMP NUPH  NVAMP NVPH NAMES PERIOD]= read_adcirc_tdb(XOUT,YOUT,MASK)
grdfile='./ec2001.grd';
constfile='./ec2001.tdb';

%GET CONSTITUENTS

fid=fopen(constfile,'r');

NHC= fscanf(fid,'%f',1);
C=textscan(fid,'%f%f%f%s',NHC);
FREQ=C{1};
NFACT=C{2};
EQARG=C{3};
NAMES=char(C{4});
PERIOD=2*pi*(1./FREQ)./3600;

NPP= fscanf(fid,'%f',1);
EAMP=nan(NPP,NHC);
EPH=nan(NPP,NHC);
UAMP=nan(NPP,NHC);
UPH=nan(NPP,NHC);
VAMP=nan(NPP,NHC);
VPH=nan(NPP,NHC);

for inpp=1:NPP
    J1=fscanf(fid,'%f',(NHC*2)+1);
    EAMP(inpp,:)=J1(2:2:end);
    EPH(inpp,:)=J1(3:2:end);
    J2=fscanf(fid,'%f',(NHC*2));
    UAMP(inpp,:)=J2(1:2:end);
    UPH(inpp,:)=J2(2:2:end);
    J3=fscanf(fid,'%f',(NHC*2));
    VAMP(inpp,:)=J3(1:2:end);
    VPH(inpp,:)=J3(2:2:end);
end

fclose(fid)

fid=fopen(grdfile,'r');
agrid= fscanf(fid,'%s',1)
tmp= fscanf(fid,'%f',2)
NE=tmp(1);
NP=tmp(2);
X=nan(1,NP);
Y=nan(1,NP);
Z=nan(1,NP);
for inp=1:NP
    
    tmp= fscanf(fid,'%f',4);
    JKI=tmp(1);
    X(JKI)=tmp(2);
    Y(JKI)=tmp(3);
    Z(JKI)=tmp(4);
    
end



NM1=nan(1,NE);
NM2=nan(1,NE);
NM3=nan(1,NE);

for ine=1:NE
    
    tmp= fscanf(fid,'%f',5);
    JKI=tmp(1);
    NHY=tmp(2);
    NM1(JKI)=tmp(3);
    NM2(JKI)=tmp(4);
    NM3(JKI)=tmp(5);
end

fclose(fid)


DIMS=size(XOUT);

NEAMP=nan(NHC,DIMS(1),DIMS(2));
NEPH=nan(NHC,DIMS(1),DIMS(2));
NUAMP=nan(NHC,DIMS(1),DIMS(2));
NUPH=nan(NHC,DIMS(1),DIMS(2));
NVAMP=nan(NHC,DIMS(1),DIMS(2));
NVPH=nan(NHC,DIMS(1),DIMS(2));

NOUT=length(XOUT(:));

disp('GRIDDING')
for ihc=1:NHC
     NAMES(ihc,:)
     
    %ELEVATION
    TAMP=EAMP(:,ihc);
    TPH=EPH(:,ihc);
    A=TAMP.*cos(TPH.*pi/180);
    B=TAMP.*sin(TPH.*pi/180);
    NA=griddata(X,Y,A,XOUT,YOUT);
    NB=griddata(X,Y,B,XOUT,YOUT);
    NA(MASK==0)=0;
    NB(MASK==0)=0;
    NEAMP(ihc,:,:)=sqrt(NA.^2+NB.^2);
    NEPH(ihc,:,:)=mod(atan2(NB,NA)*180/pi,360);
    
     
    %U
    TAMP=UAMP(:,ihc);
    TPH=UPH(:,ihc);
    A=TAMP.*cos(TPH.*pi/180);
    B=TAMP.*sin(TPH.*pi/180);
    NA=griddata(X,Y,A,XOUT,YOUT);
    NB=griddata(X,Y,B,XOUT,YOUT);
    NA(MASK==0)=0;
    NB(MASK==0)=0;
    NUAMP(ihc,:,:)=sqrt(NA.^2+NB.^2);
    NUPH(ihc,:,:)=mod(atan2(NB,NA)*180/pi,360);
    %V
    TAMP=VAMP(:,ihc);
    TPH=VPH(:,ihc);
    A=TAMP.*cos(TPH.*pi/180);
    B=TAMP.*sin(TPH.*pi/180);
    NA=griddata(X,Y,A,XOUT,YOUT);
    NB=griddata(X,Y,B,XOUT,YOUT);
    NA(MASK==0)=0;
    NB(MASK==0)=0;
    NVAMP(ihc,:,:)=sqrt(NA.^2+NB.^2);
    NVPH(ihc,:,:)=mod(atan2(NB,NA)*180/pi,360);
    
    
    
end

%REMOVE STEADY COMPONENT
PERIOD=PERIOD(2:end);
NAMES=NAMES(2:end,:);
NEAMP=NEAMP(2:end,:,:);
NEPH=NEPH(2:end,:,:);
NUAMP=NUAMP(2:end,:,:);
NUPH=NUPH(2:end,:,:);
NVAMP=NVAMP(2:end,:,:);
NVPH=NVPH(2:end,:,:);

