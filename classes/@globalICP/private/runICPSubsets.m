function [g, PC] = runICPSubsets(obj, p, g, PC)

msg('S', {g.procICP{:} 'SUBSETS'}, 'LogLevel', 'basic');

for i = 1:g.nPC

    % Load point cloud
    PC{i} = obj.loadPC(i);

    % Indices of pairs of which actual point cloud is part of
    idxPairs = p.PairList(:,1) == i | p.PairList(:,2) == i;

    % All query points
    allQP = vertcat(g.qpX{idxPairs});

    % Select a subset of points based on the query points
    PC{i}.select('RangeSearch', allQP, p.SubsetRadius);
    idx2Keep = find(PC{i}.act);
    % idxRangeSearch = PC{i}.rangesearch(allQP, p.SubsetRadius);
    % idxRangeSearch = unique(horzcat(idxRangeSearch{:})');

    % Indices of points to keep
    % idx2Keep = intersect(idxRangeSearch, find(PC{i}.act));

    % Remove non active points
    % PC{i}.act(:) = false;
    % PC{i}.act(idx2Keep) = true;
    PC{i}.reconstruct;

    % Update query points
    idxPairs2update = find(p.PairList(:,1) == i);
    for i = idxPairs2update'
        g.qp{i} = g.qp{i}(idx2Keep);
    end

end

msg('E', {g.procICP{:} 'SUBSETS'}, 'LogLevel', 'basic');

end