function [obj, g, VH] = runICPVoxelHulls(obj, p, g, PC)

msg('S', {g.procICP{:} 'VOXEL HULLS'}, 'LogLevel', 'basic');

for i = 1:g.nPC

    % Load point cloud?
    if p.SubsetRadius > 0, PC{i} = obj.loadPC(i); end

    % Save reduction point of point clouds
    if i == 1, obj.D.redPoi = PC{i}.redPoi; end
    
    % Compute voxel hull
    PC{i} = PC{i}.getVoxelHull(p.HullVoxelSize, 'Centroids', true);

    % Save voxel hull
    VH{i,1} = PC{i}.voxelHull;

    % Delete point cloud again?
    if p.SubsetRadius > 0, PC{i} = []; end

end

msg('E', {g.procICP{:} 'VOXEL HULLS'}, 'LogLevel', 'basic');

end