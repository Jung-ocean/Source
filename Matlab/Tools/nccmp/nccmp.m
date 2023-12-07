function nccmp(ncfile1,ncfile2,varargin)
%NCCMP  compares two NetCDF files and prints the differences. 
% This function is useful for testing mathematical forecasting or prediction models.
%
% USAGE:
%          NCCMP(ncfile1,ncfile2)
%          NCCMP(ncfile1,ncfile2,tolerance,forceCompare)
%
% INPUT:
%    ncfile1      - name of the NetCDF file to compare
%    ncfile2      - name of the NetCDF file to compare
%    tolerance    - compare numeric data using a tolerance threshold
%    forceCompare - if false, exit when first difference is found
%                      true:  coninues to process all variables
% OUTPUT:
%
% EXAMPLES:
%    nccmp('old.nc','new.nc',0.000001)
%    nccmp('old.nc','new.nc',[],true)
%    ...
% FEATURES: 
% 1. Print the differences and their locations 
% 2. Exits when first difference is found or optionally continues to process all variables 
% 3. User defined tolerance threshold to compare the variables

% TO DO: 
% 1. Specific variable inclusion or exclusion 
% 2. Specific attribute inclusion or exclusion 
% 3. Option to ignore the history attribute 
% 4. Ignore difference between values that have different missing values etc
% See also:
%
% HISTORY:
% 1.0.0 (21-07-2014): Initial release
% 1.1.0 (21-07-2014): Option to forceCompare true or false
% 1.2.0 (16-09-2014): Input checking and clean up
% 1.3.0 (16-09-2014): Adding internal function IND2SUB1 to return single 
%                     variable IJ rather than returning I,J (length(siz)) 

% Author: Durga Lal Shrestha
% CSIRO Land & Water, Highett, Australia
% eMail: durgalal.shrestha@gmail.com
% Website: www.durgalal.co.cc
% Copyright 2014 Durga Lal Shrestha
% $First created: 21-Jul-2014
% $Revision: 1.3.0 $ $Date: 16-Sep-2014 10:06:03 $

% ***********************************************************************
%% INPUT ARGUMENTS CHECK
narginchk(2, 4)
tolerance = 0;
filesAreIdentical = true;
forceCompare = false;
if nargin>2 && ~isempty(varargin{1})
    tolerance = varargin{1};
    if ~isscalar(tolerance)
        error('NCCMP:WrongDataType','Tolerance input should be scalar')
    end
end
if nargin>3
    forceCompare = varargin{2};
    if ~isscalar(forceCompare)
        error('NCCMP:WrongDataType','Fourth argumnet should be boolean')
    end
end

% Check if files exist
if exist(ncfile1,'file')~=2 && exist(ncfile2,'file')~=2
    error('NCCMP:FileNotFound','Input files %s and %s do not exist...',ncfile1,ncfile2)
end
if exist(ncfile1,'file')~=2
    error('NCCMP:FileNotFound','Input file %s does not exist...',ncfile1)
end
if exist(ncfile2,'file')~=2
    error('NCCMP:FileNotFound','Input file %s does not exist...',ncfile2)
end


fprintf('COMPARING netcdf files: %s <> %s\n',ncfile1,ncfile2)
fprintf('...With tolerance: %1.1E\n',tolerance)
fprintf('\n')
ncid1 = netcdf.open(ncfile1,'NC_NOWRITE');
ncid2 = netcdf.open(ncfile2,'NC_NOWRITE');

%% % Get information about the contents of the file.
[numdims1, numvars1, numglobalatts1, unlimdimID1] = netcdf.inq(ncid1);
[numdims2, numvars2, numglobalatts2, unlimdimID2] = netcdf.inq(ncid2);
%ncfile2(ncid1)
%ncfile2(ncid2)

%% Get Global attributes Information
if numglobalatts1~=numglobalatts2
    fprintf('DIFFER: NUMBER OF GLOBAL ATTRIBUTES : %d <> %d\n',numglobalatts1,numglobalatts2)
    filesAreIdentical = false;
end
finfo1 = ncinfo(ncfile1);
finfo2 = ncinfo(ncfile2);

attrName1 = {finfo1.Attributes.Name};
attrName2 = {finfo2.Attributes.Name};
% Check common attribute names
comName = intersect(attrName1,attrName2);
% Check value of common attributes
for i=1:length(comName)
    attvalue1 = ncreadatt(ncfile1,'/',comName{i});
    attvalue2 = ncreadatt(ncfile2,'/',comName{i});
    if ischar(attvalue1) && ischar(attvalue1)
        if ~strcmp(attvalue1,attvalue2)
            fprintf('DIFFER: LENGTH OF GLOBAL ATTRIBUTE: %s : %d <> %d : VALUES :%s <> %s\n' ,comName{i},length(attvalue1),length(attvalue2),attvalue1,attvalue2)
            filesAreIdentical = false;
        end
    else
        if ~isequal(attvalue1,attvalue2)
            fprintf('DIFFER: LENGTH OF GLOBAL ATTRIBUTE: %s : %d <> %d : VALUES :%12.5f <> %12.5f\n' ,comName{i},length(attvalue1),length(attvalue2),attvalue1,attvalue2)
            filesAreIdentical = false;
        end
    end
end

% Check name of attributes which exist in ncfile1 but not in ncfile2
attrName1Only  = setdiff(attrName1,attrName2);
for i=1:length(attrName1Only)
    fprintf('DIFFER: NAME OF GLOBAL ATTRIBUTE: %s : GLOBAL ATTRIBUTE DOES NOT EXIST in %s\n' ,attrName1Only{i},ncfile2)
end

% Check name of attributes which exist in ncfile2 but not in ncfile1
attrName2Only  = setdiff(attrName2,attrName1);
for i=1:length(attrName2Only)
    fprintf('DIFFER: NAME OF GLOBAL ATTRIBUTE: %s : GLOBAL ATTRIBUTE DOES NOT EXIST in %s\n' ,attrName2Only{i},ncfile1)
end
fprintf('\n')
%% Get Dimension Information
if numdims1~=numdims2
    fprintf('DIFFER: NUMBER OF DIMENSION IN FILES: %d <> %d\n',numdims1,numdims2)
    filesAreIdentical = false;
end
% if ~isequal(finfo1.Dimensions,finfo2.Dimensions)
%     fprintf('Dimesnions are not same\n')
% end
dimName1 = {finfo1.Dimensions.Name};
dimName2 = {finfo2.Dimensions.Name};
% Check common attribute names
comName = intersect(dimName1,dimName2);
% Check value of common attributes
for i=1:length(comName)
    dimid1 = netcdf.inqDimID(ncid1,comName{i});
    dimid2 = netcdf.inqDimID(ncid2,comName{i});
    [dimname1, dimlen1] = netcdf.inqDim(ncid1,dimid1);
    [dimname2, dimlen2] = netcdf.inqDim(ncid2,dimid2);
    if  dimlen1 ~= dimlen2
        fprintf('DIFFER: LENGTH OF DIMENSION: %s : %d <> %d\n' ,comName{i},dimlen1,dimlen2)
    end
end
netcdf.close(ncid1);
netcdf.close(ncid2);
% Check name of attributes which exist in ncfile1 but not in ncfile2
dimName1Only  = setdiff(dimName1,dimName2);
for i=1:length(dimName1Only)
    fprintf('DIFFER: NAME OF DIMENSION: %s : DIMENSION DOES NOT EXIST in %s\n' ,dimName1Only{i},ncfile2)
end

% Check name of attributes which exist in ncfile2 but not in ncfile1
dimName2Only  = setdiff(dimName2,dimName1);
for i=1:length(dimName2Only)
    fprintf('DIFFER: NAME OF DIMENSION: %s : DIMESNION DOES NOT EXIST in %s\n' ,dimName2Only{i},ncfile1)
end
fprintf('\n')

%% Get Variable Information
if numvars1~=numvars2
    fprintf('DIFFER: NUMBER OF VARIABLE IN FILES: %d <> %d\n',numvars1,numvars2)
    filesAreIdentical = false;
end
% if ~isequal(finfo1.Variables,finfo2.Variables)
%     fprintf('Variables are not same\n')
% end

varName1 = {finfo1.Variables.Name};
varName2 = {finfo2.Variables.Name};
% Check common attribute names
[comName,ia,ib] =  intersect(varName1,varName2);
% Check value of common attributes

for i=1:length(comName)
    %     dimensions1 = finfo1.Variables(ia(i)).Dimensions;
    %     dimensions2 = finfo2.Variables(ib(i)).Dimensions;
    %     if ~isequal(dimensions1,dimensions2)
    %         %fprintf('DIFFER: DIMENSIONS: %s : %d <> %d\n' ,comName{i},dimensions1,dimensions1)
    %         fprintf('TO DO: CHECK dimension Name and Length\n')
    %     end
    size1  = finfo1.Variables(ia(i)).Size;
    size2 = finfo2.Variables(ib(i)).Size;
    if ~isequal(size1,size2)
        fprintf('DIFFER: SIZE, VARIABLE: %s : %s <> %s\n' ,comName{i},num2str(size1),num2str(size2))
    else
        DataType1  = finfo1.Variables(ia(i)).Datatype;
        DataType2  =  finfo2.Variables(ib(i)).Datatype;
        if ~strcmp(DataType1,DataType2)
            fprintf('DIFFER: TYPES, VARIABLE: %s : %s <> %s\n' ,comName{i},DataType1,DataType2)
        end
        data1=ncread(ncfile1,comName{i});
        data2=ncread(ncfile2,comName{i});
        if ~ischar(data1) && ~ischar(data2)
            dff = abs(double(data1)-double(data2));
            %             [row,col] = find(dff > tolerance);
            ind = find(dff > tolerance);
            if ~isempty(ind)
                filesAreIdentical = false;
                if forceCompare
                    for j=1:length(ind)
                        %[I1,I2,I3] = ind2sub(size1,ind(j));                       
                        X = ind2sub1(size1,ind(j));
                        fprintf('DIFFER: VARIABLE, %s : POSITION %s: VALUES: %12.20G <> %12.20G \n' ,comName{i},num2str(X),data1(ind(j)),data2(ind(j)))
                    end
                else
                    % Just report the first occurrence
                    fprintf('DIFFER: VARIABLE, %s : NUMBER OF LOCATION %d, Reporting the first location only...\n' ,comName{i},length(ind))                    
                    X = ind2sub1(size1,ind(1));
                    fprintf('DIFFER: VARIABLE, %s : POSITION %s: VALUES: %12.20G <> %12.20G \n' ,comName{i},num2str(X),data1(ind(1)),data2(ind(1)))
                end
            end
        else
            % character data
            ind = find(data1~=data2);
            if ~isempty(ind)
                filesAreIdentical = false;
                if forceCompare
                    for j=1:length(ind)
                        %[I1,I2,I3] = ind2sub(size1,ind(j));                       
                        X = ind2sub1(size1,ind(j));
                        fprintf('DIFFER: VARIABLE, %s : POSITION %s: VALUES: %12.20G <> %12.20G \n' ,comName{i},num2str(X),data1(ind(j)),data2(ind(j)))
                    end
                else
                    % Just report the first occurance
                    fprintf('DIFFER: VARIABLE, %s : NUMBER OF LOCATION %d, Reporting the first location only...\n' ,comName{i},length(ind))                   
                    X = ind2sub1(size1,ind(1));
                    fprintf('DIFFER: VARIABLE, %s : POSITION %s: VALUES: %12.20G <> %12.20G \n' ,comName{i},num2str(X),data1(ind(1)),data2(ind(1)))
                end
            end
        end
    end
    att = '';
    att = '';
    if isempty(finfo1.Variables(ia(i)).Attributes)
        fname = ncfile1;
    elseif isempty(finfo2.Variables(ib(i)).Attributes)
        fname = ncfile2;
    end
    
    if isempty(finfo1.Variables(ia(i)).Attributes) || isempty(finfo2.Variables(ib(i)).Attributes)
        if ~(isempty(finfo1.Variables(ia(i)).Attributes) && isempty(finfo2.Variables(ib(i)).Attributes))
            fprintf('DIFFER: ATTRIBUTE: VARIABLE: %s : No attributes in %s\n' ,finfo1.Variables(ia(i)).Name,fname)
        end
    else
        att1 = {finfo1.Variables(ia(i)).Attributes.Name};
        att2 = {finfo2.Variables(ib(i)).Attributes.Name};
        if length(att1)~=length(att2)
            fprintf('DIFFER: NUMBER OF ATTRIBUTE: VARIABLE: %s :  %d <> %d\n' ,finfo1.Variables(ia(i)).Name,length(att1),length(att2))
        end
        
        [comAtt,ind1,ind2] =  intersect(att1,att2);
        % Check if values are same in common attributes
        for j=1:length(comAtt)
            attvalue1 = '';
            attvalue2 = '';
            if isfield(finfo1.Variables(ia(i)),'Attributes')
                Att1= finfo1.Variables(ia(i)).Attributes;
                attvalue1  = Att1(ind1(j)).Value;
            end
            if isfield(finfo2.Variables(ib(i)),'Attributes')
                Att2= finfo2.Variables(ib(i)).Attributes;
                attvalue2  = Att2(ind2(j)).Value;
            end
            if ischar(attvalue1) && ischar(attvalue2)
                if ~strcmp(attvalue1,attvalue2)
                    fprintf('DIFFER: LENGTH, ATTRIBUTE: %s, VARIABLE: %s :%d <> %d , VALUES: %s <> %s\n' ,comAtt{j},comName{i},length(attvalue1),length(attvalue2),attvalue1,attvalue2)
                    filesAreIdentical = false;
                end
            else
                if ~isequal(attvalue1,attvalue2)
                    fprintf('DIFFER: LENGTH, ATTRIBUTE: %s, VARIABLE : %s :%d <> %d : VALUES: %12.5f <> %12.5f\n' ,comAtt{j},comName{i},length(attvalue1),length(attvalue2),attvalue1,attvalue2)
                    filesAreIdentical = false;
                end
            end
        end
        
        % Check name of attributes which exist in ncfile1 but not in ncfile2
        attrName1Only  = setdiff(att1,att2);
        for j=1:length(attrName1Only)
            fprintf('DIFFER: NAME OF ATTRIBUTE: %s : ATTRIBUTE DOES NOT EXIST in VARIABLE: %s in %s\n' ,attrName1Only{j},comName{i},ncfile2)
        end
        
        % Check name of attributes which exist in ncfile2 but not in ncfile1
        attrName2Only  = setdiff(att1,att2);
        for j=1:length(attrName2Only)
            fprintf('DIFFER: NAME OF ATTRIBUTE: %s : ATTRIBUTE DOES NOT EXIST in VARIABLE: %s in %s\n' ,attrName2Only{j},comName{i},ncfile1)
        end
    end
end

% Check name of attributes which exist in ncfile1 but not in ncfile2
varName1Only  = setdiff(varName1,varName2);
for i=1:length(varName1Only)
    fprintf('DIFFER: NAME OF VARIABLE: %s : VARIABLE DOES NOT EXIST in %s\n' ,varName1Only{i},ncfile2)
end

% Check name of attributes which exist in ncfile2 but not in ncfile1
varName2Only  = setdiff(varName2,varName1);
for i=1:length(varName2Only)
    fprintf('DIFFER: NAME OF VARIABLE: %s : VARIABLE DOES NOT EXIST in %s\n' ,varName2Only{i},ncfile1)
end
fprintf('\n')
%%
if filesAreIdentical
    % fprintf('FILES: %s and %s are identical\n' ,ncfile1,ncfile2)
    fprintf('FILES are identical\n')
end

%% Internal function ind2sub1
function IJ = ind2sub1(siz,IND)
% IND2SUB1 returns single variable IJ rather than returning I,J (length(siz)) 
% variables
if ~isvector(IND)
    error('IND2SUB1:WrongInputFormat','ind2sub1 only works with scalar and vector')     
end
IND = IND(:);
[out{1:length(siz)}] = ind2sub(siz,IND);
IJ = cell2mat(out);
