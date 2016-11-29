function plot_transform(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.UserData.idxPC; % index of PC(s)

% Get new value
prompt = {'UTM Zone:'};
dlgTitle = '';
noLines = 1;
defaultAnswer = {'33n'};
answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
if ~isempty(answer)
    UTMZone = answer{1};
else
    return;
end

% Transform
for i = 1:numel(idxPC)
    
    if i == 1, logLevelOrig = msg('O', 'GetLogLevel'); end
    msg('O', 'SetLogLevel', 'off');
    
    % mstruct
    mstruct       = defaultm('utm');
    mstruct.zone  = UTMZone;
    mstruct.geoid = referenceEllipsoid('GRS 80');
    mstruct       = defaultm(mstruct);

    % Transform!
    hFig.UserData.PC{idxPC(i)}.ecef2mapTrafo(mstruct);
    
    msg('O', 'SetLogLevel', logLevelOrig);
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i));
end

end
