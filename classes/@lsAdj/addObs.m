function idxObs = addObs(obj, varargin)
% ADDOBS Add observation(s) to problem

% Fields of obs structure
% - b           -> can be omitted (for constraints)
% - bhat        -> NaN
% - sigb_priori -> mandatory
% - res         -> NaN
% - pFac        -> can be omitted
% - pFacRWA     -> can be omitted
% - allowRWA    -> can be omitted
% - idxAdj      -> NaN
% - cat         -> can be omitted (default = 0)

obs2add = paramvalue2struct(varargin{:}); % create struct

noObs2add = numel(obs2add.sigb_priori); % no. of observations to add

% Add default values if not specified
if ~isfield(obs2add, 'b'       ), obs2add.b        = NaN(noObs2add, 1); end
if ~isfield(obs2add, 'pFac'    ), obs2add.pFac     = ones(noObs2add, 1); end
if ~isfield(obs2add, 'pFacRWA' ), obs2add.pFacRWA  = ones(noObs2add, 1); end
if ~isfield(obs2add, 'allowRWA'), obs2add.allowRWA = true(noObs2add, 1); end
if ~isfield(obs2add, 'category'), obs2add.category = 'other observations'; end
    
% Default values
obs2add.bhat   = NaN(noObs2add,1);
obs2add.res    = NaN(noObs2add,1);
obs2add.idxAdj = NaN(noObs2add,1);

% Add observations with 'direct indexing' (faster than other methods)
if isempty(obj.obs)
    
    % Indices of observations
    idxObs2add = 1:noObs2add;
    
    % Category 1. part
    idxCat = 1;
    obj.obs.category{idxCat} = obs2add.category;
    
else
    
    % Indices of observations
    noObs = numel(obj.obs.b); % actual no. of observations
    idxObs2add = noObs+1:noObs+noObs2add;
    
    % Category 1. part
    idxCat = find(strcmpi(obs2add.category, obj.obs.category));
    if isempty(idxCat)
        idxCat = numel(obj.obs.category)+1;
        obj.obs.category{idxCat} = obs2add.category;
    end
    
end

% Category 2. part
obs2add = rmfield(obs2add, 'category');
obs2add.idxCat = uint16(ones(noObs2add,1).*idxCat);

% Add
obj.obs.b(          idxObs2add,1) = obs2add.b;
obj.obs.bhat(       idxObs2add,1) = obs2add.bhat;
obj.obs.sigb_priori(idxObs2add,1) = obs2add.sigb_priori;
obj.obs.res(        idxObs2add,1) = obs2add.res;
obj.obs.pFac(       idxObs2add,1) = obs2add.pFac;
obj.obs.pFacRWA(    idxObs2add,1) = obs2add.pFacRWA;
obj.obs.allowRWA(   idxObs2add,1) = obs2add.allowRWA;
obj.obs.idxAdj(     idxObs2add,1) = obs2add.idxAdj;
obj.obs.idxCat(     idxObs2add,1) = obs2add.idxCat;

% Indices of observations
idxObs = uint32(idxObs2add)';

end