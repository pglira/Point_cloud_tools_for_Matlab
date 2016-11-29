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
%
% 8 ['Limits', limits]
%   Plot only points within a selection window. The window is defined by its 
%   coordinate limits in x, y and z as 3-by-2 matrix: [minX maxX
%                                                      minY maxY
%                                                      minZ maxZ]
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
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% hFig.UserData.hMenuAllPC -> handle to menu for all point clouds
% hFig.UserData.hMenuAddPC -> handle to menu for adding a point cloud
% hFig.UserData.hMenuPC    -> handles to individual menus of point clouds

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParameter('Color'       , ''                            , @(x) ischar(x) || numel(x)==3);
p.addParameter('MarkerSize'  , 1                             , @(x) isscalar(x) && x>0);
p.addParameter('MaxPoi'      , 10^6                          , @(x) isscalar(x) && x>0);
p.addParameter('Attribute'   , 'z'                           , @ischar);
p.addParameter('ColormapName', 'parula'                      , @ischar); % char!
p.addParameter('Colorbar'    , true                          , @islogical);
p.addParameter('CAxisLim'    , []                            , @(x) numel(x)==2);
p.addParameter('Limits'      , [-Inf Inf; -Inf Inf; -Inf Inf], @(x) isnumeric(x) && size(x,1)==3 && size(x,2)==2);
% Undocumented
p.addParameter('Menu'        , true                          , @islogical);
p.parse(varargin{:});
p = p.Results;

% Initialize for nested functions
idx = [];
hPlot = [];
percentageDisplayedPoints = [];

selectSubsetOfPoints;
plot;
setProperties;

hAxes = gca;
hFig  = gcf;

% Functions --------------------------------------------------------------------

    function updatePlot(varargin)
        
        % Replace parameter with new value
        selectNewSubset = false; % default
        for i = 1:2:numel(varargin)
            
            prm   = varargin{i};
            value = varargin{i+1};
            p.(prm) = value;
            
            if any(strcmpi(prm, {'MaxPoi', 'Limits'}))
                selectNewSubset = true;
            end
            
        end
        
        % Select new subset of points?
        if selectNewSubset, selectSubsetOfPoints; end
        
        % Delete point cloud
        if ~iscell(hPlot)
            delete(hPlot);
        else
            for i = 1:numel(hPlot)
                delete(hPlot{i});
            end
        end
        
        % Plot!
        plot;
        
    end

    function plot

        % Start ----------------------------------------------------------------
        
        percentageDisplayedPoints = numel(idx)/numel(find(obj.act))*100;
        
        procHierarchy = {'POINTCLOUD' 'PLOT'};
        msg('S', procHierarchy);
        msg('I', procHierarchy            , sprintf('Point cloud label = ''%s''', obj.label));
        msg('V', numel(find(obj.act))     , 'number of activated points', 'Prec', 0);
        msg('V', numel(idx)               , 'number of displayed points', 'Prec', 0);
        msg('V', percentageDisplayedPoints, 'percentage of displayed points', 'Prec', 2);
        
        % Plot -----------------------------------------------------------------
        
        % Colorize points according to an attribute
        if isempty(p.Color) && ~isempty(p.Attribute)

            % Attribute for colors
            if strcmpi(p.Attribute, 'z') % attribute = z coordinate
                A = obj.X(idx,3);
            else
                A = obj.A.(p.Attribute)(idx);
            end 

            % Plot!
            hPlot = scatter3ext(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), p.MarkerSize, A, ...
                                'ColormapName', p.ColormapName, ...
                                'Colorbar'    , p.Colorbar, ...
                                'CAxisLim'    , p.CAxisLim);

            % Colorbar
            if p.Colorbar
                hColorbar = findobj('Type', 'Colorbar', 'Parent', gcf);
                if ~isempty(hColorbar) % applies if min and max of CAxisLim is equal (e.g. if attribute contains only a single value)
                    p.CAxisLim = [hColorbar.Limits(1) hColorbar.Limits(2)];
                    hColorbar.Label.String = ['[' obj.label ']'];
                    hColorbar.Label.Interpreter = 'none';
                end
            end
                    
        % RGB plot
        elseif strcmpi(p.Color, 'rgb')

            colorbar off;
            
            % Check how colors are saved
            if isfield(obj.A, 'r') && isfield(obj.A, 'g') && isfield(obj.A, 'b')
                r = obj.A.r;
                g = obj.A.g;
                b = obj.A.b;
            elseif isfield(obj.A, 'red') && isfield(obj.A, 'green') && isfield(obj.A, 'blue')
                r = obj.A.red;
                g = obj.A.green;
                b = obj.A.blue;
            elseif isfield(obj.A, 'Red') && isfield(obj.A, 'Green') && isfield(obj.A, 'Blue')
                r = obj.A.Red;
                g = obj.A.Green;
                b = obj.A.Blue;
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
            elseif max(r) > 1 && max(r) <= 255
                [A, map] = rgb2ind(cat(3, r(idx)/255, g(idx)/255, b(idx)/255), nColors);
            elseif max(r) > 255 && max(r) <= 2^16-1
                [A, map] = rgb2ind(cat(3, r(idx)/65535, g(idx)/65535, b(idx)/65535), nColors);
            end

            hPlot = scatter3ext(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), p.MarkerSize, A, ...
                                'ColormapName', map, ...
                                'Colorbar'    , false, ...
                                'CAxisLim'    , [0 nColors-1]);

            % Alternative
            % hPlot = scatter3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), 5, [obj.A.r(idx)/255, obj.A.g(idx)/255, obj.A.b(idx)/255], 'fill'); (slow!)

        % Unicolor plot
        else

            colorbar off;
            
            % Unicolor plot with random color
            if strcmpi(p.Color, 'random')

                % p.Color = rand(1,3);
                
                % Plot!
                % hPlot = plot3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), '.', 'Color', p.Color, 'MarkerSize', p.MarkerSize);
                hPlot = plot3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), '.', 'MarkerSize', p.MarkerSize);

            % Unicolor plot with defined color
            else

                % Plot!
                hPlot = plot3(obj.X(idx,1), obj.X(idx,2), obj.X(idx,3), '.', 'Color', p.Color, 'MarkerSize', p.MarkerSize);

            end
            
        end
        
        % End ------------------------------------------------------------------

        msg('E', procHierarchy);

    end

    function selectSubsetOfPoints
        
        % Find indices of active points
        idx = find(obj.act);

        % Consider limits parameter
        if any(~isinf(p.Limits(:)))
            
            idxInLimits = obj.X(idx,1) >= min(p.Limits(1,:)) & ...
                          obj.X(idx,1) <= max(p.Limits(1,:)) & ...
                          obj.X(idx,2) >= min(p.Limits(2,:)) & ...
                          obj.X(idx,2) <= max(p.Limits(2,:)) & ...
                          obj.X(idx,3) >= min(p.Limits(3,:)) & ...
                          obj.X(idx,3) <= max(p.Limits(3,:));
                      
            idx = idx(idxInLimits);
            
        end
                  
        % Indices of points with consideration of parameter MaxPoi
        if ~isempty(p.MaxPoi) && numel(idx) > p.MaxPoi
            idxRandom = randperm(numel(idx), p.MaxPoi);
            idx       = idx(idxRandom);
        end

    end

    function setProperties
                
        xlabel('x');
        ylabel('y');
        zlabel('z');
        axis('equal');
        grid('on');
        set(gca, 'Color', [0.5 0.5 0.5]);
        set(gcf, 'Color', 'w');
        set(gcf, 'Name', 'pc viewer');
        hold('on');
        view(2);
        
    end

% Data cursor info -------------------------------------------------------------

dcmObj = datacursormode;
% dcmObj.DisplayStyle = 'window';
dcmObj.UpdateFcn = @plotInfo;

% Tooltip
if isempty(hAxes.UserData)
    hAxes.UserData{1}     = @findPoint;
else
    hAxes.UserData{end+1} = @findPoint;
end

    function output_txt = plotInfo(~, event_obj)

        % Attention: don't use 'obj' (or 'idx', ...) in this function, as it always refers to the last point cloud
        
        X = event_obj.Position;
        for i = 1:numel(hAxes.UserData)
            [id, label, A] = hAxes.UserData{i}(X);
            if ~isempty(id), break; end % if a point was found
        end
        
        output_txt = []; % initialize

        % Label
        output_txt = [output_txt sprintf('[%s]\n', label)];
        
        % Id
        output_txt = [output_txt sprintf('Id = %d\n', id)];
        
        % Coordinates
        output_txt = [output_txt sprintf('Coordinates:\n')]; % add empty line
        output_txt = [output_txt sprintf('X = %.3f\n', X(1))];
        output_txt = [output_txt sprintf('Y = %.3f\n', X(2))];
        output_txt = [output_txt sprintf('Z = %.3f\n', X(3))];
        
        % Attributes
        if ~isempty(A)  
            output_txt = [output_txt sprintf('Attributes:\n')]; % add empty line
            attributeNames = fields(A);
            for i = 1:numel(attributeNames)
                output_txt = [output_txt sprintf('%s = %.3f\n', attributeNames{i}, A.(attributeNames{i}))];
            end
        end
        
    end

    function [id, label, A] = findPoint(X)
        
        % Find index of selected point
        id = find(X(1) == obj.X(:,1) & ...
                  X(2) == obj.X(:,2) & ...
                  X(3) == obj.X(:,3));
                        
        % If no point was found
        if isempty(id)
            label = '';
            A = [];
            return;
        else
            
            % If more than one point was found (happens sometimes)
            id = id(1);
            
            % Save attributes of point to structure A
            A = []; % default
            if ~isempty(obj.A) % if point has attributes
                attributes = fieldnames(obj.A);
                for i = 1:numel(attributes)
                    A.(attributes{i}) = obj.A.(attributes{i})(id);
                end
            end

            label = obj.label;
            
        end
        
    end

datacursormode off

% Toolbar buttons --------------------------------------------------------------

hFig.MenuBar = 'none';
hFig.ToolBar = 'figure';

% Remove items from toolbar
hToolbar = findall(hFig, 'Type', 'uitoolbar');
hToolbarItems = allchild(hToolbar);

idx2del = [];
for i = 1:numel(hToolbarItems)
    if all(~strcmpi(hToolbarItems(i).Tag, {'Annotation.InsertColorbar' 'Exploration.Rotate' 'Exploration.DataCursor'})) % 'Exploration.Pan' 'Exploration.ZoomOut' 'Exploration.ZoomIn'
        idx2del = [idx2del; i];
    end
end
delete(hToolbarItems(idx2del));

% Initialize menu --------------------------------------------------------------

if p.Menu
    
    menuAllPCLabel = '[All point clouds]';
    menuAddPC      = 'Add point cloud(s)...';

    % Initialize menu if necessary
    if ~isfield(hFig.UserData, 'hMenuAllPC')
       
       hFig.UserData.hMenuAllPC = uimenu(hFig, 'Label', menuAllPCLabel); % create menu
       createMenu(hFig.UserData.hMenuAllPC);
       
       % Set shortcuts
       h = findobj(hFig.UserData.hMenuAllPC, 'Label', 'Show all');
       h.Accelerator = 'a';
       
       h = findobj(hFig.UserData.hMenuAllPC, 'Label', 'Draw rectangle');
       h.Accelerator = 'r';
       
       % Add 'rectangle' button
       % hPushtoolRectangle = uipushtool(hToolbar, 'ClickedCallback', h.Callback); % doesn't work
       % [img, map] = imread('icon_rectangle.gif');
       % icon = ind2rgb(img, map);
       % hPushtoolRectangle.CData = icon;
       
       % Menu for adding a new point cloud
       hFig.UserData.hMenuAddPC = uimenu(hFig, 'Label', menuAddPC, 'Callback', @addPointCloud);
       
    end

end

% Menu for actual point cloud --------------------------------------------------

if p.Menu
    
    label4menu = obj.label;
    maxNoChar = 30;
    if numel(label4menu) > maxNoChar, label4menu = [label4menu(1:maxNoChar) '...']; end
    if ~isfield(hFig.UserData, 'hMenuPC')
        idxPC = 1;
    else
        idxPC = numel(hFig.UserData.hMenuPC)+1;
    end
    hFig.UserData.hMenuPC{idxPC} = uimenu(hFig, 'Label', ['[' label4menu ']']);
    hFig.UserData.hMenuPC{idxPC}.Position = hFig.UserData.hMenuPC{idxPC}.Position-1; % move menu
    pause(0.01) % without this line position of menu doesn't change (bug???)
    createMenu(hFig.UserData.hMenuPC{idxPC});
    hFig.UserData.hMenuPC{idxPC}.UserData = @updatePlot;
    
end

% ------------------------------------------------------------------------------

    function createMenu(parentMenu)
       
        % Color
        p1 = uimenu(parentMenu, 'Label', 'Color');
        colors = {'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black' 'rgb' 'random' 'custom'};
        for i = 1:numel(colors)
            uimenu('Parent', p1, 'Label', colors{i}, 'Callback', @setColor);
        end

        % Attributes
        p2 = uimenu(parentMenu, 'Label', 'Attribute');
        uimenu('Parent', p2, 'Label', 'z', 'Callback', @setAttribute);
        if ~isempty(obj.A)
            attributeNames = fields(obj.A);
            for i = 1:numel(attributeNames)
                uimenu('Parent', p2, 'Label', attributeNames{i}, 'Callback', @setAttribute);
            end
        end

        % MarkerSize
        p3 = uimenu(parentMenu, 'Label', 'MarkerSize');
        for i = 1:10
            uimenu('Parent', p3, 'Label', num2str(i), 'Callback', @setMarkerSize);
        end
        uimenu('Parent', p3, 'Label', 'custom', 'Callback', @setMarkerSize);

        % MaxPoi
        p4 = uimenu(parentMenu, 'Label', 'MaxPoi', 'Callback', @setMaxPoi);

        % ColormapName
        colormaps = {'parula' 'jet' 'hsv' 'hot' 'cool' 'spring' 'summer' 'autumn' 'winter' 'gray' 'bone' 'copper' 'pink' 'lines' 'colorcube' 'prism' 'flag'}; % from 'doc colormap'
        p5 = uimenu(parentMenu, 'Label', 'ColormapName');
        for i = 1:numel(colormaps)
            uimenu('Parent', p5, 'Label', colormaps{i}, 'Callback', @setColormapName);
        end
        uimenu('Parent', p5, 'Label', 'custom', 'Callback', @setColormapName);

        % CAxisLim
        p6 = uimenu(parentMenu, 'Label', 'CAxisLim', 'Callback', @setCAxisLim);

        % Limits
        p7 = uimenu(parentMenu, 'Label', 'Limits');
        uimenu('Parent', p7, 'Label', 'Set', 'Callback', @setLimits);
        uimenu('Parent', p7, 'Label', 'Draw rectangle', 'Callback', @setLimitsRectangle)
        uimenu('Parent', p7, 'Label', 'Show all', 'Callback', @setLimitsShowAll)

        % uimenu(parentMenu, 'Label', sprintf('%.2f%% of points displayed', percentageDisplayedPoints), 'Separator', 'on', 'Enable', 'off');
        
    end

    function setColor(~, event_obj)
        
        color = event_obj.Source.Label;
        
        if strcmpi(color, 'custom')
            
            prompt = {'Red [0...1]:' 'Green [0...1]:' 'Blue [0...1]:'};
            dlgTitle = '';
            noLines = 1;
            defaultAnswer = {'0' '0' '0'};
            answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);

            color = [str2num(answer{1}) str2num(answer{2}) str2num(answer{3})];
            
        end
        
        callUpdatePlot(event_obj, ...
                       2, ...
                       'Color', color);
        
    end

    function setAttribute(~, event_obj)

        callUpdatePlot(event_obj, ...
                       2, ...
                       'Color'    , '', ...
                       'Attribute', event_obj.Source.Label, ...
                       'CAxisLim' , [])
        
    end

    function setMarkerSize(~, event_obj)
        
        if strcmpi(event_obj.Source.Label, 'custom')
            
            prompt = {'Markersize:'};
            dlgTitle = '';
            noLines = 1;
            if strcmpi(event_obj.Source.Parent.Label, menuAllPCLabel)
                defaultAnswer = {''};
            else
                defaultAnswer = {num2str(p.MarkerSize)};
            end
            answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);

            if ~isempty(answer)
                markerSize = str2num(answer{1});
            end
            
        else
        
            markerSize = str2num(event_obj.Source.Label);
        
        end
        
        callUpdatePlot(event_obj, ...
                       2, ...
                       'MarkerSize', markerSize);
        
    end

    function setMaxPoi(~, event_obj)
        
        prompt = {'MaxPoi:'};
        dlgTitle = '';
        noLines = 1;
        if strcmpi(event_obj.Source.Parent.Label, menuAllPCLabel)
            defaultAnswer = {''};
        else
            defaultAnswer = {num2str(p.MaxPoi)};
        end
        answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
        
        if ~isempty(answer)
            maxPoi = str2num(answer{1});
            callUpdatePlot(event_obj, ...
                           1, ...
                           'MaxPoi', maxPoi);
        end
        
    end

    function setColormapName(~, event_obj)
        
        if strcmpi(event_obj.Source.Label, 'custom')
            
            prompt = {'ColormapName:'};
            dlgTitle = '';
            noLines = 1;
            if strcmpi(event_obj.Source.Parent.Label, menuAllPCLabel)
                defaultAnswer = {''};
            else
                defaultAnswer = {p.ColormapName};
            end
            answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
        
            if ~isempty(answer)
                colormapName = answer{1};
            end
            
        else
           
            colormapName = event_obj.Source.Label;
        
        end
            
        callUpdatePlot(event_obj, ...
                       2, ...
                       'ColormapName', colormapName);

    end

    function setCAxisLim(~, event_obj)
        
        prompt = {'Min:' 'Max:'};
        dlgTitle = '';
        noLines = 1;
        if strcmpi(event_obj.Source.Parent.Label, menuAllPCLabel)
            defaultAnswer = {'' ''};
        else
            defaultAnswer = {num2str(min(p.CAxisLim)) num2str(max(p.CAxisLim))};
        end
        answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
        
        if ~isempty(answer)
            cAxisLim = [str2num(answer{1}) str2num(answer{2})];
            callUpdatePlot(event_obj, ...
                           1, ...
                           'CAxisLim', cAxisLim, ...
                           'Colorbar', true);
        end
        
    end

    function setLimits(~, event_obj)
        
        prompt = {'xMin:' 'xMax:' 'yMin:', 'yMax:' 'zMin:', 'zMax:'};
        dlgTitle = '';
        noLines = 1;
        if strcmpi(event_obj.Source.Parent.Parent.Label, menuAllPCLabel)
            xMinMax = xlim;
            yMinMax = ylim;
            zMinMax = zlim;
            defaultAnswer = {num2str(xMinMax(1)) num2str(xMinMax(2)) num2str(yMinMax(1)) num2str(yMinMax(2)) num2str(zMinMax(1)) num2str(zMinMax(2))};
        else
            defaultAnswer = {num2str(p.Limits(1,1)) num2str(p.Limits(1,2)) num2str(p.Limits(2,1)) num2str(p.Limits(2,2)) num2str(p.Limits(3,1)) num2str(p.Limits(3,2))};
        end
        answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
        
        if ~isempty(answer)
            
            limits = [str2num(answer{1}) str2num(answer{2})
                      str2num(answer{3}) str2num(answer{4})
                      str2num(answer{5}) str2num(answer{6})];
                  
            callUpdatePlot(event_obj, ...
                           2, ...
                           'Limits', limits);

        end
        
    end

    function setLimitsRectangle(~, event_obj)
       
        view(2);
        
        zoom off
        pan off
        rotate3d off
        datacursormode off
        
        rect = getrect(hAxes);
        
        limits = [rect(1) rect(1)+rect(3)
                  rect(2) rect(2)+rect(4)];
        
        if strcmpi(event_obj.Source.Parent.Parent.Label, menuAllPCLabel)
        
            limits(3,1) = -Inf;
            limits(3,2) =  Inf;
            
            % Set axes limits
            xlim(limits(1,:));
            ylim(limits(2,:));
            
        else
            
            limits(3,1) = p.Limits(3,1);
            limits(3,2) = p.Limits(3,2);
            
        end

        callUpdatePlot(event_obj, ...
                       2, ...
                       'Limits', limits);
                
    end

    function setLimitsShowAll(~, event_obj)
       
        limits = [-Inf Inf
                  -Inf Inf
                  -Inf Inf];
                
        callUpdatePlot(event_obj, ...
                       2, ...
                       'Limits', limits);
        
    end

    function callUpdatePlot(event_obj, menuDepth, varargin)
    % Call updatePlot function(s) for one or for all point clouds
        
        % Change for all?
        changeForAll = false; % default
        if menuDepth == 1
            if strcmpi(event_obj.Source.Parent.Label, menuAllPCLabel)
                changeForAll = true;
            end
        elseif menuDepth == 2
            if strcmpi(event_obj.Source.Parent.Parent.Label, menuAllPCLabel)
                changeForAll = true;
            end
        end
        
        if changeForAll % change for all point clouds
            for n = 1:numel(hFig.UserData.hMenuPC)
                f{n} = hFig.UserData.hMenuPC{n}.UserData; % handles to updatePlot functions
            end
            % Call updatePlot functions
            for i = 1:numel(f), f{i}(varargin{:}); end
        else % change only for one point cloud
            updatePlot(varargin{:});
        end

    end

    function addPointCloud(~, event_obj)
        
        % Select file(s)
        [files, path] = uigetfile('*.*', 'Select point cloud file(s)', 'MultiSelect', 'on');
        if ~iscell(files), if files == 0, return; end, end % if no file was selected
        if ischar(files), files = {files}; end % convert to cell if only one file was selected
        
        % Import and plot point cloud(s)
        for i = 1:numel(files)
            pc = pointCloud(fullfile(path, files{i}), 'kd', false);
            pc.plot;
        end
        
    end

end