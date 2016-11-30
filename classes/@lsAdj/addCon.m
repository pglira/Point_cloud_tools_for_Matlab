function obj = addCon(obj, varargin)
% ADDCON Add condition/constraint to problem

con2add = struct(varargin{:}); % create struct

% Add default values if not specified
if ~isfield(con2add, 'cst'), con2add.cst = []; end % cst may be not defined

% Note: accessing obj.con is very slow (e.g. numel(obj.con)), thus a persistent 
% variable (idxCon2add) holds the value of the next condition/constraint.

% Add condition/constraint with 'direct indexing' (faster than other methods)
% Index
persistent idxCon2add % index of new condition/constraint
if isempty(idxCon2add), idxCon2add = 1; end % initialize

% Add
obj.con{idxCon2add,1} = con2add;

idxCon2add = idxCon2add + 1;

end