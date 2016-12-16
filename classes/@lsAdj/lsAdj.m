classdef lsAdj < handle
% LSADJ Class for least squares adjustments.

    properties
        % Conditions
        con
        
        % Constants
        cst
        
        % Parameters
        prm
        
        % Observations
        obs
        
        % Adjustment results
        res
        
        % Structure for saving the indices of parameters
        idxPrm
        
        % User data
        U
    end
    
    methods
        
        function obj = lsAdj
            
            % Initialization of table for parameters
            % obj.prm = table(                  []  , []    , []   , logical([]), []      , []          , []          , []            , [], ...
            %                 'VariableNames', {'x0', 'xhat', 'sig', 'const'    , 'idxAdj', 'lowerBound', 'upperBound', 'scale4report', 'label'});
                        
            % Clear persistent variables (done by clearing the function itself)
            clear addCon % clears all persistent variables in function addCon
            
        end
    
    end
    
end