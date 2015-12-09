function [obj, idxCst] = addCst(obj, varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParamValue('v', NaN, @(x) size(x,2)==1);
p.parse(varargin{:});
p = p.Results;

% Add constant(s) to problem ---------------------------------------------------

cst2add = table(p.v, 'VariableNames', {'v'});

obj.cst = [obj.cst; cst2add];

idxCst = uint32([height(obj.cst)-height(cst2add)+1 : height(obj.cst)]');

end