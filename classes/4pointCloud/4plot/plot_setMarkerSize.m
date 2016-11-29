function plot_setMarkerSize(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.UserData.idxPC; % index of PC(s)

try
    
    % Get new value
    if strcmpi(eventObj.Source.Label, 'custom')

        prompt = {'MarkerSize:'};
        dlgTitle = '';
        noLines = 1;
        if numel(idxPC) > 1
            defaultAnswer = {''};
        else
            defaultAnswer = {num2str(hFig.UserData.PC{idxPC}.U.p.MarkerSize)};
        end
        answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);

        if ~isempty(answer)
            MarkerSize = str2num(answer{1});
        end

    else

        MarkerSize = str2num(eventObj.Source.Label);

    end
    
catch
    
    throwError('MarkerSize'); return;
    
end
    
% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i), 'MarkerSize', MarkerSize);
end

end