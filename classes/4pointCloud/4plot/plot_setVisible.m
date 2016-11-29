function plot_setVisible(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.UserData.idxPC; % index of PC

% Update plot!
hFig.UserData.PC{idxPC}.U.Visible = ~hFig.UserData.PC{idxPC}.U.Visible;
plot_updatePlot(hFig, idxPC); % plot

end