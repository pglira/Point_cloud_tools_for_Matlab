function plot_setMaxPoints(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.UserData.idxPC; % index of PC(s)

try

    % Get new value
    prompt = {'MaxPoints:'};
    dlgTitle = '';
    noLines = 1;
    if numel(idxPC) > 1
        defaultAnswer = {''};
    else
        defaultAnswer = {num2str(hFig.UserData.PC{idxPC}.U.p.MaxPoints)};
    end
    answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
    if ~isempty(answer), MaxPoints = str2num(answer{1}); end
    
catch
    
    throwError('MaxPoints'); return;
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i), 'MaxPoints', MaxPoints);
end

end