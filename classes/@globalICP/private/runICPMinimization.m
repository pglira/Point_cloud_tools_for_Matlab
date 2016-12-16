function [obj, g] = runICPMinimization(obj, p, g, CP)

msg('S', {g.procICP{:} 'MINIMIZATION'}, 'LogLevel', 'basic');

% Check if each point cloud is connected with other point clouds ---------------

% if g.nItICP == 1 % only in first iteration

    nCorr = zeros(g.nPC, 1); % no. of correspondences for each point cloud

    msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');
    msg('T', 'NUMBER OF CORRESPONDENCES FOR EACH POINT CLOUD:', 'LogLevel', 'basic');
    msg('T', sprintf('%12s %10s    file', 'point cloud', 'corresp.'), 'LogLevel', 'basic');

    for i = 1:g.nPC

        % Find indices of observations belonging to actual point cloud
        idxPairs = find(p.PairList(:,1) == i | p.PairList(:,2) == i);

        % Find no. of correspondences
        for j = 1:numel(idxPairs)
            nCorr(i) = nCorr(i) + size(CP{idxPairs(j)}.X1,1);
        end

        [~, file] = fileparts(obj.PC{i});

        msg('T', sprintf('%12s %10d    %s', ...
            ['[' num2str(i) ']'], ...
            nCorr(i), ...
            file), ...
            'LogLevel', 'basic');

        % Warning if point cloud has to few correspondences
        if nCorr(i) == 0
            msg('X', {g.procICP{:} 'MINIMIZATION'}, sprintf('attention, point cloud [%d] has %d correspondences!', i, nCorr(i)), 'LogLevel', 'basic');
        elseif nCorr(i) < p.NoOfTransfParam
            msg('X', {g.procICP{:} 'MINIMIZATION'}, sprintf('attention, point cloud [%d] has only %d correspondences!', i, nCorr(i)), 'LogLevel', 'basic');
        end

    end

    msg('T', '-------------------------------------------------------------------------------', 'LogLevel', 'basic');

% end
    
% Adjustment -------------------------------------------------------------------

% Initialize problem (call constructor method)
adj = lsAdj;

% Similarity transformation ----------------------------------------------------

if p.NoOfTransfParam <= 7

    % Add trafo parameters
    for i = 1:g.nPC

        % Fixed point cloud?
        if ismember(i, p.IdxFixedPointClouds) % all fixed
            constRotPrm   = true(3,1);
            constTransPrm = true(3,1);
            constScalePrm = true;
        elseif p.NoOfTransfParam == 1 % only z translation
            constRotPrm   = true(3,1);
            constTransPrm = [true true false]';
            constScalePrm = true;
            % Würländer 'hack'
            % constRotPrm   = [false false true]';
            % constTransPrm = [true true false]';
            % constScalePrm = true;
        elseif p.NoOfTransfParam == 3 % only translation parameters
            constRotPrm   = true(3,1);
            constTransPrm = false(3,1);
            constScalePrm = true;
        elseif p.NoOfTransfParam == 6 % rigid body
            constRotPrm   = false(3,1);
            constTransPrm = false(3,1);
            constScalePrm = true;
        elseif p.NoOfTransfParam == 7 % similarity transformation
            constRotPrm   = false(3,1);
            constTransPrm = false(3,1);
            constScalePrm = false;
        end

        % Add 3 angle parameters
        g.adjIdx.prm_opk{i} = adj.addPrm('x0'   , zeros(3,1), ...
                                         'const', constRotPrm, ...
                                         'label', {sprintf('point cloud %02d > omega', i)
                                                   sprintf('point cloud %02d > phi'  , i)
                                                   sprintf('point cloud %02d > kappa', i)}, ...
                                         'scale4report', 180/pi);

        % Add 3 translation parameters
        g.adjIdx.prm_t{i} = adj.addPrm('x0'   , zeros(3,1), ...
                                       'const', constTransPrm, ...
                                       'label', {sprintf('point cloud %02d > tx', i)
                                                 sprintf('point cloud %02d > ty', i)
                                                 sprintf('point cloud %02d > tz', i)});

        % Add 1 scale parameter
        g.adjIdx.prm_m{i} = adj.addPrm('x0'   , 1, ...
                                       'const', constScalePrm, ...
                                       'label', {sprintf('point cloud %02d > m', i)});

    end

    % Add correspondences for each pair
    for i = 1:size(p.PairList,1)

        idxPC1 = p.PairList(i,1);
        idxPC2 = p.PairList(i,2);

        if size(CP{i}.X1,1) >= p.NoOfTransfParam % just add correspondences if no. of corr. >= p.NoOfTransfParam

            % Add constants
            adjIdx.cst_X1_x{i} = adj.addCst(CP{i}.X1(:,1));
            adjIdx.cst_X1_y{i} = adj.addCst(CP{i}.X1(:,2));
            adjIdx.cst_X1_z{i} = adj.addCst(CP{i}.X1(:,3));

            adjIdx.cst_X2_x{i} = adj.addCst(CP{i}.X2(:,1));
            adjIdx.cst_X2_y{i} = adj.addCst(CP{i}.X2(:,2));
            adjIdx.cst_X2_z{i} = adj.addCst(CP{i}.X2(:,3));

            adjIdx.cst_n1_x{i} = adj.addCst(CP{i}.A1.nx);
            adjIdx.cst_n1_y{i} = adj.addCst(CP{i}.A1.ny);
            adjIdx.cst_n1_z{i} = adj.addCst(CP{i}.A1.nz);

            % Get sigma of correspondences
            sigdp_priori = 1.4826*mad(CP{i}.dp,1);

            % Add observations
            g.adjIdx.obs_dp{i} = adj.addObs('b'          , zeros(size(CP{i}.X1,1),1), ...
                                            'sigb_priori', ones(size(CP{i}.X1,1),1)*sigdp_priori, ...
                                            'pFac'       , CP{i}.A.w);

            % Add conditions
            adj.addCon('fun', @conSimPoint2PlaneOLS, ...
                       'prm', struct('om1', g.adjIdx.prm_opk{idxPC1}(1), ...
                                     'ph1', g.adjIdx.prm_opk{idxPC1}(2), ...
                                     'ka1', g.adjIdx.prm_opk{idxPC1}(3), ...
                                     'tx1', g.adjIdx.prm_t{idxPC1}(1)  , ...
                                     'ty1', g.adjIdx.prm_t{idxPC1}(2)  , ...
                                     'tz1', g.adjIdx.prm_t{idxPC1}(3)  , ...
                                     'm1' , g.adjIdx.prm_m{idxPC1}     , ...        
                                     'om2', g.adjIdx.prm_opk{idxPC2}(1), ...
                                     'ph2', g.adjIdx.prm_opk{idxPC2}(2), ...
                                     'ka2', g.adjIdx.prm_opk{idxPC2}(3), ...
                                     'tx2', g.adjIdx.prm_t{idxPC2}(1)  , ...
                                     'ty2', g.adjIdx.prm_t{idxPC2}(2)  , ...
                                     'tz2', g.adjIdx.prm_t{idxPC2}(3)  , ...
                                     'm2' , g.adjIdx.prm_m{idxPC2})    , ...
                       'cst', struct('x1' , adjIdx.cst_X1_x{i}       , ...
                                     'y1' , adjIdx.cst_X1_y{i}       , ...
                                     'z1' , adjIdx.cst_X1_z{i}       , ...
                                     'x2' , adjIdx.cst_X2_x{i}       , ...
                                     'y2' , adjIdx.cst_X2_y{i}       , ...
                                     'z2' , adjIdx.cst_X2_z{i}       , ...
                                     'nx1', adjIdx.cst_n1_x{i}       , ...
                                     'ny1', adjIdx.cst_n1_y{i}       , ...
                                     'nz1', adjIdx.cst_n1_z{i})      , ...
                       'obs', struct('dp' , g.adjIdx.obs_dp{i}));

        end

    end

end

% Affine transformation --------------------------------------------------------

if p.NoOfTransfParam == 12

    % Add trafo parameters
    for i = 1:g.nPC

        if ismember(i, p.IdxFixedPointClouds)
            constPrm = true;
        else
            constPrm = false;
        end

        % Add 9 affine parameters
        g.adjIdx.prm_a{i} = adj.addPrm('x0', [1 0 0 0 1 0 0 0 1]', ... % a11, a12, a13, a21, a22, a23, a31, a32, a33
                                       'const', constPrm, ...
                                       'label', {sprintf('point cloud %02d > a11', i)
                                                 sprintf('point cloud %02d > a12', i)
                                                 sprintf('point cloud %02d > a13', i)
                                                 sprintf('point cloud %02d > a21', i)
                                                 sprintf('point cloud %02d > a22', i)
                                                 sprintf('point cloud %02d > a23', i)
                                                 sprintf('point cloud %02d > a31', i)
                                                 sprintf('point cloud %02d > a32', i)
                                                 sprintf('point cloud %02d > a33', i)});

        % Add 3 translation parameters
        g.adjIdx.prm_t{i} = adj.addPrm('x0'   , zeros(3,1), ...
                                       'const', constPrm, ...
                                       'label', {sprintf('point cloud %02d > tx', i)
                                                 sprintf('point cloud %02d > ty', i)
                                                 sprintf('point cloud %02d > tz', i)});

    end

    % Add correspondences for each pair
    for i = 1:size(p.PairList,1)

        idxPC1 = p.PairList(i,1);
        idxPC2 = p.PairList(i,2);

        if size(CP{i}.X1,1) >= p.NoOfTransfParam % just add correspondences if no. of corr. >= p.NoOfTransfParam

            % Add constants
            adjIdx.cst_X1_x{i} = adj.addCst(CP{i}.X1(:,1));
            adjIdx.cst_X1_y{i} = adj.addCst(CP{i}.X1(:,2));
            adjIdx.cst_X1_z{i} = adj.addCst(CP{i}.X1(:,3));

            adjIdx.cst_X2_x{i} = adj.addCst(CP{i}.X2(:,1));
            adjIdx.cst_X2_y{i} = adj.addCst(CP{i}.X2(:,2));
            adjIdx.cst_X2_z{i} = adj.addCst(CP{i}.X2(:,3));

            adjIdx.cst_n1_x{i} = adj.addCst(CP{i}.A1.nx);
            adjIdx.cst_n1_y{i} = adj.addCst(CP{i}.A1.ny);
            adjIdx.cst_n1_z{i} = adj.addCst(CP{i}.A1.nz);

            % Get sigma of correspondences
            sigdp_priori = 1.4826*mad(CP{i}.dp,1);

            % Add observations
            g.adjIdx.obs_dp{i} = adj.addObs('b'          , zeros(size(CP{i}.X1,1),1), ...
                                            'sigb_priori', ones(size(CP{i}.X1,1),1)*sigdp_priori, ...
                                            'pFac'       , CP{i}.A.w);

            % Add conditions
            adj.addCon('fun', @conAffPoint2PlaneSimpleOLS, ...
                       'prm', struct('a111', g.adjIdx.prm_a{idxPC1}(1) , ...
                                     'a121', g.adjIdx.prm_a{idxPC1}(2) , ...
                                     'a131', g.adjIdx.prm_a{idxPC1}(3) , ...
                                     'a211', g.adjIdx.prm_a{idxPC1}(4) , ...
                                     'a221', g.adjIdx.prm_a{idxPC1}(5) , ...
                                     'a231', g.adjIdx.prm_a{idxPC1}(6) , ...
                                     'a311', g.adjIdx.prm_a{idxPC1}(7) , ...
                                     'a321', g.adjIdx.prm_a{idxPC1}(8) , ...
                                     'a331', g.adjIdx.prm_a{idxPC1}(9) , ...
                                     'a112', g.adjIdx.prm_a{idxPC2}(1) , ...
                                     'a122', g.adjIdx.prm_a{idxPC2}(2) , ...
                                     'a132', g.adjIdx.prm_a{idxPC2}(3) , ...
                                     'a212', g.adjIdx.prm_a{idxPC2}(4) , ...
                                     'a222', g.adjIdx.prm_a{idxPC2}(5) , ...
                                     'a232', g.adjIdx.prm_a{idxPC2}(6) , ...
                                     'a312', g.adjIdx.prm_a{idxPC2}(7) , ...
                                     'a322', g.adjIdx.prm_a{idxPC2}(8) , ...
                                     'a332', g.adjIdx.prm_a{idxPC2}(9) , ...
                                     'tx1' , g.adjIdx.prm_t{idxPC1}(1) , ...
                                     'ty1' , g.adjIdx.prm_t{idxPC1}(2) , ...
                                     'tz1' , g.adjIdx.prm_t{idxPC1}(3) , ...
                                     'tx2' , g.adjIdx.prm_t{idxPC2}(1) , ...
                                     'ty2' , g.adjIdx.prm_t{idxPC2}(2) , ...
                                     'tz2' , g.adjIdx.prm_t{idxPC2}(3)), ...
                       'cst', struct('x1' , adjIdx.cst_X1_x{i}       , ...
                                     'y1' , adjIdx.cst_X1_y{i}       , ...
                                     'z1' , adjIdx.cst_X1_z{i}       , ...
                                     'x2' , adjIdx.cst_X2_x{i}       , ...
                                     'y2' , adjIdx.cst_X2_y{i}       , ...
                                     'z2' , adjIdx.cst_X2_z{i}       , ...
                                     'nx1', adjIdx.cst_n1_x{i}       , ...
                                     'ny1', adjIdx.cst_n1_y{i}       , ...
                                     'nz1', adjIdx.cst_n1_z{i})      , ...
                       'obs', struct('dp' , g.adjIdx.obs_dp{i}));

        end

    end

end

% Solve adjustment -------------------------------------------------------------

% Adjustment!!!
adj = adj.solve(p.AdjOptions);

obj.D.adj{g.nItICP} = adj;

msg('E', {g.procICP{:} 'MINIMIZATION'}, 'LogLevel', 'basic');

end