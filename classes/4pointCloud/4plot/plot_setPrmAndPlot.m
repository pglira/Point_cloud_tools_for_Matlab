function plot_setPrmAndPlot(hFig, idxPC, varargin)

% Actual parameter
p = hFig.UserData.PC{idxPC}.U.p;

for i = 1:2:numel(varargin)

    prm = varargin{i};
    val = varargin{i+1};
    
    % Color --------------------------------------------------------------------
    
    if strcmpi(prm, 'Color')
        if ischar(val)
            % Convert color defined as char to RGB value
            % Note: this is necessary, as:
            %       - Unicolor:  colors have to be defined as RGB values
            %       - Attribute: attributes have to be defined as char
            [row, ~] = find(strcmp(hFig.UserData.colors, val));
            if ~isempty(row) % a color name was selected
                p.Color = hFig.UserData.colors{row,1};
            % Temp !!!!! - start
            elseif strcmpi(val(1:2), 'A.')
                p.Color = val;
                if ~any(strcmp(varargin, 'CAxisLim'))
                    p.CAxisLim = [];
                end
            % Temp !!!!! - end
            else % 'RGB' or 'by PC'
                p.Color = val;
            end
        elseif numel(val) == 3
            p.Color = val;
        else
            plot_throwError(prm); return;
        end
    end
    
    % MarkerSize ---------------------------------------------------------------
    
    if strcmpi(prm, 'MarkerSize')
        if isnumeric(val) && isscalar(val) && val>0
            p.MarkerSize = val;
        else
            plot_throwError(prm); return;
        end
    end

    % MaxPoints ----------------------------------------------------------------
    
    if strcmpi(prm, 'MaxPoints')
        if isnumeric(val) && isscalar(val) && val>0
            p.MaxPoints = val;
        else
            plot_throwError(prm); return;
        end
    end
    
    % ColormapName -------------------------------------------------------------
    
    if strcmpi(prm, 'ColormapName')
        if ischar(val)
            p.ColormapName = val;
        else
            plot_throwError(prm); return;
        end
    end
    
    % CAxisLim -----------------------------------------------------------------
    
    if strcmpi(prm, 'CAxisLim')
        if isnumeric(val) && numel(val)==2
            p.CAxisLim = val;
        else
            plot_throwError(prm); return;
        end
    end
    
    % ToDo: error if non-valid prm name is defined
    
end

hFig.UserData.PC{idxPC}.U.p = p;

% Update figure and axes -------------------------------------------------------

% Axes color
hAxes = findobj('Parent', hFig, 'Type', 'Axes');
row = strcmpi(hFig.UserData.options.AxesColor, hFig.UserData.colors(:,3));
if any(row), hAxes.Color = hFig.UserData.colors{row,1}; end

% Figure color
row = strcmpi(hFig.UserData.options.FigureColor, hFig.UserData.colors(:,3));
if any(row), hFig.Color = hFig.UserData.colors{row,1}; end

% Help text
hFig.UserData.hHelptext.BackgroundColor = hFig.UserData.options.FigureColor;

% Plot! ------------------------------------------------------------------------

plot_updatePlot(hFig, idxPC);

end