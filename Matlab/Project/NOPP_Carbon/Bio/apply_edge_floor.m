function [V, nlift] = apply_edge_floor(V, fl, wet)

%
% APPLY_EDGE_FLOOR:  Floors a boundary edge field at a per-time value
%
% [V, nlift] = apply_edge_floor(V, fl, wet)
%
% Raises every wet point of a boundary edge field to at least the floor
% for its time record, and leaves land points at exactly zero so the land
% mask stays visible in the file.
%
% On Input:
%
%    V           Edge field, [nspace nlevel ntime]
%    fl          Floor value per time record, [ntime 1]
%    wet         Logical mask of wet points along the edge, [nspace 1]
%
% On Output:
%
%    V           Floored field
%    nlift       Number of wet values that were below the floor
%

nlift = 0;

for it = 1:size(V,3)
  slab  = V(:,:,it);
  sub   = slab(wet,:);
  nlift = nlift + sum(sub(:) < fl(it));
  sub(sub < fl(it)) = fl(it);
  slab(wet,:) = sub;
  V(:,:,it) = slab;
end

V(~wet,:,:) = 0;

return
