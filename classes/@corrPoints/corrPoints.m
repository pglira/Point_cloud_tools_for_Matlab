classdef corrPoints < handle
% CORRPOINTS Class for corresponding points.

    properties
        % Attributes of point cloud 1
        A1
        
        % Attributes of point cloud 2
        A2
        
        % Attributes of correspondences
        A
        
        % Label
        label
    end
    
    properties (SetAccess = private)
        % Index of point cloud 1
        pc1id
        
        % Index of point cloud 2
        pc2id
        
        % Points from point cloud 1
        X1
        
        % Points from point cloud 2
        X2
        
        % Indices of corresponding points refering to input point cloud 1
        idxPC1
        
        % Indices of corresponding points refering to input point cloud 2
        idxPC2
        
        % Angle between corresponding normals
        dAlpha
        
        % Euclidean distance between corresponding points
        ds
        
        % Point to tangent plane distance
        dp
        
        % Number of corresponding points
        noCP
    end

% ------------------------------------------------------------------------------
    
    methods
        
        function obj = corrPoints(pc1id, pc2id, varargin)
        
        % Input parsing --------------------------------------------------------

        p = inputParser;
        p.addRequired( 'pc1id', @isnumeric);
        p.addRequired( 'pc2id', @isnumeric);
        p.addParameter('Label', '', @ischar);
        p.parse(pc1id, pc2id, varargin{:});
        p = p.Results;
        % Clear required inputs to avoid confusion
        clear pc1id pc2id

        % Start ----------------------------------------------------------------
        
        procHierarchy = {'CORRPOINTS' 'CREATE'};
        msg('S', procHierarchy);
        
        % Create object --------------------------------------------------------
        
        obj.pc1id = p.pc1id;
        obj.pc2id = p.pc2id;
        
        % Label ----------------------------------------------------------------
        
        if isempty(p.Label)
            obj.label = sprintf('CP between PC [%d] and PC [%d]', p.pc1id, p.pc2id);
        else
            obj.label = p.Label;
        end
        
        % End ------------------------------------------------------------------
        
        msg('I', procHierarchy, sprintf('Corr. points label = ''%s''', obj.label));
        msg('E', procHierarchy);
            
        end
        
        % ----------------------------------------------------------------------

        function dAlpha = get.dAlpha(obj)
        % DALPHA Get angle between corresponding normals.

        n1 = [obj.A1.nx obj.A1.ny obj.A1.nz];
        n2 = [obj.A2.nx obj.A2.ny obj.A2.nz];
        dAlpha = angVector(n1, n2);
   
        end
        
        % ----------------------------------------------------------------------

        function ds = get.ds(obj)
        % DS Get euclidean distance between corresponding points.

        ds = dist(obj.X1, obj.X2);
            
        end
        
        % ----------------------------------------------------------------------

        function dp = get.dp(obj)
        % DP Get point to tangent plane distance.

        if size(obj.X1,1) > 0 && isfield(obj.A1, 'nx') % only if correspondences and normals are present

            n1 = [obj.A1.nx obj.A1.ny obj.A1.nz];

            dp = dot(obj.X1-obj.X2, n1, 2);

        else

            dp = NaN;

        end
            
        end
        
        % ----------------------------------------------------------------------

        function noCP = get.noCP(obj)
        % NOCP Get number of corresponding points.
            
        noCP = size(obj.X1,1);
            
        end
        
    end
    
end