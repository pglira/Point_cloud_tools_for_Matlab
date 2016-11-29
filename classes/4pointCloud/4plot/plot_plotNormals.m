function plot_plotNormals(~, eventObj)

hFig = gcf;
idxPC = eventObj.Source.Parent.UserData.idxPC; % index of PC(s)

% Update plot!
hFig.UserData.PC{idxPC}.U.plotNormals = ~hFig.UserData.PC{idxPC}.U.plotNormals;
plot_updatePlot(hFig, idxPC); % plot

end
