function obj = addPC(obj, varargin)
% ADDPC Add a point cloud to globalICP object.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * This method is a wrapper for the constructor method of the 'pointCloud'
%   class. Thus, call 'help pointCloud.pointCloud' for the parameter 
%   description.
% * The point cloud added with this method is automatically saved to a mat file.
%   The path to this mat file is saved in the object property 'PC', i.e. obj.PC.
% ------------------------------------------------------------------------------
% INPUT
% [...]
% Parameters from the constructor method of the 'pointCloud' class (see above).
% ------------------------------------------------------------------------------
% EXAMPLES
% Call 'help globalICP.globalICP' for a minimal working example, which also 
% includes this method.
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------
        
% Start ------------------------------------------------------------------------

% Number of already present point clouds
nPC = numel(obj.PC);

% Report
procHierarchy = {'GLOBALICP' 'ADDPC' sprintf('POINT CLOUD [%d]', nPC+1)};
msg('S', procHierarchy, 'LogLevel', 'basic');

% Import and save point cloud --------------------------------------------------

% Create path to mat file
if ischar(varargin{1}) % if input is a file
    if exist(varargin{1}, 'file') % if input exists
        [~, file] = fileparts(varargin{1});
        p2mat = fullfile(obj.TempFolder, [file '.mat']);
    else
        error('File ''%s'' does not exist!', varargin{1});
    end
else % if input is an array
    p2mat = fullfile(obj.TempFolder, ['PC_' datestr(now,'yyyymmdd_HHMMSS.FFF') '.mat']);
end    
msg('I', procHierarchy, sprintf('file = ''%s''', p2mat), 'LogLevel', 'basic');

% Import point cloud (only if mat file not present)
if ~exist(p2mat, 'file')
    objPC = pointCloud(varargin{:});
    objPC.save(p2mat);
else
    msg('I', procHierarchy, 'file already exists -> no import', 'LogLevel', 'basic');
end

% Save path to point cloud in icp object
obj.PC{nPC+1,1} = p2mat;

% End --------------------------------------------------------------------------

msg('E', procHierarchy, 'LogLevel', 'basic');

end