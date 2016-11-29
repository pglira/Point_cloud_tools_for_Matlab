function obj = exportPC(obj, i, varargin)
% EXPORTPC Export a point cloud.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * With this method a point cloud which was previously added to the globalICP
%   object, can be written to a file. Usually this is performed after the ICP
%   run.
% * This method is a wrapper for the method 'export' of the 'pointCloud'
%   class. Thus, call 'help pointCloud.export' for the parameter description.
% ------------------------------------------------------------------------------
% INPUT
% 1 [i]
%   Index of point cloud to load.
% 2 [...]
%   Parameters from the method 'export' of the 'pointCloud' class (see above).
% ------------------------------------------------------------------------------
% EXAMPLES
% Call 'help globalICP.globalICP' for a minimal working example, which also 
% includes this method.
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Start ------------------------------------------------------------------------

% Report
procHierarchy = {'GLOBALICP' 'EXPORTPC' sprintf('POINT CLOUD NO. %d', i)};
msg('S', procHierarchy, 'LogLevel', 'basic');

% Export -----------------------------------------------------------------------

pc = obj.loadPC(i);
pc.act(:) = true;
pc.export(varargin{:});

% End --------------------------------------------------------------------------

msg('E', procHierarchy, 'LogLevel', 'basic');

end