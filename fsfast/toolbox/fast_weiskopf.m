function [roivar, nroi, roivar0] = fast_weiskopf(fslice,radlist,porder,seed)
% [roivar, nroi, roivar0] = fast_weiskopf(fslice,<radlist>,<porder>,<seed>)
%
% Computes the variance over an ROI of a given number of voxels.
%
% fslice - functional data [nr nc nf] = size(fslice);
% radlist - list of "radii"
% porder - detrend with polynomial of given order.
% seed - center radius as [r0 c0] = seed. Default center of slice.
%
% When fslice is white, then the following two curves should be the
% same: loglog(nroi,roivar,nroi,1./nroi)
%
% $Id: fast_weiskopf.m,v 1.2 2004/05/04 05:05:34 greve Exp $
%
% (c) Douglas N. Greve, 2004

roivar = [];
nroi = [];

if(nargin < 1 | nargin > 4)
  fprintf('[roivar nroi roivar0] = fast_weiskopf(fslice,<radlist>,<porder>,<seed>)\n');
  return;
end

[nr nc nf] = size(fslice);
nv = nr*nc;
if(nf == 1)
  fprintf('ERROR: fslice only have one frame\n');
  return;
end


if(~exist('seed','var')) seed = []; end
if(isempty(seed)) 
  r0 = round(nr/2) + 1;
  c0 = round(nc/2) + 1;
else
  r0 = seed(1);
  c0 = seed(2);
end

if(~exist('radlist','var')) radlist = []; end
if(isempty(radlist)) 
  radmax = min(round(nr/2)-1,round(nc/2)-1);
  radlist = [1:radmax];
end

fslice = reshape(fslice,[nv nf])';

if(~exist('porder','var')) porder = []; end
if(~isempty(porder)) 
  X = fast_polytrendmtx(1,nf,1,porder);
  R = eye(nf) - X*inv(X'*X)*X';
  fslice = R*fslice;
end

nradlist = length(radlist);
for nthrad = 1:nradlist
  rad = radlist(nthrad);
  r = r0 + [-rad:rad];
  c = c0 + [-rad:rad];
  if(min(r)<1 | max(r)>nr  | min(c)<1 | max(c)>nc)
    fprintf('ERROR: radius %g is too large for seed/slice slice\n',rad);
    roivar = []; nroi = [];
    return;
  end
  m = zeros(nr,nc);
  m(r,c) = 1;
  ind = find(m);
  nroi(nthrad) = length(ind);
  fslicemnroi = mean(fslice(:,ind),2);
  roivar(nthrad) = std(fslicemnroi).^2;
end

% Compute the vox-by-vox mean variance over max rad
rad = max(radlist);
r = r0 + [-rad:rad];
c = c0 + [-rad:rad];
m = zeros(nr,nc);
m(r,c) = 1;
ind = find(m);
roivar0 = mean(std(fslice(:,ind)).^2);

return;

