function scatter3ext(varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;

% Required arguments as in scatter3 function
p.addRequired('X', @iscolumn);
p.addRequired('Y', @iscolumn);
p.addRequired('Z', @iscolumn);
p.addRequired('S', @isscalar); % marker size
p.addRequired('A', @iscolumn); % attribute of points, e.g. intensity or error value

p.addParamValue('ColormapName', 'jet');
p.addParamValue('Colorbar'    , true, @islogical);
p.addParamValue('CAxisLim'    , []  , @(x) isempty(x) || numel(x)==2);
p.parse(varargin{:});
p = p.Results;

% Plot -------------------------------------------------------------------------

if strcmpi(p.ColormapName, 'classification') % create colormap for visualisation of classes
    nAttributes = numel(unique(p.A)); % number of attributes
    colors = rand(nAttributes,3);
else % load colors of colormap
    colors = colormap(p.ColormapName);
end

% Number of colors
nColors = size(colors,1);

% Attribute range for each color
if isempty(p.CAxisLim)
    p.CAxisLim = [min(p.A) max(p.A)];
end
dA = (max(p.CAxisLim)-min(p.CAxisLim)) / nColors;

% Plot each color with function plot (faster than scatter3!)
for i = 1:nColors

    % Points within attribute value range
    % First color
    if i == 1
        actColorLog = p.A <= min(p.CAxisLim) + dA*i;
       
    % Last color
    elseif i == nColors
        actColorLog = p.A > min(p.CAxisLim) + dA*(i-1);
        
    % All other colors
    else
        actColorLog = p.A > min(p.CAxisLim) + dA*(i-1) & p.A <= min(p.CAxisLim) + dA*i;
    end
    
    % Plot!
    plot3(p.X(actColorLog), p.Y(actColorLog), p.Z(actColorLog), '.', 'Color', colors(i,:), 'MarkerSize', p.S);
   
    if i == 1, hold on; end

end

axis equal

% Colorbar ---------------------------------------------------------------------

% Show colorbar only if range of attributes (or user defined CAxisLim) is not equal to zero
if min(p.CAxisLim) ~= max(p.CAxisLim) % range of attributes
    
    if p.Colorbar

        hColorbar = colorbar; % before Matlab R2014b: hColorbar = colorbar('CLimMode', 'manual');
        caxis(p.CAxisLim);

        % New due to issues when using scatter3ext together with mapshow
        set(hColorbar, 'YLim', p.CAxisLim);
        hColorbarChild = get(hColorbar, 'Children');
        range = max(p.CAxisLim) - min(p.CAxisLim);
        if numel(hColorbarChild) > 1 % find colorbar if more than one children are found
            allTags = get(hColorbarChild, 'Tag');
            idx = strcmpi(allTags, 'TMW_COLORBAR');
            hColorbarChild = hColorbarChild(idx);
        end
        set(hColorbarChild, 'YData', [min(p.CAxisLim)+range/(nColors*2) max(p.CAxisLim)-range/(nColors*2)]);
        if strcmpi(p.ColormapName, 'difpal')
            set(hColorbar, 'YTick', [min(p.CAxisLim):(max(p.CAxisLim)-min(p.CAxisLim))/12:max(p.CAxisLim)]);
        end

    end
    
end

end