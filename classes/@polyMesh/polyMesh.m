classdef polyMesh
% POLYMESH Class for 3d polygon meshes.

    properties (SetAccess = public, GetAccess = public)
        % Vertices
        vertices
        
        % Faces
        faces
    end

% ------------------------------------------------------------------------------
    
    methods
        
        function obj = polyMesh(meshData)
        % POLYMESH Import of mesh data.
        % ----------------------------------------------------------------------
        % INPUT
        % [meshData]
        % Mesh input data as ply file. Currently no other formats are
        % supported.
        % ----------------------------------------------------------------------
        % OUTPUT
        % [obj]
        % Object instance of class polyMesh.
        % ----------------------------------------------------------------------
        % philipp.glira@gmail.com
        % ----------------------------------------------------------------------
        
        % Input parsing --------------------------------------------------------

        p = inputParser;
        p.addRequired('meshData', @(x) ischar(x));
        p.parse(meshData);
        p = p.Results;
        % Clear required inputs to avoid confusion
        clear meshData

        % Check if input file exists -------------------------------------------
        
        if ischar(p.meshData)
            if exist(p.meshData) ~= 2
                error('File ''%s'' does not exist!', p.meshData);
            end
        end
        
        % Start ----------------------------------------------------------------
        
        procHierarchy = {'POLYMESH' 'IMPORT'};
        msg('S', procHierarchy);
                
        % Import of mesh -------------------------------------------------------
        
        data = plyread(p.meshData);
        
        obj.vertices = [data.vertex.x data.vertex.y data.vertex.z];
        obj.faces    = vertcat(data.face.vertex_indices{:}) + 1; % increase IDs by one!
        
        % End ------------------------------------------------------------------
        
        procHierarchy = {'POLYMESH' 'IMPORT'};
        msg('E', procHierarchy);
            
        end
        
    end
        
end