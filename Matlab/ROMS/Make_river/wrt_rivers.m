function [Vname,status]=wrt_rivers(Fname,River);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% function [Vname,status]=wrt_rivers(Fname,River)                           %
%                                                                           %
% This function writes river data to a existing FORCING NetCDF file.        %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Fname       FORCING NetCDF file name (string).                         %
%    River       River data (structure array).                              %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Vname       Names of river variables (structure array).                %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global IPRINT

IPRINT=0;

%----------------------------------------------------------------------------
%  Get some NetCDF parameters.
%----------------------------------------------------------------------------

[ncglobal]=mexcdf('parameter','nc_global');
[nclong]=mexcdf('parameter','nc_long');
[ncdouble]=mexcdf('parameter','nc_double');
[ncunlim]=mexcdf('parameter','nc_unlimited');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

%----------------------------------------------------------------------------
%  Inquire about dimensions.
%----------------------------------------------------------------------------

Nrec=length(River.time);
[Nrivers,N]=size(River.vshape);

gotDim.xr   =0;  Dname.xr   ='xi_rho';
gotDim.yr   =0;  Dname.yr   ='eta_rho';
gotDim.sr   =0;  Dname.sr   ='s_rho';       Dsize.sr   =N;
gotDim.River=0;  Dname.River='river';       Dsize.River=Nrivers;
gotDim.Rtime=0;  Dname.Rtime='river_time';  Dsize.Rtime=Nrec;

[Dnames,Dsizes]=nc_dim(Fname);
ndims=length(Dsizes);
for n=1:ndims,
  dimid=n;
  name=deblank(Dnames(n,:));
  switch name
  case {Dname.xr}
    Dsize.xr=Dsizes(n);
    did.xr=dimid-1;
    gotDim.xr=1;
  case {Dname.yr}
    Dsize.yr=Dsizes(n);
    did.yr=dimid-1;
    gotDim.yr=1;
  case {Dname.sr}
    Dsize.sr=Dsizes(n);
    did.sr=dimid-1;
    gotDim.sr=1;
  case {Dname.River}
    Dsize.River=Dsizes(n);
    did.River=dimid-1;
    gotDim.River=1;
  case {Dname.Rtime}
    Dsize.Rtime=Dsizes(n);
    did.Rtime=dimid-1;
    gotDim.Rtime=1;
  end,
end,

%----------------------------------------------------------------------------
%  Inquire variables.
%----------------------------------------------------------------------------

got.Rnum   =0;  Vname.Rnum   ='river';
got.Rxpos  =0;  Vname.Rxpos  ='river_Xposition';
got.Rypos  =0;  Vname.Rypos  ='river_Eposition';
got.Rdir   =0;  Vname.Rdir   ='river_direction';
got.Rflag  =0;  Vname.Rflag  ='river_flag';
got.Rvshape=0;  Vname.Rvshape='river_Vshape';
got.Rtime  =0;  Vname.Rtime  ='river_time';
got.Rtrans =0;  Vname.Rtrans ='river_transport';
got.Rtemp  =0;  Vname.Rtemp  ='river_temp';
got.Rsalt  =0;  Vname.Rsalt  ='river_salt';


[varnam,nvars]=nc_vname(Fname);
for n=1:nvars,
  name=deblank(varnam(n,:));
  switch name
    case {Vname.Rnum}
      got.Rnum=1;
    case {Vname.Rxpos}
      got.Rxpos=1;
    case {Vname.Rypos}
      got.Rypos=1;
    case {Vname.Rdir}
      got.Rdir=1;
    case {Vname.Rflag}
      got.Rflag=1;
    case {Vname.Rvshape}
      got.Rvshape=1;
    case {Vname.Rtime}
      got.Rtime=1;
    case {Vname.Rtrans}
      got.Rtrans=1;
    case {Vname.Rtemp}
      got.Rtemp=1;
    case {Vname.Rsalt}
      got.Rsalt=1;
  end,
end,

defmode=~got.Rnum | ~got.Rxpos | ~got.Rypos | ~got.Rdir | ~got.Rflag | ...
        ~got.Rvshape | ~got.Rtime | ~got.Rtrans | ~got.Rtemp | ~got.Rsalt;

%----------------------------------------------------------------------------
%  Open FORCING NetCDF file and put it in definition mode.
%----------------------------------------------------------------------------


if (defmode),
  [ncid]=mexcdf('ncopen',Fname,'nc_write');
  if (ncid == -1),
    error(['WRT_RIVERS: ncopen - unable to open file: ', Fname])
    return
  end
  [status]=mexcdf('ncredef',ncid);
  if (status == -1),
    error(['WRT_RIVERS: ncrefdef - unable to put into define mode.'])
    return
  end
end,

%----------------------------------------------------------------------------
%  If appropriate, define river dimensions.
%----------------------------------------------------------------------------

if (~gotDim.sr),
  [did.sr]=mexcdf('ncdimdef',ncid,Dname.sr,Dsize.sr);
  if (did.sr == -1),
    error(['WRT_RIVERS: ncdimdef - unable to define dimension: ',Dname.sr]);
  end,
end,

if (~gotDim.River),
  [did.River]=mexcdf('ncdimdef',ncid,Dname.River,Dsize.River);
  if (did.River == -1),
    error(['WRT_RIVERS: ncdimdef - unable to define dimension: ', ...
           Dname.River]);
  end,
end,

if (~gotDim.Rtime),
  [did.Rtime]=mexcdf('ncdimdef',ncid,Dname.Rtime,Dsize.Rtime);
  if (did.Rtime == -1),
    error(['WRT_RIVERS: ncdimdef - unable to define dimension: ', ...
           Dname.Rtime]);
  end,
end,

%----------------------------------------------------------------------------
%  Create global attribute.
%----------------------------------------------------------------------------

if (defmode)
  i = 1;
  text=[ '(' int2str(i) ')' River.Name(i,:)];
  for i=2:Nrivers,
     name=[ '(' int2str(i) ')' River.Name(i,:)];
     lstr=length(name);
     if (lstr > 2), text=strcat(text,', ',name(1:lstr)); end,
  end,
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,ncglobal,'rivers',ncchar,lstr,text);
  if (status == -1),
    error(['WRT_RIVERS: ncattput - unable to global attribure: rivers.']);
    return
  end,
end,

%----------------------------------------------------------------------------
%  Define river variables.
%----------------------------------------------------------------------------

if (~got.Rnum),
  Var.name =Vname.Rnum;
  Var.type =ncdouble;
  Var.dimid=[did.River];
  Var.long ='river runoff identification number';
  Var.units='nondimensional';
  Var.field=[Vname.Rnum,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rxpos),
  Var.name =Vname.Rxpos;
  Var.type =ncdouble;
  Var.dimid=[did.River];
  Var.long ='river XI-position at RHO-points';
  Var.units='nondimensional';
  Var.min  =1;
  Var.max  =Dsize.xr-1;
  Var.field=[Vname.Rxpos,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rypos),
  Var.name =Vname.Rypos;
  Var.type =ncdouble;
  Var.dimid=[did.River];
  Var.long ='river ETA-position at RHO-points';
  Var.units='nondimensional';
  Var.min  =1;
  Var.max  =Dsize.yr-1;
  Var.field=[Vname.Rypos,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rdir),
  Var.name =Vname.Rdir;
  Var.type =ncdouble;
  Var.dimid=[did.River];
  Var.long ='river runoff direction';
  Var.units='nondimensional';
  Var.field=[Vname.Rdir,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rflag),
  Var.name =Vname.Rflag;
  Var.type =ncdouble;
  Var.dimid=[did.River];
  Var.long ='river runoff tracer flag';
  Var.units='nondimensional';
  Var.opt_0='all tracers are off';
  Var.opt_1='only temperature is on';
  Var.opt_2='only salinity is on';
  Var.opt_3='both temperature and salinity are on';
  Var.field=[Vname.Rflag,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
  defmode=1;
end,

if (~got.Rvshape),
  Var.name =Vname.Rvshape;
  Var.type =ncdouble;
  Var.dimid=[did.sr did.River];
  Var.long ='river runoff mass transport vertical profile';
  Var.units='nondimensional';
  Var.field=[Vname.Rvshape,', scalar'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rtime),
  Var.name =Vname.Rtime;
  Var.type =ncdouble;
  Var.dimid=[did.Rtime];
  Var.long ='river runoff time';
  if isfield(River,'time_units')
    Var.units=River.time_units;
    Var.offset = julian(parsetnc(Var.units));
  else
    Var.units='Julian day';
    Var.offset=2440000;
  end  
  Var.field=[Vname.Rtime,', scalar, series'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rtrans),
  Var.name =Vname.Rtrans;
  Var.type =ncdouble;
  Var.dimid=[did.Rtime did.River];
  Var.long ='river runoff vertically integrated mass transport';
  Var.units='meter3 second-1';
  Var.time =Vname.Rtime;
  Var.field=[Vname.Rtrans,', scalar, series'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rtemp),
  Var.name =Vname.Rtemp;
  Var.type =ncdouble;
  Var.dimid=[did.Rtime did.sr did.River];
  Var.long ='river runoff potential temperature';
  Var.units='Celsius';
  Var.time =Vname.Rtime;
  Var.field=[Vname.Rtemp,', scalar, series'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

if (~got.Rsalt),
  Var.name =Vname.Rsalt;
  Var.type =ncdouble;
  Var.dimid=[did.Rtime did.sr did.River];
  Var.long ='river runoff salinity';
  Var.units='PSU';
  Var.time =Vname.Rtime;
  Var.field=[Vname.Rsalt,', scalar, series'];
  [varid,status]=nc_vdef(ncid,Var);
  clear Var
end,

%----------------------------------------------------------------------------
%  Leave definition mode.
%----------------------------------------------------------------------------

if (defmode),
  [status]=mexcdf('ncendef',ncid);
  if (status == -1),
    error(['WRT_RIVERS: ncendef - unable to leave definition mode.'])
  end,
  [status]=mexcdf('ncclose',ncid);
  if (status == -1),
    error(['WRT_RIVERS: ncclose - unable to close NetCDF file: ', Iname])
  end
end,

%----------------------------------------------------------------------------
%  Write out river data.
%----------------------------------------------------------------------------

[status]=nc_write(Fname,Vname.Rnum,River.num);
[status]=nc_write(Fname,Vname.Rxpos,River.Xpos);
[status]=nc_write(Fname,Vname.Rypos,River.Ypos);
[status]=nc_write(Fname,Vname.Rdir,River.dir);
[status]=nc_write(Fname,Vname.Rflag,River.flag);
[status]=nc_write(Fname,Vname.Rvshape,River.vshape);
[status]=nc_write(Fname,Vname.Rtime,River.time);
[status]=nc_write(Fname,Vname.Rtrans,River.trans);
[status]=nc_write(Fname,Vname.Rtemp,River.temp);
[status]=nc_write(Fname,Vname.Rsalt,River.salt);


