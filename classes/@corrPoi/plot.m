function plot(obj, what, varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired(  'what'                            , @ischar); % 'dz', 'points' or an attribute ('ds', 'dAlpha' or other attributes in obj.A)
p.addParamValue('MarkerSize', 5                   , @isnumeric);
p.addParamValue('MaxPoi'    , 10^6                , @isnumeric);
p.addParamValue('PlotLines' , false               , @islogical);
p.addParamValue('Histos'    , {'dp' 'w' 'dAlpha'} , @(x) iscellstr(x) && numel(x)<=3);
p.addParamValue('CAxisLim'  , []                  , @(x) numel(x)==2);
p.parse(what, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear what

% Start ------------------------------------------------------------------------

procHierarchy = {'CORRPOI' 'PLOT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('pc1id = ''%d'', pc2id = ''%d''', obj.pc1id, obj.pc2id));

% Correspondences present? -----------------------------------------------------

if size(obj.X1,1) == 0
    msg('I', procHierarchy, 'termination of function due to missing correspondences');
    return;
end

% Figure, Axes -----------------------------------------------------------------

if numel(p.Histos) > 0, subplot(3,4,[1 2 3 5 6 7 9 10 11]); end

xlabel('x');
ylabel('y');
zlabel('z');
hold('on');
axis('equal');
title(sprintf('Correspondences between pc1id = ''%d'' and pc2id = ''%d''', obj.pc1id, obj.pc2id));
set(gca, 'Color', [0.3 0.3 0.3]);

% Select subset of points ------------------------------------------------------

% Indices of points with consideration of parameter MaxPoi
nPoi = size(obj.X1,1);
if nPoi > p.MaxPoi
    idx = randperm(nPoi, p.MaxPoi);
else
    idx = 1:nPoi;
end

msg('V', nPoi      , 'number of corresponding points'          , 'Prec', 0);
msg('V', numel(idx), 'number of displayed corresponding points', 'Prec', 0);

% Plot of points ---------------------------------------------------------------

if strcmpi(p.what, 'points') % plot of corresponding points
    
    plot3(obj.X1(idx,1), obj.X1(idx,2), obj.X1(idx,3), '.', 'Color', 'r', 'MarkerSize', p.MarkerSize);
    plot3(obj.X2(idx,1), obj.X2(idx,2), obj.X2(idx,3), '.', 'Color', 'b', 'MarkerSize', p.MarkerSize);
    legend(sprintf('pc1id = ''%d''', obj.pc1id), sprintf('pc2id = ''%d''', obj.pc2id));
    
    if p.PlotLines
        plot3([obj.X1(idx,1) obj.X2(idx,1)]', ...
              [obj.X1(idx,2) obj.X2(idx,2)]', ...
              [obj.X1(idx,3) obj.X2(idx,3)]', 'w');
    end

elseif strcmpi(p.what, 'dz') % plot of vertical discrepancies
    
    dz = obj.X1(:,3) - obj.X2(:,3);

    if isempty(p.CAxisLim)
        p.CAxisLim = [-max(abs(dz)) max(abs(dz))];
    end
    
    colormapName = 'difpal';
    
    scatter3ext(obj.X1(idx,1), obj.X1(idx,2), obj.X1(idx,3), p.MarkerSize, dz(idx), ...
                'ColormapName', colormapName, ...
                'Colorbar'    , true, ...
                'CAxisLim'    , p.CAxisLim);
            
    view(3);

else % plot of an attribute
    
    A = obj.getAttribute(p.what);
    
    if isempty(p.CAxisLim)
        if strcmpi(p.what, 'dp'),
            p.CAxisLim = [-max(abs(A)) max(abs(A))];
        else
            p.CAxisLim = [min(A) max(A)];
        end
    end
    
    if strcmpi(p.what, 'dp'),
        colormapName = 'difpal';
    else
        colormapName = 'jet';
    end
    
    scatter3ext(obj.X1(idx,1), obj.X1(idx,2), obj.X1(idx,3), p.MarkerSize, A(idx), ...
                'ColormapName', colormapName, ...
                'Colorbar'    , true, ...
                'CAxisLim'    , p.CAxisLim);
    
end

view(2);

% Histograms -------------------------------------------------------------------

for h = 1:numel(p.Histos)
    
    hHisto = subplot(3,4,h*4);
    att = obj.getAttribute(p.Histos{h});
    histo(att, 'handle', hHisto, -20);
    grid on
    title(sprintf('%s', p.Histos{h}));
    
end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end