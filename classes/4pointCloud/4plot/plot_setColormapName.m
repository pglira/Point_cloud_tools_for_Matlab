function plot_setColormapName(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.UserData.idxPC; % index of PC(s)

try

    % Get new value
    if strcmpi(eventObj.Source.Label, 'custom')

        prompt = {'ColormapName:'};
        dlgTitle = '';
        noLines = 1;
        if numel(idxPC) > 1
            defaultAnswer = {''};
        else
            defaultAnswer = {hFig.UserData.PC{idxPC}.U.p.ColormapName};
        end
        answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);

        if ~isempty(answer)
            ColormapName = answer{1};
        end

    else

        ColormapName = eventObj.Source.Label;

    end
    
catch
    
    throwError('ColormapName'); return;
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i), 'ColormapName', ColormapName);
end

end