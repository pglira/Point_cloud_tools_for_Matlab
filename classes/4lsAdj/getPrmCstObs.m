function [prm, cst, obs] = getPrmCstObs(actCon, prmIn, cstIn, obsIn, nIt)

% All types of design variables
varTypes = {'prm' 'cst' 'obs'};

% For each type of design variable
for i = 1:numel(varTypes)

    % Selection of variable type (prm, cst or obs)
    varType = varTypes{i};

    % If for the actual varType values are present
    if ~isempty(actCon.(varType))
    
        % Names of design variable groups for selected variable type
        varNames = fields(actCon.(varType));

        % For each design variable group
        for n = 1:numel(varNames)

            % Name of selected design variable group
            varName = varNames{n};

            % Parameter, constant or observation?
            switch varType

                case 'prm'

                    % Get parameter values for selected design variable group
                    if nIt == 1, x0_or_xhat = 'x0'; else x0_or_xhat = 'xhat'; end
                    prm.(varName) = prmIn.(x0_or_xhat)(actCon.(varType).(varName));
                    
                case 'cst'

                    % Get constant values for selected design variable group
                    cst.(varName) = cstIn(actCon.(varType).(varName));
                    
                case 'obs'
                    
                    % Get observation values for selected design variable group
                    obs.(varName) = obsIn.b(actCon.(varType).(varName));

            end

        end
    
    % If for the actual varType NO values are present
    else
        
        switch varType
            
            case 'prm'
                
                prm = [];
                
            case 'cst'
                
                cst = [];
                
            case 'obs'
                
                obs = [];
                
        end
    
    end

end

end