function plot_transform(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.Parent.UserData.idxPC; % index of PC(s)

% Get new value
prompt = {'m:' 'A:' 't:'};
dlgTitle = '';
noLines = 1;
defaultAnswer = {'1' '[1 0 0; 0 1 0; 0 0 1]' '[0 0 0]'};
answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
if ~isempty(answer)
    m = str2num(answer{1});
    A = str2num(answer{2});
    t = str2num(answer{3});
else
    return;
end

% Transform
for i = 1:numel(idxPC)
    
    if i == 1, logLevelOrig = msg('O', 'GetLogLevel'); end
    msg('O', 'SetLogLevel', 'off');
    
    % Transform!
    hFig.UserData.PC{idxPC(i)}.transform(m, A, t);
    
    msg('O', 'SetLogLevel', logLevelOrig);
    
end

% Update plot!
for i = 1:numel(idxPC)
    plot_setPrmAndPlot(hFig, idxPC(i));
end

end
