function plot_updatePlot(hFig, idxPC)

% PC in UserData of figure -> PC -----------------------------------------------

PC = hFig.UserData.PC{idxPC};

% Delete points and normals of previous plot -----------------------------------

% Delete points
if ~iscell(PC.U.hPlot)
    delete(PC.U.hPlot);
else
    for j = 1:numel(PC.U.hPlot)
        delete(PC.U.hPlot{j});
    end
end

% Delete normals
delete(PC.U.hPlotNormals);

% Consider parameter 'MaxPoints' -----------------------------------------------

if sum(PC.act) > PC.U.p.MaxPoints
    PC.U.percentOfVisiblePoints = PC.U.p.MaxPoints/sum(PC.act)*100;
    idxAct = find(PC.act); % indices of active points
    idxRandom = randperm(numel(idxAct), PC.U.p.MaxPoints); % indices of randomly selected points
    act4plot = false(PC.noPoints,1);
    act4plot(idxAct(idxRandom)) = true; % reactivate randomly selected points
else
    PC.U.percentOfVisiblePoints = 100;
    act4plot = PC.act;
end

% Plot -------------------------------------------------------------------------

if PC.U.Visible && sum(act4plot) > 0
    
    % Axes handle
    hAxes = findobj('Parent', hFig, 'Type', 'Axes');
    
    % Colorize points according to an attribute
    if numel(PC.U.p.Color) > 1 && strcmp(PC.U.p.Color(1:2), 'A.') && ~strcmpi(PC.U.p.Color, 'A.RGB') % if p.Color begins with 'A.'

        % Values of attribute to plot
        attribute2plot = PC.U.p.Color(3:end); % attribute name
        if strcmpi(attribute2plot, 'x') % attribute = x coordinate
            A = PC.X(act4plot,1);
        elseif strcmpi(attribute2plot, 'y') % attribute = y coordinate
            A = PC.X(act4plot,2);
        elseif strcmpi(attribute2plot, 'z') % attribute = z coordinate
            A = PC.X(act4plot,3);
        else
            A = PC.A.(attribute2plot)(act4plot);
        end 

        % Plot!
        PC.U.hPlot = scatter3(hAxes, PC.X(act4plot,1), PC.X(act4plot,2), PC.X(act4plot,3), PC.U.p.MarkerSize^2, A, '.');
        
        % Colormap
        colormap(PC.U.p.ColormapName);
        
        % CAxisLim
        if strcmpi(PC.U.p.ColormapName, 'classpal') % for visualization of classes with maximum distiguishable colors
        
            caxis([-0.5 50.5]); % for no. of classes = 50, see classpal.m
            
        else % usual case
            
            if isempty(PC.U.p.CAxisLim)
                CAxisLim = [min(A) max(A)];
            else
                CAxisLim = PC.U.p.CAxisLim;
            end
            caxis(CAxisLim);
            
        end
        
        % % Colorbar
        % hColorbar = findobj('Type', 'Colorbar', 'Parent', gcf);
        % if ~isempty(hColorbar) % applies if min and max of CAxisLim is equal (e.g. if attribute contains only a single value)
        %     PC.U.p.CAxisLim = [hColorbar.Limits(1) hColorbar.Limits(2)];
        %     hColorbar.Label.String = PC.label;
        %     hColorbar.Label.Interpreter = 'none';
        % end

    % RGB plot
    elseif strcmpi(PC.U.p.Color, 'A.RGB')

        colorbar off;

        % Check how colors are saved
        if isfield(PC.A, 'r') && isfield(PC.A, 'g') && isfield(PC.A, 'b')
            r = PC.A.r;
            g = PC.A.g;
            b = PC.A.b;
        elseif isfield(PC.A, 'red') && isfield(PC.A, 'green') && isfield(PC.A, 'blue')
            r = PC.A.red;
            g = PC.A.green;
            b = PC.A.blue;
        elseif isfield(PC.A, 'Red') && isfield(PC.A, 'Green') && isfield(PC.A, 'Blue')
            r = PC.A.Red;
            g = PC.A.Green;
            b = PC.A.Blue;
        elseif isfield(PC.A, 'diffuse_red') && isfield(PC.A, 'diffuse_green') && isfield(PC.A, 'diffuse_blue')
            r = PC.A.diffuse_red;
            g = PC.A.diffuse_green;
            b = PC.A.diffuse_blue;
        end

        % Check if colors were found
        if ~exist('r', 'var') | ~exist('g', 'var') | ~exist('b', 'var')
            errordlg('No RGB attributes found!');
            return;
        end
        
        % Conversion of colors
        if max(r) <= 1
            % do nothing
        elseif max(r) > 1 && max(r) <= 2^8-1
            r = r/(2^8-1); g = g/(2^8-1); b = b/(2^8-1);
        elseif max(r) > 255 && max(r) <= 2^16-1
            r = r/(2^16-1); g = g/(2^16-1); b = b/(2^16-1);
        end
        
        % Plot!
        PC.U.hPlot = scatter3(hAxes, PC.X(act4plot,1), PC.X(act4plot,2), PC.X(act4plot,3), PC.U.p.MarkerSize^2, [r(act4plot) g(act4plot) b(act4plot)], '.');
        
    % Unicolor plot
    else

        colorbar off;

        % Plot!
        if strcmpi(PC.U.p.Color, 'by PC')
            nColor = size(hFig.UserData.colors,1);
            idxColor = mod(idxPC,nColor); if idxColor == 0, idxColor = nColor; end % get color index
            PC.U.p.Color = hFig.UserData.colors{idxColor,1};
        end

        PC.U.hPlot = plot3(hAxes, PC.X(act4plot,1), PC.X(act4plot,2), PC.X(act4plot,3), '.', 'MarkerSize', PC.U.p.MarkerSize, 'Color', PC.U.p.Color);

    end
 
    % Plot normals
    if hFig.UserData.PC{idxPC}.U.plotNormals
        PC.U.hPlotNormals = PC.plotNormals('Scale', hFig.UserData.options.NormalsScale, 'Color', hFig.UserData.options.NormalsColor, 'Axes', hAxes); % plot normals!
    end
    
end

% PC -> UserData of figure -----------------------------------------------------

hFig.UserData.PC{idxPC} = PC;

% Update menus -----------------------------------------------------------------

plot_updateMenus(hFig)

% Update histogram -------------------------------------------------------------

plot_updateHisto(hFig)

end
