function plot_savePC(hFig, obj, idxPC)

% Copy object
hFig.UserData.PC{idxPC} = obj.copy;

% Keep only active points to save memory
if sum(hFig.UserData.PC{idxPC}.act) < hFig.UserData.PC{idxPC}.noPoints
    
    % Deactivate logging
    originalLogLevel = msg('O', 'GetLogLevel');
    msg('O', 'SetLogLevel', 'off');
    
    % Reconstruct
    hFig.UserData.PC{idxPC}.reconstruct;

    % Reactivate logging
    msg('O', 'SetLogLevel', originalLogLevel);
    
end

% Fields saved in user property of point cloud (hFig.UserData.PC{idxPC}.U):
% PC.U.hPlot                   handles of plotted points
% PC.U.hMenu                   handle of menu
% PC.U.Visible                 logical value that defines if PC is visible or not
% PC.U.p                       plot parameters
% PC.U.percentOfVisiblePoints  percent of points visible within area defined by the parameter 'Limits'
% PC.U.plotNormals             plot normals? (true or false)
% PC.U.hPlotNormals            handle of normals

% Initialize plot handle
hFig.UserData.PC{idxPC}.U.hPlot = [];

% Initialize menu handle
hFig.UserData.PC{idxPC}.U.hMenu = [];

% Visible
hFig.UserData.PC{idxPC}.U.Visible = true;

% Default parameters
hFig.UserData.PC{idxPC}.U.p.Color        = 'A.z';
hFig.UserData.PC{idxPC}.U.p.MarkerSize   = 1;
hFig.UserData.PC{idxPC}.U.p.MaxPoints    = 1e6;
hFig.UserData.PC{idxPC}.U.p.ColormapName = 'parula';
hFig.UserData.PC{idxPC}.U.p.CAxisLim     = [];
hFig.UserData.PC{idxPC}.U.p.Limits       = [-Inf Inf; -Inf Inf; -Inf Inf];

% Plot normals
hFig.UserData.PC{idxPC}.U.plotNormals = false;

% Initialize plot handle for normals
hFig.UserData.PC{idxPC}.U.hPlotNormals = [];


end