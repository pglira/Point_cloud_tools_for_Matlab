function [hFig, idxPC, firstCall] = plot_start

% Get figure handle
hFig = findobj('type', 'figure', 'Name', 'pointCloud.plot');
if isempty(hFig),
    hFig = figure;
    centerfigureonscreen(hFig);
end

% Get index of actual PC
if ~isfield(hFig.UserData, 'PC')
    idxPC = 1;
    firstCall = true; % first call of method 'plot'
else
    idxPC = numel(hFig.UserData.PC) + 1;
    firstCall = false;
end

% Call functions which otherwise are not included during compilation with mcc
if firstCall
    jetinv;
    difpal;
    classpal;
end

end