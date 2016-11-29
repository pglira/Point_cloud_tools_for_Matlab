function varargout = select(obj, selmode, varargin)
% SELECT Select a subset of points.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% The property 'act' of the point cloud object, i.e. obj.act, is a n-by-1
% logical vector defining for each point if it is active (true) or not active
% (false). Several selection strategies are provided in this function. All
% methods (except 'All') select a subset of the active points, i.e. not active
% points don't change their status.
%
% The available selection strategies are:
%    1 'All'                 -> Select all points.
%    2 'None'                -> Deactivate all points.
%    3 'RandomSampling'      -> Random sampling of points.
%    4 'IntervalSampling'    -> Select each n-th point, e.g. each 10-th point.
%    5 'UniformSampling'     -> Uniform sampling of points in space.
%    6 'MaxLeverageSampling' -> Selection of points based on their 'leverages'.
%    7 'NormalSampling'      -> Selection of points based on the normal vector.
%    8 'Attribute'           -> Selection of points based on an attribute.
%    9 'Limits'              -> Selection of points based on coordinate limits.
%   10 'InPolygon'           -> Selection of points inside a 2d polygonal region.
%   11 'InVoxelHull'         -> Selection of points included in a voxel hull.
%   12 'RangeSearch'         -> Selection of points within the range of another
%                               point cloud.
%   13 'KnnSearch'           -> Selection of K nearest neighbors for each point
%                               of another point cloud.
%   14 'GeoTiff'             -> Selection of points based on a GeoTiff file.
%   15 'Profile'             -> Selection of points in a vertical profile.
%   16 'ByIDs'               -> Selection of points by point IDs.
% ------------------------------------------------------------------------------
% 1 'All'
%   DESCRIPTION Select all points. No further inputs required.
%   EXAMPLE     pc = pointCloud('Lion.xyz');
%               pc.select('All');
% ------------------------------------------------------------------------------
% 2 'None'
%   DESCRIPTION Deactivate all points. No further inputs required.
%   EXAMPLE     pc = pointCloud('Lion.xyz');
%               pc.select('None');
% ------------------------------------------------------------------------------
% 3 'RandomSampling'
%   DESCRIPTION Random sampling of a percentage of points.
%   INPUT       [percentPoi]
%               Percentage of points to select.
%   EXAMPLE     Select 5 percent of all points.
%               pc = pointCloud('Lion.xyz');
%               pc.select('RandomSampling', 5);
%               pc.plot;
% ------------------------------------------------------------------------------
% 4 'IntervalSampling'
%   DESCRIPTION Select each n-th point based upon ordering of points in obj.X.
%   INPUT       [nthPoi]
%               Defintion of interval in which points are selected.
%   EXAMPLE     Select each 50-th point.
%               pc = pointCloud('Lion.xyz');
%               pc.select('IntervalSampling', 50);
%               pc.plot;
% ------------------------------------------------------------------------------
% 5 'UniformSampling'
%   DESCRIPTION Uniform sampling of points in space. This gives a homogeneous 
%               distribution of the selected points. For this strategy a voxel
%               structure is derived from the point cloud and the points closest
%               to each voxel center are selected. Consequently, the mean
%               sampling distance corresponds to the edge length of the voxels.
%   INPUT       [voxelSize]
%               Edge lenght of voxels used for the selection of points. Equal to
%               mean sampling distance in each coordinate direction.
%   EXAMPLE     Select points with a mean sampling distance of 3mm.
%               pc = pointCloud('Lion.xyz');
%               pc.select('UniformSampling', 3);
%               pc.plot('MarkerSize', 5);
% ------------------------------------------------------------------------------
% 6 'MaxLeverageSampling'
%   DESCRIPTION This special selection strategy is only relevant if points are
%               used for the estimation of transformation parameters (e.g. for
%               the Iterative Closest Point algorithm). For details upon this
%               selection strategy see [1]. The normal vectors are required for
%               this option.
%   INPUT       [percentPoi]
%               Percentage of points to select.
%   EXAMPLE     Select geometrically stable points.
%               pc = pointCloud('Lion.xyz');
%               pc.select('UniformSampling', 2);
%               pc.normals(1);
%               pc.select('MaxLeverageSampling', 25);
%               pc.plot('MarkerSize', 5);
% ------------------------------------------------------------------------------
% 7 'NormalSampling'
%   DESCRIPTION The aim of this strategy is to select points such that the 
%               distribution of their normals in angular space is as large as
%               possible. For this the angular space (exposition=x vs. slope=y)
%               is divided into classes of equal angular extension (e.g.
%               10 degree x 10 degree), and points are uniformly sampled among 
%               these classes. The normal vectors are required for this option.
%   INPUT       1 [percentPoi]
%                 Percentage of points to select.
%               2 ['DeltaAngleExposition' deltaAngleExposition]
%                 Class width on exposition axis (=x).
%               3 ['DeltaAngleSlope' deltaAngleSlope] 
%                 Class width on slope axis (=y).
%   EXAMPLES    1 Select 5 percent of all points.
%                 pc = pointCloud('Lion.xyz');
%                 pc.select('UniformSampling', 2);
%                 pc.normals(1);
%                 pc.select('NormalSampling', 10);
%                 pc.plot('MarkerSize', 5);
%               2 Define class widths.
%                 pc = pointCloud('Lion.xyz');
%                 pc.select('UniformSampling', 2);
%                 pc.normals(1);
%                 pc.select('NormalSampling', 10, ...
%                                             'DeltaAngleExposition', 10, ...
%                                             'DeltaAngleSlope'     , 5);
%                 pc.plot('MarkerSize', 5);
% ------------------------------------------------------------------------------
% 8 'Attribute'
%   DESCRIPTION Selection of points based on attribute values. The attribute has
%               to be a field of the structure obj.A, e.g. obj.A.roughness.
%   INPUTS      1 [attributeName]
%                 Name of attribute as char.
%               2 [attributeMinMax]
%                 Limits of attribute defined as vector with 2 elements.
%   EXAMPLE     Selection of points based on their roughness attribute.
%               pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%               % Note: the imported attributes are saved as fields in the
%               % structure pc.A, e.g. the roughness in saved in pc.A.roughness.
%               pc.select('Attribute', 'roughness', [0.01 0.3]);
%               pc.plot;
% ------------------------------------------------------------------------------
% 9 'Limits'
%   DESCRIPTION Selection of points within a selection window. The window is
%               defined by its coordinate limits in x, y and z.
%   INPUT       1 [limitsMinMax]
%                 Selection window as 3-by-2 matrix: [minX maxX
%                                                     minY maxY
%                                                     minZ maxZ]
%               2 ['Reduced', reduced]
%                 Logical value which specifies if limits are given in reduced
%                 coordinates (true) or not (false=default).
%   EXAMPLE     Selection of the lions head.
%               pc = pointCloud('Lion.xyz');
%               pc.select('Limits', [-Inf -10; -30 20; -10 Inf]);
%               pc.plot;
% ------------------------------------------------------------------------------
% 10 'InPolygon'
%   DESCRIPTION Selection of points inside of a 2d polygonal region.
%   INPUT       [polygon]
%               Matrix of size n-by-2, where each row contains the x and y
%               coordinates of one polygon vertex.
%   EXAMPLE     Selection of the lions tail.
%               pc = pointCloud('Lion.xyz');
%               pc.select('InPolygon', [45 4; 45 -7; 56 -7; 71 -2; 71 4; 63 6]);
%               pc.plot;
% ------------------------------------------------------------------------------
% 11 'InVoxelHull'
%   DESCRIPTION Selection of points inside of a specified voxel hull. This 
%               method can be used to select points in parts which are common to
%               another point cloud, i.e. in the overlapping areas of two point
%               clouds.
%   INPUT       1 [voxelHull]
%                 Voxel hull of a point cloud as a n-by-3 matrix. For the
%                 computation of a voxel hull the method getVoxelHull is
%                 recommended, see 'help pointCloud.getVoxelHull'.
%               2 [voxelSize]
%                 Edge length of voxels.
%   EXAMPLE     Two point clouds are given. Select those points of the second 
%               point cloud, which are overlapping to the first point cloud.
%               pcScan1 = pointCloud('LionScan1.xyz');
%               pcScan2 = pointCloud('LionScan2.xyz');
%               pcScan1.plot('Color', 'r');
%               pcScan2.plot('Color', 'b');
%               pcScan1.getVoxelHull(2);
%               pcScan2.select('InVoxelHull', pcScan1.voxelHull, ...
%                                             pcScan1.voxelHullVoxelSize);
%               pcScan2.plot('Color', 'm');
% ------------------------------------------------------------------------------
% 12 'RangeSearch'
%   DESCRIPTION Selection of all points within a specified distance from another
%               point cloud. This method is based upon the official function
%               'rangesearch'.
%   INPUT       1 [points]
%                 Point cloud as a n-by-3 matrix.
%               2 [searchRadius]
%                 Search radius.
%               3 ['Distance', distance]
%                 String or function handle specifying the distance metric. Run
%                 doc rangesearch for further details.
%   EXAMPLE     First select a subset of points with uniform sampling, then
%               search all points within the range of 1 from these points.
%               pc = pointCloud('Lion.xyz');
%               pc.select('UniformSampling', 5);
%               points = pc.X(pc.act,:);
%               pc.select('All');
%               pc.select('RangeSearch', points, 1);
%               pc.plot;
% ------------------------------------------------------------------------------
% 13 'KnnSearch'
%   DESCRIPTION Selection of K nearest neighbors for each point of another point
%               cloud. This method is based upon the official function
%               'knnsearch'.
%   INPUT       1 [points]
%                 Point cloud as a n-by-3 matrix.
%               2 ['K', k]
%                 Number of nearest neighbors to search.
%               3 ['Distance', distance]
%                 String or function handle specifying the distance metric. Run
%                 doc rangesearch for further details.
%   OUTPUT      [Distances]
%               Distances to nearest neighbors n-by-k matrix.
%   EXAMPLE     First select a subset of points with uniform sampling, then
%               search the 500 nearest neighbors of these points.
%               pc = pointCloud('Lion.xyz');
%               pc.select('UniformSampling', 10);
%               points = pc.X(pc.act,:);
%               pc.select('All');
%               pc.select('KnnSearch', points, 'K', 500);
%               pc.plot;
% ------------------------------------------------------------------------------
% 14 'GeoTiff'
%   DESCRIPTION Selection of points within specific cells of a geotiff file. For
%               this strategy the Mapping Toolbox is required.
%   INPUTS      1 [source]
%                 Source of geotiff file. Two possibilities are offered:
%                 1 Path to a geotiff file defined as char, e.g. 'C:\map.tif'.
%                 2 Cell containing objects A and R (see doc geotiffread),
%                   e.g. {A R}.
%               2 [minMax]
%                 Limits of cell values in which the points should be selected
%                 as vector with 2 elements.
%               3 ['RedPoi', redPoi]
%                 Optional reduction point of geotiff file specified as vector
%                 with 3 elements.
% ------------------------------------------------------------------------------
% 15 'Profile'
%   DESCRIPTION Selection of points within a vertical profile. The profile
%               is defined by start point (x/y), end point (x,y) and width.
%   INPUTS      1 [lineStart]
%                 Starting point of profile defined as vector with 2 elements:
%                 [startX startY].
%               2 [lineEnd]
%                 Ending point of profile defined as vector with 2 elements:
%                 [endX endY].
%               3 [lineWidth]
%                 Width of profile.
%   OUTPUT      [Azimuth]
%               Azimuth of profile. The azimuth can be used for the
%               visualization of the profile with view(azimuth, 0).
%   EXAMPLE     Profile through point cloud.
%               pc = pointCloud('Lion.xyz');
%               az = pc.select('Profile', [ 100 0], [-100 0], 2);
%               pc.plot; view(az,0);
% ------------------------------------------------------------------------------
% 16 'ByIDs'
%   DESCRIPTION Selection of points by point IDs. For this, the point IDs have
%               to be saved as point attribute 'id'.
%   INPUTS      [IDs2select]
%               Vector of point IDs to select.
% ------------------------------------------------------------------------------
% REFERENCES
% [1] Glira, P., Pfeifer, N., Ressl, C., Briese, C. (2015): A correspondence 
%     framework for ALS strip adjustments based on variants of the ICP 
%     algorithm. In: Journal for Photogrammetry, Remote Sensing and 
%     Geoinformation Science (PFG) 2015(04), pp. 275-289.
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

validSelmode = {'All'                 ... % 1
                'None'                ... % 2
                'RandomSampling'      ... % 3
                'IntervalSampling'    ... % 4
                'UniformSampling'     ... % 5
                'MaxLeverageSampling' ... % 6
                'NormalSampling'      ... % 7
                'Attribute'           ... % 8
                'Limits'              ... % 9
                'InPolygon'           ... % 10
                'InVoxelHull'         ... % 11
                'RangeSearch'         ... % 12
                'KnnSearch'           ... % 13
                'GeoTiff'             ... % 14
                'Profile'             ... % 15
                'ByIDs'};                 % 16

p = inputParser;
p.addRequired('selmode', @(x) any(strcmpi(x, validSelmode)));
p.parse(selmode);

%% Start -----------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'SELECT' upper(selmode)};

msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label)); 
msg('V', numel(find(obj.act)), 'number of activated points before filtering', 'Prec', 0);

% Stop function if no points are active and selection method is not 'All'
if sum(obj.act) == 0 && ~strcmpi(selmode, 'All')
    
    msg('V', numel(find(obj.act)), 'number of activated points after filtering', 'Prec', 0);
    msg('E', procHierarchy);
    return
    
end 

% Set random seed for reproducable results
% rng(0);

%% 'All' -----------------------------------------------------------------------

if strcmpi(selmode, 'All')
    
    % Activate all points
    obj.act(:) = true;
    
end

%% 'None' ----------------------------------------------------------------------

if strcmpi(selmode, 'None')
    
    % Deactivate all points
    obj.act(:) = false;

end

%% 'RandomSampling' ------------------------------------------------------------

if strcmpi(selmode, 'RandomSampling')

    % Temp: set random seed
    % rng(5);
    
    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('percentPoi', @(x) numel(x)==1 && isnumeric(x) && x>0 && x<100);
    p.parse(varargin{:});
    p = p.Results;

    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Number of points to keep active
    noPoi = floor(numel(idxAct)/100*p.percentPoi);
    
    % Indices of points which remain active
    idxRandom = randperm(numel(idxAct));
    idxRandom = idxRandom(1:noPoi); % take first noPoi elements
    % idxRandom = randi(numel(idxAct), noPoi, 1); % produces double values!
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only points in cell of the originally activated points
    obj.act(idxAct(idxRandom)) = true;
    
end

%% 'IntervalSampling' ----------------------------------------------------------

if strcmpi(selmode, 'IntervalSampling')
    
    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('nthPoi', @(x) numel(x)==1 && isnumeric(x) && x>0);
    p.parse(varargin{:});
    p = p.Results;
    
    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idx = find(obj.act);
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only each NhtPoi point of the originally activated points
    obj.act(idx(1:p.nthPoi:end)) = true;
    
end

%% 'UniformSampling' -----------------------------------------------------------

if strcmpi(selmode, 'UniformSampling')
    
    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('voxelSize', @(x) numel(x)==1 && isnumeric(x) && x>0);
    p.parse(varargin{:});
    p = p.Results;

    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Uniform sampling
    idxSelection = uniformSampling(obj.X(idxAct,:), p.voxelSize);
    
    idx2activate = idxAct(idxSelection);
    
    % Keep only one point per cluster
    knnObj = createns(obj.X(idx2activate,:)); % create new kd tree with selected points
    idx2del = [];
    [idx, dist] = knnObj.knnsearch(knnObj.X, 'K', 27); % a cluster can have a maximum of 27 points (point itself + 26 neighbour voxel)
    for i = 1:size(knnObj.X,1) % for each point
        if sum(idx2del==i) == 0 % check if actual point should already be deleted
            idxCluster = idx(i, dist(i,:) < p.voxelSize/2); % ids of all cluster points
            idx2del = [idx2del, idxCluster(2:end)]; % delete all cluster points except the actual point
        end
    end
    idx2activate(idx2del) = []; % delete points
    
    % Activate found points
    obj.act(:) = false;
    obj.act(idx2activate) = true;
    
end

%% 'MaxLeverageSampling' -------------------------------------------------------

if strcmpi(selmode, 'MaxLeverageSampling')

    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('percentPoi', @(x) numel(x)==1 && isnumeric(x) && x>0 && x<100);
    p.parse(varargin{:});
    p = p.Results;

    % Preparations -------------------------------------------------------------
    
    % Indices of all originally activated points (with or without normal vector)
    idxAct = find(obj.act);
    
    % Total number of points to select
    noPoi2select = floor(numel(idxAct) * p.percentPoi/100);
    
    % Deactivation of points without normal vector
    idxNoNormal = isnan(obj.A.nx(idxAct)) | isnan(obj.A.ny(idxAct)) | isnan(obj.A.nz(idxAct));
    obj.act(idxAct(idxNoNormal)) = false;
    msg('V', sum(idxNoNormal), 'number of deactivated points due to missing normal vector', 'Prec', 0);
	
    % Indices of all originally activated points with normal vector
    idxAct = find(obj.act);
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Select points ------------------------------------------------------------
    
    % Reduced coordinates (without reduction N = A'*A may have to large numbers)
    cog = obj.cog; % this way only one calculation of cog is necessary
    x = obj.X(idxAct,1) - cog(1);
    y = obj.X(idxAct,2) - cog(2);
    z = obj.X(idxAct,3) - cog(3);
    
    % Normal components
    nx = obj.A.nx(idxAct);
    ny = obj.A.ny(idxAct);
    nz = obj.A.nz(idxAct);
    
    % Design matrix for affine transformation (12 parameters)
    A = [nx.*x nx.*y nx.*z ... % columns  1 ...  3
         ny.*x ny.*y ny.*z ... % columns  4 ...  6
         nz.*x nz.*y nz.*z ... % columns  7 ...  9
         nx    ny    nz   ];   % columns 10 ... 12

    % 4Video
    % p2video = 'n:\Dropbox\Prj\2015-09-15_Geospatial_Week_Presentation\MLS';
    % writerObj = VideoWriter(p2video, 'Motion JPEG AVI');
    % writerObj.Quality = 80;
    % writerObj.FrameRate = 5;
    % open(writerObj);
     
    % Remove in each iteration 1 percent of observations with highest redundancy parts
    while numel(idxAct) > noPoi2select

        Qxx = inv(A'*A); % Qxx = inv(N)

        % Leverage of each observation
        h = sum((A*Qxx).*A,2);
        
        % 4Debug and 4Video
        % if ~exist('nIt'), nIt = 1; else nIt = nIt + 1; end
        % if nIt == 1, [~, idxhMax] = max(h); idx2plot = idxAct(idxhMax); end
        % plot(nIt, h(idxAct == idx2plot), '.', 'MarkerSize', 5); hold on; grid on; title(['Iteration ' num2str(nIt)]);
        % cla;
        % idxNonAct = [1:obj.noPoints]; idxNonAct(idxAct) = [];
        % plot3(obj.X(idxNonAct,1), obj.X(idxNonAct,2), obj.X(idxNonAct,3), 'k.', 'MarkerSize', 1); hold on;
        % scatter3(obj.X(idxAct,1), obj.X(idxAct,2), obj.X(idxAct,3), 10, h, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r'); grid on; title(['Iteration ' num2str(nIt)]);
        % maxCAxisLim = 0.009; % graben.xyz
        % maxCAxisLim = 0.001; % Vaihingen_crop1.xyz
        % scatter3ext(obj.X(idxAct,1), obj.X(idxAct,2), obj.X(idxAct,3), 10, h, 'CAxisLim', [0 maxCAxisLim]); grid on; title(['Maximum Leverage Sampling (Iteration ' num2str(nIt) ')'], 'FontSize', 15);
        
        % 4Video
        % el = 60; % graben.xyz
        % el = 30; % Vaihingen_crop1.xyz
        % view(-37.5, el);
        % set(gcf, 'Position', [0 0 1080 810]);
        % set(gcf, 'Color', 'w');
        % set(gca, 'Color', 'w');
        % xlim([min(obj.X(:,1)) max(obj.X(:,1))]);
        % ylim([min(obj.X(:,2)) max(obj.X(:,2))]);
        % zlim([min(obj.X(:,3)) max(obj.X(:,3))]);
        % frame = getframe(gcf);
        % writeVideo(writerObj,frame);
        
        % maximize; p2images = 'N:\mls'; mkdir(p2images); screencapture(gcf, [], fullfile(p2images, sprintf('iteration%03d.png', nIt)));
        
        % Limit for leverages
        hMin = quantile(h, 0.02);

        % Delete observations (i.e. rows in A) with to low leverages
        idx2del = find(h < hMin);
        if isempty(idx2del), [~, idx2del] = min(h); end % if no point was found below the limit, select the point with the lowest leverage
        A(idx2del, :)   = [];
        idxAct(idx2del) = [];
        
    end
    
    % 4Video
    % for i = 1:30, writeVideo(writerObj,frame); end
    % close(writerObj);
    
    % Reactivate selected points
    obj.act(idxAct) = true;
    
end

%% 'NormalSampling' ------------------------------------------------------------

if strcmpi(selmode, 'NormalSampling')

    % Temp: set random seed
    rng(9);
    
    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired( 'percentPoi'               , @(x) numel(x)==1 && isnumeric(x) && x>0 && x<100);
    p.addParameter('DeltaAngleExposition', 10 , @(x) numel(x)==1 && isnumeric(x) && x>0 && mod(400,x)==0);
    p.addParameter('DeltaAngleSlope'     , 2.5, @(x) numel(x)==1 && isnumeric(x) && x>0 && mod(100,x)==0);
    p.parse(varargin{:});
    p = p.Results;

    % Preparations -------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Add attributes exposition and slope temporarily if not present
    if ~isfield(obj.A, 'exposition'), obj.addAttribute('exposition'); delExp = true; else delExp = false; end
    if ~isfield(obj.A, 'slope')     , obj.addAttribute('slope');      delSlo = true; else delSlo = false; end
    
    % Points in normal space
    XNormalSpace = [obj.A.exposition(idxAct) obj.A.slope(idxAct)];
    
    % 4Debug
    % figure; obj.plot('Attribute', 'exposition', 'MarkerSize', 5);
    % figure; obj.plot('Attribute', 'slope', 'MarkerSize', 5);
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Assign to each point an angle class --------------------------------------
    
    % Initialize class counter
    actClass = 0;
    
    % Initialize class id for each point
    idxClass = NaN(numel(idxAct),1);
    
    % For each class
    for e = 0:p.DeltaAngleExposition:400-p.DeltaAngleExposition % exposition
        
        for s = 0:p.DeltaAngleSlope:100-p.DeltaAngleSlope % slope
            
            actClass = actClass + 1;

            % Find points in actual class
            idxPoiInActClass = XNormalSpace(:,1) >= e & XNormalSpace(:,1) <= e+p.DeltaAngleExposition & ... % <= instead of <, so that all points are assigned to a class
                               XNormalSpace(:,2) >= s & XNormalSpace(:,2) <= s+p.DeltaAngleSlope;
            
            idxClass(idxPoiInActClass) = actClass;
        
        end
        
    end
    
    % Total number of classes
    noClasses = actClass;
    
    % Number of points in actual class
    for i = 1:noClasses, noPoiPerClass(i,1) = sum(idxClass == i); end
    
    % 4Debug
    % figure; scatter3ext(obj.X(idxAct,1), obj.X(idxAct,2), obj.X(idxAct,3), 5, idxClass, 'ColorMap', 'colorcube');
    
    % Find number of points to select in each class ----------------------------
    
    % Total number of points to select
    noPoi2select = floor(numel(idxAct) * p.percentPoi/100);
    
    % Initialize vector with selected number of points per class
    noSelectedPointsPerClass = zeros(noClasses,1); % actClass corresponds to number of classes
    
    i = 0;
    
    while sum(noSelectedPointsPerClass) < noPoi2select
        
        % Find classes with more than i points
        idxLog = noPoiPerClass > i; % logical indices
        idx = find(idxLog); % non logical indices
        
        % Number of remaining points to select
        noRemainingPoints = noPoi2select - sum(noSelectedPointsPerClass);
        
        % If more points would be added than necessary, select a subset of the indices
        if numel(idx) > noRemainingPoints
            idx = idx(randperm(numel(idx), noRemainingPoints));
        end
        
        % Add one point from all selected classes
        noSelectedPointsPerClass(idx) = i+1;
        
        i = i+1;
        
    end
    
    % Selection of points in classes -------------------------------------------
    
    for c = 1:noClasses
        
        idxLogInClass = idxClass == c;
        idxInClass = find(idxLogInClass);
        n = numel(idxInClass); % no. of points in actual class
        k = noSelectedPointsPerClass(c);
        idxSel = randperm(n, k);
        obj.act(idxAct(idxInClass(idxSel))) = true;
        
    end
    
    % 4Debug
    % figure; scatter3ext(XNormalSpace(:,1), XNormalSpace(:,2), zeros(size(XNormalSpace(:,1),1),1), 10, idxClass); view(2); axis equal; xlim([0 400]); ylim([0 100]); grid on; set(gca, 'XTick', 0:p.DeltaAngleExposition:400, 'YTick', 0:p.DeltaAngleSlope:100); set(gca,'layer','top');
    % hold on; plot(obj.A.exposition(obj.act), obj.A.slope(obj.act), 'ro', 'MarkerSize', 5);
    % figure; subplot(2,1,1); bar(noPoiPerClass); subplot(2,1,2); bar(noSelectedPointsPerClass)
    
    % Delete temporary attributes
    if delExp, obj.A = rmfield(obj.A, 'exposition'); end
    if delSlo, obj.A = rmfield(obj.A, 'slope');      end
    
end

%% 'Attribute' -----------------------------------------------------------------

if strcmpi(selmode, 'Attribute')

    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('attributeName'  , @ischar);
    p.addRequired('attributeMinMax', @(x) numel(x)==2 && isnumeric(x));
    p.parse(varargin{:});
    p = p.Results;
    
    % Filtering ----------------------------------------------------------------
    
    actAttribute = obj.A.(p.attributeName) >= min(p.attributeMinMax) & ...
                   obj.A.(p.attributeName) <= max(p.attributeMinMax);
            
    obj.act = obj.act & actAttribute;
    
end

%% 'Limits' --------------------------------------------------------------------

if strcmpi(selmode, 'Limits')

    % Input parsing ------------------------------------------------------------

    p = inputParser;
    p.addRequired( 'limitsMinMax', @(x) isnumeric(x) && size(x,1)==3 && size(x,2)==2);
    p.addParameter('Reduced', false, @islogical);
    p.parse(varargin{:});
    p = p.Results;

    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Find points within limits
    if ~p.Reduced % if limits are NOT given in reduced coordinates
    
        idxInLimits = obj.X(idxAct,1) >= min(p.limitsMinMax(1,:))-obj.redPoi(1) & ...
                      obj.X(idxAct,1) <= max(p.limitsMinMax(1,:))-obj.redPoi(1) & ...
                      obj.X(idxAct,2) >= min(p.limitsMinMax(2,:))-obj.redPoi(2) & ...
                      obj.X(idxAct,2) <= max(p.limitsMinMax(2,:))-obj.redPoi(2) & ...
                      obj.X(idxAct,3) >= min(p.limitsMinMax(3,:))-obj.redPoi(3) & ...
                      obj.X(idxAct,3) <= max(p.limitsMinMax(3,:))-obj.redPoi(3);
                  
    else % if limits are given in reduced coordinates
        
        idxInLimits = obj.X(idxAct,1) >= min(p.limitsMinMax(1,:)) & ...
                      obj.X(idxAct,1) <= max(p.limitsMinMax(1,:)) & ...
                      obj.X(idxAct,2) >= min(p.limitsMinMax(2,:)) & ...
                      obj.X(idxAct,2) <= max(p.limitsMinMax(2,:)) & ...
                      obj.X(idxAct,3) >= min(p.limitsMinMax(3,:)) & ...
                      obj.X(idxAct,3) <= max(p.limitsMinMax(3,:));
    
    end
              
	% Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only points within limits
    obj.act(idxAct(idxInLimits)) = true;
    
end

%% 'InPolygon' -----------------------------------------------------------------

if strcmpi(selmode, 'InPolygon')
    
    % Input parsing ------------------------------------------------------------

    p = inputParser;
    p.addRequired('polygon', @(x) isnumeric(x) && size(x,2)==2);
    p.parse(varargin{:});
    p = p.Results;
    
    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Find points inside polygon
    idxInPolygon = inpolygon(obj.X(idxAct, 1), ...
                             obj.X(idxAct, 2), ...
                             p.polygon(:,1), ...
                             p.polygon(:,2));
              
	% Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only points within polygon
    obj.act(idxAct(idxInPolygon)) = true;
    
end

%% 'InVoxelHull' ---------------------------------------------------------------

if strcmpi(selmode, 'InVoxelHull')
    
    % Input parsing ------------------------------------------------------------

    p = inputParser;
    p.addRequired('voxelHull', @(x) isnumeric(x) && size(x,2)==3);
    p.addRequired('voxelSize', @(x) numel(x)==1 && isnumeric(x) && x>0);
    p.parse(varargin{:});
    p = p.Results;
    
    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Rangesearch
    idxInVoxel = rangesearch(obj.X(idxAct,:), p.voxelHull, p.voxelSize/2, 'Distance', 'Chebychev');
    idxInVoxel = [idxInVoxel{:}];
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate points which were activated and are within voxel hull
    obj.act(idxAct(idxInVoxel)) = true;
    
end

%% 'RangeSearch' ---------------------------------------------------------------

if strcmpi(selmode, 'RangeSearch')
    
    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired( 'points'                      , @(x) isnumeric(x) && size(x,2)==3);
    p.addRequired( 'searchRadius'                , @(x) numel(x)==1 && isnumeric(x) && x>0);
    p.addParameter('Distance'       , 'euclidean', @ischar);
    % Undocumented
    p.addParameter('MaxPointDensity', Inf        , @(x) isnumeric(x) && x>0);
    p.parse(varargin{:});
    p = p.Results;
    
    bucketSize = 1000;
    
    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Rangesearch
    idxInRange = rangesearch(obj.X(idxAct,:), p.points, p.searchRadius, 'Distance', p.Distance, 'BucketSize', bucketSize);
    
    % Consider maximum point density within each 'island'
    if ~isinf(p.MaxPointDensity)
        areaIsland = p.searchRadius^2*pi;
        maxNoPointsPerIsland = ceil(p.MaxPointDensity * areaIsland);
        for i = 1:numel(idxInRange)
            noPointsInIsland = numel(idxInRange{i});
            if noPointsInIsland > maxNoPointsPerIsland
                idxRandom = randperm(noPointsInIsland, maxNoPointsPerIsland);
                idxInRange{i} = idxInRange{i}(idxRandom);
            end
        end
    end
    
    % Merge
    idxInRange = [idxInRange{:}];
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate points which were activated and are within voxel hull
    obj.act(idxAct(idxInRange)) = true;
    
end

%% 'KnnSearch' -----------------------------------------------------------------

if strcmpi(selmode, 'KnnSearch')
    
    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired( 'points'                , @(x) isnumeric(x) && size(x,2)==3);
    p.addParameter('K'       , 1           , @(x) numel(x)==1 && isnumeric(x) && x>0);
    p.addParameter('Distance', 'euclidean' , @ischar);
    p.parse(varargin{:});
    p = p.Results;
    
    bucketSize = 1000;
    
    % Filtering ----------------------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    if nargout == 1 % save also distances
        [idxKnn, varargout{1}] = knnsearch(obj.X(idxAct,:), p.points, 'K', p.K, 'Distance', p.Distance, 'BucketSize', bucketSize);
    else
                        idxKnn = knnsearch(obj.X(idxAct,:), p.points, 'K', p.K, 'Distance', p.Distance, 'BucketSize', bucketSize);
    end
    obj.act(:) = false; % deactivate all points
    obj.act(idxAct(idxKnn)) = true; % reactivate only nn

end

%% 'GeoTiff' -------------------------------------------------------------------

if strcmpi(selmode, 'GeoTiff')

    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired( 'source'         , @(x) iscell(x) || ischar(x));
    p.addRequired( 'minMax'         , @(x) numel(x)==2 && isnumeric(x));
    p.addParameter('RedPoi', [0 0 0], @(x) isnumeric(x) && size(x,1)==1 && size(x,2)==3);
    p.parse(varargin{:});
    p = p.Results;
    
    % Import -------------------------------------------------------------------
    
    % File import
    if ischar(p.source) && exist(p.source) == 2
        [A, R] = geotiffread(p.source);
    end

    % Data import
    if iscell(p.source)
        A = p.source{1};
        R = p.source{2};
    end
    
    % Consider reduction point of GeoTiff
    R.XLimWorld = R.XLimWorld+p.RedPoi(1);
    R.YLimWorld = R.YLimWorld+p.RedPoi(2);
    
    % Filtering ----------------------------------------------------------------
    
    % Find all values within defined value range
    [row, col] = find(A >= p.minMax(1) & A <= p.minMax(2));
    
    % Transformation from row, column coord.sys. to global coord.sys.
    [x, y] = R.intrinsicToWorld(col, row);
    
    % Consider reduction point of point cloud
    x = x-obj.redPoi(1);
    y = y-obj.redPoi(2);
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Indices of all points, which are in the selected cells
    idxInCells = rangesearch(obj.X(idxAct,1:2), [x y], R.DeltaX/2, 'Distance', 'Chebychev');
    idxInCells = [idxInCells{:}];
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only points in cell of the originally activated points
    obj.act(idxAct(idxInCells)) = true;
    
end

%% 'Profile' -------------------------------------------------------------------

if strcmpi(selmode, 'Profile')

    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('lineStart', @(x) numel(x)==2 && isnumeric(x));
    p.addRequired('lineEnd'  , @(x) numel(x)==2 && isnumeric(x));
    p.addRequired('lineWidth', @(x) numel(x)==1 && isnumeric(x) && x>0);
    p.parse(varargin{:});
    p = p.Results;
    
    % Create polygon -----------------------------------------------------------
    
    % Delta profile line
    dL = [p.lineEnd(1)-p.lineStart(1) p.lineEnd(2)-p.lineStart(2) 0];
      
    % Delta profile in polar coordinates (for azimuth)
    dLPolar = xyz2polar(dL);
    az = dLPolar(2);
    varargout{1} = az*9/10 + 180; % azimuth in degree!!! (to use with 'view(az, 0)')
      
    % Create polygon
    polygon(1,:) = [p.lineStart(1) p.lineStart(2) 0] + polar2xyz([p.lineWidth/2 az-100 100]);
    polygon(2,:) = [p.lineStart(1) p.lineStart(2) 0] + polar2xyz([p.lineWidth/2 az+100 100]);
    polygon(3,:) = [p.lineEnd(1)   p.lineEnd(2)   0] + polar2xyz([p.lineWidth/2 az+100 100]);
    polygon(4,:) = [p.lineEnd(1)   p.lineEnd(2)   0] + polar2xyz([p.lineWidth/2 az-100 100]);
    
    % Select points within polygon ---------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
        
    % Points within polygon
    idxInPolygon = inpolygon(obj.X(idxAct,1), obj.X(idxAct,2), polygon(:,1), polygon(:,2));
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only points within polygon
    obj.act(idxAct(idxInPolygon)) = true;
        
    % 4Debug -------------------------------------------------------------------
    
    % plot([p.lineStart(1); p.lineEnd(1)], [p.lineStart(2); p.lineEnd(2)], 'rx'); axis equal; hold on;
    % plot(polygon(:,1), polygon(:,2), 'b.-');
    
end

%% 'ByIDs' ---------------------------------------------------------------------

if strcmpi(selmode, 'ByIDs')

    % Input parsing ------------------------------------------------------------
    
    p = inputParser;
    p.addRequired('IDs2select', @isnumeric);
    p.parse(varargin{:});
    p = p.Results;
    
    % Check if attribute 'id' is present
    attributes = fieldnames(obj.A);
    if ~any(strcmp(attributes, 'id'))
        error('Attribute ''id'' required for selection mode ''ByIDs''!');
    end
    
    % Select points by IDs -----------------------------------------------------
    
    % Indices of all originally activated points
    idxAct = find(obj.act);
    
    % Find IDs
    [~, idxByIDs] = intersect(obj.A.id(idxAct), p.IDs2select);
    
    % Deactivate all points
    obj.act(:) = false;
    
    % Reactivate only points selected by ID
    obj.act(idxAct(idxByIDs)) = true;
    
end

%% End -------------------------------------------------------------------------

msg('V', numel(find(obj.act)), 'number of activated points after filtering', 'Prec', 0);
msg('E', procHierarchy);

end