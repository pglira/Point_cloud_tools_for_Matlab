function plot_createToolbar(hFig)

hFig.ToolBar = 'figure';

% Remove items from toolbar
hToolbar = findall(hFig, 'Type', 'uitoolbar');
hToolbarItems = allchild(hToolbar);

idx2del = [];
for i = 1:numel(hToolbarItems)
    hToolbarItems(i).Separator = 'Off';
    if all(~strcmpi(hToolbarItems(i).Tag, {'Annotation.InsertColorbar' 'Exploration.Rotate' 'Exploration.DataCursor'})) % 'Exploration.Pan' 'Exploration.ZoomOut' 'Exploration.ZoomIn'
        idx2del = [idx2del; i];
    end
end
delete(hToolbarItems(idx2del));

% Change callback of 'colormap' button
hToggletoolColorbar = findobj(hToolbarItems, 'Tag', 'Annotation.InsertColorbar');
hToggletoolColorbar.ClickedCallback = @selectToggletoolColorbar;

% Data cursor info (tooltip)
hTooltip = datacursormode;
hTooltip.UpdateFcn = @plot_showPointInfo;
datacursormode off

% Add 'PrintParameter' button
hPushtoolPrintParameter = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolPrintParameter);
hPushtoolPrintParameter.TooltipString = 'Print plot parameter';
hPushtoolPrintParameter.CData = readicon('icon_print_parameter.gif');

% Add 'ByPC' button
hPushtoolByPC = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolByPC);
hPushtoolByPC.TooltipString = 'Color by PC';
hPushtoolByPC.CData = readicon('icon_bypc.gif');

% Add 'AttributeX' button
hPushtoolAttributeX = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolAttributeX);
hPushtoolAttributeX.TooltipString = 'Color all PCs by x-coordinate';
hPushtoolAttributeX.CData = readicon('icon_attributex.gif');;

% Add 'AttributeY' button
hPushtoolAttributeY = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolAttributeY);
hPushtoolAttributeY.TooltipString = 'Color all PCs by y-coordinate';
hPushtoolAttributeY.CData = readicon('icon_attributey.gif');

% Add 'AttributeZ' button
hPushtoolAttributeZ = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolAttributeZ);
hPushtoolAttributeZ.TooltipString = 'Color all PCs by z-coordinate';
hPushtoolAttributeZ.CData = readicon('icon_attributez.gif');

% Add 'RGB' button
hPushtoolRGB = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolRGB);
hPushtoolRGB.TooltipString = 'Color all PCs by RGB colors';
hPushtoolRGB.CData = readicon('icon_rgb.gif');

% Add 'MarkerSize1' button
hPushtoolMarkerSize1 = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolMarkerSize1);
hPushtoolMarkerSize1.TooltipString = 'MarkerSize = 1';
hPushtoolMarkerSize1.CData = readicon('icon_markersize1.gif');

% Add 'MarkerSize5' button
hPushtoolMarkerSize5 = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolMarkerSize5);
hPushtoolMarkerSize5.TooltipString = 'MarkerSize = 5';
hPushtoolMarkerSize5.CData = readicon('icon_markersize5.gif');

% Add 'MarkerSize10' button
hPushtoolMarkerSize10 = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolMarkerSize10);
hPushtoolMarkerSize10.TooltipString = 'MarkerSize = 10';
hPushtoolMarkerSize10.CData = readicon('icon_markersize10.gif');

% Add 'Set Limits' button
hPushtoolSetLimits = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolSetLimits);
hPushtoolSetLimits.Separator = 'On';
hPushtoolSetLimits.TooltipString = 'Set Limits';
hPushtoolSetLimits.CData = readicon('icon_set_limits.gif');

% Add 'Choose Limits' button
hPushtoolChooseLimits = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolChooseLimits);
hPushtoolChooseLimits.TooltipString = 'Choose Limits (Ctrl+S)';
hPushtoolChooseLimits.CData = readicon('icon_choose_limits.gif');

% Add 'Zoom out' button
hPushtoolZoomOut = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolZoomOut);
hPushtoolZoomOut.TooltipString = 'Zoom out';
hPushtoolZoomOut.CData = readicon('icon_zoom_out.gif');

% Add 'Show all' button
hPushtoolShowAll = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolShowAll);
hPushtoolShowAll.TooltipString = 'Show all (Ctrl+A)';
hPushtoolShowAll.CData = readicon('icon_show_all.gif');

% Add 'Select profile' button
hPushtoolShowAll = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolSelectProfile);
hPushtoolShowAll.TooltipString = 'Select profile';
hPushtoolShowAll.CData = readicon('icon_select_profile.gif');

% Add 'Select polygon' button
hPushtoolShowAll = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolSelectInPolygon);
hPushtoolShowAll.TooltipString = 'Select polygon';
hPushtoolShowAll.CData = readicon('icon_select_inpolygon.gif');

% Add 'ViewXY' button
hPushtoolViewXY = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolViewXY);
hPushtoolViewXY.TooltipString = 'View XY';
hPushtoolViewXY.CData = readicon('icon_viewxy.gif');

% Add 'ViewXZ' button
hPushtoolViewXZ = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolViewXZ);
hPushtoolViewXZ.TooltipString = 'View XZ';
hPushtoolViewXZ.CData = readicon('icon_viewxz.gif');

% Add 'ViewYZ' button
hPushtoolViewYZ = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolViewYZ);
hPushtoolViewYZ.TooltipString = 'View YZ';
hPushtoolViewYZ.CData = readicon('icon_viewyz.gif');

% Add 'Histo' button
hPushtoolHisto = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolHisto);
hPushtoolHisto.TooltipString = 'Histogram';
hPushtoolHisto.CData = readicon('icon_histo.gif');

% Add 'ToggleAxis' button
hToggletoolToggleAxis = uitoggletool(hToolbar, 'Separator', 'On', 'State', 'on', 'ClickedCallback', @selectToggletoolToggleAxis);
hToggletoolToggleAxis.TooltipString = 'Toggle axis';
hToggletoolToggleAxis.CData = readicon('icon_toggle_axis.gif');

% Add 'SaveScreenshot' button
hPushtoolSaveScreenshot = uipushtool(hToolbar, 'ClickedCallback', @selectPushtoolSaveScreenshot);
hPushtoolSaveScreenshot.TooltipString = 'Save screenshot';
hPushtoolSaveScreenshot.CData = readicon('icon_save_screenshot.gif');

% Add 'Options' button
hPushtoolOptions = uipushtool(hToolbar, 'Separator', 'On', 'ClickedCallback', @selectPushtoolOptions);
hPushtoolOptions.TooltipString = 'Options';
hPushtoolOptions.CData = readicon('icon_options.gif');
    
    function selectToggletoolColorbar(~, ~)
        
        if strcmpi(hToggletoolColorbar.State, 'on')
            
            hColorbar = colorbar;
            
            % Change text color
            row = strcmpi('lgy', hFig.UserData.colors(:,3));
            hColorbar.Color = hFig.UserData.colors{row,1};
            
        else
            colorbar off;
        end
        
    end

    function selectPushtoolPrintParameter(~, ~)

        msg('T', '-------------------------------------------------------------------------------------------------------------------------------------------------------');
        msg('T', 'PLOT PARAMETER:', 'LogLevel', 'basic');
        msg('T', sprintf('%s|%s|%s|%s|%s|%s|%s|%s', 'idxPC', 'Group', 'Label', 'Color', 'MarkerSize', 'MaxPoints', 'ColormapName', 'CAxisLim'), 'LogLevel', 'basic');

        for idxPC = 1:numel(hFig.UserData.PC)
           
            PC = hFig.UserData.PC{idxPC};
            
            % Convert color to char if defined as RGB value
            if ~ischar(PC.U.p.Color)
                PC.U.p.Color = sprintf('%d/%d/%d', floor(PC.U.p.Color*255));
            end
            
            % Trim label if necessary
            if numel(PC.label) > 29, PC.label = [PC.label(1:10) '...' PC.label(end-15:end)]; end
            
            msg('T', sprintf('%d|%d|%s|%s|%d|%d|%s|%s', idxPC, ...
                                                        NaN, ...
                                                        PC.label, ...
                                                        PC.U.p.Color, ...
                                                        PC.U.p.MarkerSize, ...
                                                        PC.U.p.MaxPoints, ...
                                                        PC.U.p.ColormapName, ...
                                                        sprintf('[%s]', regexprep(num2str(PC.U.p.CAxisLim), '\s*', ' '))), ... % works also for CAxisLim = []
                     'LogLevel', 'basic');
            
        end
        
        msg('T', '-------------------------------------------------------------------------------------------------------------------------------------------------------', 'LogLevel', 'basic');
        
    end

    function selectPushtoolByPC(~, ~)

        hMenuUnicolor = findobj(hFig.UserData.hMenuAll, 'Label', 'Unicolor');
        eventObjDummy.Source = findobj(hMenuUnicolor, 'Label', 'by PC');
        plot_setColor([], eventObjDummy);
        
    end

    function selectPushtoolAttributeX(~, ~)

        hMenuAttribute = findobj(hFig.UserData.hMenuAll, 'Label', 'Attribute');
        eventObjDummy.Source = findobj(hMenuAttribute, 'Label', 'x');
        plot_setColor([], eventObjDummy);
        
    end

    function selectPushtoolAttributeY(~, ~)

        hMenuAttribute = findobj(hFig.UserData.hMenuAll, 'Label', 'Attribute');
        eventObjDummy.Source = findobj(hMenuAttribute, 'Label', 'y');
        plot_setColor([], eventObjDummy);
        
    end

    function selectPushtoolAttributeZ(~, ~)

        hMenuAttribute = findobj(hFig.UserData.hMenuAll, 'Label', 'Attribute');
        eventObjDummy.Source = findobj(hMenuAttribute, 'Label', 'z');
        plot_setColor([], eventObjDummy);
        
    end

    function selectPushtoolRGB(~, ~)

        hMenuAttribute = findobj(hFig.UserData.hMenuAll, 'Label', 'Attribute');
        eventObjDummy.Source = findobj(hMenuAttribute, 'Label', 'RGB');
        plot_setColor([], eventObjDummy);
        
    end

    function selectPushtoolMarkerSize1(~, ~)

        hMenuMarkerSize = findobj(hFig.UserData.hMenuAll, 'Label', 'MarkerSize');
        eventObjDummy.Source = findobj(hMenuMarkerSize, 'Label', '1');
        plot_setMarkerSize([], eventObjDummy);

    end  

    function selectPushtoolMarkerSize5(~, ~)

        hMenuMarkerSize = findobj(hFig.UserData.hMenuAll, 'Label', 'MarkerSize');
        eventObjDummy.Source = findobj(hMenuMarkerSize, 'Label', '5');
        plot_setMarkerSize([], eventObjDummy);

    end  

    function selectPushtoolMarkerSize10(~, ~)

        hMenuMarkerSize = findobj(hFig.UserData.hMenuAll, 'Label', 'MarkerSize');
        eventObjDummy.Source = findobj(hMenuMarkerSize, 'Label', '10');
        plot_setMarkerSize([], eventObjDummy);

    end

    function selectPushtoolSetLimits(~, ~)

        eventObjDummy.Source = findobj(hFig.UserData.hMenuAll, 'Label', 'Set');
        plot_selectLimits([], eventObjDummy);

    end    

    function selectPushtoolChooseLimits(~, ~)

        eventObjDummy.Source = findobj(hFig.UserData.hMenuAll, 'Label', 'Choose');
        plot_selectLimits([], eventObjDummy);

    end    

    function selectPushtoolZoomOut(~, ~)

        eventObjDummy.Source = findobj(hFig.UserData.hMenuAll, 'Label', 'Zoom out');
        plot_selectLimits([], eventObjDummy);

    end    

    function selectPushtoolShowAll(~, ~)

        eventObjDummy.Source = findobj(hFig.UserData.hMenuAll, 'Label', 'Show all');
        plot_selectLimits([], eventObjDummy);

    end

    function selectPushtoolSelectProfile(~, ~)

        eventObjDummy.Source = findobj(hFig.UserData.hMenuAll, 'Label', 'Profile');
        plot_selectProfile([], eventObjDummy);

    end

    function selectPushtoolSelectInPolygon(~, ~)

        eventObjDummy.Source = findobj(hFig.UserData.hMenuAll, 'Label', 'InPolygon');
        plot_selectInPolygon([], eventObjDummy);

    end

    function selectPushtoolViewXY(~, ~)

        view(2);

    end  

    function selectPushtoolViewXZ(~, ~)

        view(0,0);

    end  

    function selectPushtoolViewYZ(~, ~)

        view(90,0);

    end

    function selectPushtoolHisto(~, ~)

        % Search figure handle
        hFigHisto = findobj('Type', 'Figure', ...
                            'Name', 'Histogram');
                        
        if isempty(hFigHisto)
            
            % Create figure
            hFigHisto = figure('Name', 'Histogram', ...
                               'NumberTitle', 'off', ...
                               'MenuBar', 'none', ...
                               'Units', 'pixels');
                           
            hFigHisto.Position(3) = 900; % make figure wider
            hFigHisto.Position(4) = 500; % make figure higher
            
            centerfigureonscreen(hFigHisto);
            
            % Set minimal size of figure
            LimitFigSize(hFigHisto, 'min', [900, 500])
            
            % Some measures
            marginTop = 22;
            margin = 15; % all other margins
            panelWidth = 250;
            panelHeight = 400;
            
            % Panel
            hPanelHisto = uipanel('Title', 'Settings', ...
                                  'Units', 'pixels', ...
                                  'Position', [margin hFigHisto.Position(4)-panelHeight-margin panelWidth panelHeight]);
                  
            % Popup menu with PC labels
            for i = 1:numel(hFig.UserData.PC), PCLabels{i} = hFig.UserData.PC{i}.label; end
            uicontrol('Style', 'text', ...
                      'Parent', hPanelHisto, ...
                      'String', 'Point Cloud:', ...
                      'HorizontalAlignment', 'left', ...
                      'Position', [margin panelHeight-50 panelWidth-margin*2 20]);
            hPCPopup = uicontrol('Style', 'popup', ...
                                 'Parent', hPanelHisto, ...
                                 'Tag', 'hPCHisto', ... % for plot_updateHisto
                                 'Position', [margin panelHeight-68 panelWidth-margin*2 20], ...
                                 'String', PCLabels, ...
                                 'Callback', @refreshHisto);
                  
            % Popup menu with attributes
            uicontrol('Style', 'text', ...
                      'Parent', hPanelHisto, ...
                      'String', 'Attributes:', ...
                      'HorizontalAlignment', 'left', ...
                      'Position', [margin panelHeight-110 panelWidth-margin*2 20]);
            
            attributeNames1 = {'x' 'y' 'z'};
            if isstruct(hFig.UserData.PC{hPCPopup.Value}.A)
                attributeNames2 = fields(hFig.UserData.PC{hPCPopup.Value}.A);
            else
                attributeNames2 = {};
            end
            attributeNames = {attributeNames1{:} attributeNames2{:}};
            uicontrol('Style', 'popup', ...
                      'Parent', hPanelHisto, ...
                      'Tag', 'hAttributeHisto', ... % for plot_updateHisto
                      'Position', [margin panelHeight-128 panelWidth-margin*2 20], ...
                      'String', attributeNames, ...
                      'Value', 3, ... % default = z
                      'Callback', @refreshHisto);

            % Buttons for more and fewer bins
            uicontrol('Style', 'text', ...
                      'Parent', hPanelHisto, ...
                      'String', 'Histogram settings:', ...
                      'HorizontalAlignment', 'left', ...
                      'Position', [margin panelHeight-170 panelWidth-margin*2 20]);
            pushbuttonWidth = (panelWidth-3*margin)/2; % panelWidth = margin+pushbutton+margin+pushbutton+margin
            hMoreBinsPushbutton = uicontrol('Style', 'pushbutton', ...
                                            'Parent', hPanelHisto, ...
                                            'Tag', 'hMoreBinsHisto', ...
                                            'Position', [margin panelHeight-188 pushbuttonWidth 20], ... 
                                            'String', 'More bins', ...
                                            'Callback', @morebinsHisto);
            hFewerBinsPushbutton = uicontrol('Style', 'pushbutton', ...
                                             'Parent', hPanelHisto, ...
                                             'Tag', 'hFewerBinsHisto', ...
                                             'Position', [margin+pushbuttonWidth+margin panelHeight-188 pushbuttonWidth 20], ... % arrangment within panel: margin|pushbutton|margin|pushbutton|margin
                                             'String', 'Fewer bins', ...
                                             'Callback', @fewerbinsHisto);
                  
            % Axes
            hAxesHisto = axes('Parent', hFigHisto, ...
                              'Units', 'pixels', ...
                              'OuterPosition', [margin+panelWidth+margin margin hFigHisto.Position(3)-(margin+panelWidth+margin) hFigHisto.Position(4)-marginTop]);
                         
            hFigHisto.SizeChangedFcn = @resizeHisto;
                         
        else
            figure(hFigHisto); % bring to front
        end
        
        plot_updateHisto(hFig)
        
        function resizeHisto(~, ~)
            
            hAxesHisto.OuterPosition(3) = hFigHisto.Position(3)-(margin+panelWidth+margin);
            hAxesHisto.OuterPosition(4) = hFigHisto.Position(4)-marginTop;
            hPanelHisto.Position(2) = hFigHisto.Position(4)-panelHeight-margin;
            
        end
        
        function refreshHisto(~, ~)
            
            plot_updateHisto(hFig);
            
        end
        
        function morebinsHisto(~, ~)
            
            hHisto = findobj(hAxesHisto, 'Type', 'Histogram');
            morebins(hHisto);
            plot_zoomHisto([], [], hAxesHisto, hHisto);
            
        end

        function fewerbinsHisto(~, ~)
            
            hHisto = findobj(hAxesHisto, 'Type', 'histogram');
            fewerbins(hHisto);
            plot_zoomHisto([], [], hAxesHisto, hHisto);
            
        end

        
    end

    function selectToggletoolToggleAxis(~, ~)

        if strcmpi(hToggletoolToggleAxis.State, 'on')
            axis on
            hAxes = gca;
            hAxes.Position = [0.13 0.11 0.775 0.815]; % default values in normalized units
        else
            axis off
            hAxes = gca;
            hAxes.Position = [0.05 0.05 0.90 0.90]; % in normalized units
        end

        % Update plot!
        for idxPC = 1:numel(hFig.UserData.PC)
            plot_setPrmAndPlot(hFig, idxPC);
        end
        
    end

    function selectPushtoolSaveScreenshot(~, ~)
        
        persistent lastPath
        
        % Select file
        [file, path] = uiputfile('*.png', 'Select file', lastPath);
        
        if file == 0 % if no file was selected
            
            return;
            
        else
            
            lastPath = path;
            
            prompt = {'Resolution (pixels per inch):'};
            dlgTitle = '';
            noLines = 1;
            defaultAnswer = {'150'};
            answer = inputdlg(prompt, dlgTitle, noLines, defaultAnswer);
            if ~isempty(answer)
                resolution = str2num(answer{1});
                hFig.UserData.hHelptext.Visible = 'off';
                export_fig(fullfile(path, file), sprintf('-r%d', resolution));
                hFig.UserData.hHelptext.Visible = 'on';
            end
            
        end

    end

    function selectPushtoolOptions(~, ~)

        % Open options figure (not visible)
        hFigOptions = figure('Name'       , 'Options', ...
                             'NumberTitle', 'off', ...
                             'Toolbar'    , 'none', ...
                             'Menubar'    , 'none', ...
                             'Units'      , 'pixels', ...
                             'Resize'     , 'off', ...
                             'Visible'    , 'on');

        % Change size
        hFigOptions.Position(3) = 500; % width
        hFigOptions.Position(4) = 200; % heigth

        % OK button
        uicontrol('Parent'  , hFigOptions, ...
                  'Style'   , 'pushbutton', ...
                  'Position', [hFigOptions.Position(3)-110 20 90 30], ...
                  'String'  , 'OK', ...
                  'Tag'     , 'pushbuttonOK', ...
                  'Callback', @selectOptionsOK);


        % Some measures
        marginTop      = 10;
        marginLeft     = 20;
        marginRight    = 20;
        heightElements = 20;

        % Tooltip string for colors
        tooltipStringColors = [];
        for i = 1:size(hFig.UserData.colors,1)
            tooltipStringColors = [tooltipStringColors hFig.UserData.colors{i,3} '=' hFig.UserData.colors{i,2} sprintf('\n')];
        end
        
        n = 1;
        hOptionsSyncAttributeColors = uicontrol('Parent'  , hFigOptions, ...
                                                'Style'   , 'checkbox', ...
                                                'Position', [marginLeft+15 hFigOptions.Position(4)-marginTop-n*25 hFigOptions.Position(3)-marginRight heightElements], ...
                                                'String'  , 'Synchronize ''CAxisLim'' and ''ColormapName'' between PCs showing the same attribute', ...
                                                'Tag'     , 'checkboxSyncAttributeColors', ...
                                                'Value'   , hFig.UserData.options.SyncAttributeColors);

        n = 2;
        hOptionsAdaptColors2Limits  = uicontrol('Parent'  , hFigOptions, ...
                                                'Style'   , 'checkbox', ...
                                                'Position', [marginLeft+15 hFigOptions.Position(4)-marginTop-n*25 hFigOptions.Position(3)-marginRight heightElements], ...
                                                'String'  , 'Adapt ''CAxisLim'' automatically to actual ''Limits''', ...
                                                'Tag'     , 'checkboxAdaptColors2Limits', ...
                                                'Value'   , hFig.UserData.options.AdaptColors2Limits);

        n = 3;
        hOptionsAxesColor           = uicontrol('Parent'       , hFigOptions, ...
                                                'Style'        , 'edit', ...
                                                'Position'     , [marginLeft hFigOptions.Position(4)-marginTop-n*25 30 heightElements], ...
                                                'Tag'          , 'editAxesColor', ...
                                                'String'       , num2str(hFig.UserData.options.AxesColor), ...
                                                'TooltipString', tooltipStringColors);
                                            
                                      uicontrol('Parent'             , hFigOptions, ...
                                                'Style'              , 'text', ...
                                                'Position'           , [marginLeft+32 hFigOptions.Position(4)-marginTop-n*25-3 300 heightElements], ...
                                                'HorizontalAlignment', 'Left', ...
                                                'String'             , 'Axes Background color');
        
        n = 4;
        hOptionsFigureColor         = uicontrol('Parent'       , hFigOptions, ...
                                                'Style'        , 'edit', ...
                                                'Position'     , [marginLeft hFigOptions.Position(4)-marginTop-n*25 30 heightElements], ...
                                                'Tag'          , 'editFigureColor', ...
                                                'String'       , num2str(hFig.UserData.options.FigureColor), ...
                                                'TooltipString', tooltipStringColors);
                                            
                                      uicontrol('Parent'             , hFigOptions, ...
                                                'Style'              , 'text', ...
                                                'Position'           , [marginLeft+32 hFigOptions.Position(4)-marginTop-n*25-3 300 heightElements], ...
                                                'HorizontalAlignment', 'Left', ...
                                                'String'             , 'Figure Background color');
        
        n = 5;
        hOptionsNormalsScale        = uicontrol('Parent'  , hFigOptions, ...
                                                'Style'   , 'edit', ...
                                                'Position', [marginLeft hFigOptions.Position(4)-marginTop-n*25 30 heightElements], ...
                                                'Tag'     , 'editNormalsScale', ...
                                                'String'  , num2str(hFig.UserData.options.NormalsScale));
                                            
                                      uicontrol('Parent'             , hFigOptions, ...
                                                'Style'              , 'text', ...
                                                'Position'           , [marginLeft+32 hFigOptions.Position(4)-marginTop-n*25-3 300 heightElements], ...
                                                'HorizontalAlignment', 'Left', ...
                                                'String'             , 'Scale of normal vectors');
                                            
        n = 6;
        hOptionsNormalsColor        = uicontrol('Parent'       , hFigOptions, ...
                                                'Style'        , 'edit', ...
                                                'Position'     , [marginLeft hFigOptions.Position(4)-marginTop-n*25 30 heightElements], ...
                                                'Tag'          , 'editNormalsColor', ...
                                                'String'       , hFig.UserData.options.NormalsColor, ...
                                                'TooltipString', tooltipStringColors);
                                            
                                      uicontrol('Parent'             , hFigOptions, ...
                                                'Style'              , 'text', ...
                                                'Position'           , [marginLeft+32 hFigOptions.Position(4)-marginTop-n*25-3 300 heightElements], ...
                                                'HorizontalAlignment', 'Left', ...
                                                'String'             , 'Color of normal vectors');

                                            
            function selectOptionsOK(~,~)

                % Save options
                hFig.UserData.options.SyncAttributeColors  = hOptionsSyncAttributeColors.Value;
                hFig.UserData.options.AdaptColors2Limits   = hOptionsAdaptColors2Limits.Value;
                hFig.UserData.options.AxesColor            = hOptionsAxesColor.String;
                hFig.UserData.options.FigureColor          = hOptionsFigureColor.String;
                hFig.UserData.options.NormalsScale         = str2num(hOptionsNormalsScale.String);
                hFig.UserData.options.NormalsColor         = hOptionsNormalsColor.String;

                closereq;
                
                % Update plot!
                for idxPC = 1:numel(hFig.UserData.PC)
                    plot_setPrmAndPlot(hFig, idxPC);
                end

            end

    end
    
end