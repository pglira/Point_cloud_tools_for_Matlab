function plotPolar(obj, varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParameter('MaxPoi', 10^6, @(x) isnumeric(x) && x>0);
p.parse(varargin{:});
p = p.Results;

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'PLOTPOLAR'};
msg('S', procHierarchy);
msg('V', p.MaxPoi, 'IN: MaxPoi', 'Prec', 0);

% Figure, Axes, GUI elements ---------------------------------------------------

% Create axes
hAxesPolar = axes('Color' , [0.3 0.3 0.3]);
xlabel('horizontal angle [g]');
ylabel('vertical angle [g]');
hold('on');
axis('equal');
grid('on');
title(obj.label, 'Interpreter', 'none');

% Add menu
hMenu = uimenu(gcf, 'Label', 'PointCloud');
uimenu(hMenu, 'Label', 'Select points',                     'Callback', @selpoints);
uimenu(hMenu, 'Label', 'Show all'     , 'Accelerator', 'A', 'Callback', @showall);

% Callbacks for zoom and pan
set(zoom(gca), 'ActionPostCallback', @updplot);
set(pan(gcf) , 'ActionPostCallback', @updplot);

% Load colors of jet colormap
jet = colormap('jet');

% Number of colors
nColors = size(jet,1);

% Polar coordinates ------------------------------------------------------------

% Find indices of active points
idx = find(obj.act == true);

% Polar coordinates
msg('S', {procHierarchy{:} 'POLARCOORD'});
P = xyz2polar(obj.X(idx, :));
msg('E', {procHierarchy{:} 'POLARCOORD'});

% Transformation of zenith angle (otherwise plot is upside/down)
P(:,3) = 100 - P(:,3);

% Plot points ------------------------------------------------------------------

updplot

% Original limits of axes
XLimOrig = get(gca, 'XLim');
YLimOrig = get(gca, 'YLim');

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function updplot(~, ~)

        % First run
        if isempty(get(hAxesPolar, 'Children'))

            % Polar points to plot
            P2Plot = P;
            
        else
            
            cla;
        
            % Get limits from axes
            XLim = get(gca, 'XLim');
            YLim = get(gca, 'YLim');

            % Points within Limits
            idxInLim = P(:,2) >= XLim(1) & P(:,2) <= XLim(2) & P(:,3) >= YLim(1) & P(:,3) <= YLim(2);

            % Polar points to plot
            P2Plot = P(idxInLim,:);

        end

        % Indices of points with consideration of parameter MaxPoi
        if ~isempty(p.MaxPoi) && size(P2Plot,1) > p.MaxPoi

            idxRand = randi(size(P2Plot,1), p.MaxPoi, 1);
            P2Plot = P2Plot(idxRand,:);

        end
        
        % Distance range for each color
        dMin = min(P2Plot(:,1));
        dMax = max(P2Plot(:,1));
        deltad = (dMax-dMin)/nColors;

        % Plot each color with function plot (faster than scatter)
        for i = 1:nColors

            % Points whitin range
            actColor = P2Plot(:,1) >= dMin + deltad*(i-1) & P2Plot(:,1) < dMin + deltad*i;

            % Plot!
            plot(P2Plot(actColor,2), P2Plot(actColor,3), '.', 'Color', jet(i,:));

        end
        
        % Colorbar
        colorbar('YTick', [1 65], 'YTickLabel', {sprintf('%.1f m', min(P2Plot(:,1))), sprintf('%.1f m', max(P2Plot(:,1)))});

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function showall(~, ~)
        
        % Set axes limits to original limits
        set(gca, 'XLim', XLimOrig);
        set(gca, 'YLim', YLimOrig);

        updplot;
        
    end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function selpoints(~, ~)

        % Ask for variable name containing the ids of the selected points
        title  = 'Select points';
        prompt = {'variable name containing ids of points:'};
        defId = {'sel'};
        answer = inputdlg(prompt, title, 1, defId);
        
        % If user confirms dialog with OK
        if ~isempty(answer)

            % Draw polygon
            [x, y] = getline('closed');

            % Which points are in polygon?
            idxInPolyLog = inpolygon(P(:,2), P(:,3), x, y);
            idxInPoly = idx(idxInPolyLog);

            % Save variable with ids in base workspace
            assignin('base', answer{1}, idxInPoly);

            % Display selection in 3d
            figure;
            plot3(obj.X(idxInPoly,1), obj.X(idxInPoly,2), obj.X(idxInPoly,3), 'r.');
            axis('equal');
            xlabel('x');
            ylabel('y');
            zlabel('z');
            
        end
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end