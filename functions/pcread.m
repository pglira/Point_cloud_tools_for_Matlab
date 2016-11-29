function [X, A] = pcread(pcData, varargin)
% PCREAD Read point cloud data.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'pcData'           , @(x) ischar(x) || ismatrix(x));
p.addParameter('Attributes'  , [] , @(x) iscell(x) || (isnumeric(x) && isempty(x)));
p.addParameter('HeaderLines' , 0  , @(x) isscalar(x) && x>=0);
p.addParameter('Filter'      , '' , @ischar); % only for odm files
p.parse(pcData, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear pcData

% Import point cloud data ------------------------------------------------------

% Initialization
A = [];

% If input is a file path, import data from file to array
if ischar(p.pcData)

    % Get file extension
    [~, ~, ext] = fileparts(p.pcData);

    % If input is a binary file
    if strcmpi(ext, '.bin') || strcmpi(ext, '.bxyz')

        fid = fopen(p.pcData);
        allData = fread(fid, [3+numel(p.Attributes), Inf], 'double'); % output has n columns (n = no. of points)
        X = allData(1:3,:)';
        allData(1:3,:) = []; % save memory!
        for i = 1:numel(p.Attributes)
            A.(p.Attributes{i}) = allData(1,:)';
            allData(1,:) = []; % save memory!
        end
        fclose(fid);

    % If input is a las file
    elseif any(strcmpi(ext, {'.las' '.laz'}))

        % Check if las2mat exists on path
        if exist('las2mat') == 3
            
            % Note: It is NOT possible to read only the demanded data from a las file. Instead always the full data amount must be read from the file.

            % Read las file
            [lasHeader, A] = las2mat(['-i "' p.pcData '"']);

            % Import point coordinates
            X = [A.x A.y A.z];
            A = rmfield(A, {'x' 'y' 'z'});

            % Get ONLY points
            if isempty(p.Attributes) && iscell(p.Attributes) % i.e. p.Attributes == {}
                
                A = [];
                
            else % i.e. p.Attributes is [] (-> get ALL attributes) or not empty
                
                % Delete empty attributes
                lasAttributes = fieldnames(A);
                for a = 1:numel(lasAttributes)
                    if all(diff(A.(lasAttributes{a}))==0) % attribute contains only one data value
                        A = rmfield(A, lasAttributes{a});
                    end
                end

                % Special case: rgb attribute
                lasAttributes = fieldnames(A); % update
                if any(strcmpi(lasAttributes, 'rgb'))
                    A.r = A.rgb(:,1);
                    A.g = A.rgb(:,2);
                    A.b = A.rgb(:,3);
                    A = rmfield(A, 'rgb');
                end

                % Special case: extra attributes
                if any(strcmpi(lasAttributes', 'attributes'))
                    for i = 1:size(A.attributes, 2)
                        attName = lasHeader.attributes(i).name;
                        attName = strrep(attName, ' ', '_'); % replace space by underscore, since space are not allowed as field name
                        A.(attName) = A.attributes(:,i);
                    end
                    A = rmfield(A, 'attributes');
                end

                % Get points and selected attributes
                if ~isempty(p.Attributes)
                    
                    lasAttributes = fieldnames(A); % update
                    for i = 1:numel(lasAttributes) % check for each attribute if it is included in p.Attributes
                        if ~strcmpi(lasAttributes{i}, p.Attributes)
                            A = rmfield(A, lasAttributes{i}); % remove if not included
                        end
                    end
                    
                end
                
            end
            
        else

            error('Function ''las2mat'' for reading las files is missing on path!');

        end

    % If input is a odm file
    elseif strcmpi(ext, '.odm')
    
        % Note: it is possible to read only the demanded data from the odm

        % Get points and ALL attributes
        if isempty(p.Attributes) && ~iscell(p.Attributes) % i.e. p.Attributes == []

            if isempty(p.Filter)
                [data, info] = odmGetPointsFull(p.pcData);
            else
                [data, info] = odmGetPointsFull(p.pcData, p.Filter);
            end
            p.Attributes = {info{5:end,1}};

        % Get ONLY points
        elseif isempty(p.Attributes) && iscell(p.Attributes) % i.e. p.Attributes == {}

            if isempty(p.Filter)
                data = odmGetPoints(p.pcData, {'x' 'y' 'z'});
            else
                data = odmGetPoints(p.pcData, {'x' 'y' 'z'}, p.Filter);
            end

        % Get points and selected attributes
        else

            if isempty(p.Filter)
                data = odmGetPoints(p.pcData, {'x' 'y' 'z' p.Attributes{:}});
            else
                data = odmGetPoints(p.pcData, {'x' 'y' 'z' p.Attributes{:}}, p.Filter);
            end

        end

        % Point coordinates
        X = data(:,1:3);

        % Attributes
        for i = 1:numel(p.Attributes)
            
            if strcmp(p.Attributes{i}(1), '_'), p.Attributes{i}(1) = ''; end % remove '_' at the beginning of attribute name (most likely from OPALS)
            
            if strcmpi(p.Attributes{i}, 'NormalX'), p.Attributes{i} = 'nx'; end
            if strcmpi(p.Attributes{i}, 'NormalY'), p.Attributes{i} = 'ny'; end
            if strcmpi(p.Attributes{i}, 'NormalZ'), p.Attributes{i} = 'nz'; end
            
            A.(p.Attributes{i}) = data(:,3+i);
            
        end

    % If input is a ply file
    elseif strcmpi(ext, '.ply')

        % Note: It is NOT possible to read only the demanded data from a ply file. Instead always the full data amount must be read from the file.
        
        % Read ply file
        data = plyread(p.pcData);

        % Import point coordinates
        X = [data.vertex.x data.vertex.y data.vertex.z];
        data.vertex = rmfield(data.vertex, {'x' 'y' 'z'});
        
        % Get ONLY points
        if isempty(p.Attributes) && iscell(p.Attributes) % i.e. p.Attributes == {}
        
            A = [];
            
        else % i.e. p.Attributes is [] (-> get ALL attributes) or not empty
            
            A = data.vertex; clear data
            
            % Get points and selected attributes
            if ~isempty(p.Attributes)

                plyAttributes = fieldnames(A);
                for i = 1:numel(plyAttributes) % check for each attribute if it is included in p.Attributes
                    if ~strcmpi(plyAttributes{i}, p.Attributes)
                        A = rmfield(A, plyAttributes{i}); % remove if not included
                    end
                end

            end
            
        end
        
    % If input is a plain text file
    else

        % Check if attribute names are defined in file
        % Attribute names must be defined at beginning of file with '# columns: ...', e.g. '# columns: x y z nx ny nz'
        attributeNames = []; % initialization
        text2search = '# columns: ';
        fid = fopen(p.pcData);
        line = fgetl(fid);
        while strcmp(line(1), '#')
            if ~isempty(strfind(line, text2search))
                line = strrep(line, text2search, '');
                allNames = textscan(line, '%s');
                attributeNames = {allNames{1}{4:end}};
            end
            line = fgetl(fid);
            if isempty(line), break; end % stop if an empty line was found
        end
        frewind(fid); % jump back to beginning of file
        
        % Find out the no. of attributes
        for i = 1:p.HeaderLines, fgetl(fid); end % skip header
        line = fgetl(fid);
        while strcmp(line(1), '#'), line = fgetl(fid); end
        delimiter = {' ' '\b' '\t' ',' ';' }; % all possible delimiter
        firstLineXA = textscan(line, '%f', 'Delimiter', delimiter, 'MultipleDelimsAsOne', 1);
        noAttributes = numel(firstLineXA{1})-3;
        frewind(fid); % jump back to beginning of file
        
        % Delete attributeNames if not consistent with noAttributes
        if numel(attributeNames) ~= noAttributes
            attributeNames = [];
        end
        
        % Read all data
        formatSpec = [repmat('%f ', 1, 3+noAttributes) '%*[^\n]'];
        allData = textscan(fid, ... % textscan much faster than dlmread
                           formatSpec, ...
                           'HeaderLines'        , p.HeaderLines, ...
                           'CommentStyle'       , '#', ...
                           'Delimiter'          , delimiter, ...
                           'MultipleDelimsAsOne', 1);
        fclose(fid);
        X = [allData{1} allData{2} allData{3}]; % points
        
        % Get ALL attributes
        if isempty(p.Attributes) && ~iscell(p.Attributes) % i.e. p.Attributes == []
            for i = 1:noAttributes
                if ~isempty(attributeNames)
                    attributeName = attributeNames{i};
                else
                    attributeName = sprintf('attribute%02d', i);
                end
                A.(attributeName) = allData{3+i};
            end
            
        % Get ONLY points, i.e. NO attributes
        elseif isempty(p.Attributes) && iscell(p.Attributes) % i.e. p.Attributes == {}
            A = [];
            
        % Get user selected attributes
        else
            
            % If attribute names are defined in file
            if ~isempty(attributeNames)
                
                % Note: an attribute is only imported if the attribute name matches with one of the attribute names defined in file
                for i = 1:numel(p.Attributes)
                    attributeName = p.Attributes{i};
                    idxAttribute = find(strcmpi(attributeNames, attributeName)); % find index of actual attribute
                    if ~isempty(idxAttribute)
                        A.(attributeName) = allData{3+idxAttribute};
                    end
                end
                
            % If attribute names are NOT defined in file
            else
            
                for i = 1:numel(p.Attributes)
                    attributeName = p.Attributes{i};
                    A.(attributeName) = allData{3+i};
                end
                
            end

        end

    end

% If input is an array
else

    X = p.pcData(:,1:3); % points (takes no time -> pass by reference)
    for i = 1:numel(p.Attributes)
        A.(p.Attributes{i}) = p.pcData(:,3+i);
    end
    
end

% Error if no point is present
if size(X,1) == 0
    error('Unable to read points from input data (empty matrix/file?)!');
end