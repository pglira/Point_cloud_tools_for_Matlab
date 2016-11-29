function obj = runICPTransformFinal(obj, p, g)

msg('S', {g.proc{:} 'TRANSFORMATION'}, 'LogLevel', 'basic');

for i = 1:g.nPC
    
    % Find new path
    [~, file] = fileparts(obj.PC{i});
    p2mat = fullfile(obj.OutputFolder, [file '_POSTICP.mat']);
    
    if ~ismember(i, p.IdxFixedPointClouds) % trafo only if point cloud is not fixed, i.e. loose

        % Load point cloud
        PC = obj.loadPC(i);

        % Trafo
        PC.transform(1, obj.D.H{1,i}(1:3,1:3), obj.D.H{1,i}(1:3,4));

        % Update mat file
        PC.save(p2mat);
        
    else
        
        % Copy original mat file
        copyfile(obj.PC{i}, p2mat);
        
    end

    % Set new path
    obj.PC{i} = p2mat;
    
end

msg('E', {g.proc{:} 'TRANSFORMATION'}, 'LogLevel', 'basic');
    
end