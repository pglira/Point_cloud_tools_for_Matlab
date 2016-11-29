function plot_updateHisto(hFig)

hFigHisto = findobj('Type', 'Figure', 'Name', 'Histogram');

if ~isempty(hFigHisto)
    
    % Get index of selected point cloud
    hPCHisto = findobj(hFigHisto, 'Tag', 'hPCHisto');
    idxPC = hPCHisto.Value;
    
    % Get selected attribute
    hAttributeHisto = findobj(hFigHisto, 'Tag', 'hAttributeHisto');
    attributeName = hAttributeHisto.String{hAttributeHisto.Value};
    
    % Data for histogram
    act = hFig.UserData.PC{idxPC}.act;
    if strcmpi(attributeName, 'x')
        data = hFig.UserData.PC{idxPC}.X(act,1);
    elseif strcmpi(attributeName, 'y')
        data = hFig.UserData.PC{idxPC}.X(act,2);
    elseif strcmpi(attributeName, 'z')
        data = hFig.UserData.PC{idxPC}.X(act,3);
    else
        data = hFig.UserData.PC{idxPC}.A.(attributeName)(act);
    end
    
    % Handle of axes
    hAxesHisto = findobj('Parent', hFigHisto, 'Type', 'Axes');
    
    % Plot histogram!
    hHisto = histogram(hAxesHisto, ...
                       data, ...
                       'Normalization', 'probability');
    
    h = zoom(hFigHisto);
    h.Motion = 'horizontal';
    h.RightClickAction = 'InverseZoom';
    h.Enable = 'on';
    h.ActionPostCallback = {@plot_zoomHisto, hAxesHisto, hHisto};
    % h.ActionPostCallback = @(src, evt)plot_zoomHisto(src, evt, hAxesHisto, hHisto); % alternative syntax
    
    grid(hAxesHisto, 'on');
    
    % Label of x axis (inspired by Camillos histo function!)
    xlabel(hAxesHisto,  {['n: '             num2str(numel(data)                   , '%d'    ) ...
                          '    RMS: '       num2str(sqrt(sum(data.^2)/numel(data)), '%11.4f') ...
                          '    median: '    num2str(median(data)                  , '%11.4f') ...
                          '    sig_{MAD}: ' num2str(1.4826*mad(data,1)            , '%11.4f')] ...
                         ['min: '           num2str(min(data)                     , '%11.4f') ...
                          '    max: '       num2str(max(data)                     , '%11.4f') ...
                          '    mean: '      num2str(mean(data)                    , '%11.4f') ...
                          '    sig: '       num2str(std(data)                     , '%11.4f')]})
    
end

end