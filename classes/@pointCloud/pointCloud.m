classdef pointCloud < handle
% POINTCLOUD Class for 3d point clouds.

    properties (SetAccess = immutable, GetAccess = public) % only the class constructor can set property values
        % center of gravity (=centroid)
        cog
        
        % Min and max in each dimension
        lim
        
        % Number of points
        noPoints
    end
    
    properties (SetAccess = public, GetAccess = public)
        % Coordinates of points
        X
        
        % Attributes
        A
        
        % Activation (= true) and deactivation (= false) flag for each point
        act
        
        % Label of point cloud
        label
        
        % User data
        U
        
        % Reduction point
        redPoi
    end
    
    properties (SetAccess = private, GetAccess = public)
        % Point cloud hull
        hull
        
        % Raster data
        raster
        
        % Voxel hull
        voxelHull
        voxelHullVoxelSize
    end

% ------------------------------------------------------------------------------
    
    methods
        
        function obj = pointCloud(pcData, varargin)
        % POINTCLOUD Import of point cloud data.
        % ----------------------------------------------------------------------
        % DESCRIPTION/NOTES        
        % This function creates an object instance of the pointCloud class. For
        % a listing of available attributes and methods for the pointCloud class
        % run 'doc pointCloud'.
        % ----------------------------------------------------------------------
        % INPUT
        % 1 [pcData]
        %   Point cloud input data defined as:
        %   a PATH TO A POINT CLOUD FILE
        %     Absolute or relative path to a:
        %     1 PLAIN TEXT FILE
        %       Column oriented text file where each row correspondonds to one
        %       point. The first 3 columns contain the point coordinates x, y
        %       and z. Further columns can be used for point attributes (e.g.
        %       color values r, g and b). Two possibilities exist to define the
        %       names of the attributes:
        %         * by using the parameter 'Attributes' (see below) 
        %         * by defining the attribute names in the first line of the
        %           file using the following format: 
        %           '# columns: x y z attributeName1 attributeName2 ...'
        %     2 BINARY FILE
        %       In binary files all values have to be stored in double precision
        %       (i.e. 8 bytes per value). All values are stored sequentially
        %       (e.g. for two points with one attribute the ordering would be
        %       x1, y1, z1, a1, x2, y2, z2, a2).
        %     3 LAS/LAZ FILE
        %       For reading las or laz files the function 'las2mat' must be
        %       accessible on the path. It can be downloaded here:
        %       https://github.com/plitkey/matlas_tools
        %     4 ODM FILE
        %       Files created with OPALS (http://geo.tuwien.ac.at/opals). For
        %       this it is necessary to:
        %       1) Install OPALS
        %       2) Add '%opals_root%\opals' to the search path in Matlab.
        %       Note: with the 'Filter' parameter, an odm filter string can be 
        %       applied during the import.
        %     5 PLY FILE
        %       Polygon file format, either in ascii or binary format.
        %     6 MAT FILE
        %       This method can also be used to load a mat file generated with
        %       the 'save' method of this class. For more details run
        %       'help pointCloud.save'.
        %   b MATRIX CONTAINING POINT CLOUD DATA
        %     A matrix of size n-by-3+a. Each row corresponds to one point, i.e.
        %     n is the total number of points. The first 3 columns contain the
        %     point coordinates x, y and z. Further columns can be used for
        %     point attributes (e.g. color values r, g and b). To import these
        %     attributes the parameter 'Attributes' has to be defined (see
        %     below).
        %
        % 2 ['Attributes', attributes]
        %   Name of attributes contained in input data defined as 1-by-a cell,
        %   where a denotes the number of attributes. Predefined attribute names
        %   to use for extended functionality:
        %     * 'id'        = point id
        %     * 'nx'        = normal x component
        %     * 'ny'        = normal x component
        %     * 'nz'        = normal z component
        %     * 'r'         = color red component
        %     * 'g'         = color green component
        %     * 'b'         = color blue component
        %     * 'roughness' = roughness in point neighborhood
        %   Imported attributes are saved into the property A of the pointCloud
        %   object, i.e. obj.A.
        %   Additionally, for LAS/LAZ, ODM and PLY files the following applies:
        %   - If the parameter 'Attributes' is not defined by the user, all 
        %     non-empty attributes are imported.
        %   - If the name of one or more attribute is specified by the parameter
        %     'Attributes', only these are imported.
        %   - If the parameter 'Attributes' is set to an empty cell, i.e. {}, NO
        %     attributes are imported.
        %
        % 3 ['Label', label]
        %   Label of point cloud defined as a string. If no label is defined and
        %   input is a file path, the file name is used as label.
        %
        % 4 ['RedPoi', redPoi]
        %   Coordinate reduction point defined as vector with 3 elements. The
        %   reduction point defines the origin of a local coordinate system in
        %   which the points are stored.
        %
        % 5 ['HeaderLines', headerLines]
        %   Number of header lines (=rows) to be skipped, if a plain text file
        %   is used as point cloud input.
        % ----------------------------------------------------------------------
        % OUTPUT
        % 1 [obj]
        %   Object instance of class pointCloud.
        % ----------------------------------------------------------------------
        % EXAMPLES
        % 1 Import a point cloud without attributes.
        %   pc = pointCloud('Lion.xyz');
        %   pc.plot;
        %
        % 2 Import a point cloud with attributes.
        %   pc = pointCloud('Gieszkanne.xyz', 'Attributes', {'r' 'g' 'b'});
        %   % Attributes are now accessible in the object property pc.A
        %   pc.plot('Color', 'A.rgb', 'MarkerSize', 5);
        %
        % 3 Import a point cloud from a matrix.
        %   [x, y, z] = sphere(100);
        %   x = x(:); y = y(:); z = z(:);
        %   pc = pointCloud([x y z], 'Label', 'sphere');
        %   pc.plot('MarkerSize', 5);
        % ----------------------------------------------------------------------
        % philipp.glira@gmail.com
        % ----------------------------------------------------------------------
        
        % Input parsing --------------------------------------------------------
        
        p = inputParser;
        p.addRequired( 'pcData'     , @(x) ischar(x) || ismatrix(x));           % same validation fcn as in pcread
        p.addParameter('Label'      , 'noLabel', @(x) ischar(x) || isempty(x));
        p.addParameter('RedPoi'     , [0 0 0]  , @(x) numel(x)==3);
        p.addParameter('Attributes' , []);                                      % validation fcn in pcread
        p.addParameter('HeaderLines', 0);                                       % validation fcn in pcread
        p.addParameter('Filter'     , '');                                      % validation fcn in pcread
        p.parse(pcData, varargin{:});
        p = p.Results;
        % Clear required inputs to avoid confusion
        clear pcData

        % Check input file -----------------------------------------------------
        
        if ischar(p.pcData)

            % Check if exists
            if ~exist(p.pcData, 'file')
                error('File ''%s'' does not exist!', p.pcData);
            end
            
            % Check file size
            % info = dir(p.pcData);
            % if info.bytes == 0
            %     error('File ''%s'' seems to be empty!', p.pcData);
            % end

        end
        
        % Special case: load point cloud from mat file -------------------------
        
        if ischar(p.pcData)
            [~,  ~, ext] = fileparts(p.pcData);
            if strcmpi(ext, '.mat')
                msg('S', {'POINTCLOUD' 'IMPORT'});
                msg('S', {'POINTCLOUD' 'IMPORT' 'LOAD FROM MAT FILE'});
                load(p.pcData); % object is loaded into variable 'obj' -> see method 'save'
                msg('E', {'POINTCLOUD' 'IMPORT' 'LOAD FROM MAT FILE'});
                msg('E', {'POINTCLOUD' 'IMPORT'});
                return;
            end
        end
        
        % Label ----------------------------------------------------------------
        
        % Set label to filename if not defined by user
        if ischar(p.pcData) && strcmpi(p.Label, 'noLabel')
            [~, file, ext] = fileparts(p.pcData);
            p.Label = [file ext];
        end
        
        % Start ----------------------------------------------------------------
        
        procHierarchy = {'POINTCLOUD' 'IMPORT'};
        msg('S', procHierarchy);
        msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', p.Label));
        
        % Import of coordinates ------------------------------------------------
        
        procHierarchy = {'POINTCLOUD' 'IMPORT' 'READ DATA'};
        msg('S', procHierarchy);
        
        % try
            [XNonRed, A] = pcread(p.pcData, 'Attributes' , p.Attributes, ...
                                            'HeaderLines', p.HeaderLines, ...
                                            'Filter'     , p.Filter);
        % catch
        %     error('Unable to read points from input data!');
        % end
        
        msg('E', procHierarchy);
        
        % Coordinate reduction!
        X = [XNonRed(:,1)-p.RedPoi(1) XNonRed(:,2)-p.RedPoi(2) XNonRed(:,3)-p.RedPoi(3)]; clear XNonRed

        % Save to object
        obj.X = X;
        
        % Assign remaining properties ------------------------------------------
        
        % Attributes
        obj.A      = A; clear A
        
        % Misc.
        obj.act    = true(size(X,1),1);
        obj.redPoi = p.RedPoi;
        obj.label  = num2str(p.Label);
        
        % Correct normals? -----------------------------------------------------
        
        if isfield(obj.A, 'nx')
            obj.correctNormals;
        end

        % End ------------------------------------------------------------------
        
        procHierarchy = {'POINTCLOUD' 'IMPORT'};
        msg('E', procHierarchy);
        obj.info
            
        end
        
        % ----------------------------------------------------------------------
        % ----------------------------------------------------------------------
        
        function noPoints = get.noPoints(obj)
            
        noPoints = size(obj.X,1);
            
        end
        
        % ----------------------------------------------------------------------
        
        function cog = get.cog(obj)
            
        cog = mean(obj.X(:,1:3));
            
        end
        
        % ----------------------------------------------------------------------
        
        function lim = get.lim(obj)
            
        % Limits
        lim.min = min(obj.X, [], 1);
        lim.max = max(obj.X, [], 1);
            
        end

        % ----------------------------------------------------------------------
        
        function obj = set.A(obj, A)
        % Check if attribute structure has correct form.
            
        % Input parsing --------------------------------------------------------
        
        p = inputParser;
        p.addRequired('A', @(x) isstruct(x) || isempty(x)); % check if A is a structure
        p.parse(A);
        p = p.Results;
        % Clear required inputs to avoid confusion
        clear A
        
        % Check if fields of A have right size ---------------------------------
        
        if ~isempty(p.A)
        
            att = fieldnames(p.A);

            for i = 1:numel(att)

                if (size(p.A.(att{i}),1) ~= obj.noPoints) || (size(p.A.(att{i}),2) ~= 1)

                    error(sprintf('Attribute %s has wrong size! (size should be %d-by-1)', att{i}, obj.noPoints));

                end

            end
            
        end
        
        % Save attribute to object ---------------------------------------------
        
        obj.A = p.A;
        
        end
        
    end
    
    % --------------------------------------------------------------------------
    % --------------------------------------------------------------------------
    
    methods (Hidden = true)
        
        % Signatures here must match with them in separate function files!
        obj = alphashape(obj, r, varargin)
        obj = correctNormals(obj)
        obj = createRaster(obj, varargin)
        plotPolar(obj, varargin)
        obj = segmentation(obj, r, varargin)
        
    end
    
end