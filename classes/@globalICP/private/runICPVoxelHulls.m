function [obj, g, VH] = runICPVoxelHulls(obj, p, g, PC)

msg('S', {g.procICP{:} 'VOXEL HULLS'}, 'LogLevel', 'basic');

for i = 1:g.nPC

    % Load point cloud?
    if p.SubsetRadius > 0, PC{i} = obj.loadPC(i); end

    % Save reduction point of point clouds and check if they are consistent
    if i == 1
        obj.D.redPoi = PC{i}.redPoi;
    else
        if any(PC{i}.redPoi ~= obj.D.redPoi)
            if i == 2
                error(sprintf('The reduction point of point cloud [%d] is different to the reduction point of point cloud [1]!', i));
            else
                error(sprintf('The reduction point of point cloud [%d] is different to the reduction point of the point clouds [1]-[%d]!', i, i-1));
            end
        end
    end
    
    % Compute voxel hull
    PC{i}.getVoxelHull(p.HullVoxelSize, 'Centroids', true);

    % Save voxel hull
    VH{i,1} = PC{i}.voxelHull;

    % Delete point cloud again?
    if p.SubsetRadius > 0, PC{i} = []; end

end

msg('E', {g.procICP{:} 'VOXEL HULLS'}, 'LogLevel', 'basic');

end