function CP = runICPMatching(p, g, PC)

msg('S', {g.procICP{:} 'MATCHING'}, 'LogLevel', 'basic');
    
for i = 1:size(p.PairList,1)

    % Indices of point clouds of actual pair
    idxPC1 = p.PairList(i,1);
    idxPC2 = p.PairList(i,2);

    % Select query points
    PC{idxPC1} = PC{idxPC1}.select('None');
    PC{idxPC1}.act = g.qp{i};

    % Options for normal estimation
    OptNormals = {p.PlaneSearchRadius};

    % Create object for corresponding points
    CP{i,1} = corrPoi(idxPC1, idxPC2);

    % Matching!
    CP{i} = CP{i}.match(PC{idxPC1}, PC{idxPC2}, ...
                        'Prm4normals', OptNormals, ...
                        'SaveIdx'    , true);

    % Rejection of corresponding points where normal estimation was not successful
    CP{i} = CP{i}.rejection('dAlphaNaN');

    % Reselect all points
    PC{idxPC1} = PC{idxPC1}.select('All');

end

msg('E', {g.procICP{:} 'MATCHING'}, 'LogLevel', 'basic');
    
end