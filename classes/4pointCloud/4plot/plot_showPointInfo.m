function infoTxt = plot_showPointInfo(~, eventObj)

hFig = gcf;

% Find point -------------------------------------------------------------------

% Selected point coordinates
X = eventObj.Position;

% Search in each point cloud
for idxPC = 1:numel(hFig.UserData.PC)
    
    % Find index of selected point in activated (i.e. displayed) points
    idxSelPoiInActPoi = find(X(1) == hFig.UserData.PC{idxPC}.X(hFig.UserData.PC{idxPC}.act,1) & ...
                             X(2) == hFig.UserData.PC{idxPC}.X(hFig.UserData.PC{idxPC}.act,2) & ...
                             X(3) == hFig.UserData.PC{idxPC}.X(hFig.UserData.PC{idxPC}.act,3));

    % If one ore more points were found
    if ~isempty(idxSelPoiInActPoi)        
        idxSelPoiInActPoi = idxSelPoiInActPoi(1); % use first point if more than one points were found
        idxAllActPoi = find(hFig.UserData.PC{idxPC}.act);
        idxSelPoi = idxAllActPoi(idxSelPoiInActPoi);
        break; % leave loop if point was found
    end
    
end

% Create output text -----------------------------------------------------------
% Note: idxPC     is index of PC
%       idxSelPoi is index of selected point

% Label
infoTxt = sprintf('[%s]\n', hFig.UserData.PC{idxPC}.label);

% Point index
infoTxt = [infoTxt sprintf('Index = %d\n', idxSelPoi)];

% Coordinates
infoTxt = [infoTxt sprintf('COORDINATES:\n')];
infoTxt = [infoTxt sprintf('X = %s\n', num2str(hFig.UserData.PC{idxPC}.X(idxSelPoi,1)))];
infoTxt = [infoTxt sprintf('Y = %s\n', num2str(hFig.UserData.PC{idxPC}.X(idxSelPoi,2)))];
infoTxt = [infoTxt sprintf('Z = %s\n', num2str(hFig.UserData.PC{idxPC}.X(idxSelPoi,3)))];

% Attributes
if isstruct(hFig.UserData.PC{idxPC}.A)
    att = fields(hFig.UserData.PC{idxPC}.A);
    for i = 1:numel(att)
        if i == 1, infoTxt = [infoTxt sprintf('ATTRIBUTES:\n')]; end
        infoTxt = [infoTxt sprintf('%s = %s\n', att{i}, num2str(hFig.UserData.PC{idxPC}.A.(att{i})(idxSelPoi)))]; % num2str to show significant amount of digits only
    end
end

end