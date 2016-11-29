function plot_createMenu(hFig, firstCall, idxPC)

% Menu for all point clouds ----------------------------------------------------

if firstCall

    hFig.MenuBar = 'none';
    
    % Create menu for all PCs
    hFig.UserData.hMenuAll = uimenu(hFig, 'Label', 'All PCs');
    hFig.UserData.hMenuAll.UserData.idxPC = idxPC; % save index of PC in UserData of menu
    fillmenu(hFig.UserData.hMenuAll, hFig);

    % Menu for adding a new PC
    hFig.UserData.hMenuAddPC = uimenu(hFig, 'Label', 'Add PC...', 'Callback', @plot_addPC);
    
else

    % Add only idxPC to menu for all PCs
    hFig.UserData.hMenuAll.UserData.idxPC = [hFig.UserData.hMenuAll.UserData.idxPC idxPC]; % save index of PC in UserData of menu
    
end

% Menu for actual point cloud --------------------------------------------------

hFig.UserData.PC{idxPC}.U.hMenu = uimenu(hFig, 'Label', hFig.UserData.PC{idxPC}.label);
hFig.UserData.PC{idxPC}.U.hMenu.UserData.idxPC = idxPC; % save index of PC in UserData of menu
hFig.UserData.PC{idxPC}.U.hMenu.Position = hFig.UserData.PC{idxPC}.U.hMenu.Position - 1; % move menu
pause(0.001) % without this line position of menu doesn't change (bug???)

fillmenu(hFig.UserData.PC{idxPC}.U.hMenu, hFig);

end

function fillmenu(parentMenu, hFig)

% Menu for all PCs?
if strcmp(parentMenu.Label, 'All PCs'), menu4allPCs = true; else menu4allPCs = false; end

% Visible ----------------------------------------------------------------------

if ~menu4allPCs, h = uimenu(parentMenu, 'Label', 'Visible', 'Checked', 'On', 'Callback', @plot_setVisible); end

% Color ------------------------------------------------------------------------

h = uimenu(parentMenu, 'Label', 'Color');
if ~menu4allPCs, h.Separator = 'On'; end

% Unicolor
hUnicolor = uimenu(h, 'Label', 'Unicolor');
for i = 1:size(hFig.UserData.colors,1)
    uimenu('Parent', hUnicolor, 'Label', hFig.UserData.colors{i,2}, 'Callback', @plot_setColor, 'ForegroundColor', hFig.UserData.colors{i,1});
end
uimenu('Parent', hUnicolor, 'Label', 'by PC' , 'Callback', @plot_setColor, 'Separator', 'On');
uimenu('Parent', hUnicolor, 'Label', 'custom', 'Callback', @plot_setColor);

% Attributes
hAttributes = uimenu(h, 'Label', 'Attribute');
uimenu('Parent', hAttributes, 'Label', 'x'  , 'Callback', @plot_setColor);
uimenu('Parent', hAttributes, 'Label', 'y'  , 'Callback', @plot_setColor);
uimenu('Parent', hAttributes, 'Label', 'z'  , 'Callback', @plot_setColor);
uimenu('Parent', hAttributes, 'Label', 'RGB', 'Callback', @plot_setColor);

if ~menu4allPCs

    % Add attribute to menu for actual PC
    if isstruct(hFig.UserData.PC{parentMenu.UserData.idxPC}.A)
        att = fields(hFig.UserData.PC{parentMenu.UserData.idxPC}.A);
        if ~isempty(att)
            for i = 1:numel(att)
                h = uimenu('Parent', hAttributes, 'Label', att{i}, 'Callback', @plot_setColor);
                if i == 1, h.Separator = 'On'; end
            end
        end
    end
    
    % Update attributes in menu for all PCs
    updateAttributesInMenu4allPCs(hFig)
    
else % if menu4allPCs is true
    
    hFig.UserData.hMenuAllAttributes = hAttributes; % save handle to attributes menu (for adding attributes later)

end

% MarkerSize -------------------------------------------------------------------

h = uimenu(parentMenu, 'Label', 'MarkerSize');
for i = 1:10
    uimenu(h, 'Label', num2str(i), 'Callback', @plot_setMarkerSize);
end
uimenu(h, 'Label', 'custom', 'Callback', @plot_setMarkerSize, 'Separator', 'On');

% MaxPoi -----------------------------------------------------------------------

h = uimenu(parentMenu, 'Label', 'MaxPoints', 'Callback', @plot_setMaxPoints);

% ColormapName -----------------------------------------------------------------

colormaps = {'parula' 'jet' 'jetinv' 'hsv' 'hot' 'cool' 'spring' 'summer' 'autumn' 'winter' 'gray' 'bone' 'copper' 'pink' 'lines' 'colorcube' 'prism' 'flag' 'difpal' 'classpal'}; % from 'doc colormap'
h = uimenu(parentMenu, 'Label', 'ColormapName');
for i = 1:numel(colormaps)
    uimenu('Parent', h, 'Label', colormaps{i}, 'Callback', @plot_setColormapName);
end
uimenu('Parent', h, 'Label', 'custom', 'Callback', @plot_setColormapName, 'Separator', 'On');

% CAxisLim ---------------------------------------------------------------------

h = uimenu(parentMenu, 'Label', 'CAxisLim', 'Callback', @plot_setCAxisLim);

% Select -----------------------------------------------------------------------

h = uimenu(parentMenu, 'Label', 'Select', 'Separator', 'on');

% Limits
hLimits = uimenu(h, 'Label', 'Limits');

           uimenu('Parent', hLimits, 'Label', 'Set'     , 'Callback', @plot_selectLimits);
hChoose  = uimenu('Parent', hLimits, 'Label', 'Choose'  , 'Callback', @plot_selectLimits);
           uimenu('Parent', hLimits, 'Label', 'Zoom out', 'Callback', @plot_selectLimits);
hShowAll = uimenu('Parent', hLimits, 'Label', 'Show all', 'Callback', @plot_selectLimits);
if menu4allPCs % shortcuts
    hChoose.Accelerator  = 's';
    hShowAll.Accelerator = 'a';
end

% Profile
hProfile = uimenu('Parent', h, 'Label', 'Profile', 'Callback', @plot_selectProfile);

% InPolygon
hInPolygon = uimenu('Parent', h, 'Label', 'InPolygon', 'Callback', @plot_selectInPolygon);

% Modify -----------------------------------------------------------------------

h = uimenu(parentMenu, 'Label', 'Modify');

% transform
hProfile = uimenu('Parent', h, 'Label', 'transform', 'Callback', @plot_transform);

% ecef2mapTrafo
hProfile = uimenu('Parent', h, 'Label', 'ecef2mapTrafo', 'Callback', @plot_ecef2mapTrafo);

% map2ecefTrafo
hProfile = uimenu('Parent', h, 'Label', 'map2ecefTrafo', 'Callback', @plot_map2ecefTrafo);

% Plot normals -----------------------------------------------------------------

if ~menu4allPCs
    
    if isstruct(hFig.UserData.PC{parentMenu.UserData.idxPC}.A)
        att = fields(hFig.UserData.PC{parentMenu.UserData.idxPC}.A);
        if ~isempty(att)
            if any(strcmpi(att, 'nx'))
                uimenu(parentMenu, 'Label', 'Plot normals', 'Separator', 'on', 'Callback', @plot_plotNormals);
            end
        end
    end
    
end

end

function updateAttributesInMenu4allPCs(hFig)
% Update attributes in menu for all PCs
% (not in plot_updateMenus, as plot_updateMenus is called on each plot and this is only necessary when a new PC is added)

for i = 1:numel(hFig.UserData.hMenuAllAttributes.Children) % delete all attributes (except x, y, z, RGB)
    if i == 1, idx2del = []; end
    if all(~strcmp(hFig.UserData.hMenuAllAttributes.Children(i).Label, {'x' 'y' 'z' 'RGB'}))
        idx2del = [idx2del; i];
    end
end
delete(hFig.UserData.hMenuAllAttributes.Children(idx2del));

for idxPC = 1:numel(hFig.UserData.PC) % find attributes common to all PCs
    if isstruct(hFig.UserData.PC{idxPC}.A)
        att{idxPC} = fields(hFig.UserData.PC{idxPC}.A);
    else
        att{idxPC} = {};
    end
    if idxPC == 1
        commonAtt = att{idxPC};
    else
        commonAtt = intersect(commonAtt, att{idxPC});
    end
end

for i = 1:numel(commonAtt) % add attributes common to all PCs
    if i == 1, separator = 'On'; else separator = 'Off'; end
    uimenu(hFig.UserData.hMenuAllAttributes, 'Label', commonAtt{i}, 'Callback', @plot_setColor, 'Separator', separator);
end

end