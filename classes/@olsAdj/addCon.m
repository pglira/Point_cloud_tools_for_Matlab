function obj = addCon(obj, varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParamValue('fun', []);
p.addParamValue('prm', []);
p.addParamValue('obs', []);
p.addParamValue('cst', []);
p.parse(varargin{:});
p = p.Results;

% Add constraint to problem ----------------------------------------------------

obj.con = [obj.con; p];

end