function plot_setCAxisLim(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.UserData.idxPC; % index of PC(s)

try

    % Get new value
    prompt = {'Min:' 'Max:'};
    dlgTitle = '';
    noLines = 1;
    if numel(idxPC) > 1
        defaultAnswer = {'' ''};
    else
        defaultAnswer = {num2str(min(hFig.UserData.PC{idxPC}.U.p.CAxisLim)) num2str(max(hFig.UserData.PC{idxPC}.U.p.CAxisLim))};
    end
    answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);

    if ~isempty(answer)
        if ~any(cellfun(@isempty, answer))
            CAxisLim = [str2num(answer{1}) str2num(answer{2})];
        else
            return;
        end
    else
        return;
    end
    
catch
    
    throwError('CAxisLim'); return;
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i), 'CAxisLim', CAxisLim);
end

end
