function [obj, idxPrm] = addPrm(obj, varargin)
      
% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParamValue('x0'          , NaN  , @(x) size(x,2)==1);
p.addParamValue('const'       , false, @(x) islogical(x) && size(x,2)==1);
p.addParamValue('lowerBound'  , -Inf , @(x) isnumeric(x) && size(x,2)==1);
p.addParamValue('upperBound'  , +Inf , @(x) isnumeric(x) && size(x,2)==1);
p.addParamValue('scale4report', 1    , @(x) isnumeric(x) && size(x,2)==1);
p.addParamValue('label'       , {''} , @iscell);
p.parse(varargin{:});
p = p.Results;

% Add parameter(s) to problem --------------------------------------------------

if numel(p.const)        == 1, p.const        = repmat(p.const       , numel(p.x0), 1); end
if numel(p.lowerBound)   == 1, p.lowerBound   = repmat(p.lowerBound  , numel(p.x0), 1); end
if numel(p.upperBound)   == 1, p.upperBound   = repmat(p.upperBound  , numel(p.x0), 1); end
if numel(p.scale4report) == 1, p.scale4report = repmat(p.scale4report, numel(p.x0), 1); end
if numel(p.label)        == 1, p.label        = repmat(p.label       , numel(p.x0), 1); end

xhat   = NaN(numel(p.x0), 1);
sig    = NaN(numel(p.x0), 1);
idxAdj = NaN(numel(p.x0), 1);

prm2add = table(                  p.x0, xhat  , sig  , p.const, idxAdj  , p.lowerBound, p.upperBound, p.scale4report, p.label, ...
                'VariableNames', {'x0', 'xhat', 'sig', 'const', 'idxAdj', 'lowerBound', 'upperBound', 'scale4report', 'label'});

obj.prm = [obj.prm; prm2add];

idxPrm = uint32([height(obj.prm)-height(prm2add)+1 : height(obj.prm)]');

end