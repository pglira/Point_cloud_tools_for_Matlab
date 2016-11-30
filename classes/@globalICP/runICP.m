function runICP(obj, varargin)
% RUNICP Run ICP algorithm.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% With this method the global ICP process is started. For a short description of
% the ICP algorithm, run 'help globalICP.globalICP'.
% ------------------------------------------------------------------------------
% INPUT
% 1 GENERAL ICP
%   a ['MaxNoIt', MaxNoit]
%     Maximum number of ICP iterations.
%
%   b ['IdxFixedPointClouds', IdxFixedPointClouds]
%     Index i of fixed point cloud. Index i refers to obj.PC{i}. To fix more
%     than one point cloud, multiple values can be defined as row vector.
%
%   c ['NoOfTransfParam', NoOfTransfParam]
%     Number of transformation parameters that are used in the ICP algorithm for
%     the transformation of the loose point clouds. Possible choices are 1, 3, 
%     6, 7 or 12:
%     *  1 = only z translation parameter.
%     *  3 = only 3 translation parameters (in x, y, and z).
%     *  6 = rigid body transformation, i.e. 3 translation parameters plus
%            3 rotational parameters.
%     *  7 = similarity transformation, i.e. rigid body transformation plus an
%            additional scale parameter.
%     * 12 = affine transformation (9 parameters) and 3 translation
%            parameters.
%
% 2 DETERMINE POINT CLOUD OVERLAP
%   a ['HullVoxelSize', HullVoxelSize]
%     Voxel size of voxel hulls. The voxel hulls are used to determine the
%     overlap between the point clouds. This parameter defines the voxel size
%     (equal to edge length) of a single voxel.
%
%     Side note: What is the voxel hull of a point cloud?
%     The voxel hull is a low resolution representation of the volume occupied
%     by a point cloud. For the computation of the voxel hull the object space
%     is subdivided into a voxel structure. The voxel hull of the point cloud
%     consists of all voxels which contain at least one point of the point
%     cloud.
%
% 3 SELECTION OF CORRESPONDENCES
%   a ['UniformSamplingDistance', UniformSamplingDistance]
%     Mean distance between corresponding points. The selection of
%     correspondences is based on a uniform sampling strategy. For this a voxel
%     structure is derived from the point clouds and those points which are
%     closest to each voxel center are selected. This parameter defines the edge
%     length of the voxels. This strategy leads to a homogeneus distribution of
%     the selected points in object space.
%       
% 4 PLANE FITTING
%   a ['PlaneSearchRadius', PlaneSearchRadius]
%     Search radius for plane fitting. All points within the search radius are
%     considered for the plane fitting. A good choice of the search radius is
%     based on the point cloud density and the geometry of the scanned object.
%     Note: to ensure a certain redundancy, planes are only considered if the
%     search area contains at least 8 points.
%
% 5 WEIGHTING
%   a ['WeightByRoughness', WeightByRoughness]
%     Logical value defining if correspondences are weighted on basis of the
%     roughness of corresponding points.
%
%   b ['WeightByDeltaAngle', WeightByDeltaAngle]
%     Logical value defining if correspondences are weighted on basis of the
%     angle between the normals of corresponding points.
%
% 6 REJECTION OF CORRESPONDENCES
%   a ['MaxDeltaAngle', MaxDeltaAngle]
%     Maximum allowed angle (in degree) between normals of corresponding points.
%
%   b ['MaxDistance', MaxDistance]
%     Maximum allowed point to point distance between corresponding points.
%
%   c ['MaxSigmaMad', MaxSigmaMad]
%     This option is used to remove correspondence outliers. All correspondences
%     with a point to plane distance (dp) outside the range
%     [-MaxSigmaMad*SigmaMad(dp) +MaxSigmaMad*SigmaMad(dp)] are rejected.
%     Note: SigmaMad is a robust estimator for the standard deviation of a data
%           set under the assumption that the set has a Gaussian distribution:
%           SigmaMad = 1.4812 * mad; where mad is the median of the absolute
%           differences (with respect to the median) of the data set.
%
%   d ['MaxRoughness', MaxRoughness]
%     Maximum allowed roughness of extracted planes. As roughness measure the
%     standard deviation of plane fitting is used.
% 
% 7 REPORT
%   a ['LogLevel', LogLevel]
%     Possible choices:
%     * 'debug' -> all informations are displayed in workspace.
%     * 'basic' -> only basic informations are displayed in workspace.
%     * 'off'   -> no informations are displayed in workspace.
%
%   b ['Plot', Plot]
%     If true, the point clouds are visualized after each ICP iteration.
%
% 8 ADVANCED PARAMETERS
%   a ['SubsetRadius', subsetRadius]
%     Radius for the selection of point cloud subsets. Background: for large
%     point clouds, usually it is not possible to load all point clouds in
%     memory simultaneously. Thus, only a small subset of points has to be
%     selected for each point cloud. For this points are selected around the
%     established correspondences within a specific radius, which is defined by
%     this parameter.
% ------------------------------------------------------------------------------
% CODEBLOCK FOR INPUT PARAMETERS
% ICPOptions.MaxNoIt                  = ;
% ICPOptions.IdxFixedPointClouds      = ;
% ICPOptions.NoOfTransfParam          = ;
% ICPOptions.HullVoxelSize            = ;
% ICPOptions.UniformSamplingDistance  = ;
% ICPOptions.PlaneSearchRadius        = ;
% ICPOptions.WeightByRoughness        = ;
% ICPOptions.WeightByDeltaAngle       = ;
% ICPOptions.MaxDeltaAngle            = ;
% ICPOptions.MaxDistance              = ;
% ICPOptions.MaxSigmaMad              = ;
% ICPOptions.MaxRoughness             = ;
% ICPOptions.LogLevel                 = ;
% ICPOptions.Plot                     = ;
% ICPOptions.SubsetRadius             = ;
% Undocumented parameters
% ICPOptions.PairList                 = ;
% ICPOptions.RandomSubsampling        = ;
% ICPOptions.NormalSubsampling        = ;
% ICPOptions.MaxLeverageSubsampling   = ;
% ICPOptions.SubsamplingPercentPoi    = ;
% ICPOptions.AdjOptions               = ;
% ICPOptions.MinNoIntersectingVoxel   = ;
% ICPOptions.TrafoOriginalPointClouds = ;
% ICPOptions.StopConditionNormdx      = ;
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

p = inputParser;
p.addParameter('MaxNoIt'                , 5      , @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('IdxFixedPointClouds'    , 1      , @(x) isrow(x));
p.addParameter('NoOfTransfParam'        , 6      , @(x) isnumeric(x) && isscalar(x) && ismember(x, [1 3 6 7 12]));
p.addParameter('HullVoxelSize'          , 'auto' , @(x) (isnumeric(x) && isscalar(x) && x > 0) || strcmpi(x, 'auto'));
p.addParameter('UniformSamplingDistance', 'auto' , @(x) isrow(x) || strcmpi(x, 'auto'));
p.addParameter('PlaneSearchRadius'      , 1      , @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('WeightByRoughness'      , true   , @(x) islogical(x));
p.addParameter('WeightByDeltaAngle'     , true   , @(x) islogical(x));
p.addParameter('MaxDeltaAngle'          , 10     , @(x) isnumeric(x) && isscalar(x) && x > 0); % angle in degree!
p.addParameter('MaxDistance'            , 'auto' , @(x) (isnumeric(x) && isscalar(x) && x > 0) || strcmpi(x, 'auto'));
p.addParameter('MaxSigmaMad'            , 3      , @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('MaxRoughness'           , 'auto' , @(x) (isnumeric(x) && isscalar(x) && x > 0) || strcmpi(x, 'auto'));
p.addParameter('LogLevel'               , 'basic', @(x) any(strcmpi(x, {'debug' 'basic'})));
p.addParameter('Plot'                   , false  , @(x) islogical(x));
p.addParameter('SubsetRadius'           , 0      , @(x) isnumeric(x) && isscalar(x) && x >= 0);
% Undocumented
p.addParameter('PairList'                , []    , @(x) size(x,2) == 2 || isempty(x));
p.addParameter('RandomSubsampling'       , false , @islogical);
p.addParameter('NormalSubsampling'       , false , @islogical);
p.addParameter('MaxLeverageSubsampling'  , false , @islogical);
p.addParameter('SubsamplingPercentPoi'   , 10    , @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('AdjOptions'              , []    , @(x) isstruct(x) || isempty(x));
p.addParameter('MinNoIntersectingVoxel'  , 1     , @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('TrafoOriginalPointClouds', true  , @islogical);
p.addParameter('StopConditionNormdx'     , -1    , @(x) isnumeric(x) && isscalar(x));

p.parse(varargin{:});
p = p.Results; clear varargin

% Default values for adjustments (only to be defined if different from ones in lsAdj.solve)
if isempty(p.AdjOptions)
    p.AdjOptions.Rank = true; % default for ICP
end

% ICP --------------------------------------------------------------------------

% Init
[obj, p, g] = runICPInit(obj, p);

% Load point clouds?
if p.SubsetRadius == 0
    PC = runICPLoadPC(obj, p, g);
else
    PC = [];
end

% Start of main ICP iteration loop
while (g.nItICP <= p.MaxNoIt) && (obj.D.stats{end}.normdx > p.StopConditionNormdx)
    
    % Start iteration
    g.procICP = {g.proc{:} sprintf('ICP ITERATION %d of %d', g.nItICP, p.MaxNoIt)};
    msg('S', g.procICP, 'LogLevel', 'basic');

    % Voxel hulls
    if g.nItICP == 1 || p.SubsetRadius == 0
        [obj, g, VH] = runICPVoxelHulls(obj, p, g, PC);
    end
    
    % Pair list
    if g.nItICP == 1 && isempty(p.PairList)
        p = runICPPairList(p, g, VH);
    end
    
    % Selection
    if g.nItICP == 1 || p.SubsetRadius == 0
        g = runICPSelection(obj, p, g, PC, VH);
    end
        
    % Subsets
    if g.nItICP == 1 && p.SubsetRadius > 0
        [g, PC] = runICPSubsets(obj, p, g, PC);
    end
    
    % Plot
    if p.Plot && g.nItICP == 1
        runICPPlot(obj, p, g, PC);
    end
    
    % Matching
    CP = runICPMatching(p, g, PC);
    
    % Rejection
    CP = runICPRejection(p, g, CP);
    
    % Weighting
    CP = runICPWeighting(p, g, CP);
    
    % Minimization
    [obj, g] = runICPMinimization(obj, p, g, CP);
    
    % Transformation
    [obj, PC] = runICPTransform(obj, p, g, PC);

    % Statistics
    obj = runICPStats(obj, p, g);
    
    % Plot
    if p.Plot
        runICPPlot(obj, p, g, PC);
    end
    
    % Save correspondences?
    obj = runICPSaveCorr(obj, p, g, CP);
        
    % End iteration
    g.nItICP = g.nItICP+1; % increase iteration number
    msg('E', g.procICP, 'LogLevel', 'basic');
    
end

% Transformation of original point clouds
if p.TrafoOriginalPointClouds
    obj = runICPTransformFinal(obj, p, g);
end

% Save results to output folder
runICPSaveResults(obj, p, g);

% Report transformation parameters
runICPReportTrafo(obj, p, g);

% End
msg('E', g.proc, 'LogLevel', 'basic');
diary off

end