%MAXIMIZE  Maximize a figure window to fill the entire screen
%
% Examples:
%   maximize
%   maximize(hFig)
%
% Maximizes the current or input figure so that it fills the whole of the
% screen that the figure is currently on. This function is platform
% independent.
%
%IN:
%   hFig - Handle of figure to maximize. Default: gcf.

function maximize(hFig)
if nargin < 1
    hFig = gcf;
end
drawnow % Required to avoid Java errors
jFig = get(handle(hFig), 'JavaFrame');
jFig.setMaximized(true);