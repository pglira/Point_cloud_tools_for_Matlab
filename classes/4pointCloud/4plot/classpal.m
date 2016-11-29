function cmap = classpal

nClasses = 51;

hFig  = gcf;
hAxes = gca;

if strcmpi(hAxes.Visible, 'on')
    bgColor = hAxes.Color;
else
    bgColor = hFig.Color;
end

cmap = distinguishable_colors(nClasses, bgColor);

end