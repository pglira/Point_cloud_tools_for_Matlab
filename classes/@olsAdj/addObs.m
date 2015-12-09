function [obj, idxObs] = addObs(obj, varargin)
      
% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParamValue('b'          , NaN , @(x) size(x,2)==1);
p.addParamValue('sigb_priori', NaN , @(x) size(x,2)==1);
p.addParamValue('pFac'       , 1   , @(x) size(x,2)==1);
p.addParamValue('pFacRWA'    , 1   , @(x) size(x,2)==1);
p.addParamValue('allowRWA'   , true, @islogical);
p.parse(varargin{:});
p = p.Results;

% Add observation(s) to problem ------------------------------------------------

if numel(p.sigb_priori) == 1, p.sigb_priori = repmat(p.sigb_priori, numel(p.b), 1); end
if numel(p.pFac)        == 1, p.pFac        = repmat(p.pFac       , numel(p.b), 1); end
if numel(p.pFacRWA)     == 1, p.pFacRWA     = repmat(p.pFacRWA    , numel(p.b), 1); end
if numel(p.allowRWA)    == 1, p.allowRWA    = repmat(p.allowRWA   , numel(p.b), 1); end

bhat   = NaN(numel(p.b), 1);
res    = NaN(numel(p.b), 1);
idxAdj = NaN(numel(p.b), 1);

obs2add = table(                 p.b , bhat  , p.sigb_priori, res  , p.pFac, p.pFacRWA, p.allowRWA, idxAdj, ...
                'VariableNames', {'b', 'bhat', 'sigb_priori', 'res', 'pFac', 'pFacRWA', 'allowRWA', 'idxAdj'});

obj.obs = [obj.obs; obs2add];

idxObs = uint32([height(obj.obs)-height(obs2add)+1 : height(obj.obs)]');

end