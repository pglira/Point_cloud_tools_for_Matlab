function idxSelection = uniformSampling(X, voxelSize)

% Preparations -----------------------------------------------------------------

% No. of points
noPoi = size(X,1);

% Logical indices for selection of points (true = selected)
idxSelection = false(noPoi,1);

% Find voxel centers -----------------------------------------------------------

% Point with smallest coordinates
minPoi = min(X, [], 1);
    
% Rounded local origin for voxel structure (voxels of different pcs have coincident voxel centers if mod(100, voxelSize) == 0)
localOrigin = (floor(minPoi/100))*100;

% Find 3-dimensional indices of voxels in which points are lying
idxVoxel = [floor( (X(:,1)-localOrigin(1)) / voxelSize ) ...
            floor( (X(:,2)-localOrigin(2)) / voxelSize ) ...
            floor( (X(:,3)-localOrigin(3)) / voxelSize )];

% Remove multiple voxels
[idxVoxelUnique, ~, ic] = unique(idxVoxel, 'rows'); % ic contains "voxel index" for each point

% Coordinates of voxel centers
XVoxelCenter = [localOrigin(1) + voxelSize/2 + idxVoxelUnique(:,1)*voxelSize ...
                localOrigin(2) + voxelSize/2 + idxVoxelUnique(:,2)*voxelSize ...
                localOrigin(3) + voxelSize/2 + idxVoxelUnique(:,3)*voxelSize];

% No. of voxel (equal to no. of selected points)
noVoxel = size(XVoxelCenter,1);
    
% Select points nearest to voxel centers ---------------------------------------

% Sort indices and points (in order to find points inside of voxels very fast in the next loop)
[ic, idxSort] = sort(ic);
X = X(idxSort,:);

idxJump = find(diff(ic));

% Example (3 voxel)
% ic         = [1 1 1 2 2 2 3]';
% diff(ic)   = [ 0 0 1 0 0 1 ]';
% idxJump    = [     3     6 ]';
%
% idxInVoxel = [1 2 3]; for voxel 1
% idxInVoxel = [4 5 6]; for voxel 2
% idxInVoxel = [7    ]; for voxel 3

for i = 1:noVoxel

    % Find indices of points inside of voxel (very, very fast this way)
    if i == 1
        idxInVoxel = [1:idxJump(i)];
    elseif i == noVoxel
        idxInVoxel = [idxJump(i-1)+1:noPoi];
    else
        idxInVoxel = [idxJump(i-1)+1:idxJump(i)];
    end
    
    % Distance of points to voxel center
    dist2voxelCenter = sqrt((X(idxInVoxel,1)-XVoxelCenter(i,1)).^2 + (X(idxInVoxel,2)-XVoxelCenter(i,2)).^2 + (X(idxInVoxel,3)-XVoxelCenter(i,3)).^2);
    
    % Find index of point with smallest distance to voxel center
    [~, idxSelectedPoi] = min(dist2voxelCenter);
    
    % Select point
    idxSelection(idxSort(idxInVoxel(idxSelectedPoi))) = true;
    
    % 4Debug
    % idxInVoxel
    % idxSelectedPoi
    % XVoxelCenter(i,:)
    % X(idxInVoxel,:)
    % dist2voxelCenter
    % maxDist = sqrt(3*(voxelSize/2)^2);
    % correct(i) = all(dist2voxelCenter <= maxDist);
    
end

end