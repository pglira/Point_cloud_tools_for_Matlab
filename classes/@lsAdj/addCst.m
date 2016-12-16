function idxCst = addCst(obj, cst2add)
% ADDCST Add constant(s) to problem

noCst2add = numel(cst2add); % no. of constants to add

% Add constants with 'direct indexing' (faster than other methods)
% Indices
if isempty(obj.cst)
    idxCst2add = 1:noCst2add;
else
    noCst = numel(obj.cst); % actual no. of constants
    idxCst2add = noCst+1:noCst+noCst2add;
end

% Add
obj.cst(idxCst2add,1) = cst2add;

% Indices of constants
idxCst = uint32(idxCst2add)';

end