function [obj, PC] = runICPTransform(obj, p, g, PC)

msg('S', {g.procICP{:} 'TRANSFORMATION'}, 'LogLevel', 'basic');

adj = obj.D.adj{g.nItICP};

for i = 1:g.nPC

    % Similarity transformation
    if p.NoOfTransfParam <= 7

        m = adj.prm.xhat(g.adjIdx.prm_m{i});

        R = opk2R(adj.prm.xhat(g.adjIdx.prm_opk{i}(1)), adj.prm.xhat(g.adjIdx.prm_opk{i}(2)), adj.prm.xhat(g.adjIdx.prm_opk{i}(3)), 'Unit', 'Radian');

        t = adj.prm.xhat(g.adjIdx.prm_t{i});

    end

    % Affine transformation
    if p.NoOfTransfParam == 12

        m = 1;

        R = [adj.prm.xhat(g.adjIdx.prm_a{i}(1)) adj.prm.xhat(g.adjIdx.prm_a{i}(2)) adj.prm.xhat(g.adjIdx.prm_a{i}(3)) 
             adj.prm.xhat(g.adjIdx.prm_a{i}(4)) adj.prm.xhat(g.adjIdx.prm_a{i}(5)) adj.prm.xhat(g.adjIdx.prm_a{i}(6)) 
             adj.prm.xhat(g.adjIdx.prm_a{i}(7)) adj.prm.xhat(g.adjIdx.prm_a{i}(8)) adj.prm.xhat(g.adjIdx.prm_a{i}(9))];

        t = [adj.prm.xhat(g.adjIdx.prm_t{i})];

    end

    if ~ismember(i, p.IdxFixedPointClouds) % trafo only if point cloud is not fixed, i.e. loose

        % Transformation
        PC{i}.transform(m, R, t);

    end 

    % Differential homogeneous transformation matrix
    obj.D.dH{g.nItICP,i} = homotrafo(m, R, t);

    % Update homogeneous transformation matrix
    obj.D.H{1,i} = obj.D.dH{g.nItICP,i} * obj.D.H{1,i};

    % Global homogeneous transformation matrix without reduction point
    obj.D.HO{1,i} = [eye(3) PC{1}.redPoi'; zeros(1,3) 1] * obj.D.H{1,i} * [eye(3) -PC{1}.redPoi'; zeros(1,3) 1];

end

msg('E', {g.procICP{:} 'TRANSFORMATION'}, 'LogLevel', 'basic');

end
