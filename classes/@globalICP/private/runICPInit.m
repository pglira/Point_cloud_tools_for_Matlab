function [obj, p, g] = runICPInit(obj, p, g)

% Start ------------------------------------------------------------------------

% Start
msg('O', 'SetLogLevel', p.LogLevel);

% Log to file
diary off; fclose all;
p2report = fullfile(obj.OutputFolder, 'ICPLog.txt');
if exist(p2report)==2 % delete old report file if any
    try delete(p2report); end
end
if ~exist(obj.OutputFolder, 'dir')
    mkdir(obj.OutputFolder);
end
diary(p2report);

g.proc = {'GLOBALICP' 'RUNICP'};
msg('S', g.proc, 'LogLevel', 'basic');

% Initialize variables ---------------------------------------------------------

g.nPC = numel(obj.PC);
g.nItICP = 1;
obj.D.stats{g.nItICP}.normdx = Inf;

% Initialize homogeneous transformation matrices
obj.D.H = repmat({eye(4)}, 1, g.nPC);
    
% Estimate input parameters set to auto ----------------------------------------

if strcmpi(p.HullVoxelSize          , 'auto') || ...
   strcmpi(p.UniformSamplingDistance, 'auto') || ...
   strcmpi(p.MaxDistance            , 'auto') || ...
   strcmpi(p.MaxRoughness           , 'auto')

    msg('S', {g.proc{:} 'ESTIMATE INPUT PARAMETERS'}, 'LogLevel', 'basic');


    if strcmpi(p.HullVoxelSize, 'auto')
        firstTryHullVoxelSize = 5*p.PlaneSearchRadius;
        validVoxelSizes = [0.01 0.02 0.04 0.05 0.08 0.1 0.16 0.2 0.25 0.4 0.5 0.8 1 1.25 2 2.5 4 5 6.25 10 12.5 20 25 50 100]'; % mod(100, voxelSize) has to be zero, see pointCloud.getVoxelSize
        idx = knnsearch(validVoxelSizes, firstTryHullVoxelSize);
        p.HullVoxelSize = validVoxelSizes(idx);
        msg('V', p.HullVoxelSize, 'HullVoxelSize', 'Prec', 2, 'LogLevel', 'basic');
    end

    if strcmpi(p.UniformSamplingDistance, 'auto')
        p.UniformSamplingDistance = 2*p.PlaneSearchRadius;
        msg('V', p.UniformSamplingDistance, 'UniformSamplingDistance', 'Prec', 2, 'LogLevel', 'basic');
    end

    if strcmpi(p.MaxDistance, 'auto')
        p.MaxDistance = 3*p.PlaneSearchRadius;
        msg('V', p.MaxDistance, 'MaxDistance', 'Prec', 2, 'LogLevel', 'basic');
    end

    if strcmpi(p.MaxRoughness, 'auto')
        p.MaxRoughness = 0.2*p.PlaneSearchRadius;
        msg('V', p.MaxRoughness, 'MaxRoughness', 'Prec', 2, 'LogLevel', 'basic');
    end

    msg('E', {g.proc{:} 'ESTIMATE INPUT PARAMETERS'}, 'LogLevel', 'basic');
    
end

% Assign point cloud dependent parameters --------------------------------------

% Uniform sampling for each point cloud
if numel(p.UniformSamplingDistance) == 1
    p.UniformSamplingDistance = ones(1,g.nPC)*p.UniformSamplingDistance;
end

% Random subsampling for each point cloud
if numel(p.RandomSubsampling) == 1
    p.RandomSubsampling = repmat(p.RandomSubsampling, 1, g.nPC);
end

% Normal subsampling for each point cloud
if numel(p.NormalSubsampling) == 1
    p.NormalSubsampling = repmat(p.NormalSubsampling, 1, g.nPC);
end

% Max leverage subsampling for each point cloud
if numel(p.MaxLeverageSubsampling) == 1
    p.MaxLeverageSubsampling = repmat(p.MaxLeverageSubsampling, 1, g.nPC);
end

% Report input point clouds ----------------------------------------------------

msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');

msg('T', 'INPUT POINT CLOUDS:', 'LogLevel', 'basic');

msg('T', sprintf('%12s %12s %8s %8s %8s %8s    file', 'point_cloud', 'fix/loose', 'USD', 'RS', 'NS', 'MLS'), 'LogLevel', 'basic');

for i = 1:g.nPC
    if ismember(i, p.IdxFixedPointClouds), fixOrLoose = 'fix  '; else fixOrLoose = 'loose'; end
    if p.RandomSubsampling(i)     , RS  = 'true'; else RS  = 'false'; end
    if p.NormalSubsampling(i)     , NS  = 'true'; else NS  = 'false'; end
    if p.MaxLeverageSubsampling(i), MLS = 'true'; else MLS = 'false'; end
    
    [~, file] = fileparts(obj.PC{i});
    
    msg('T', sprintf('%12s %12s %8.2f %8s %8s %8s    %s', ...
        ['[' num2str(i) ']'], ...
        fixOrLoose, ...
        p.UniformSamplingDistance(i), ...
        RS, ...
        NS, ...
        MLS, ...
        file), ...
        'LogLevel', 'basic');
    
end

msg('T', 'where USD = UniformSamplingDistance', 'LogLevel', 'basic');
msg('T', '      RS  = RandomSubsampling'      , 'LogLevel', 'basic');
msg('T', '      NS  = NormalSubsampling'      , 'LogLevel', 'basic');
msg('T', '      MLS = MaxLeverageSubsampling' , 'LogLevel', 'basic');

msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');

end