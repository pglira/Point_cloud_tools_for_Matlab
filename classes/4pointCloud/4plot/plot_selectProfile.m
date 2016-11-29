function plot_selectProfile(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.UserData.idxPC; % index of PC(s)

hAxes = gca;

try

    % Get new value
    view(2);
    hRotate = rotate3d;
    if strcmpi(hRotate.Enable, 'On'), reactivateRotate3d = true; else reactivateRotate3d = false; end
    
    % Var1: Select profile
    % [x, y] = ginput_2016a_mod(2);
    % lineStart = [x(1) y(1)];
    % lineEnd   = [x(2) y(2)];
    
    % Var2: Select profile
    [lineStart(1), lineStart(2)] = ginput_2016a_mod(1); % get start point
    zMax = max(get(gca, 'ZLim'));
    hStart = plot3(lineStart(1), lineStart(2), zMax, 'o', 'Color', 'r', 'MarkerSize', 5, 'LineWidth', 2);
    [lineEnd(1), lineEnd(2)] = ginput_2016a_mod(1); % get end point
    hEnd = plot3(lineEnd(1), lineEnd(2), zMax, 'o', 'Color', 'r', 'MarkerSize', 5, 'LineWidth', 2);
    hLine1 = plot3([lineStart(1); lineEnd(1)], [lineStart(2); lineEnd(2)], [zMax; zMax], '-', 'LineWidth', 3, 'Color', 'k');
    hLine2 = plot3([lineStart(1); lineEnd(1)], [lineStart(2); lineEnd(2)], [zMax; zMax], ':', 'LineWidth', 3, 'Color', 'w');
    
    % Define width
    prompt = {'Profile width:'};
    dlgTitle = '';
    noLines = 1;
    defaultAnswer = {'1'};
    answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
    delete(hStart); delete(hEnd); delete(hLine1); delete(hLine2); % delete points and line
    if ~isempty(answer{1})
        lineWidth = str2num(answer{1});
    else
        return;
    end
    
    if reactivateRotate3d, hRotate.Enable  = 'On'; end
    
catch
    
    error('Error selecting ''Profile''!'); return;
    
end

% Select profile
for i = 1:numel(idxPC)
    
    if i == 1, logLevelOrig = msg('O', 'GetLogLevel'); end
    msg('O', 'SetLogLevel', 'off');
    
    % Select profile!
    hFig.UserData.PC{idxPC(i)}.select('All');
    az = hFig.UserData.PC{idxPC(i)}.select('Profile', lineStart, lineEnd, lineWidth);
    
    msg('O', 'SetLogLevel', logLevelOrig);
    
end

view(az, 0);

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i));
end

end
