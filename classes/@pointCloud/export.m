function export(obj, path, varargin)
% EXPORT Export activated points to a file.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * Only active points are exported.
% ------------------------------------------------------------------------------
% INPUT
% 1 [path]
%   Path to output file. The file extension defines the format of the output
%   file:
%     * 'bxyz'     -> binary format containing ONLY x, y and z coordinates.
%     * 'las/laz'  -> las/laz file (only with supported attributes).
%     * 'bin'      -> binary format containing x, y, z coordinates AND all
%                     attributes defined with the 'Attributes' parameter.
%     * 'shp'      -> shape file format containing x, y coordinates AND all
%                     attributes defined with the 'Attributes' parameter
%                     (Note: the z coordinates of the points can be written as
%                     shape attribute by using 'z' as attribute name).
%                     For this feature the 'Mapping Toolbox' is needed.
%     * 'ply'      -> polygon file format with specified attributes.
%     * '???'      -> for any other extension (e.g. '.xyz') a plain text file
%                     is created (delimiter = space).
%
% 2 ['Attributes', attributes]
%   Cell with attributes to export, where each attribute is defined as char. Of
%   course, these attributes have to be defined in the attributes structure of
%   the point cloud object, i.e. obj.A.
%   (This parameter is not considered for bxyz files.)
%
% 3 ['ColumnWidth', columnWidth]
%   Width of each column. If this parameter is omitted, the output file is not
%   column oriented, but values are simply divided by a space character.
%   (This parameter is only considered for plain text files.)
%
% 4 ['PrecCoord', precCoord]
%   Precision of coordinates. It is possible to define either one value for all
%   coordinates, or an own value for each coordinate in a 3-by-1 vector.
%   (This parameter is only considered for plain text files.)
%
% 5 ['PrecAttributes', precAttributes]
%   Precision of attributes. It is possible to define either one value for all
%   attributes, or an own value for each attribute in a a-by-1 vector, where a
%   is the number of attributes to export.
%   (This parameter is only considered for plain text files.)
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Conversion to bxyz file.
%   pc = pointCloud('Lion.xyz');
%   pc.export('Lion.bxyz');
%
% 2 Export to binary file with attributes.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%   pc.export('Lion.bin', 'Attributes', {'nx' 'ny' 'nz'});
%
% 3 Export to a plain text file with a lot of specifications.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%   pc.export('Lion.txt', 'Attributes'    , {'nx' 'ny' 'nz' 'roughness'}, ...
%                         'PrecAttributes', [5 5 5 3], ...
%                         'PrecCoord'     , 3, ...
%                         'ColumnWidth'   , 10);
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('path');
% For plain text files and binary files
p.addParameter('Attributes'    , [], @(x) iscell(x) || (isnumeric(x) && isempty(x)));
% For plain text files only
p.addParameter('ColumnWidth'   , [], @(x) isscalar(x) || isempty(x));
p.addParameter('PrecCoord'     , 4 , @(x) numel(x)==1 || numel(x)==3);
p.addParameter('PrecAttributes', 5);
p.parse(path, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear path

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'EXPORT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Preparations -----------------------------------------------------------------

% Non reduced coordinates for export
XNonRed = [obj.X(obj.act, 1) + obj.redPoi(1) ...
           obj.X(obj.act, 2) + obj.redPoi(2) ...
           obj.X(obj.act, 3) + obj.redPoi(3)];

% Get extension
[folder, ~, ext] = fileparts(p.path);

% Create folder if not already present
if ~exist(folder) && ~isempty(folder), mkdir(folder); end

% Precisions of coordinates
if numel(p.PrecCoord) == 1
    precCoord = repmat(p.PrecCoord, 1, 3);
else
    precCoord = p.PrecCoord;
end

% Precisions of attributes
if ~isempty(p.Attributes)
    if numel(p.PrecAttributes) == 1
        precAttributes = repmat(p.PrecAttributes, 1, numel(p.Attributes));
    else
        precAttributes = p.PrecAttributes;
    end
end

% Export to binary xyz file (only points) --------------------------------------

if strcmpi(ext, '.bxyz')

    XNonRed = XNonRed';
    
    fid = fopen(p.path, 'w');
    fwrite(fid, XNonRed(:), 'double');
    fclose(fid);
    
% Export to las/laz file (may include attributes supported by las format) ------

elseif any(strcmpi(ext, {'.las' '.laz'}))
    
    data = obj.A;
    if ~isempty(data)
        attributes = fieldnames(data);
        if any(strcmpi(attributes, 'r')) && any(strcmpi(attributes, 'g')) && any(strcmpi(attributes, 'b'))
            data.rgb = [data.r data.g data.b];
            data = rmfield(data, {'r' 'g' 'b'});
        end
    end
    data.x = XNonRed(:,1);
    data.y = XNonRed(:,2);
    data.z = XNonRed(:,3);
    
    % Change OPALS attribute names to LAS attribute names (see http://www.geo.tuwien.ac.at/opals/html/ref_fmt_las.html)
    lookuptable = {'Amplitude'           'intensity'
                   'EchoNumber'          'return_number'
                   'NrOfEchos'           'number_of_returns'
                   'ClassificationFlags' 'classification_flags'
                   'ChannelDesc'         'scanner_channel'
                   'ScanDirection'       'scan_direction_flag'
                   'EdgeOfFlightLine'    'edge_of_flight_line'
                   'Classification'      'classification'
                   'UserData'            'user_data'
                   'ScanAngle'           'scan_angle_rank'
                   'PointSourceId'       'point_source_ID'
                   'GPSTime'             'gps_time'
                   'InfraRed'            'NIR'}; % echo width missing! is there any correspondence in las format?

   for i = 1:size(lookuptable,1)
        if isfield(data, lookuptable{i,1})
            data.(lookuptable{i,2}) = data.(lookuptable{i,1});
            data = rmfield(data, lookuptable{i,1});
        end
    end

%     % If header is already present -> only update
%     if isfield(obj.U, 'lasHeader')
%         lasHeader = obj.U.lasHeader;
%         lasHeader.number_of_point_records = numel(data.x);
%         lasHeader.x_scale_factor = 10^-p.PrecCoord;
%         lasHeader.y_scale_factor = 10^-p.PrecCoord;
%         lasHeader.z_scale_factor = 10^-p.PrecCoord;
%         lasHeader.min_x = min(data.x);
%         lasHeader.min_y = min(data.y);
%         lasHeader.min_z = min(data.z);
%         lasHeader.max_x = max(data.x);
%         lasHeader.max_y = max(data.y);
%         lasHeader.max_z = max(data.z);
%         
%     % If header is not present -> create new minimal header
%     else
%         lasHeader = struct('file_signature', 'LASF', ...
%                            'header_size', 227, ...
%                            'point_data_format', 0, ...
%                            'point_data_record_length', 36, ...
%                            'number_of_point_records', numel(data.x), ...
%                            'number_of_points_by_return', [numel(data.x) 0 0 0 0], ...
%                            'x_scale_factor', 10^-p.PrecCoord, ...
%                            'y_scale_factor', 10^-p.PrecCoord, ...
%                            'z_scale_factor', 10^-p.PrecCoord, ...
%                            'x_offset', 0, ...
%                            'y_offset', 0, ...
%                            'z_offset', 0, ...
%                            'user_data_after_header_size', 0, ...
%                            'min_x', min(data.x), ...
%                            'min_y', min(data.y), ...
%                            'min_z', min(data.z), ...
%                            'max_x', max(data.x), ...
%                            'max_y', max(data.y), ...
%                            'max_z', max(data.z) ...
%                            );
%     end
%     
%     % Create las file!
%     mat2las(data, lasHeader, ['-o ' p.path]);
    mat2las(data, ['-o ' p.path]);

% Export to shape file ---------------------------------------------------------

elseif strcmpi(ext, '.shp')
    
    % Export ONLY x and y
    if isempty(p.Attributes) && iscell(p.Attributes) % i.e. p.Attributes == {}
    
        s = mapshape(XNonRed(:,1), XNonRed(:,2), 'Geometry', 'point');
        
    % Export x, y, and ALL attributes
    elseif isempty(p.Attributes) && ~iscell(p.Attributes) % i.e. p.Attributes == []
       
        % Create attribute structure
        att.z = XNonRed(:,3)';
        if ~isempty(obj.A)
            attributeNames = fields(obj.A);
            for i = 1:numel(attributeNames)
                att.(attributeNames{i}) = obj.A.(attributeNames{i})(obj.act)';
            end
        end
        
        s = mappoint(XNonRed(:,1)', XNonRed(:,2)', att);
        
    % Export x, y, and SELECTED attributes
    else
        
        % Create attribute structure
        attributeNames = fields(obj.A);
        for a = 1:numel(p.Attributes)
            if strcmpi(p.Attributes{a}, 'z')
                att.z = XNonRed(:,3)';
            elseif any(strcmpi(p.Attributes{a}, attributeNames))
                att.(p.Attributes{a}) = obj.A.(p.Attributes{a})(obj.act)';
            end
        end
        
        s = mappoint(XNonRed(:,1)', XNonRed(:,2)', att);
        
    end
    
    shapewrite(s, p.path);
        
% Export to binary file (may include attributes) -------------------------------

elseif strcmpi(ext, '.bin')
    
    % Export coordinates and ALL attributes
    if isempty(p.Attributes) && ~iscell(p.Attributes) % i.e. p.Attributes == []
        p.Attributes = fields(obj.A);
    end
        
    % Attributes
    if ~isempty(p.Attributes)
        for a = 1:numel(p.Attributes)
            % Matrix with a column for each attribute
            A(:,a) = obj.A.(p.Attributes{a})(obj.act);
        end
    else
        A = [];
    end
    
    allData = [XNonRed A]';
    
    fid = fopen(p.path, 'w');
    fwrite(fid, allData(:), 'double');
    fclose(fid);

% Export to ply file -----------------------------------------------------------

elseif strcmpi(ext, '.ply')

%     data.vertex.x = XNonRed(:,1);
%     data.vertex.y = XNonRed(:,2);
%     data.vertex.z = XNonRed(:,3);
%     
%     % Attributes
%     for a = 1:numel(p.Attributes)
%         data.vertex.(p.Attributes{a}) = obj.A.(p.Attributes{a})(obj.act);
%     end
%     
%     plywrite(data, p.path);
    
    fid = fopen(p.path, 'wt');
    
    % Header -------------------------------------------------------------------
    
    fprintf(fid, 'ply\n');
    fprintf(fid, 'format ascii 1.0\n');
    fprintf(fid, 'element vertex %d\n', size(XNonRed,1));
    fprintf(fid, 'property float x\n');
    fprintf(fid, 'property float y\n');
    fprintf(fid, 'property float z\n');
    
    if ~isempty(p.Attributes)
        
        for a = 1:numel(p.Attributes)
            
            % Precision
            if precAttributes(a) == 0
                datatype = 'uchar';
            else
                datatype = 'float';
            end
            
            % Name
            if any(strcmpi(p.Attributes{a}, {'r' 'diffuse_red'}))
                name = 'red';
            elseif any(strcmpi(p.Attributes{a}, {'g' 'diffuse_green'}))
                name = 'green';
            elseif any(strcmpi(p.Attributes{a}, {'b' 'diffuse_blue'}))
                name = 'blue';
            else
                name = p.Attributes{a};
            end
            
            fprintf(fid, 'property %s %s\n', datatype, name);
            
        end
        
    end
    
    fprintf(fid, 'end_header\n');
    
    % Points (with attributes) -------------------------------------------------
    
    % Initialize format string for export
    formatSpec = sprintf('%%.%df ', precCoord);
    formatSpec(end) = '';

    % Attributes
    if ~isempty(p.Attributes)

        for a = 1:numel(p.Attributes)

            % Matrix with a column for each attribute
            A(:,a) = obj.A.(p.Attributes{a})(obj.act);

            % Add entry in format string for each attribute
            formatSpec = [formatSpec sprintf(' %%.%df', precAttributes(a))];
            
        end

    else
        A = [];
    end

    % Add newline character
    formatSpec = [formatSpec '\n'];

    % Write points (with attributes)
    fprintf(fid, formatSpec, [XNonRed A]');
    
    fclose(fid);
    
% Export to normal xyz file (may include attributes) ---------------------------
else

    % Initialize format string for export
    formatSpec = sprintf('%%%d.%df ', p.ColumnWidth, precCoord(1), ...
                                      p.ColumnWidth, precCoord(2), ...
                                      p.ColumnWidth, precCoord(3));
    formatSpec(end) = '';

    % Attributes
    if ~isempty(p.Attributes)

        for a = 1:numel(p.Attributes)

            % Matrix with a column for each attribute
            A(:,a) = obj.A.(p.Attributes{a})(obj.act);

            % Add entry in format string for each attribute
            formatSpec = [formatSpec sprintf(' %%%d.%df', p.ColumnWidth, precAttributes(a))];
            
        end

    else
        A = [];
    end

    % Add newline character
    formatSpec = [formatSpec '\n'];

    save2(p.path, [XNonRed A], formatSpec);
       
end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end