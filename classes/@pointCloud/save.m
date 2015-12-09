function save(obj, path)
% SAVE Save point cloud object as mat file.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * Point cloud object is saved as variable 'obj' in mat file.
% ------------------------------------------------------------------------------
% INPUT
% 1 [path]
%   Path to mat file.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Import a point cloud and save it as mat file.
%   pc = pointCloud('Lion.xyz');
%   pc.save('Lion.mat');
%
% 2 Import, save and load a point cloud.
%   pc = pointCloud('Lion.xyz');
%   pc.save('Lion.mat');
%   clear; % clear all variables
%   load('Lion.mat'); pc = obj;
% ------------------------------------------------------------------------------
% philipp.glira@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('path', @(x) ischar(x));
p.parse(path);
p = p.Results;
% Clear required inputs to avoid confusion
clear path

% Save object to mat file ------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'SAVE'};
msg('S', procHierarchy);

% Create directory if not already present
p2folder = fileparts(p.path);
if ~exist(p2folder) && ~isempty(p2folder), mkdir(p2folder); end

% Retrieve size of object in GB
infoObj = whos('obj');
gb = infoObj.bytes/(1024*1024*1024);

% Save!
if gb < 1.9 % if size of object is smaller 1.9 GB (threshold vor v7.3 is 2.0 GB)
    save(p.path, 'obj', '-v6');
else
    save(p.path, 'obj', '-v7.3');
end

msg('E', procHierarchy);

end