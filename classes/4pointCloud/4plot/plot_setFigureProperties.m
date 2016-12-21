function plot_setFigureProperties(hFig)

xlabel x
ylabel y
zlabel z
axis tight
axis equal
grid on
hold on
view(2)

% Text color
row = strcmpi('lgy', hFig.UserData.colors(:,3));
textColor = hFig.UserData.colors{row,1};

hFig.UserData.hHelptext = uicontrol('Style', 'text', ...
                                    'String', {'Ctrl+A: Show all' 'Ctrl+S: Choose limits' 'Double-click: XY view'}, ... %replace something with the text you want
                                    'Units','pixels', ...
                                    'Position', [10 10 120 40], ...
                                    'BackgroundColor', hFig.UserData.options.FigureColor, ...
                                    'ForegroundColor', textColor, ...
                                    'HorizontalAlignment', 'left'); 

hFig.Name = 'pointCloud.plot';
hFig.NumberTitle = 'off';
hFig.Color = hFig.UserData.options.FigureColor;

hAxes = gca;
hAxes.Visible = 'off';
hAxes.XColor = textColor;
hAxes.YColor = textColor;
hAxes.ZColor = textColor;
hAxes.Box = 'on';

% rotate3d_2016a_mod ON % ON (i.e. in capital letters) disables text feedback (in the bottom left corner)
rotate3d ON % ON (i.e. in capital letters) disables text feedback (in the bottom left corner)

end