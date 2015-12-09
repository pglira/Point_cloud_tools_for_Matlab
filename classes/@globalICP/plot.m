function plot(objICP, varargin)
% PLOT Plot all added point clouds.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * This method is a wrapper for the method 'plot' of the 'pointCloud' class.
%   Thus, call 'help pointCloud.plot' for the parameter description.
% * This method plots all previously added point clouds.
% ------------------------------------------------------------------------------
% INPUT
% [...]
% Parameters from the method 'plot' of the 'pointCloud' class (see above). These
% parameters are applied to each of the previously added point clouds.
% ------------------------------------------------------------------------------
% EXAMPLES
% Call 'help globalICP.globalICP' for a minimal working example, which also 
% includes this method.
% ------------------------------------------------------------------------------
% philipp.glira@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Plot each point cloud
for i = 1:numel(objICP.PC)
    
    % Load point cloud
    pc = objICP.loadPC(i);
    
    % Plot
    if i == 1, resetColorCounter = true; else resetColorCounter = false; end
    pc.plot('ResetColorCounter', resetColorCounter, varargin{:});
    
end

% Title
title('Point cloud overview');

end