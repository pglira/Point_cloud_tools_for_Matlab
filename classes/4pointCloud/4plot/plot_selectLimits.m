function plot_selectLimits(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.Parent.UserData.idxPC; % index of PC(s)

hAxes = gca;

try

    % Option 'Set'
    if strcmp(eventObj.Source.Label, 'Set')

        % Get new value
        prompt = {'xMin:' 'xMax:' 'yMin:', 'yMax:' 'zMin:', 'zMax:'};
        dlgTitle = '';
        noLines = 1;
        if numel(idxPC) > 1 | numel(hFig.UserData.PC) == numel(idxPC) % if more than one point cloud or there is just one single point cloud
            xMinMax = xlim;
            yMinMax = ylim;
            zMinMax = zlim;
            defaultAnswer = {num2str(xMinMax(1)) num2str(xMinMax(2)) num2str(yMinMax(1)) num2str(yMinMax(2)) num2str(zMinMax(1)) num2str(zMinMax(2))};
        else
            defaultAnswer = {num2str(hFig.UserData.PC{idxPC}.U.p.Limits(1,1)) num2str(hFig.UserData.PC{idxPC}.U.p.Limits(1,2)) num2str(hFig.UserData.PC{idxPC}.U.p.Limits(2,1)) num2str(hFig.UserData.PC{idxPC}.U.p.Limits(2,2)) num2str(hFig.UserData.PC{idxPC}.U.p.Limits(3,1)) num2str(hFig.UserData.PC{idxPC}.U.p.Limits(3,2))};
        end
        answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
        if ~isempty(answer)
            Limits = [str2num(answer{1}) str2num(answer{2})
                      str2num(answer{3}) str2num(answer{4})
                      str2num(answer{5}) str2num(answer{6})];
        else
            return;
        end

    % Option 'Choose'
    elseif strcmp(eventObj.Source.Label, 'Choose')

        % Get new value
        view(2);
        hRotate = rotate3d;
        if strcmpi(hRotate.Enable, 'On'), reactivateRotate3d = true; else reactivateRotate3d = false; end

        % rect = getrect(gca);
        rect = getrect_2016b_mod(gca);

        Limits = [rect(1) rect(1)+rect(3)
                  rect(2) rect(2)+rect(4)
                  -Inf    Inf];

        if reactivateRotate3d, hRotate.Enable  = 'On'; end
        
    % Option 'Zoom out'
    elseif strcmp(eventObj.Source.Label, 'Zoom out')
        
        Limits = [hAxes.XLim(1)-(hAxes.XLim(2)-hAxes.XLim(1))*0.5 hAxes.XLim(2)+(hAxes.XLim(2)-hAxes.XLim(1))*0.5
                  hAxes.YLim(1)-(hAxes.YLim(2)-hAxes.YLim(1))*0.5 hAxes.YLim(2)+(hAxes.YLim(2)-hAxes.YLim(1))*0.5
                  -Inf                                            Inf];

    % Option 'Show all'
    elseif strcmp(eventObj.Source.Label, 'Show all')

        % Set new value
        Limits = [-Inf Inf
                  -Inf Inf
                  -Inf Inf];

    end
    
catch
    
    error('Error selecting ''Limits''!'); return;
    
end

% Select limits
for i = 1:numel(idxPC)
    
    if i == 1, logLevelOrig = msg('O', 'GetLogLevel'); end
    msg('O', 'SetLogLevel', 'off');
    
    % Select all? (only if new limits are greater than old limits)
    % if any(strcmp(eventObj.Source.Label, {'Show all' 'Zoom out'}))
        hFig.UserData.PC{idxPC(i)}.select('All');
    % end
    
    % Select limits!
    hFig.UserData.PC{idxPC(i)}.select('Limits', Limits, 'Reduced', true);
    
    msg('O', 'SetLogLevel', logLevelOrig);
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i));
end

end
