function plot_updateMenus(hFig)

% Remove all checkmarks
hChecked = findobj(hFig, 'Checked', 'On');
for i = 1:numel(hChecked), hChecked(i).Checked = 'off'; end

% Update individual menus ------------------------------------------------------

for i = 1:numel(hFig.UserData.PC)

    % Label
    hFig.UserData.PC{i}.U.hMenu.Label = sprintf('%s (%.1f%%)', hFig.UserData.PC{i}.label, hFig.UserData.PC{i}.U.percentOfVisiblePoints);
    
    % Visible
    hMenuVisible = findobj(hFig.UserData.PC{i}.U.hMenu, 'Label', 'Visible');
    if hFig.UserData.PC{i}.U.Visible, hMenuVisible.Checked = 'On'; end
    
    % Color
    % Note: name of attribute and unicolor name can be the same (e.g. red)
    hMenuColor = findobj(hFig.UserData.PC{i}.U.hMenu, 'Label', 'Color');
    if ~ischar(hFig.UserData.PC{i}.U.p.Color) && numel(hFig.UserData.PC{i}.U.p.Color) == 3 % if 'Color' is defined as three RGB values (Unicolor)
        parent2search4Color{i} = hMenuColor.Children(2); % Menu entry 'Unicolor'
        for j = 1:size(hFig.UserData.colors,1)
            if isequal(hFig.UserData.PC{i}.U.p.Color, hFig.UserData.colors{j,1})
                label2search4Color{i} = hFig.UserData.colors{j,2};
                break;
            else
                label2search4Color{i} = 'custom';
            end
        end
    elseif ischar(hFig.UserData.PC{i}.U.p.Color) && strcmp(hFig.UserData.PC{i}.U.p.Color(1:2), 'A.') % if 'Color' is defined as attribute (Attribute)
        parent2search4Color{i} = hMenuColor.Children(1); % Menu entry 'Attribute'
        label2search4Color{i} = hFig.UserData.PC{i}.U.p.Color(3:end);
    end
    hMenuColorSelected = findobj(hMenuColor, 'Label', label2search4Color{i}, 'Parent', parent2search4Color{i});
    if ~isempty(hMenuColorSelected), hMenuColorSelected.Checked = 'On'; end
    
    % MarkerSize
    hMenuMarkerSize = findobj(hFig.UserData.PC{i}.U.hMenu, 'Label', 'MarkerSize');
    hMenuMarkerSizeSelected = findobj(hMenuMarkerSize, 'Label', num2str(hFig.UserData.PC{i}.U.p.MarkerSize));
    if ~isempty(hMenuMarkerSizeSelected), hMenuMarkerSizeSelected.Checked = 'On'; end
    MarkerSize(i) = hFig.UserData.PC{i}.U.p.MarkerSize; % MarkerSize of each PC
    
    % ColormapName
    hMenuColormapName = findobj(hFig.UserData.PC{i}.U.hMenu, 'Label', 'ColormapName');
    hMenuColormapNameSelected = findobj(hMenuColormapName, 'Label', hFig.UserData.PC{i}.U.p.ColormapName);
    if ~isempty(hMenuColormapNameSelected), hMenuColormapNameSelected.Checked = 'On'; end
    ColormapName{i} = hFig.UserData.PC{i}.U.p.ColormapName; % ColormapName of each PC
    
    % Plot normals
    hMenuPlotNormals = findobj(hFig.UserData.PC{i}.U.hMenu, 'Label', 'Plot normals');
    if hFig.UserData.PC{i}.U.plotNormals, hMenuPlotNormals.Checked = 'On'; end
    
end

% Update for menu of all PCs ---------------------------------------------------

% Color
for i = 1:numel(parent2search4Color), parentLabel{i} = parent2search4Color{i}.Label; end % save labels of parents for comparison
if numel(unique(label2search4Color)) == 1 && numel(unique(parentLabel)) == 1 % if all PCs have the same Color
    hMenuColor = findobj(hFig.UserData.hMenuAll, 'Label', 'Color');
    if strcmp(parentLabel{1}, 'Unicolor')
        parent2search4Color = hMenuColor.Children(2);
    elseif strcmp(parentLabel{1}, 'Attribute')
        parent2search4Color = hMenuColor.Children(1);
    end
    hMenuColorSelected = findobj(hMenuColor, 'Label', label2search4Color{1}, 'Parent', parent2search4Color);
    if ~isempty(hMenuColorSelected), hMenuColorSelected.Checked = 'On'; end
end

% Markersize
if numel(unique(MarkerSize)) == 1 % if all PCs have the same MarkerSize
    hMenuMarkerSize = findobj(hFig.UserData.hMenuAll, 'Label', 'MarkerSize');
    hMenuMarkerSizeSelected = findobj(hMenuMarkerSize, 'Label', num2str(MarkerSize(1)));
    if ~isempty(hMenuMarkerSizeSelected), hMenuMarkerSizeSelected.Checked = 'On'; end
end

% ColormapName
if numel(unique(ColormapName)) == 1 % if all PCs have the same ColormapName
    hMenuColormapName = findobj(hFig.UserData.hMenuAll, 'Label', 'ColormapName');
    hMenuColormapNameSelected = findobj(hMenuColormapName, 'Label', ColormapName{1});
    if ~isempty(hMenuColormapNameSelected), hMenuColormapNameSelected.Checked = 'On'; end
end

end