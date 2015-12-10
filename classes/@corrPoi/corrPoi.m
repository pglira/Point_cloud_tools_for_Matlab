classdef corrPoi
% CORRPOI Class for corresponding points.

    properties
        % Attributes of point cloud 1
        A1
        
        % Attributes of point cloud 2
        A2
        
        % Attributes of correspondences
        A
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
    end

% ------------------------------------------------------------------------------
    
    methods
        
        function obj = corrPoi(pc1id, pc2id)
        
        % Input parsing --------------------------------------------------------

        p = inputParser;
        p.addRequired('pc1id', @isnumeric);
        p.addRequired('pc2id', @isnumeric);
        p.parse(pc1id, pc2id);
        p = p.Results;
        % Clear required inputs to avoid confusion
        clear pc1id pc2id

        % Start ----------------------------------------------------------------
        
        procHierarchy = {'CORRPOI' 'CREATE'};
        msg('S', procHierarchy);
        msg('I', procHierarchy, sprintf('IN: pc1id = %d', p.pc1id));
        msg('I', procHierarchy, sprintf('IN: pc2id = %d', p.pc2id));
        
        % Create class ---------------------------------------------------------
        
        obj.pc1id = p.pc1id;
        obj.pc2id = p.pc2id;
        
        % End ------------------------------------------------------------------
        
        msg('E', procHierarchy);
            
        end
        
% ------------------------------------------------------------------------------

        function dAlpha = get.dAlpha(obj)
        % DALPHA Get angle between corresponding normals.

            n1 = [obj.A1.nx obj.A1.ny obj.A1.nz];
            n2 = [obj.A2.nx obj.A2.ny obj.A2.nz];
            dAlpha = angVector(n1, n2);
   
        end
        
% ------------------------------------------------------------------------------

        function ds = get.ds(obj)
        % DS Get euclidean distance between corresponding points.

            ds = dist(obj.X1, obj.X2);
            
        end
        
% ------------------------------------------------------------------------------

        function dp = get.dp(obj)
        % DP Get point to tangent plane distance.

            if size(obj.X1,1) > 0 && isfield(obj.A1, 'nx') % only if correspondences and normals are present

                n1 = [obj.A1.nx obj.A1.ny obj.A1.nz];

                dp = dot(obj.X1-obj.X2, n1, 2);
                
            else
                
                dp = NaN;
                
            end
            
        end
        
    end
    
end