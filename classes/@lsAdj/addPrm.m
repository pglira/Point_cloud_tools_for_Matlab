function idxPrm = addPrm(obj, varargin)
% ADDPRM Add parameter(s) to problem

% Fields of prm structure
% - x0           -> mandatory
% - xhat         -> NaN
% - sig          -> NaN
% - const        -> can be omitted
% - idxAdj       -> NaN
% - lowerBound   -> can be omitted
% - upperBound   -> can be omitted
% - scale4report -> can be omitted
% - report       -> can be omitted
% - label        -> can be omitted

prm2add = paramvalue2struct(varargin{:}); % create struct

noPrm2add = numel(prm2add.x0); % no. of parameters to add

% Add default values if not specified
if ~isfield(prm2add, 'const'       ), prm2add.const        = false(       noPrm2add, 1); end
if ~isfield(prm2add, 'lowerBound'  ), prm2add.lowerBound   = repmat(-Inf, noPrm2add, 1); end
if ~isfield(prm2add, 'upperBound'  ), prm2add.upperBound   = repmat(+Inf, noPrm2add, 1); end
if ~isfield(prm2add, 'scale4report'), prm2add.scale4report = ones(        noPrm2add, 1); end
if ~isfield(prm2add, 'report'      ), prm2add.report       = true(        noPrm2add, 1); end
if ~isfield(prm2add, 'label'       ), prm2add.label        = repmat({''}, noPrm2add, 1); end

% Default values
prm2add.xhat   = NaN(noPrm2add,1);
prm2add.sig    = NaN(noPrm2add,1);
prm2add.idxAdj = NaN(noPrm2add,1);

% Add observations with 'direct indexing' (faster than other methods)
% Indices
if isempty(obj.prm)
    idxPrm2add = 1:noPrm2add;
else
    noPrm = numel(obj.prm.x0); % actual no. of parameters
    idxPrm2add = noPrm+1:noPrm+noPrm2add;
end

% Add
obj.prm.x0(          idxPrm2add,1) = prm2add.x0;
obj.prm.xhat(        idxPrm2add,1) = prm2add.xhat;
obj.prm.sig(         idxPrm2add,1) = prm2add.sig;
obj.prm.const(       idxPrm2add,1) = prm2add.const;
obj.prm.idxAdj(      idxPrm2add,1) = prm2add.idxAdj;
obj.prm.lowerBound(  idxPrm2add,1) = prm2add.lowerBound;
obj.prm.upperBound(  idxPrm2add,1) = prm2add.upperBound;
obj.prm.scale4report(idxPrm2add,1) = prm2add.scale4report;
obj.prm.report(      idxPrm2add,1) = prm2add.report;
obj.prm.label(       idxPrm2add,1) = prm2add.label;

% Indices of observations
idxPrm = uint32(idxPrm2add)';

% % Input parsing ----------------------------------------------------------------
%
% p = inputParser;
% p.addParamValue('x0'          , NaN  , @(x) size(x,2)==1);
% p.addParamValue('const'       , false, @(x) islogical(x) && size(x,2)==1);
% p.addParamValue('lowerBound'  , -Inf , @(x) isnumeric(x) && size(x,2)==1);
% p.addParamValue('upperBound'  , +Inf , @(x) isnumeric(x) && size(x,2)==1);
% p.addParamValue('scale4report', 1    , @(x) isnumeric(x) && size(x,2)==1);
% p.addParamValue('label'       , {''} , @iscell);
% p.parse(varargin{:});
% p = p.Results;
% 
% % Add parameter(s) to problem --------------------------------------------------
%
% if numel(p.const)        == 1, p.const        = repmat(p.const       , numel(p.x0), 1); end
% if numel(p.lowerBound)   == 1, p.lowerBound   = repmat(p.lowerBound  , numel(p.x0), 1); end
% if numel(p.upperBound)   == 1, p.upperBound   = repmat(p.upperBound  , numel(p.x0), 1); end
% if numel(p.scale4report) == 1, p.scale4report = repmat(p.scale4report, numel(p.x0), 1); end
% if numel(p.label)        == 1, p.label        = repmat(p.label       , numel(p.x0), 1); end
% 
% xhat   = NaN(numel(p.x0), 1);
% sig    = NaN(numel(p.x0), 1);
% idxAdj = NaN(numel(p.x0), 1);
% 
% prm2add = table(                  p.x0, xhat  , sig  , p.const, idxAdj  , p.lowerBound, p.upperBound, p.scale4report, p.label, ...
%                 'VariableNames', {'x0', 'xhat', 'sig', 'const', 'idxAdj', 'lowerBound', 'upperBound', 'scale4report', 'label'});
% 
% obj.prm = [obj.prm; prm2add];
% 
% idxPrm = uint32([height(obj.prm)-height(prm2add)+1 : height(obj.prm)]');

end