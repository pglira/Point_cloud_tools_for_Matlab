function obj = assignIdxAdj(obj, varargin)

% Start ------------------------------------------------------------------------

% Create a copy of con structure (as accessing obj.con is unbelievable slow!!!)
con = obj.con;

% Find all non constant parameters and observations defined in constraints -----
% Note: only parameters and observation which are part of a constraint, get 
% an adjustment index (i.e. are considered in the adjustment)

% For each defined constraint
for i = 1:numel(con)
    
    % For both types of design variables
    for varTypes = {'prm' 'obs'}

        % Selection of variable type (prm or obs)
        varType = varTypes{1};

        % Names of design variable groups for selected variable type
        varNames = fields(con{i}.(varType));

        % For each design variable group
        for n = 1:numel(varNames)

            % Name of design variable group
            varName = varNames{n};

            % Defined indices of parameter or observation structure
            idxAll = con{i}.(varType).(varName);

            % Save all non constant indices in cell
            switch varType
                case 'prm'

                    % Mask to remove all constant indices
                    isConst = [obj.(varType).const(idxAll)]';

                    % Indices of all non constant parameters used in actual condition
                    idxPrm{i,n} = idxAll(~isConst);

                case 'obs'

                    % Indices of all observations used in actual condition
                    idxObs{i,n} = idxAll;
            end

        end

    end

end

% Assign idxAdj to parameter and observation table -----------------------------

% Unique indices
idxUniquePrm = unique(vertcat(idxPrm{:}));
idxUniqueObs = unique(vertcat(idxObs{:}));

% Assign idxAdj
obj.prm.idxAdj(idxUniquePrm) = [1:numel(idxUniquePrm)]';
obj.obs.idxAdj(idxUniqueObs) = [1:numel(idxUniqueObs)]';

% Save idxAdj in condition structure -------------------------------------------

% For each defined constraint
for i = 1:numel(con)
    
    % For both types of design variables
    for varTypes = {'prm' 'obs'}
                   
        % Selection of variable type (prm or obs)
        varType = varTypes{1};
        
        % Names of design variable groups for selected variable type
        varNames = fields(con{i}.(varType));

        % For each design variable group
        for n = 1:numel(varNames)

            % Name of design variable group
            varName = varNames{n};

            % Defined indices of parameter or observation structure
            idxAll = con{i}.(varType).(varName);

            % Save idxAdj in constraint structure
            con{i}.idxAdj.(varType).(varName) = obj.(varType).idxAdj(idxAll);

        end

    end
    
end

% End --------------------------------------------------------------------------

% Copy back con structure to object
obj.con = con;

end