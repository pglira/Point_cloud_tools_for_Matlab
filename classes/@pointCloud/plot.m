function plot(obj, varargin)
% PLOT Plot of point cloud.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * Only active points are visualized.
% * For generation of high resolution screenshots, we suggest the function
%   'export_fig' (see Matlab File Exchange).
% ------------------------------------------------------------------------------
% INPUT
% 1 ['Color', color]
%   Color of the points. For possible values, look for 'ColorSpec' in the
%   documentation. Among them the following choices are possible:
%     * 'random'
%        Random color.
%     * 'rgb'
%        True color plot using attributes r, g and b.
%   (This parameter overrules the attribute parameter.)
% 
% 2 ['MarkerSize', markerSize]
%   Marker size of points.
%
% 3 ['MaxPoi', maxPoi]
%   Maximum number of points to plot. If the point cloud contains more than
%   maxPoi points, the points for plotting are randomly sampled among all
%   points.
%
% 4 ['Attribute', attribute]
%   Colorize point cloud according to an attribute. The attribute has to be
%   defined as char (e.g. 'slope'). Next to the attributes attached to the
%   object, the following choices are possible:
%     'z' = colorize points according to z coordinate
%
% 5 ['ColormapName', colormapName]
%   Name of colormap defined as char (e.g. 'jet'). For possible values, look for
%   'colormap' in the documentation.
%   Additionally, for visualization of classes, the colormap 'classification'
%   can be used.
%   (This parameter is only considered for attribute dependent plots.)
%
% 6 ['Colorbar', colorbar]
%   Logical value which defines if a colorbar is displayed or not. 
%   (This parameter is only considered for attribute dependent plots.)
%    
% 7 ['CAxisLim', cAxisLim]
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
%   pc.plot('MaxPoi', Inf);
%
% 4 Plot only 1000 points of a point cloud with increased point size.
%   pc = pointCloud('Lion.xyz');
%   pc.plot('MaxPoi', 1000, 'MarkerSize', 10);
%
% 5 Plot points according to true color attributes r, g and b.
%   pc = pointCloud('Gieszkanne.xyz', 'Attributes', {'r' 'g' 'b'});
%   pc.plot('Color', 'rgb', 'MarkerSize', 5);
%
% 6 Plot points colored by an imported attribute.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%   % Note: the imported attributes are saved as fields in the structure pc.A,
%   % e.g. the roughness is saved in pc.A.roughness.
%   pc.plot('Attribute', 'roughness');
% ------------------------------------------------------------------------------
% philipp.glira@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParamValue('Color'            , ''      );
p.addParamValue('MarkerSize'       , 1       , @(x) isscalar(x) && x>0);
p.addParamValue('MaxPoi'           , 10^6    , @(x) isscalar(x) && x>0);
p.addParamValue('Attribute'        , 'z'     , @ischar);
p.addParamValue('ColormapName'     , 'parula', @ischar); % char!
p.addParamValue('Colorbar'         , true    , @islogical);
p.addParamValue('CAxisLim'         , []      , @(x) numel(x)==2);
% Undocumented
p.addParamValue('ResetColorCounter', false, @islogical);
p.parse(varargin{:});
p = p.Results;

% Persistent variables ---------------------------------------------------------

% Variable for random coloring of point cloud
persistent colorCounter;
if strcmpi(p.Color, 'random')
    if isempty(colorCounter) || p.ResetColorCounter % initialize colorCounter
        colorCounter = 1;
    end
end

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'PLOT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Get indices of points to plot ------------------------------------------------

% Find indices of active points
idx = find(obj.act);

% Indices of points with consideration of parameter MaxPoi
if ~isempty(p.MaxPoi) && numel(idx) > p.MaxPoi
    idxRandom = randperm(numel(idx), p.MaxPoi);
    idx       = idx(idxRandom);
end

msg('V', numel(find(obj.act)), 'number of activated points', 'Prec', 0);
msg('V', numel(idx)          , 'number of displayed points', 'Prec', 0);

% Figure, Axes -----------------------------------------------------------------

xlabel('x');
ylabel('y');
zlabel('z');
hold('on');
axis('equal');
grid('on');
set(gca, 'Color', [0.3 0.3 0.3]);

% Plot of points ---------------------------------------------------------------

% Colorize points according to an attribute
if isempty(p.Color) && ~isempty(p.Attribute)

    % Attribute for colors
    if strcmpi(p.Attribute, 'z') % attribute = z coordinate
        A = obj.X(idx,3);
    else
        A = obj.A.(p.Attribute)(idx);
    end 
    
    scatter3ext(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), p.MarkerSize, A, ...
                'ColormapName', p.ColormapName, ...
                'Colorbar'    , p.Colorbar, ...
                'CAxisLim'    , p.CAxisLim);

% RGB plot
elseif strcmpi(p.Color, 'rgb')

    % Check how colors are saved
    if isfield(obj.A, 'r') && isfield(obj.A, 'g') && isfield(obj.A, 'b')
        r = obj.A.r;
        g = obj.A.g;
        b = obj.A.b;
    elseif isfield(obj.A, 'red') && isfield(obj.A, 'green') && isfield(obj.A, 'blue')
        r = obj.A.red;
        g = obj.A.green;
        b = obj.A.blue;
    elseif isfield(obj.A, 'diffuse_red') && isfield(obj.A, 'diffuse_green') && isfield(obj.A, 'diffuse_blue')
        r = obj.A.diffuse_red;
        g = obj.A.diffuse_green;
        b = obj.A.diffuse_blue;
    end
    
    % No. of displayed colors
    nColors = 256;
    
    % Conversion of colors
    if max(r) <= 1
        [A, map] = rgb2ind(cat(3, r(idx)    , g(idx)    , b(idx))    , nColors);
    else
        [A, map] = rgb2ind(cat(3, r(idx)/255, g(idx)/255, b(idx)/255), nColors);
    end
    
    scatter3ext(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), p.MarkerSize, A, ...
                'ColormapName', map, ...
                'Colorbar'    , false, ...
                'CAxisLim'    , [0 nColors-1]);
    
    % Alternative
    % scatter3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), 5, [obj.A.r(idx)/255, obj.A.g(idx)/255, obj.A.b(idx)/255], 'fill'); (slow!)
    
% Unicolor plot
else
    
    % Unicolor plot with random color
    if strcmpi(p.Color, 'random')
        
        if verLessThan('matlab', '8.4')
        
            allColors = [255   0 255 % magenta
                           0 255 255 % cyan
                           0 255   0 % green
                           0   0 255 % blue
                         255   0   0 % red
                         255 255   0 % yellow
                           0   0 128
                           0 128   0
                           0 128 128
                         128   0   0
                         128   0 128
                         128 128   0
                         128 128 128
                         208 208 208];
             
            allColors = allColors/255;

            if colorCounter > size(allColors,1), colorCounter = 1; end % restart from one

            p.Color = allColors(colorCounter,:); % select color

            colorCounter = colorCounter+1; % increase counter
    
            % Plot!
            plot3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), '.', 'Color', p.Color, 'MarkerSize', p.MarkerSize);
    
        else
        
            % Plot!
            plot3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), '.', 'MarkerSize', p.MarkerSize);
            
        end
        
    % Unicolor plot with defined color
    else
        
        % Plot!
        plot3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), '.', 'Color', p.Color, 'MarkerSize', p.MarkerSize);

    end
        
end

view(2);

if isempty(p.Attribute), hold('on'); else hold('off'); end

hold('on');

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end