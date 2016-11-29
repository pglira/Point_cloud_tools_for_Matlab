function plot_selectInPolygon(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.UserData.idxPC; % index of PC(s)

hAxes = gca;

try

    % Get new value
    view(2);
    hRotate = rotate3d;
    if strcmpi(hRotate.Enable, 'On'), reactivateRotate3d = true; else reactivateRotate3d = false; end
    
    % Select polygon
    % [x, y] = ginput;
    
    % Initialization
    button = 1;
    i = 0;
    
    zMax = max(get(gca, 'ZLim')); % for selection line
    
    while button == 1 % as long as left mouse button is clicked
        
        i = i+1;
        
        [xNew, yNew, button] = ginput_2016a_mod(1);
       
        % Break if user hits return
        if isempty(xNew), break; end
        
        x(i,1) = xNew;
        y(i,1) = yNew;
        
        z = repmat(zMax, numel(x), 1);

        % Polygon points
        if numel(x) >= 2, delete(h0); end
        h0 = plot3(x, y, z, 'o', 'Color', 'r', 'MarkerSize', 5, 'LineWidth', 2);
            
        % Polygon line
        if numel(x) == 2 % if only 2 points are selected
            h1 = plot3(x, y, z, '-', 'LineWidth', 3, 'Color', 'k');
            h2 = plot3(x, y, z, ':', 'LineWidth', 3, 'Color', 'w');
        elseif numel(x) >= 3 % if more than 2 points are selected
            delete(h1); delete(h2);
            h1 = plot3([x; x(1)], [y; y(1)], [z; z(1)], '-', 'LineWidth', 3, 'Color', 'k');
            h2 = plot3([x; x(1)], [y; y(1)], [z; z(1)], ':', 'LineWidth', 3, 'Color', 'w');
        end

    end

    % Delete line and points
    delete(h0); delete(h1); delete(h2);
    
    % plot([xNew x(1)], [yNew y(1)], 'g-'); % join first to last points
    
    if reactivateRotate3d, hRotate.Enable  = 'On'; end
    
catch
    
    error('Error selecting ''Profile''!'); return;
    
end

% Select polygon
for i = 1:numel(idxPC)
    
    if i == 1, logLevelOrig = msg('O', 'GetLogLevel'); end
    msg('O', 'SetLogLevel', 'off');
    
    % Select polygon!
    hFig.UserData.PC{idxPC(i)}.select('All');
    hFig.UserData.PC{idxPC(i)}.select('InPolygon', [x y]);
    
    msg('O', 'SetLogLevel', logLevelOrig);
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i));
end

end
