function plot_setColor(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.Parent.UserData.idxPC; % index of PC(s)

try

    % Get new value
    if strcmp(eventObj.Source.Parent.Label, 'Unicolor')

        if strcmp(eventObj.Source.Label, 'custom')

            prompt = {'Red [0...255]:' 'Green [0...255]:' 'Blue [0...255]:'};
            dlgTitle = '';
            noLines = 1;
            defaultAnswer = {'0' '0' '0'};
            answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);

            Color = [str2num(answer{1})/255 str2num(answer{2})/255 str2num(answer{3})/255];

        else

            Color = eventObj.Source.Label;

        end

    elseif strcmp(eventObj.Source.Parent.Label, 'Attribute')

        Color = ['A.' eventObj.Source.Label];

    end
    
catch
    
    throwError('Color'); return;
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i), 'Color', Color);
end

end