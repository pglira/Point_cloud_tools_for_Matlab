function plot(obj, varargin)
% PLOT Plot of point cloud.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * Only active points are visualized.
% ------------------------------------------------------------------------------
% INPUT
% 1 ['Color', color]
%   Color of the points. The following choices are possible:
%
%     * Unicolor (format = 'ColorName'):
%       A single color is used for all points, e.g. 'yellow'. For possible 
%       values, look for 'ColorSpec' in the documentation.
%
%     * Attribute (format = 'A.AttributeName'):
%       Coloring according to an attribute, e.g. 'A.roughness'.
%       Additionally, the following choices are possible:
%         * 'A.x'  : coloring according to x coordinate
%         * 'A.y'  : coloring according to y coordinate
%         * 'A.z'  : coloring according to z coordinate
%         * 'A.rgb': true color plot using the attributes r, g and b.
% 
% 2 ['MarkerSize', markerSize]
%   Marker size of points.
%
% 3 ['MaxPoints', maxPoints]
%   Maximum number of points to plot. If the point cloud contains more than
%   maxPoi points, the points for plotting are randomly sampled among all
%   points.
%
% 4 ['ColormapName', colormapName]
%   Name of colormap defined as char (e.g. 'jet'). For possible values, look for
%   'colormap' in the documentation. Additionally, for visualization of classes,
%   the colormap 'classpal' can be used.
%   (This parameter is only considered for attribute dependent plots.)
%
% 5 ['CAxisLim', cAxisLim]
%   Limits of colorbar defined as vector with 2 elements.
%   (This parameter is only considered for attribute dependent plots.)
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Import a point cloud and plot points according to z coordinate (default).
%   pc = pointCloud('Lion.xyz');
%   pc.plot;
%
% 2 Unicolor plot.
%   pc = pointCloud('Lion.xyz');
%   pc.plot('Color', 'red');
%
% 3 Plot all points of a point cloud.
%   pc = pointCloud('Lion.xyz');
%   pc.plot('MaxPoints', Inf);
%
% 4 Plot only 1000 points of a point cloud with increased point size.
%   pc = pointCloud('Lion.xyz');
%   pc.plot('MaxPoints', 1000, 'MarkerSize', 10);
%
% 5 Plot points according to true color attributes r, g and b.
%   pc = pointCloud('Gieszkanne.xyz', 'Attributes', {'r' 'g' 'b'});
%   pc.plot('Color', 'A.rgb', 'MarkerSize', 5);
%
% 6 Plot points colored by an imported attribute.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%   % Note: the imported attributes are saved as fields in the structure pc.A,
%   % e.g. the roughness is saved in pc.A.roughness.
%   pc.plot('Color', 'A.roughness');
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Start
[hFig, idxPC, firstCall] = plot_start;

if firstCall

    % Save colors to figure
    plot_saveColors(hFig)
                    
    % Save default options to figure
    plot_saveOptions(hFig)
    
    % Create toolbar
    plot_createToolbar(hFig)
    
    % Set properties of figure
    plot_setFigureProperties(hFig)
    
end

% Save PC data to figure
plot_savePC(hFig, obj, idxPC); clear obj

% Create menu
plot_createMenu(hFig, firstCall, idxPC)

% Set parameters and plot
plot_setPrmAndPlot(hFig, idxPC, varargin{:})

% Temporary solution
if firstCall, set(gca, 'Visible', 'on'); end

end