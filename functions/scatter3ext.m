function h = scatter3ext(varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;

% Required arguments as in scatter3 function
p.addRequired('X', @iscolumn);
p.addRequired('Y', @iscolumn);
p.addRequired('Z', @iscolumn);
p.addRequired('S', @isscalar); % marker size
p.addRequired('A', @iscolumn); % attribute of points, e.g. intensity or error value

p.addParameter('ColormapName', 'jet');
p.addParameter('Colorbar'    , true, @islogical);
p.addParameter('CAxisLim'    , []  , @(x) isempty(x) || numel(x)==2);
p.parse(varargin{:});
p = p.Results;

% Plot -------------------------------------------------------------------------

% Get colors
if strcmpi(p.ColormapName, 'classification') % create colormap for visualisation of classes
    nAttributes = numel(unique(p.A)); % number of attributes
    colors = rand(nAttributes,3);
    colorbar off; p.Colorbar = false;
else % load colors of colormap
    colors = colormap(p.ColormapName);
end

% Number of colors
nColors = size(colors,1);

% Limits of colorbar
if isempty(p.CAxisLim)
    p.CAxisLim = [min(p.A) max(p.A)];
    % p.CAxisLim = [quantile(p.A, 0.05) quantile(p.A, 0.95)];
end

% Special case: min and max of CAxisLim is equal
if min(p.CAxisLim) == max(p.CAxisLim)
    h = plot3(p.X, p.Y, p.Z, '.', 'Color', colors(1,:), 'MarkerSize', p.S); % plot all points with first color
    colorbar off; % disable if already present
    return;
end

% Plot each color with function plot (faster than scatter3!)
dA = (max(p.CAxisLim)-min(p.CAxisLim)) / nColors; % attribute range for each color

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
    h{i} = plot3(p.X(actColorLog), p.Y(actColorLog), p.Z(actColorLog), '.', 'Color', colors(i,:), 'MarkerSize', p.S);
   
    if i == 1, hold on; end

end

axis equal

% Colorbar ---------------------------------------------------------------------

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