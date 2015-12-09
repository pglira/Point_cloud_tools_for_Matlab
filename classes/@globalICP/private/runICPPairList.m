function p = runICPPairList(p, g, VH)

msg('S', {g.procICP{:} 'FIND OVERLAPPING POINT CLOUDS'}, 'LogLevel', 'basic');

% List of all possible point cloud pairList
p.PairList = nchoosek(1:g.nPC, 2);

idx2del = [];

% Check intersection of voxel hulls for each pair
for i = 1:size(p.PairList,1)

    % Indices of point clouds of actual pair
    idxPC1 = p.PairList(i,1);
    idxPC2 = p.PairList(i,2);

    % Intersection of voxel hulls
    C = intersect(VH{idxPC1}(:, 1:3), VH{idxPC2}(:, 1:3), 'rows');

    % Number of intersecting voxels
    noIntersectingVoxel(i) = size(C,1);

    % Delete pair?
    if (noIntersectingVoxel(i) < p.MinNoIntersectingVoxel) || ... % to less intersecting voxels?
       all(ismember([idxPC1 idxPC2], p.IdxFixedPointClouds))   % both point clouds are fixed
        idx2del = [idx2del; i];
    end

end

% Delete pairs
p.PairList(idx2del, :) = [];
noIntersectingVoxel(idx2del) = []; % for report

% Switch columns so that fixed point clouds are always in first column (i.e. query points are selected in fixed point clouds)
for i = 1:numel(p.IdxFixedPointClouds)
    idx2switch = p.PairList(:,2) == p.IdxFixedPointClouds(i);
    p.PairList(idx2switch,:) = [p.PairList(idx2switch,2) p.PairList(idx2switch,1)]; % switch columns
end

% Report
if isempty(p.PairList)
    error('Input point clouds are not overlapping!');
else
    msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');
    msg('T', 'LIST OF POINT CLOUD PAIRS:', 'LogLevel', 'basic');
    msg('T', sprintf('%12s %14s %14s %14s', 'pair', 'point_cloud', 'point_cloud', 'overlapping'), 'LogLevel', 'basic');
    msg('T', sprintf('%12s %14s %14s %14s', ''    , ''           , ''           , 'voxel'      ), 'LogLevel', 'basic');
    for i = 1:size(p.PairList,1)
        msg('T', sprintf('%12s %14s %14s %14d', ['[' num2str(i) ']'], ['[' num2str(p.PairList(i,1)) ']'], ['[' num2str(p.PairList(i,2)) ']'], noIntersectingVoxel(i)), 'LogLevel', 'basic'); 
    end
    msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');
end

% Warning if point cloud is not overlapping with other point clouds
for i = 1:g.nPC
    if sum(p.PairList(:) == i) == 0
        msg('X', {g.procICP{:} 'FIND OVERLAPPING POINT CLOUDS'}, sprintf('attention, point cloud [%d] is not overlapping with other point clouds!', i), 'LogLevel', 'basic');
    end
end
msg('E', {g.procICP{:} 'FIND OVERLAPPING POINT CLOUDS'}, 'LogLevel', 'basic');

end