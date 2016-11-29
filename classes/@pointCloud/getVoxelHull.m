function getVoxelHull(obj, voxelSize, varargin)
% GETVOXELHULL Compute the voxel hull of a point cloud.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * The voxel hull is a low resolution representation of the volume occupied by
%   a point cloud. For the computation of the voxel hull the object space is
%   subdivided into a voxel structure. The voxel hull of the point cloud
%   consists of all voxels which contain at least one point of the point cloud.
%
% * Only active points are considered for the computation of the voxel hull.
%
% * The voxel hull can be used to select points, which are overlapping with
%   another point cloud. An example for this task is given in the documentation
%   of the 'select' method. For this call 'help pointCloud.select' and see the
%   examples for the 'InVoxelHull' selection strategy.
% ------------------------------------------------------------------------------
% INPUT
% 1 [voxelSize]
%   Voxel size (equal to edge length) of a single voxel.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 [obj]
%   The voxel hull is attached to the following properties of the ouput object:
%   * obj.voxelHull          = n-by-3 matrix containing the x, y, z coordinates 
%                              of the centers of the voxels
%   * obj.voxelHullVoxelSize = edge length of voxels (given by parameter
%                              voxelSize)
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Import a point cloud and compute its voxel hull.
%   pc = pointCloud('Lion.xyz');
%   pc.getVoxelHull(5); % voxel size is 5mm
%   % The voxel hull can now be found in pc.voxelHull and pc.voxelHullVoxelSize 
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('voxelSize', @(x) isscalar(x) && x>0);
% Undocumented
p.addParameter('Centroids', false, @islogical);
p.parse(voxelSize, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear voxelSize

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'GETVOXELHULL'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));
    
% Compute voxel hull -----------------------------------------------------------

% Lower left point of activated points
lim.min = min(obj.X(obj.act,:), [], 1);
% Round origin (voxel hulls have coincident voxel centers if mod(100, p.voxelSize) == 0)
lim.min = (floor(lim.min/100))*100;

% Indices of voxel cells in x, y and z direction (indices start with 0!)
idxXYZ = [floor( (obj.X(obj.act,1) - lim.min(1)) / p.voxelSize ) ...
          floor( (obj.X(obj.act,2) - lim.min(2)) / p.voxelSize ) ...
          floor( (obj.X(obj.act,3) - lim.min(3)) / p.voxelSize )];

% Remove multiple points to get unique voxels
[voxel, ~, ic] = unique(idxXYZ, 'rows'); % ic for centroids

% Transformation of indices to coordinate system and save to object
obj.voxelHull = [lim.min(1) + p.voxelSize/2 + voxel(:,1) * p.voxelSize ...
                 lim.min(2) + p.voxelSize/2 + voxel(:,2) * p.voxelSize ...
                 lim.min(3) + p.voxelSize/2 + voxel(:,3) * p.voxelSize];

% Round voxel hull (because e.g. -100+0.025+1982*0.05 ~= -0.875)
if p.voxelSize < 1
    noDigits = abs(floor(log10(p.voxelSize)-1)) + 2; % e.g. for 0.05 -> noDigits = 3+2 = 5 (+2 is arbitrary choice to be on the safe side)
    obj.voxelHull = round(obj.voxelHull, noDigits);
end
             
% Save voxel size to object
obj.voxelHullVoxelSize = p.voxelSize;

% Calculate centroids within each voxel ----------------------------------------

if p.Centroids
    
    % Add centroid matrix
    obj.voxelHull = [obj.voxelHull zeros(size(voxel,1),3)];
    
    % Centroid for each voxel
    % Var1
    % tic;
    % for i = 1:size(voxel,1), obj.voxelHull(i,4:6) = mean(obj.X(ic == i,:),1); end
    % toc;
    % c1 = obj.voxelHull(:,4:6);
    
    % Var2
    % tic;
    % cellX = cell(size(voxel,1),1);
    % for i = 1:size(voxel,1), cellX{i,1} = obj.X(ic == i,:); end
    % cellMean = cellfun(@(x) mean(x,1), cellX, 'UniformOutput', false);
    % obj.voxelHull(:,4:6) = vertcat(cellMean{:});
    % toc;
    % c2 = obj.voxelHull(:,4:6);
    
    % Var3
    % tic;
    % cellMean = arrayfun(@(x) mean(obj.X(ic == x,:),1), [1:size(voxel,1)]', 'UniformOutput', false);
    % obj.voxelHull(:,4:6) = vertcat(cellMean{:});
    % toc;
    % c3 = obj.voxelHull(:,4:6);
    
    % Var4
    % tic;
    [~, idx] = sort(ic);
    Xs = obj.X(idx,:);
    rowDist = diff(find([1; diff(ic(idx)); 1]));
    cellX = mat2cell(Xs, rowDist);
    cellMean = cellfun(@(x) mean(x,1), cellX, 'UniformOutput', false);
    obj.voxelHull(:,4:6) = vertcat(cellMean{:});
    % toc;
    % c4 = obj.voxelHull(:,4:6);
    
end
             
% End --------------------------------------------------------------------------

msg('E', {'POINTCLOUD' 'GETVOXELHULL'});

end