classdef olsAdj
% OLSADJ Class for ordinary least squares adjustments.

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
        
    end
    
    methods
        
        function obj = olsAdj
    
            % Initialization of table for parameters
            obj.prm = table(                  []  , []    , []   , logical([]), []      , []          , []          , []            , [], ...
                            'VariableNames', {'x0', 'xhat', 'sig', 'const'    , 'idxAdj', 'lowerBound', 'upperBound', 'scale4report', 'label'});
                        
            % Initialization of table for observations
            obj.obs = table(                  [] , []    , []           , []   , []    , []       , []        , [], ...
                            'VariableNames', {'b', 'bhat', 'sigb_priori', 'res', 'pFac', 'pFacRWA', 'allowRWA', 'idxAdj'});
                        
            % Initialization of table for constants
            obj.cst = table([], 'VariableNames', {'v'});
      
        end
    
    end
    
end