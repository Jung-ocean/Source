function fld_avg=Cgrd_avg(fld,dim);
% This is (finally) a general function to average 2,3 or 4 dimensional arrays
% as on a C-grid, neighboring points in the specified dimension (dim) are
% averaged.
ndims=length(size(fld));
if dim>ndims 
    fld_avg=[];
    fprintf('error: variable has fewer than %d dimensions \n',dim);
    return
end
switch dim
    case 2,
        fld=shiftdim(fld,1);
    case 3
        fld=shiftdim(fld,2);
    case 4
        fld=shiftdim(fld,3);
end
switch ndims
    case 2,
        fld_avg=shiftdim(0.5.*(fld(2:end,:)+fld(1:end-1,:)),ndims-(dim-1));
    case 3,
        fld_avg=shiftdim(0.5.*(fld(2:end,:,:)+fld(1:end-1,:,:)),ndims-(dim-1));
    case 4,
        fld_avg=shiftdim(0.5.*(fld(2:end,:,:,:)+fld(1:end-1,:,:,:)),ndims-(dim-1));
end
end

       