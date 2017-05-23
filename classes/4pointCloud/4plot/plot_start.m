function [hFig, idxPC, firstCall] = plot_start

% Get figure handle
hFigOpals  = findobj('type', 'figure', 'Name', 'opalsView');
hFigPCPlot = findobj('type', 'figure', 'Name', 'pointCloud.plot');
if ~isempty(hFigOpals) , hFig = hFigOpals;  end % use found opalsView figure
if ~isempty(hFigPCPlot), hFig = hFigPCPlot; end % use found pointCloud.plot figure
if isempty(hFigOpals) && isempty(hFigPCPlot) % new figure
    hFig = figure;
    % centerfigureonscreen(hFig);
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