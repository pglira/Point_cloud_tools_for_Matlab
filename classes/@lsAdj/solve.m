function obj = solve(obj, varargin)

% adjOptions.MaxIt                = ;
% adjOptions.Sig0_priori          = ;
% adjOptions.MaxTolLin            = ;
% adjOptions.MaxEpsKraus          = ;
% adjOptions.RobustWeightAdaption = ;
% adjOptions.Cxx                  = ;
% adjOptions.Condition            = ;
% adjOptions.Rank                 = ;
% adjOptions.RWAMaxSig            = ;
% adjOptions.RWAPoi2RemovePerIt   = ;
% adjOptions.RWASlant             = ;
% adjOptions.RWApFacOfGrossErrors = ;
% adjOptions.RWAMaxIt             = ;

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParameter('MaxIt'               , 10   , @(x) isscalar(x) && x > 0);
p.addParameter('Sig0_priori'         , 1    , @(x) isscalar(x) && x > 0);
p.addParameter('MaxTolLin'           , 1e-8 , @(x) isscalar(x) && x > 0); % d in Lother 2007, Ausgleichsrechnung (page 7-9)
p.addParameter('MaxEpsKraus'         , 1e-5 , @(x) isscalar(x) && x > 0); % eps in Kraus 1996, Photogrammetrie Band 2 (page 80)
p.addParameter('RobustWeightAdaption', true , @islogical);
p.addParameter('Cxx'                 , false, @islogical);
p.addParameter('Condition'           , false, @islogical);
p.addParameter('Rank'                , false, @islogical);
p.addParameter('RWAMaxSig'           , 3    , @(x) isscalar(x) && x > 0);
p.addParameter('RWAPoi2RemovePerIt'  , 10   , @(x) isscalar(x) && x > 0);
p.addParameter('RWASlant'            , 2    , @(x) isscalar(x) && x > 0);
p.addParameter('RWApFacOfGrossErrors', 0.01 , @(x) isscalar(x) && x >= 0 && x < 1);
p.addParameter('RWAMaxIt'            , 10   , @(x) isscalar(x) && x > 1);

p.parse(varargin{:});
p = p.Results;

% Start ------------------------------------------------------------------------

procHierarchy = {'LSADJ' 'SOLVE'};

msg('S', procHierarchy);

% Preparations -----------------------------------------------------------------

% Assign indices for adjustment
msg('S', {'LSADJ' 'SOLVE' 'ASSIGNIDXADJ'});
obj = obj.assignIdxAdj;
msg('E', {'LSADJ' 'SOLVE' 'ASSIGNIDXADJ'});

% Create a copy of con structure (as accessing obj.con is unbelievable slow!!!)
con = obj.con;

% sigb_priori of observations as vector
sigb_priori = obj.obs.sigb_priori(~isnan(obj.obs.idxAdj) & obj.obs.sigb_priori > 0);

% pFac of observations as vector
pFac = obj.obs.pFac(~isnan(obj.obs.idxAdj) & obj.obs.sigb_priori > 0);

% pFac for RWA of observations as vector
pFacRWA = ones(size(pFac,1), 1);

% allowRWA for RWA of observations as vector
allowRWA = obj.obs.allowRWA(~isnan(obj.obs.idxAdj) & obj.obs.sigb_priori > 0);

% idxCat of observations as vector
idxCat = obj.obs.idxCat(~isnan(obj.obs.idxAdj) & obj.obs.sigb_priori > 0);

% Indices of constraints
idxCsr = obj.obs.sigb_priori == 0;

% Number of parameters, observations (=condititions) and constraints
nPrm = sum(~isnan(obj.prm.idxAdj));
nObs = sum(~isnan(obj.obs.idxAdj) & obj.obs.sigb_priori > 0);
nCsr = sum(idxCsr);

% Start of main iteration loop -------------------------------------------------

endOfAdj = false; % variable to mark end of adjustment
pAct = true(nObs,1); % multiplicative factor for activation (=true) and deactivation (=false) of observations (only used if RWA is true)
nIt = 0; % initialization of iteration number

while ~endOfAdj

    % Update number of iteration
    nIt = nIt + 1;
    
    % Create weight matrix
    pFacRWA(~pAct) = p.RWApFacOfGrossErrors; % set pFacRWA (weight multiplication factor) to RWApFacOfGrossErrors for detected gross errors
    P = sparse(1:nObs, 1:nObs, pFac .* pFacRWA .* double(p.Sig0_priori^2./sigb_priori.^2), nObs, nObs, nObs);
    
    % No. of observations with nearly zero weight
    nObsZeroWeight = sum(full(diag(P)) == 0);
    
    % Redundancy
    r = nObs + nCsr - nPrm - nObsZeroWeight;
    
    % Get x0, b pre adjustment -------------------------------------------------
    
    % Get x0
    if nIt == 1
        x0{nIt} = obj.prm.x0(  ~isnan(obj.prm.idxAdj));
    else
        x0{nIt} = obj.prm.xhat(~isnan(obj.prm.idxAdj));
    end
    
    % Prepare vector b, b0 and matrix A ----------------------------------------
    
    % Initialization (for A)
    der    = {};
    derRow = {};
    derCol = {};
    
    % For each condition
    for nActCon = 1:numel(con) % number of actual condition
    
        % fprintf(1, 'condition %d of %d\n', nActCon, numel(con));
        
        % Get parameter, constants and observations as structure as input for the condition
        % [prm, cst, obs] = obj.getPrmCstObs(nActCon, nIt);
        [prm, cst, obs] = getPrmCstObs(con{nActCon}, obj.prm, obj.cst, obj.obs, nIt);
        
        % Get function handles from condition function
        [bFun, b0Fun, derFun] = con{nActCon}.fun(prm, cst, obs);

        % Prepare b ------------------------------------------------------------
        
        if nIt == 1; bCell{nActCon} = bFun(obs); end
        
        % Prepare b0 -----------------------------------------------------------

        b0Cell{nActCon} = b0Fun(prm, cst);
        
        % Number of conditions -------------------------------------------------
        
        % Error if lenght of b and b0 is different
        if nIt == 1 % check only in first iteration
            if numel(bCell{nActCon}) ~= numel(b0Cell{nActCon})
                error('Different length of b and b0 for actual condition!');
            end
        end
        
        nCon{nActCon} = numel(b0Cell{nActCon});
        
        % Total no. of conditions
        if nActCon == 1
            nConTotal = nCon{nActCon};
        else
            nConTotal = nConTotal + nCon{nActCon};
        end
        
        % Prepare A ------------------------------------------------------------

        % Names of parameters
        varNames = fields(con{nActCon}.prm);

        % For each parameter
        for n = 1:numel(varNames)

            % Name of selected parameter
            varName = varNames{n};

            % idxAdj of current parameter
            % Note: Length of idxAdj is 1 or nCon. Elements equal to NaN are not
            %       considered for building the A matrix.
            idxAdj = con{nActCon}.idxAdj.prm.(varName);

            % If parameter is not constant
            if any(~isnan(idxAdj))

                % Calculate derivatives of parameters
                der{end+1} = ones(nCon{nActCon},1).*derFun.prm.(varName)(prm, cst); 
             
                % Rows for A matrix
                if nActCon == 1
                    derRow{end+1} = [1:nCon{nActCon}]';
                else
                    % derRow{end+1} = sum(vertcat(nCon{1:nActCon-1})) + [1:nCon{nActCon}]'; % old, very slow
                    derRow{end+1} = (nConTotal-nCon{nActCon}) + [1:nCon{nActCon}]';
                end
                
                % Column for A matrix
                if numel(idxAdj) == 1
                    derCol{end+1} = repmat(idxAdj, nCon{nActCon}, 1);
                elseif numel(idxAdj) == numel(der{end})
                    derCol{end+1} = idxAdj;
                else
                    error(sprintf('idxAdj for condition/constraint=%d and variable=''%s'' has the wrong size!', nActCon, varName));
                end
                
                % Delete derivatives where idxAdj is equal to NaN
                der{end}(   isnan(idxAdj)) = [];
                derRow{end}(isnan(idxAdj)) = [];
                derCol{end}(isnan(idxAdj)) = [];
                
            end

        end

    end

    % Create vector b, b0 and matrix A -----------------------------------------
    
    % b
    if nIt == 1; b = vertcat(bCell{:}); end
    
    % b0
    b0 = vertcat(b0Cell{:});
    
    % A
    derAll = vertcat(der{:});
    derRow = vertcat(derRow{:});
    derCol = vertcat(derCol{:});

    A = sparse(double(derRow), double(derCol), derAll, nObs+nCsr, nPrm, numel(derAll)); % always use sparse function to fill sparse matrices!!!

    % Delete conditions or constraints and observations where all derivatives are zero (happens if all parameters of a condition or constraint are constant)
    con2del = find(sum(A,2) == 0);
    
    % Clear variables with high memory consumption
    clear bCell b0Cell der derAll derRow derCol
    
    % Solving adjustment -------------------------------------------------------
    % Note: general formulation of linear equation system as N*dx = n!
    
    % Bounds for dx, not for xhat!
    lowerBounds = obj.prm.lowerBound(~isnan(obj.prm.idxAdj)) - x0{nIt};
    upperBounds = obj.prm.upperBound(~isnan(obj.prm.idxAdj)) - x0{nIt};
    
    % Consider constraints?
    if nCsr == 0 % no constraints
    
        % Solve adjustment -----------------------------------------------------
        
        % Check singularity
        if p.Rank
            rankA = rank(full(A));
            if rankA < nPrm
                error(sprintf('Singularity detected! (no. of parameters = %d, rank(A) = %d)', nPrm, rankA));
            end
        end
        
        l = b - b0; % gekuerzte Beobachtungen
        
        if all(isinf([lowerBounds; upperBounds])) % if no lower or upper bounds are specified
            
            tic;
            
            % If P is the unit matrix
            if all(diag(P) == 1)
                
                dx = lscov(A, l);
                
            % If P is a diagonal matrix (correlations are not supported (yet))
            else
                
                % lscov is very fast without weights and
                %          very slow with    weights!
                % If P is a diagonal matrix, A and l can be modified, so that
                % P can be ommited. For this: 
                % - each row a_i of A must be multiplied with sqrt(p_ii) and
                % - each element l_i of l must be multiplied with sqrt(p_ii)
                % This leads to Amod and lmod.
                
                % Var 1 -> very, very fast
                fac = sqrt(full(diag(P)));
                [row, col, a] = find(A);
                amod = a.*fac(row);
                Amod = sparse(row, col, amod);
                lmod = l.*fac;
                dx = lscov(Amod, lmod);
                
                % Var 2 -> slower
                % Amod = bsxfun(@times, A, sqrt(full(diag(P))));
                % lmod = bsxfun(@times, l, sqrt(full(diag(P))));
                % dx = lscov(Amod, lmod);
                
                % Control
                % dxControl = lscov(A, l, diag(P));
                % errMax = max(abs(dx-dxControl));
                
            end
            
            t2solve = toc;
            
        else % lower or upper bounds are specified
            
            N = A'*P*A;
            n = A'*P*l;
            tic; dx = lsqlin(N, n, [], [], [], [], lowerBounds, upperBounds); t2solve = toc;
            
        end
        
        % Condition number
        if p.Condition
            condN = cond(full(A'*P*A));
        else
            condN = NaN;
        end
        
    else % with constraints
        
        % Preparations ---------------------------------------------------------
        
        % Save rows with constraints to A2
        A2 = A(idxCsr,:);
        
        % Save elements from b0 with constraints to w
        w = b0(idxCsr);
        
        % Delete rows with constraints b, b0 and matrix A
        if nIt == 1, b(idxCsr) = []; end
        b0(idxCsr) = [];
        A(idxCsr,:) = [];
        
        l = b - b0; % gekuerzte Beobachtungen
        
        % Solve adjustment -----------------------------------------------------
        
        % Check singularity (is it correct to check the rank of A if constraints are present?)
        if p.Rank
            rankA = rank(full(A));
            if rankA < nPrm
                error(sprintf('Singularity detected! (no. of parameters = %d, rank(A) = %d)', nPrm, rankA));
            end
        end
        
        N = [A'*P*A  A2'
             A2      zeros(nCsr)];
         
        n = [A'*P*l
             -w]; % could also be +w (to check if problems occur)

        if all(isinf([lowerBounds; upperBounds]))
        
            tic; dx_minusk = lsqlin(N, n); t2solve = toc;
            dx = dx_minusk(1:nPrm);
            
            % Alternative 1
            % options = optimoptions('lsqlin', 'Algorithm', 'active-set', 'Display', 'iter-detailed');
            % tic; dx = lsqlin(A, l, [], [], A2, -w, [], [], x0{nIt}, options); t2solve = toc; % Attention: P missing here!

            % Alternative 2
            % dx_minusk = N\n;
            % dx = dx_minusk(1:nPrm);
            
        else
            
            tic; dx_minusk = lsqlin(N, n, [], [], [], [], lowerBounds, upperBounds); t2solve = toc;
            dx = dx_minusk(1:nPrm);
            
        end
        
        % Condition number (not jet working)
        if p.Condition
            condN = NaN;
        else
            condN = NaN;
        end
        
    end
    
    % Residuals
    v = A*dx - l;

    % Normalized residuals
    vNorm = v./sigb_priori;
    
    vPv  = full(v'*P*v);
    
    xhat = x0{nIt} + dx;
    bhat = b0 + v;
    
    % Parameters: assign xhat
    obj.prm.xhat(~isnan(obj.prm.idxAdj)) = xhat;

    % Constant parameters: assign x0 as xhat
    if nIt == 1
        obj.prm.xhat(isnan(obj.prm.idxAdj),1) = obj.prm.x0(isnan(obj.prm.idxAdj));
    end
    
    % No. of satisfied constraints
    if nCsr == 0  % no constraints
        nSatisfCsr = NaN;
    else  % with constraints
        nSatisfCsr = sum(abs(A2*xhat) < 1e-10);
    end
    
    % Check convergence criteria -----------------------------------------------
    
    % Get bhat = f(xhat)
    for nActCon = 1:numel(con) % number of actual condition
    
        % Get parameter, observations and constants as structure as input for the condition
        % [prm, cst, obs] = obj.getPrmCstObs(nActCon, nIt+1); % nIt+1 to get xhat instead of x0 in first iteration
        [prm, cst, obs] = getPrmCstObs(con{nActCon}, obj.prm, obj.cst, obj.obs, nIt+1);

        % Get function handles from condition function
        [~, b0Fun] = con{nActCon}.fun(prm, cst, obs);

        bhatCell{nActCon} = b0Fun(prm, cst);
        
    end
    
    bhat = vertcat(bhatCell{:});
    
    if nCsr > 0, bhat(idxCsr) = []; end
    
    % Termination criterion by Kraus 1996, Photogrammetrie Band 2 (page 80)
    lhat = b-bhat;
    epsKraus = abs((lhat'*P*lhat-v'*P*v)/(lhat'*P*lhat));
    
    % Maximal linearization error (see Linearisierungsprobe)
    maxLinError = max(abs(b + v - bhat));
    
    % Convergence reached?
    if (maxLinError < p.MaxTolLin) || (epsKraus < p.MaxEpsKraus)
        conv = true;
    else
        conv = false;
    end

    % Print results to command window ------------------------------------------
    
    if nIt == 1
    
        msg('I', procHierarchy, 'Adjustment overview:');
    
        msg('V', p.Sig0_priori , 'sigma0 a priori'                                                                  , 'Prec', 5);
        msg('V', nObs          , 'number of conditions/observations'                                                , 'Prec', 0);
        msg('V', nCsr          , 'number of constraints'                                                            , 'Prec', 0);
        msg('V', sum(~pAct)    , sprintf('number of detected gross errors (pFacRWA = %.3f)', p.RWApFacOfGrossErrors), 'Prec', 0);
        msg('V', nObsZeroWeight, 'number of conditions/observations with zero weight'                               , 'Prec', 0);
        msg('V', nPrm          , 'number of parameters'                                                             , 'Prec', 0);
        msg('V', r             , 'redundancy'                                                                       , 'Prec', 0);
        if p.Rank
        msg('V', rankA         , 'rank of A'                                                                        , 'Prec', 0); 
        end
        msg('I', procHierarchy, 'Adjustment results:');
        % Print column headers
        msg('T', sprintf('%4s %16s %16s %16s %12s %12s %12s %12s %12s %12s', 'nIt', 'v''Pv', 'norm(dx)', 'norm(v)', 'maxLinError', 'epsKraus', 'converged?', 'cond(N)', 'satisfConstr', 'time2solve'));
        
    end
    
    % Print numerical output
    msg('T', sprintf('%4d %16.8e %16.8e %16.8e %12.4e %12.4e %12.0f %12.4e %12d %11.3fs', nIt, vPv, norm(dx), norm(v), maxLinError, epsKraus, conv, condN, nSatisfCsr, t2solve));
    
    % Worst normalized residuals -----------------------------------------------

    % If adjustment converged
    if conv
        
        % Report worst active observations -------------------------------------
        
        [~, idx] = sort(abs(vNorm), 'descend');
        
        % Remove indices of not active observations
        idx = setdiff(idx, find(~pAct), 'stable');
        
        % Number of normalized residuals exceeding limit
        n = sum(abs(vNorm(idx)) >= p.RWAMaxSig);
        
        % Maximum no. of reported observations
        nMax = 100; % default
        if n < nMax, nMax = n; end
        
        msg('I', procHierarchy, sprintf('%d (out of %d = %.2f%%) worst *active* observations with normalized residuals vNorm >= %.1f:', nMax, n, n/nObs*100, p.RWAMaxSig));
        
        if n > 0
            msg('T', sprintf('%4s %8s %12s %12s %12s %12s %12s %12s %12s %12s', 'i', 'idxAdj', 'vNorm', 'v', 'sigb', 'b', 'bhat', 'pFac', 'pFacRWA', 'allowRWA'));
            for i = 1:nMax
                msg('T', sprintf('%4d %8d %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12d', i, idx(i), abs(vNorm(idx(i))), v(idx(i)), sigb_priori(idx(i)), b(idx(i)), bhat(idx(i)), pFac(idx(i)), pFacRWA(idx(i)), allowRWA(idx(i))));
            end
        else
            msg('I', procHierarchy, '-> None!');
        end

        % Report worst non active observations ---------------------------------
        
        [~, idx] = sort(abs(vNorm), 'descend');
        
        % Remove indices of active observations
        idx = setdiff(idx, find(pAct), 'stable');
        
        % Number of non active observations
        n = numel(idx); % or sum(~pAct)
        
        % Maximum no. of reported observations
        nMax = 100; % default
        if n < nMax, nMax = n; end
        
        msg('I', procHierarchy, sprintf('%d (out of %d = %.2f%%) worst *non active* observations:', nMax, n, n/nObs*100));
        
        if n > 0
            msg('T', sprintf('%4s %8s %12s %12s %12s %12s %12s %12s %12s %12s', 'i', 'idxAdj', 'vNorm', 'v', 'sigb', 'b', 'bhat', 'pFac', 'pFacRWA', 'allowRWA'));
            for i = 1:nMax
                msg('T', sprintf('%4d %8d %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12d', i, idx(i), abs(vNorm(idx(i))), v(idx(i)), sigb_priori(idx(i)), b(idx(i)), bhat(idx(i)), pFac(idx(i)), pFacRWA(idx(i)), allowRWA(idx(i))));
            end
        else
            msg('I', procHierarchy, '-> None!');
        end

    end
    
    % One more iteration? ------------------------------------------------------
    
    if conv || (nIt == p.MaxIt)
        
        if p.RobustWeightAdaption
            
            % Number of robust iteration
            if ~exist('nRobAdj')
                nRobAdj = 1;
            else
                nRobAdj = nRobAdj + 1;
            end
            
            % If there are any gross errors
            if max(abs(vNorm(pAct))) > p.RWAMaxSig && nRobAdj <= p.RWAMaxIt
                
                % Info
                if nRobAdj == 1
                    additionalInfo = '(with adapted weights)';
                else
                    additionalInfo = '(with adapted weights and without detected gross errors)';
                end
                msg('I', procHierarchy, sprintf('Start of new adjustment: robust weight adaption no. %d %s.', nRobAdj, additionalInfo));
            
                % Start new adjustment
                nIt = 0;
                
                % Weight function parameters
                hw(nRobAdj) = max(abs(vNorm(pAct))); % half weight
                aRob = 1/hw(nRobAdj);
                bRob = p.RWASlant;

                % Weight multiplication factor
                pFacRWA = 1 ./ ( 1 + (aRob .* abs(vNorm)) ).^bRob;
                pFacRWA(~allowRWA) = 1;
                 
                % Elimination of gross errors
                if nRobAdj > 1
                    
                    % Sort by vNorm
                    [~, idx] = sort(abs(vNorm));
                    
                    % Deactivate RWAPoi2RemovePerIt observations with highest vNorm
                    pAct = true(nObs,1);
                    if isinf(p.RWAPoi2RemovePerIt) || p.RWAPoi2RemovePerIt > numel(pAct)
                        pAct(:) = false;
                    else
                        pAct(idx(end-(nRobAdj-1)*p.RWAPoi2RemovePerIt+1:end)) = false;
                    end
                    
                    % Reactivate observations below threshold RWAMaxSig
                    pAct(abs(vNorm) <= p.RWAMaxSig) = true;
                   
                    % Reactivate observations for which RWA is not enabled
                    pAct(~allowRWA) = true;
                    
                end

            else
                
                % Use results of first adjustment
                if nRobAdj == 1
                    
                    endOfAdj = true;
                    
                % Final adjustment
                else
                
                    msg('I', procHierarchy, sprintf('Start of final adjustment.', nRobAdj));
                    
                    % Start new adjustment
                    nIt = 0;
                    
                    pFacRWA = ones(nObs,1);
                    p.RobustWeightAdaption = false;
                    
                end
                
            end
            
        else
        
            endOfAdj = true;
            
        end
        
    end
        
end

% Save further results to object -----------------------------------------------

obj.obs.res(~idxCsr) = v;
obj.obs.pFacRWA(~idxCsr) = pFacRWA;

% Stochastic a posteriori ------------------------------------------------------

msg('S', {'LSADJ' 'SOLVE' 'A POSTERIORI STOCHASTIC'});

% Sigma0 a posteriori
sig0_post = sqrt(vPv/r);

% Residuals
std_v  = std(v);
mean_v = mean(v);

std_vp  = std(v.*full(diag(P)));
mean_vp = mean(v.*full(diag(P)));

std_vWithoutGrossErrors = std(v(pFacRWA~=p.RWApFacOfGrossErrors));
mean_vWithoutGrossErrors = mean(v(pFacRWA~=p.RWApFacOfGrossErrors));

% Cxx
if p.Cxx
    
    % Consider constraints?
    if nCsr == 0 % no constraints
    
        Qxx = full(inv(A'*P*A));
        
    else % with constraints
        
        invN = full(inv(N));
        Qxx = invN(1:nPrm,1:nPrm);
        
    end
    
    Cxx = sig0_post^2 * Qxx;

    Cxx = triu(Cxx) + triu(Cxx,1)'; % make Cxx symmetric! (check: triu(Cxx) + triu(Cxx,1)' - Cxx)
    [Rxx, sig] = corrcov(Cxx); % Rxx...correlation matrix, sig = sqrt(diag(Cxx))
    
    % Assign sig to parameter
    obj.prm.sig(~isnan(obj.prm.idxAdj)) = sqrt(diag(Cxx));
    
end

msg('V', sig0_post               , 'sigma0 a posteriori'           , 'Prec', 7);
msg('V', std_v                   , 'std(v)'                        , 'Prec', 7);
msg('V', mean_v                  , 'mean(v)'                       , 'Prec', 7);
msg('V', std_vWithoutGrossErrors , 'std(v)  (without gross errors)', 'Prec', 7);
msg('V', mean_vWithoutGrossErrors, 'mean(v) (without gross errors)', 'Prec', 7);

% Report statistics for each observation category
msg('S', {'LSADJ' 'SOLVE' 'A POSTERIORI STOCHASTIC' 'OBSERVATION CATEGORIES'});
for c = 1:numel(obj.obs.category)
    msg('T', sprintf('CATEGORY %d: ''%s''', c, obj.obs.category{c}));
    msg('V', sum(idxCat==c)                                      , 'number of observations'         , 'Prec', 0);
    msg('V', std( v(idxCat==c))                                  , 'std(v)'                         , 'Prec', 7);
    msg('V', mean(v(idxCat==c))                                  , 'mean(v)'                        , 'Prec', 7);
    msg('V', sum(idxCat==c & pFacRWA==p.RWApFacOfGrossErrors)    , 'number of detected gross errors', 'Prec', 0);
    msg('V', std( v(idxCat==c & pFacRWA~=p.RWApFacOfGrossErrors)), 'std(v)  (without gross errors)' , 'Prec', 7);
    msg('V', mean(v(idxCat==c & pFacRWA~=p.RWApFacOfGrossErrors)), 'mean(v) (without gross errors)' , 'Prec', 7);
end
msg('E', {'LSADJ' 'SOLVE' 'A POSTERIORI STOCHASTIC' 'OBSERVATION CATEGORIES'});

msg('E', {'LSADJ' 'SOLVE' 'A POSTERIORI STOCHASTIC'});

% Save adjustment results to object --------------------------------------------

obj.obs.bhat(~isnan(obj.obs.idxAdj) & ~idxCsr) = bhat;

obj.res.nPrm      = nPrm;
obj.res.nObs      = nObs;
obj.res.nCsr      = nCsr;

obj.res.nIt       = nIt;
obj.res.vPv       = vPv;
obj.res.x0        = x0{1}; % from first iteration
obj.res.xhat      = xhat;

obj.res.sig0_post = sig0_post;
% obj.res.rms_v     = rms_v;
obj.res.std_v     = std_v;
obj.res.mean_v    = mean_v;
obj.res.condN     = condN;

obj.res.std_vWithoutGrossErrors = std_vWithoutGrossErrors;
obj.res.mean_vWithoutGrossErrors = mean_vWithoutGrossErrors;

% Output parameters results ----------------------------------------------------

if any(obj.prm.report)

    msg('I', procHierarchy, 'Parameters results:');
    msg('T', sprintf('%8s %6s %16s %16s %16s %7s %5s  %s', 'idx', ...
                                                           'const', ...
                                                           'x0', ...
                                                           'xhat', ...
                                                           'sig(xhat)', ...
                                                           'scale', ...
                                                           'idx', ...
                                                           'label'));

    for i = 1:numel(obj.prm.x0)

        if obj.prm.report(i)
            
            if ~isnan(obj.prm.idxAdj(i)) % report only estimated parameters

                msg('T', sprintf('%8d %6d %16.5f %16.5f %16.5f %7.2f %5d  %s', obj.prm.idxAdj(i), ...
                                                                               obj.prm.const(i), ...
                                                                               obj.prm.x0(i)   * obj.prm.scale4report(i), ...
                                                                               obj.prm.xhat(i) * obj.prm.scale4report(i), ...
                                                                               obj.prm.sig(i)  * obj.prm.scale4report(i), ...
                                                                               obj.prm.scale4report(i), ...
                                                                               obj.prm.idxAdj(i), ...
                                                                               obj.prm.label{i}));
                                                                           
            end
                                                                       
        end

    end

end
    
% Output parameters correlations -----------------------------------------------

if p.Cxx
    
    if nPrm >= 6
   
        msg('I', procHierarchy, 'Parameters correlations:');
        msg('I', procHierarchy, 'Note: for each parameter the five highest correlations (r1...r5) are reported (format is idx : r).');

        msg('T', sprintf('%5s %14s %14s %14s %14s %14s %5s  %s', 'idx', 'r1', 'r2', 'r3', 'r4', 'r5', 'idx', 'label'));

        allLabels = obj.prm.label(~isnan(obj.prm.idxAdj));

        for i = 1:size(Cxx,1)

            [~, idxSort] = sort(abs(Rxx(i,:)), 'descend');

            idxSort(idxSort == i) = [];

            msg('T', sprintf('%5d %14s %14s %14s %14s %14s %5d  %s', i, ...
                                                                     sprintf('%4d : %+.3f', idxSort(1), Rxx(i,idxSort(1))), ...
                                                                     sprintf('%4d : %+.3f', idxSort(2), Rxx(i,idxSort(2))), ...
                                                                     sprintf('%4d : %+.3f', idxSort(3), Rxx(i,idxSort(3))), ...
                                                                     sprintf('%4d : %+.3f', idxSort(4), Rxx(i,idxSort(4))), ...
                                                                     sprintf('%4d : %+.3f', idxSort(5), Rxx(i,idxSort(5))), ...
                                                                     i, ...
                                                                     allLabels{i}));

        end
        
    end
    
end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end