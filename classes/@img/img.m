classdef img < handle
    
    properties (SetAccess = public, GetAccess = public)
        
        % Label
        label
        
        % XOR
        X0
        Y0
        Z0
        ome % in gradian
        phi % in gradian
        kap % in gradian
        
        % IOR
        c
        x0
        y0
        a3 = 0;
        a4 = 0;
        a5 = 0;
        a6 = 0;
        rho0
        camId
        
        % Image observations
        id
        x
        y
        
        % Other
        file
        
        % UserData
        U
        
    end
    
    properties (SetAccess = private)

        % Rotation matrix
        R
        
    end
    
    methods
        
        function obj = img(varargin)

            % Input parsing ----------------------------------------------------
            p = inputParser;
            p.addParameter('File' , ''       , @ischar);
            p.addParameter('Label', 'noLabel', @ischar);
            p.parse(varargin{:});
            p = p.Results;

            % Label ------------------------------------------------------------
            
            % Set label to filename (if label is not defined and file is given)
            if strcmpi(p.Label, 'noLabel') && ~isempty(p.File)

                [~, file, ext] = fileparts(p.File);
                p.Label = [file ext];

            end
            
            % Start ------------------------------------------------------------
            
            procHierarchy = {'IMG' 'IMPORT'};
            msg('S', procHierarchy);
            msg('I', procHierarchy, sprintf('Image label = ''%s''', p.Label));
            
            % Set properties ---------------------------------------------------

            obj.label = p.Label;
            obj.file  = p.File;
            
            % End --------------------------------------------------------------
            
            msg('E', procHierarchy);
            
        end
        
        % ----------------------------------------------------------------------
        
        function new = copy(obj)
        % COPY Create copy of handle class.
        % See: http://www.mathworks.com/matlabcentral/newsreader/view_thread/257925
        
            % Instantiate new object of the same class
            new = feval(class(obj));
 
            % Copy all non-hidden properties
            p = properties(obj);
            for i = 1:length(p)
                new.(p{i}) = obj.(p{i});
            end
            
        end
        
        % ----------------------------------------------------------------------
        
        function R = get.R(obj)
        % R Get rotation matrix from angles ome, phi, kap.

            R = opk2R(obj.ome, obj.phi, obj.kap, 'Unit', 'Gradian');
            
        end

    end
    
end

