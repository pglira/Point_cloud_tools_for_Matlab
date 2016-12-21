function varargout = ICP(varargin)
% ICP Implementation of the Iterative Closest Point (ICP) algorithm.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% With this function the alignment of two or more point clouds can be refined. A
% prerequisite for this is an approximate alignment of the point clouds.
% ------------------------------------------------------------------------------
% IMPORT PARAMETERS
%
% a ['InFiles', InFiles]
%   Path to point clouds. Use '*' to select multiple files.
%
% b ['RedPoi', RedPoi]
%   Coordinate reduction point defined as vector with 3 elements. A reduction
%   point should be defined if the point clouds contain very large coordinates.
%
% ------------------------------------------------------------------------------
% EXPORT PARAMETERS
%
% a ['OutputFolder', OutputFolder]
%   Path to directory in which output files are stored. If this option is
%   omitted, the path given by the command 'cd' is used as directory.
%
% b ['OutputFormat', OutputFormat]
%   Output format of transformed point clouds, e.g. 'ply', 'xyz', 'txt', 'las'.
%
% c ['TempFolder', TempFolder]
%   Folder in which temporary files are saved, e.g. imported point clouds. If
%   this option is omitted, the path given by the command 'tempdir' is used as
%   directory.
%
% ------------------------------------------------------------------------------
% ICP PARAMETERS
% 
% 1 GENERAL ICP
%   a ['MaxNoIt', MaxNoit]
%     Maximum number of ICP iterations.
%
%   b ['FixedPointClouds', FixedPointClouds]
%     Filename(s) of fixed point cloud(s). It is possible to define multiple
%     files.
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
%
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Example with demo data (switch to folder demodata)
%   ICP('inFiles'                , 'lionscan*approx.xyz', ...
%       'UniformSamplingDistance', 2, ...
%       'PlaneSearchRadius'      , 2, ...
%       'Plot'                   , true);
% 2 Same example with syntax for command line executable (ICP.exe)
%   ICP -inFiles demodata\lionscan*approx.xyz -UniformSamplingDistance 2 -PlaneSearchRadius 2 -Plot 1
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------
                
% IMPORT PARAMETERS
% opt.InFiles                  = ; % documented
% opt.RedPoi                   = ; % documented
% opt.Attributes               = ;
% opt.BucketSize               = ;
% opt.HeaderLines              = ;

% EXPORT PARAMETERS
% opt.OutputFolder             = ; % documented
% opt.OutputFormat             = ; % documented
% opt.PrecCoord                = ;
% opt.PrecAttributes           = ;
% opt.ColumnWidth              = ;

% ICP PARAMETERS
% opt.FixedPointClouds         = ; % documented
% opt.Mask                     = ;
% opt.MaxNoIt                  = ; % documented
% opt.NoOfTransfParam          = ; % documented
% opt.HullVoxelSize            = ; % documented
% opt.UniformSamplingDistance  = ; % documented
% opt.PlaneSearchRadius        = ; % documented
% opt.WeightByRoughness        = ; % documented
% opt.WeightByDeltaAngle       = ; % documented
% opt.MaxDeltaAngle            = ; % documented
% opt.MaxDistance              = ; % documented
% opt.MaxSigmaMad              = ; % documented
% opt.MaxRoughness             = ; % documented
% opt.LogLevel                 = ; % documented
% opt.Plot                     = ; % documented
% opt.SubsetRadius             = ; % documented
% opt.PairList                 = ;
% opt.RandomSubsampling        = ;
% opt.NormalSubsampling        = ;
% opt.MaxLeverageSubsampling   = ;
% opt.SubsamplingPercentPoi    = ;
% opt.AdjOptions               = ;
% opt.MinNoIntersectingVoxel   = ;
% opt.TrafoOriginalPointClouds = ;
% opt.StopConditionNormdx      = ;

% Show only help text? ---------------------------------------------------------

if isempty(varargin)
    if ~isdeployed
        help ICP
    else
        type ICP_help.txt
    end
    return
end

if numel(varargin) > 0
    if strcmpi(varargin{1}, '-help')
        if ~isdeployed
            help ICP
        else
            type ICP_help.txt
        end
        return
    end
end
   
% Input parsing ----------------------------------------------------------------

% If parameters are defined as a structure, convert them to a cell
if numel(varargin) == 1 && isstruct(varargin{1})
    prmStruct = varargin{1};
    fields = fieldnames(prmStruct);
    for i = 1:numel(fields)
        varargin{2*i-1} = fields{i};
        varargin{2*i}   = prmStruct.(fields{i});
    end
end

% Convert and save parameters into a structure for each function
for i = 1:2:numel(varargin) % each second argument
    
    % Delete '-' if present
    if varargin{i}(1) == '-', varargin{i}(1) = ''; end
    
    prm = varargin{i}; % parameter
    val = varargin{i+1}; % value
    
    % Logical value indicating if parameter was found or not
    ok = false;
    
    % Parameters for function ICP (parsing here)
    if strcmpi(prm, 'InFiles'                 ),                                                  p.ICP.(prm) = val;        ok = true; end
    if strcmpi(prm, 'FixedPointClouds'        ), if isstr(val), val = strsplit(val, ' ');    end, p.ICP.(prm) = val;        ok = true; end
    if strcmpi(prm, 'OutputFormat'            ),                                                  p.ICP.(prm) = val;        ok = true; end
    if strcmpi(prm, 'Mask'                    ),                                                  p.ICP.(prm) = val;        ok = true; end
    % Parameters for function pointCloud.pointCloud (parsing not here)
    if strcmpi(prm, 'Attributes'              ), if isstr(val), val = strsplit(val, ' ');    end, p.pointCloud.(prm) = val; ok = true; end
    if strcmpi(prm, 'RedPoi'                  ), if isstr(val), val = str2num(val);          end, p.pointCloud.(prm) = val; ok = true; end
    if strcmpi(prm, 'BucketSize'              ), if isstr(val), val = str2num(val);          end, p.pointCloud.(prm) = val; ok = true; end
    if strcmpi(prm, 'HeaderLines'             ), if isstr(val), val = str2num(val);          end, p.pointCloud.(prm) = val; ok = true; end
    if strcmpi(prm, 'Filter'                  ),                                                  p.pointCloud.(prm) = val; ok = true; end
    % Parameters for function globalICP.globalICP (parsing not here)
    if strcmpi(prm, 'OutputFolder'            ),                                                  p.globalICP.(prm) = val;  ok = true; end
    if strcmpi(prm, 'TempFolder'              ),                                                  p.globalICP.(prm) = val;  ok = true; end
    % Parameters for function globalICP.runICP (parsing not here)
    if strcmpi(prm, 'MaxNoIt'                 ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'NoOfTransfParam'         ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'HullVoxelSize'           ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'UniformSamplingDistance' ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'PlaneSearchRadius'       ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'WeightByRoughness'       ), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'WeightByDeltaAngle'      ), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'MaxDeltaAngle'           ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'MaxDistance'             ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'MaxSigmaMad'             ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'MaxRoughness'            ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'LogLevel'                ),                                                  p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'Plot'                    ), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'SubsetRadius'            ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'PairList'                ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'RandomSubsampling'       ), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'NormalSubsampling'       ), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'MaxLeverageSubsampling'  ), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'SubsamplingPercentPoi'   ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'AdjOptions'              ),                                                  p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'MinNoIntersectingVoxel'  ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'TrafoOriginalPointClouds'), if isstr(val), val = logical(str2num(val)); end, p.runICP.(prm) = val;     ok = true; end 
    if strcmpi(prm, 'StopConditionNormdx'     ), if isstr(val), val = str2num(val);          end, p.runICP.(prm) = val;     ok = true; end
    % Note: parameter 'IdxFixedPointClouds' is derived from parameter 'FixedPointClouds'!!!
    % Parameters for function globalICP.exportPC (parsing not here)
    if strcmpi(prm, 'ColumnWidth'             ), if isstr(val), val = str2num(val);          end, p.exportPC.(prm) = val;   ok = true; end 
    if strcmpi(prm, 'PrecCoord'               ), if isstr(val), val = str2num(val);          end, p.exportPC.(prm) = val;   ok = true; end 
    if strcmpi(prm, 'PrecAttributes'          ), if isstr(val), val = str2num(val);          end, p.exportPC.(prm) = val;   ok = true; end 
    
    % Error if parameter was not found
    if ~ok, error(sprintf('Unknown parameter ''%s''!', prm)); end

end

% Parsing of parameters for this function
pp = inputParser;
pp.addParameter('InFiles'         , []   , @(x) iscell(x) || ischar(x)); % must be defined (default value is invalid)
pp.addParameter('FixedPointClouds', ''   , @(x) iscell(x) || isempty(x));
pp.addParameter('OutputFormat'    , 'las', @ischar);
pp.addParameter('Mask'            , ''   , @ischar);
pp.parse(p.ICP);
p.ICP = pp.Results;

% 4Debug
% structstruct(p);

% Create ICP object ------------------------------------------------------------

if isfield(p, 'globalICP')
    icp = globalICP(p.globalICP);
else
    icp = globalICP;
end
    
% Import of point clouds -------------------------------------------------------

% Find files for given path and save them into cell
if ischar(p.ICP.InFiles)
    files  = dirext(p.ICP.InFiles);
    folder = fileparts(p.ICP.InFiles); 
    for i = 1:numel(files)
        if i == 1, p.ICP = rmfield(p.ICP, 'InFiles'); end
        p.ICP.InFiles{i} = fullfile(folder, files{i});
    end
end

% Find indices of fixed point clouds
if isempty(p.ICP.FixedPointClouds)
    p.runICP.IdxFixedPointClouds = 1;
else
    p.runICP.IdxFixedPointClouds = []; % initialize
    for i = 1:numel(p.ICP.FixedPointClouds)
        for j = 1:numel(p.ICP.InFiles)
            [~, fixedFile] = fileparts(p.ICP.FixedPointClouds{i}); % only filename without extension
            [~, inFile   ] = fileparts(p.ICP.InFiles{j});          % only filename without extension
            if strcmpi(fixedFile, inFile)
                p.runICP.IdxFixedPointClouds = [p.runICP.IdxFixedPointClouds j];
            end
        end
    end
    if isempty(p.runICP.IdxFixedPointClouds)
        error('File name(s) defined in ''FixedPointClouds'' could not be matched with those defined in ''InFiles''!');
    end
end

% Import point clouds
for i = 1:numel(p.ICP.InFiles)
    if isfield(p, 'pointCloud')
        icp = icp.addPC(p.ICP.InFiles{i}, p.pointCloud);
    else
        icp = icp.addPC(p.ICP.InFiles{i});
    end
end

% Consider mask? ---------------------------------------------------------------

if ~isempty(p.ICP.Mask)
    for i = 1:numel(files)
        pc = pc.select('GeoTiff', p.ICP.Mask, [1 1]);
    end
end

% Run ICP ----------------------------------------------------------------------

if isfield(p, 'runICP')
    icp.runICP(p.runICP);
else
    icp.runICP;
end

% Export -----------------------------------------------------------------------
% Only if p.runICP.TrafoOriginalPointClouds is true and p.ICP.OutputFormat is non-empty

export = true; % default value
if isfield(p, 'runICP')
    if isfield(p.runICP, 'TrafoOriginalPointClouds')
        export = p.runICP.TrafoOriginalPointClouds; % override with value set by user if present
    end
end

if export
    if ~isempty(p.ICP.OutputFormat)
        if ~strcmp(p.ICP.OutputFormat, '.'), p.ICP.OutputFormat = ['.' p.ICP.OutputFormat]; end % add point if necessary
        for i = 1:numel(icp.PC)
            
            % Path to output file
            [path, file] = fileparts(icp.PC{i});
            p2out = fullfile(path, [file, p.ICP.OutputFormat]);
            
            % Export point cloud
            if isfield(p, 'exportPC')
                icp.exportPC(i, p2out, p.exportPC);
            else
                icp.exportPC(i, p2out);
            end
            
        end
    end
end

% Save transformation parameters to matrix -------------------------------------

if nargout == 1
    
    for i = 1:numel(icp.PC)

        trafoParam(i,1)  = icp.D.H{i}(1,1); % a11
        trafoParam(i,2)  = icp.D.H{i}(1,2); % a12
        trafoParam(i,3)  = icp.D.H{i}(1,3); % a13

        trafoParam(i,4)  = icp.D.H{i}(2,1); % a21
        trafoParam(i,5)  = icp.D.H{i}(2,2); % a22
        trafoParam(i,6)  = icp.D.H{i}(2,3); % a23

        trafoParam(i,7)  = icp.D.H{i}(3,1); % a31
        trafoParam(i,8)  = icp.D.H{i}(3,2); % a32
        trafoParam(i,9)  = icp.D.H{i}(3,3); % a33

        trafoParam(i,10) = icp.D.H{i}(1,4); % tx
        trafoParam(i,11) = icp.D.H{i}(2,4); % ty
        trafoParam(i,12) = icp.D.H{i}(3,4); % tz

        trafoParam(i,13) = icp.D.redPoi(1); % redPoi_x
        trafoParam(i,14) = icp.D.redPoi(2); % redPoi_y
        trafoParam(i,15) = icp.D.redPoi(3); % redPoi_z

    end
    
    varargout{1} = trafoParam;
    
end