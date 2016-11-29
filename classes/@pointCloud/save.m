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
% 1 Import, save and load a point cloud.
%   pc = pointCloud('Lion.xyz');
%   pc.save('Lion.mat');
%   clear; % clear all variables
%   pc = pointCloud('Lion.mat'); % load from mat file
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
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
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Create directory if not already present
p2folder = fileparts(p.path);
if ~exist(p2folder, 'dir') && ~isempty(p2folder), mkdir(p2folder); end

% Save!
save(p.path, 'obj', '-v7.3');

msg('E', procHierarchy);

end