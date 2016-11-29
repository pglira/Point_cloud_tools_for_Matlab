function obj = runICPStats(obj, p, g)

msg('S', {g.procICP{:} 'RESULTS'}, 'LogLevel', 'basic');

% General stats
obj.D.stats{g.nItICP}.std_vWithoutGrossErrors  = obj.D.adj{g.nItICP}.res.std_vWithoutGrossErrors;
obj.D.stats{g.nItICP}.mean_vWithoutGrossErrors = obj.D.adj{g.nItICP}.res.mean_vWithoutGrossErrors;
obj.D.stats{g.nItICP}.normdx                   = norm([obj.D.adj{g.nItICP}.prm.xhat] - [obj.D.adj{g.nItICP}.prm.x0]);

% Number of observations
% ... is equal to no. of all observations ...
obj.D.stats{g.nItICP}.nObs = obj.D.adj{g.nItICP}.res.nObs;
% ... minus no. of deactivated observations (if any)
if min(obj.D.adj{g.nItICP}.obs.pFacRWA) < max(obj.D.adj{g.nItICP}.obs.pFacRWA)
    obj.D.stats{g.nItICP}.nObs = obj.D.stats{g.nItICP}.nObs - sum(obj.D.adj{g.nItICP}.obs.pFacRWA == min(obj.D.adj{g.nItICP}.obs.pFacRWA));
end

% Point cloud 'quality'
for i = 1:g.nPC

    % Find indices of observations belonging to actual point cloud
    idxPairs = find(p.PairList(:,1) == i | p.PairList(:,2) == i);
    idxObs = [];
    for j = 1:numel(idxPairs)
        if idxPairs(j) <= numel(g.adjIdx.obs_dp) % it may happen that one of the last pair(s) have to few correspondences, so that g.adjIdx.obs_dp does not exist
            idxObs = [idxObs; g.adjIdx.obs_dp{idxPairs(j)}];
        end
    end
    
    res     = obj.D.adj{g.nItICP}.obs.res(idxObs);
    pFacRWA = obj.D.adj{g.nItICP}.obs.pFacRWA(idxObs);

    res = res(pFacRWA == max(pFacRWA));
    
    obj.D.stats{g.nItICP}.PC_nObs(i)                            = numel(res);
    obj.D.stats{g.nItICP}.PC_std_obs_dp_vWithoutGrossErrors(i)  = std(res);
    obj.D.stats{g.nItICP}.PC_mean_obs_dp_vWithoutGrossErrors(i) = mean(res);
    
end

% Report
msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');

msg('T', 'GENERAL STATISTICS:', 'LogLevel', 'basic');

msg('T', sprintf('%12s %12s %12s %12s %12s', 'iteration', 'corresp.', 'std(dp)', 'mean(dp)', 'norm(dx)'), 'LogLevel', 'basic'); 
for i = 1:g.nItICP
    if i == g.nItICP, iteration = sprintf('new: %d', i); else iteration = sprintf('%12d', i); end
    msg('T', sprintf('%12s %12d %12.5f %12.5f %12.5f', iteration, obj.D.stats{i}.nObs, obj.D.stats{i}.std_vWithoutGrossErrors, obj.D.stats{i}.mean_vWithoutGrossErrors, obj.D.stats{i}.normdx), 'LogLevel', 'basic');
end
msg('T', 'where dp = vector of all (signed) point-to-plane distances', 'LogLevel', 'basic');
msg('T', '      dx = vector of parameter increments', 'LogLevel', 'basic');

msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');

msg('T', 'POINT CLOUD DEPENDANT STATISTICS:', 'LogLevel', 'basic');

msg('T', sprintf('%12s %12s %12s %12s     file', 'point_cloud', 'corresp.', 'std(dp)', 'mean(dp)'), 'LogLevel', 'basic');
for i = 1:g.nPC
    [~, file] = fileparts(obj.PC{i});
    msg('T', sprintf('%12s %12d %12.5f %12.5f     %s', ['[' num2str(i) ']'], obj.D.stats{g.nItICP}.PC_nObs(i), obj.D.stats{g.nItICP}.PC_std_obs_dp_vWithoutGrossErrors(i), obj.D.stats{g.nItICP}.PC_mean_obs_dp_vWithoutGrossErrors(i), file), 'LogLevel', 'basic');
end
msg('T', 'where dp = vector of all (signed) point-to-plane distances associated to a single point cloud', 'LogLevel', 'basic');

msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');

msg('E', {g.procICP{:} 'RESULTS'}, 'LogLevel', 'basic');

end