function g = runICPSelection(obj, p, g, PC, VH)

msg('S', {g.procICP{:} 'SELECTION'}, 'LogLevel', 'basic');

% List of query point clouds
PCQueryList = sort(unique(p.PairList(:,1)));

for i = 1:numel(PCQueryList)

    % Index of actual query point cloud
    idxPCQuery = PCQueryList(i);

    % Load point cloud?
    if p.SubsetRadius > 0, PC{idxPCQuery} = obj.loadPC(idxPCQuery); end

    % Uniform sampling
    if p.UniformSamplingDistance(idxPCQuery) ~= 0, % if voxel size is zero, no uniform sampling
        PC{idxPCQuery}.select('UniformSampling', p.UniformSamplingDistance(idxPCQuery));
    end

    % Normals needed?
    if p.NormalSubsampling(idxPCQuery) || p.MaxLeverageSubsampling(idxPCQuery)
        
        if ~isfield(PC{idxPCQuery}.A, 'nx') % calculate normals only if not already present
            
            % Estimate normals
            PC{idxPCQuery}.normals(p.PlaneSearchRadius);
            
            % Deactivate points where normal computation was not successful
            PC{idxPCQuery}.act(isnan(PC{idxPCQuery}.A.nx)) = false;
            
        end
        
    end
    
    % Save activated points
    actOrig = PC{idxPCQuery}.act;

    % List of all search point clouds for actual query point cloud
    PCSearchList = p.PairList(p.PairList(:,1) == idxPCQuery,2);
    PCSearchList = sort(unique(PCSearchList));

    for s = 1:numel(PCSearchList)

        % Index of actual search point cloud
        idxPCSearch = PCSearchList(s);

        % Index of actual pair
        actPair = p.PairList(:,1) == idxPCQuery & p.PairList(:,2) == idxPCSearch;

        % Consider overlap
        % PC{idxPCQuery}.select('RangeSearch', VH{idxPCSearch}(:, 4:6), sqrt(3)*p.HullVoxelSize);
        PC{idxPCQuery}.select('InVoxelHull', VH{idxPCSearch}(:, 1:3), p.HullVoxelSize);

        if p.RandomSubsampling(idxPCQuery)     , PC{idxPCQuery}.select('RandomSampling'     , p.SubsamplingPercentPoi); end
        if p.NormalSubsampling(idxPCQuery)     , PC{idxPCQuery}.select('NormalSampling'     , p.SubsamplingPercentPoi); end
        if p.MaxLeverageSubsampling(idxPCQuery), PC{idxPCQuery}.select('MaxLeverageSampling', p.SubsamplingPercentPoi); end

        % Logical vector with query points for actual pair
        g.qp{actPair,1} = PC{idxPCQuery}.act;

        % Query point coordinates for selection of subsets
        if p.SubsetRadius > 0, g.qpX{actPair,1} = PC{idxPCQuery}.X(PC{idxPCQuery}.act,:); end

        % Restore activated points
        PC{idxPCQuery}.act = actOrig;

    end

    % Delete point cloud again?
    if p.SubsetRadius > 0, PC{idxPCQuery} = []; end

end

msg('E', {g.procICP{:} 'SELECTION'}, 'LogLevel', 'basic');

end