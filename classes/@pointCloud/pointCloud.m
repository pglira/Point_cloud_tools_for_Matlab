classdef pointCloud < KDTreeSearcher
% POINTCLOUD Class for 3d point clouds.

    properties (SetAccess = immutable, GetAccess = public) % only the class constructor can set property values
        % center of gravity (=centroid)
        cog
        
        % Min and max in each dimension
        lim
        
        % Number of points
        noPoints

        % Reduction point
        redPoi
        
    end
    
    properties (SetAccess = public, GetAccess = public)
        % Attributes
        A
        
        % Activation (= true) and deactivation (= false) flag for each point
        act
        
        % Label of point cloud
        label
        
        % User data
        U
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
        %       color values r, g and b). To import these attributes the
        %       parameter 'Attributes' has to be defined (see below).
        %     2 BINARY FILE
        %       In binary files all values have to be stored in double precision
        %       (i.e. 8 bytes per value). All values are stored sequentially
        %       (e.g. for two points with one attribute the ordering would be
        %       x1, y1, z1, a1, x2, y2, z2, a2).
        %     3 LAS/LAZ FILE
        %       For reading las or laz files the function 'las2mat' must be
        %       accessible on the path.
        %     4 ODM FILE
        %       Files created with OPALS (http://geo.tuwien.ac.at/opals). For
        %       this it is necessary to:
        %       1) Install OPALS
        %       2) Copy these files into the folder '%opals_root%\opals':
        %          - odmGetPoints.mexw64
        %          - odmGetPointsFull.mexw64
        %          - odmGetStatistics.mexw64
        %          You can find these files in 'files2readODM.zip'
        %          (see folder 'classes\4pointCloud').
        %       3) Add '%opals_root%\opals' to the search path in Matlab.
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
        % 5 ['BucketSize', bucketSize]
        %   Bucket size of kd-tree. Run 'doc KDTreeSearcher' for further
        %   informations.
        %
        % 6 ['HeaderLines', headerLines]
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
        %   pc.plot('Color', 'rgb', 'MarkerSize', 5);
        %
        % 3 Import a point cloud from a matrix.
        %   [x, y, z] = sphere(100);
        %   x = x(:); y = y(:); z = z(:);
        %   pc = pointCloud([x y z], 'Label', 'sphere');
        %   pc.plot('MarkerSize', 5);
        % ----------------------------------------------------------------------
        % philipp.glira@geo.tuwien.ac.at
        % ----------------------------------------------------------------------
        
        % Input parsing --------------------------------------------------------

        p = inputParser;
        p.addRequired(  'pcData'                , @(x) ischar(x) || ismatrix(x));
        p.addParamValue('Attributes' , []       , @iscell); % note: if Attributes is [], all attributes are imported for some file types (e.g. LAS/LAZ or ODM)
        p.addParamValue('Label'      , 'noLabel', @(x) ischar(x) || isempty(x));
        p.addParamValue('RedPoi'     , [0 0 0]  , @(x) numel(x)==3);
        p.addParamValue('BucketSize' , 1000     , @isnumeric);
        p.addParamValue('HeaderLines', 0        , @(x) isscalar(x) && x>=0);
        % Undocumented
        p.addParamValue('KDTree'     , true     , @islogical);
        p.parse(pcData, varargin{:});
        p = p.Results;
        % Clear required inputs to avoid confusion
        clear pcData

        % Check if input file exists -------------------------------------------
        
        if ischar(p.pcData)
            if exist(p.pcData) ~= 2
                error('File ''%s'' does not exist!', p.pcData);
            end
        end
        
        % Special case: load point cloud from mat file -------------------------
        
        if ischar(p.pcData)
            [~,  ~, ext] = fileparts(p.pcData);
            if  strcmpi(ext, '.mat')
                msg('S', {'POINTCLOUD' 'IMPORT'});
                msg('S', {'POINTCLOUD' 'IMPORT' 'LOAD FROM MAT FILE'});
                load(p.pcData); % object is loaded into variable 'obj' -> see method 'save'
                msg('E', {'POINTCLOUD' 'IMPORT' 'LOAD FROM MAT FILE'});
                msg('E', {'POINTCLOUD' 'IMPORT'});
                return;
            end
        end
        
        % Label ----------------------------------------------------------------
        
        % Set filename to label if not defined by user
        if ischar(p.pcData) && strcmpi(p.Label, 'noLabel')
            
            [~, file, ext] = fileparts(p.pcData);
            p.Label = [file ext];
            
        end
        
        % Start ----------------------------------------------------------------
        
        procHierarchy = {'POINTCLOUD' 'IMPORT'};
        msg('S', procHierarchy);
        msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', p.Label));
        
        % Import of coordinates ------------------------------------------------
        
        % If input is a file path, import data from file to array
        if ischar(p.pcData)
            
            procHierarchy = {'POINTCLOUD' 'IMPORT' 'READ FILE'};
            msg('S', procHierarchy);
            
            % Get file extension
            [~, ~, ext] = fileparts(p.pcData);
            
            % If input is a binary file
            if strcmpi(ext, '.bin') || strcmpi(ext, '.bxyz')
            
                fid = fopen(p.pcData);
                allData = fread(fid, [3+numel(p.Attributes), Inf], 'double'); % output has n columns (n = no. of points)
                XNonRed = allData(1:3,:)';
                if ~isempty(p.Attributes), att = allData(4:end,:)'; end % attributes
                fclose(fid);

            % If input is a las file
            elseif any(strcmpi(ext, {'.las' '.laz'}))
                
                % Check if las2mat exists on path
                if exist('las2mat') == 3
                   
                    % Read las file
                    [lasHeader, data] = las2mat(['-i "' p.pcData '"']);
                    
                    % Import point coordinates
                    XNonRed = [data.x data.y data.z];
                    data = rmfield(data, {'x' 'y' 'z'});
                    
                    % Delete empty attributes
                    lasAttributes = fieldnames(data);
                    for a = 1:numel(lasAttributes)
                        if all(diff(data.(lasAttributes{a}))==0) % attribute contains only one data value
                            data = rmfield(data, lasAttributes{a});
                        end
                    end
                    
                    % Special case: rgb attribute
                    lasAttributes = fieldnames(data); % update
                    if any(strcmpi(lasAttributes, 'rgb'))
                        data.r = data.rgb(:,1);
                        data.g = data.rgb(:,2);
                        data.b = data.rgb(:,3);
                        data = rmfield(data, 'rgb');
                    end
                    
                    % Special case: extra attributes
                    if any(strcmpi(lasAttributes', 'attributes'))
                        for i = 1:size(data.attributes, 2)
                            attName = lasHeader.attributes(i).name;
                            attName = strrep(attName, ' ', '_'); % replace space by underscore, since space are not allowed as field name
                            data.(attName) = data.attributes(:,i);
                        end
                        data = rmfield(data, 'attributes');
                    end
                    
                    % Import attributes
                    if isempty(p.Attributes) % then it is either [] or {}
                    
                        if ~iscell(p.Attributes) % then it must be [], i.e. import all attributes
                            p.Attributes = fieldnames(data);
                        end
                        
                    end
                    
                    if ~isempty(p.Attributes) % if any attributes should be imported
                    
                        att = zeros(size(XNonRed,1), numel(p.Attributes)); % preallocate matrix
                        for a = 1:numel(p.Attributes)
                            att(:,a) = data.(p.Attributes{a});
                        end
                        
                    end
                    
                else
                    
                    error('Function ''las2mat'' for reading las files is missing on path!');
                    
                end
                
            % If input is a odm file
            elseif strcmpi(ext, '.odm')
                
                % Get points and ALL attributes
                if isempty(p.Attributes) && ~iscell(p.Attributes)
                    
                    [data, info] = odmGetPointsFull(p.pcData);
                    p.Attributes = {info{5:end,1}};
                    
                % Get ONLY points
                elseif isempty(p.Attributes) && iscell(p.Attributes)
                    
                    data = odmGetPoints(p.pcData, {'x' 'y' 'z'});
                   
                % Get points and selected attributes
                else
                    
                    data = odmGetPoints(p.pcData, {'x' 'y' 'z' p.Attributes{:}});
                    
                end
                
                % Point coordinates
                XNonRed = data(:,1:3);
                
                % Attributes
                att = data(:,4:end);
            
            % If input is a ply file
            elseif strcmpi(ext, '.ply')
                
                % Read ply file
                data = plyread(p.pcData);
                
                % Import point coordinates
                XNonRed = [data.vertex.x data.vertex.y data.vertex.z];
                data.vertex = rmfield(data.vertex, {'x' 'y' 'z'});
                
                % Import attributes
                if isempty(p.Attributes) % then it is either [] or {}
                    
                    if ~iscell(p.Attributes) % then it must be [], i.e. import all attributes
                        p.Attributes = fieldnames(data.vertex);
                    end
                    
                end
                
                if ~isempty(p.Attributes) % if any attributes should be imported
                    
                    att = zeros(size(XNonRed,1), numel(p.Attributes)); % preallocate matrix
                    for a = 1:numel(p.Attributes)
                        att(:,a) = data.vertex.(p.Attributes{a});
                    end
                    
                end
                
            % If input is a plain text file
            else
            
                fid = fopen(p.pcData);
                formatSpec = [repmat('%f ', 1, 3+numel(p.Attributes)) '%*[^\n]'];
                allData = textscan(fid, formatSpec, 'HeaderLines', p.HeaderLines); % much faster than dlmread
                XNonRed = [allData{1} allData{2} allData{3}]; % points
                if ~isempty(p.Attributes), att = [allData{4:end}]; end % attributes
                fclose(fid);
                
            end
            
            msg('E', procHierarchy);
            
        % If input is an array
        else
            
            XNonRed = p.pcData(:,1:3); % points (takes no time -> pass by reference)
            if ~isempty(p.Attributes), att = p.pcData(:,4:end); end % attributes
            
        end

        % Error if no point is present
        if size(XNonRed,1) == 0
            error('Unable to read points from input data!');
        end
        
        % Coordinate reduction!
        X = [XNonRed(:,1)-p.RedPoi(1) XNonRed(:,2)-p.RedPoi(2) XNonRed(:,3)-p.RedPoi(3)];

        % Import points --------------------------------------------------------
        % Trick: if no KDTree should be built, an empty matrix is used for the
        % mandatory initizialization of the KDTree. After that, the property X
        % is overwritten with the original (reduced) coordinates.
        
        if ~p.KDTree, X4Tree = []; else X4Tree = X; end
        
        if p.KDTree
            
            % Check if toolbox is installed
            if exist('knnsearch') ~= 2
                error('''Statistics and Machine Learning Toolbox'' not found! This toolbox is needed for the k-d tree. You can create a pointCloud object WITHOUT a k-d tree with the parameter value pair [''kdtree'', false], e.g. pc = pointCloud(''Lion.xyz'', ''kdtree'', false);. In this case the methods which are using the functionality of the k-d tree will not work, e.g. the selection methods ''RangeSearch'' and ''KnnSearch'' of the method ''select''.');
            end
            
            msg('S', {'POINTCLOUD' 'IMPORT' 'BUILD KD-TREE'});
        
        end
        
        obj@KDTreeSearcher(X4Tree, 'BucketSize', p.BucketSize); % has to be a top level statement
        
        if p.KDTree
            msg('E', {'POINTCLOUD' 'IMPORT' 'BUILD KD-TREE'});
        end
        
        if ~p.KDTree, obj.X = X; end

        % Assign remaining properties ------------------------------------------
        
        obj.act    = true(size(X,1),1);
        obj.redPoi = p.RedPoi;
        obj.label  = num2str(p.Label);
        
        % Limits
        obj.lim.min = min(obj.X, [], 1);
        obj.lim.max = max(obj.X, [], 1);
        
        % CoG
        obj.cog = mean( obj.X(:,1:3) );
        
        % Number of points
        obj.noPoints = size(obj.X,1);
        
        % Assign attributes ----------------------------------------------------
        
        for a = 1:numel(p.Attributes)
            obj.A.(p.Attributes{a}) = att(:,a);
        end
        
        if exist('lasHeader') == 1, obj.U.lasHeader = lasHeader; end
        
        % Correct normals? -----------------------------------------------------
        
        if any(strcmpi(p.Attributes, 'nx'))
            obj = obj.correctNormals;
        end

        % End ------------------------------------------------------------------
        
        procHierarchy = {'POINTCLOUD' 'IMPORT'};
        msg('E', procHierarchy);
        obj.info
            
        end
        
        % ----------------------------------------------------------------------
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
        
            fields = fieldnames(p.A);

            for i = 1:numel(fields)

                if (size(p.A.(fields{i}),1) ~= obj.noPoints) || (size(p.A.(fields{i}),2) ~= 1)

                    error(sprintf('Attribute %s has wrong size! (size should be %d-by-1)', fields{i}, obj.noPoints));

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