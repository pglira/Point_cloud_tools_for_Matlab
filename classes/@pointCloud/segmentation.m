function obj = segmentation(obj, r, varargin)
% SEGMENTATION Segmentation of point cloud in plane elements.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * This method adds an attribute 'segId' for each point, which contains the
%   segment id. Two segment ids have a special meaning:
%   * segId = 0 -> for isolated points (no neighbours within radius r)
%   * segId = 1 -> for points from small segments (where the no. of points is
%                  smaller than minNoPoints)
% * This segmentation algorithm is modified from [1].
% * This algorithm needs the normal vector for each point (attributes nx, ny, 
%   nz). The normal vectors can be calculated with the method 'normals' (for 
%   help run 'help pointCloud.normals').
% ------------------------------------------------------------------------------
% INPUT
% 1 [r]
%   Radius for segment growing.
%
% 2 ['dAngleMax', dAngleMax]
%   A point is only added to an existing segment, if the difference between its
%   normal and the segment normal is smaller than dAngleMax.
%
% 3 ['MinNoPoints', minNoPoints]
%   Minimum number of points in a segments. To segments with a lower number of
%   points the segmentation id 0 is assigned.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Segment point cloud.
%   pc = pointCloud('Lion.xyz');
%   pc.segmentation(3, 5);
% ------------------------------------------------------------------------------
% REFERENCES
% [1] Rabbani T., 2006: Automatic Reconstruction of Industrial Installations
%     Using Point Clouds and Images
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'r'          , @(x) isscalar(x) && x>0);
p.addParameter('dAngleMax'  , 10, @(x) isscalar(x) && x>0);
p.addParameter('MinNoPoints', 100, @(x) isscalar(x) && x>0);
p.parse(r, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear r

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'SEGMENTATION'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Preparations -----------------------------------------------------------------

% Indices of activated points
idxAct = find(obj.act);

X = obj.X(idxAct,:);
N = [obj.A.nx(idxAct) obj.A.ny(idxAct) obj.A.nz(idxAct)];
segId = NaN(numel(idxAct),1);

% Search neighbors of each point -----------------------------------------------

msg('S', {procHierarchy{:} 'NNSEARCH'});

% NN of each point
[idxNN, dist] = knnsearch(X, X, 'K', 2);

idxNN = idxNN(:,2);
dist  = dist(:,2);

msg('E', {procHierarchy{:} 'NNSEARCH'});

% Find segments ----------------------------------------------------------------

segId = findSegments(X, N, segId, idxNN, dist, p);

% Report results ---------------------------------------------------------------

for i = 0:max(obj.A.segId)
    switch i
        case 0
            addInfo = '(isolated points)';
        case 1
            addInfo = '(too small segments)';
        otherwise
            addInfo = '';
    end
               
    msg('V', sum(obj.A.segId == i), sprintf('number of points in segment with segId=%d %s', i, addInfo), 'Prec', 0);
end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end

function percent = percentSegmentedPoints(obj)

    percent = sum(~isnan(obj.A.segId)) / obj.noPoints * 100;

end