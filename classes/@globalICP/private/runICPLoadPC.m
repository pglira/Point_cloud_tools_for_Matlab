function PC = runICPLoadPC(obj, p, g)

msg('S', {g.proc{:} 'LOAD POINT CLOUDS'}, 'LogLevel', 'basic');

for i = 1:g.nPC

    % Load point cloud
    PC{i} = obj.loadPC(i);

    % Remove non active points if any
    if sum(~PC{i}.act) > 0
        PC{i}.reconstruct;
    end

end

msg('E', {g.proc{:} 'LOAD POINT CLOUDS'}, 'LogLevel', 'basic');

end