function segId = findSegments(X, N, segId, idxNN, dist, p)

% Set id of isolated points to 0
segId(dist>p.r) = 0;

% i = 0 -> reserved for isolated points
% i = 1 -> reserved for points from too small segments
i = 2;

% Loop over segments
while sum(isnan(segId)) > 0 % until each point has a segment id
    
    % Index of seed point
    notSegmented = find(isnan(segId));
    seedIdx = notSegmented(1); % first point of not segmented points
    
    % Initialize vector containing all point indices belonging to a segment
    segIdx = seedIdx;

    % Normal vector of segment
    nSeg = [N(seedIdx,1)
            N(seedIdx,2)
            N(seedIdx,3)];
    
    addedPoi = 1;
    
    % Find segment
    while addedPoi > 0 % until no point is added to the actual segment

        % Estimate new segment normal?
        if size(segIdx,1) >= 8
            C = cov(X(segIdx,:));
            P = pcacov(C);
            nSeg = P(:,3);
        end
        
        % NN of all seed indices
        idxNN = unique([idNN{seedIdx}]');
        
        % Ids of points which are not already part of a segment
        newIdx = idxNN(isnan(obj.A.segId(idxNN)));
        
        addedPoi = numel(newIdx);
        
        % Check added points
        if addedPoi > 0

            % Calculate inner product of segment normal with point normals
            innProd = nSeg' * [obj.A.nx(newIdx)'
                               obj.A.ny(newIdx)'
                               obj.A.nz(newIdx)'];

            % Angle between normals
            dAlpha = acos(innProd) * 200/pi;

            % Delete all points for which dAlpha exceeds the maximal value
            newIdx(dAlpha > p.dAngleMax) = [];

            % Add point indices to segment
            segIdx = [segIdx; newIdx];

            % Assign segment id to new points
            obj.A.segId(newIdx) = i;
            
        end

        % 4Debug
        % cla
        % if ~exist('cmap')
        %     cmap = rand(2,3); % color for segment 0 and 1
        % elseif size(cmap,1) < i+1
        %     cmap = [cmap; rand(1,3)]; % add color for next segment
        % end
        % for s = 0:i-1 % for each segment except the actual one
        %     plotauto(obj.X(obj.A.segId == s, :), '.', 'Color', cmap(s+1,:));
        %     if s == 0, hold on; view(2); axis equal; grid on; end
        % end
        % plotauto(obj.X( isnan(obj.A.segId),:), '.', 'Color', [0.8 0.8 0.8]); % not segmented points
        % plotauto(obj.X(seedIdx,:), 'ro') % seed point(s)
        % plotauto(obj.X(segIdx, :), '.', 'Color', cmap(i+1,:)); % segment points

        % Added points are new seed points in next loop
        seedIdx = newIdx;
        
    end
    
    % If segment is too small assign sedId 1
    if numel(segIdx) < p.MinNoPoints
        obj.A.segId(segIdx) = 1;
    else
        % Increase segment id
        i = i + 1;
    end
    
end

end