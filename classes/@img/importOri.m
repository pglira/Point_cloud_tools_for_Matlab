function importOri(obj, file, varargin)
% IMPORTORI Import image (exterior and inner) orientation from file.

% Input parsing ----------------------------------------------------------------

validFormat = {'own' 'pix4d'};

p = inputParser;
p.addRequired('file', @ischar);
p.addParameter('Format', 'own', @(x) any(strcmpi(x, validFormat)));
p.parse(file, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear file

% Start ------------------------------------------------------------------------

% procHierarchy = {'IMG' 'IMPORTORI'};
% msg('S', procHierarchy);
% msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Import orientation -----------------------------------------------------------

% Read whole file
fid = fopen(p.file);
allData = textscan(fid, '%s', 'Delimiter', '\n');
allData = allData{1}; % each line is one cell
fclose(fid);

if strcmpi(p.Format, 'own')

    % First line of image
    idxFirstLine = find(strncmpi(['# ' obj.label], allData, numel(obj.label)+2));

    % Get next line
    i = 1;
    line = allData{idxFirstLine+i};

    while ~strcmpi(line(1), '#')

        % Add semicolon if not included
        if ~strcmp(line(end), ';'), line(end+1) = ';'; end

        % Run line
        eval(['obj.' line]);

        % Get next line
        i = i+1;
        if idxFirstLine+i <= size(allData,1)
            line = allData{idxFirstLine+i};
        else % if the end of file is reached
            break;
        end

    end
    
elseif strcmpi(p.Format, 'pix4d')
    
    % From 'prjName_calibrated_external_camera_parameters.txt'
    
    % Line of image
    [~, file] = fileparts(obj.label);
    idxImg = find(strncmpi(file, allData, numel(file)));
    
    % Read data
    data = textscan(allData{idxImg}, '%s %f %f %f %f %f %f');
    
    % Exterior orientation: projection center
    obj.X0 = data{2};
    obj.Y0 = data{3};
    obj.Z0 = data{4};
    
    % Exterior orientation: rotation angles
    obj.ome = data{5}*10/9;
    obj.phi = data{6}*10/9;
    obj.kap = data{7}*10/9;
    
end

% End --------------------------------------------------------------------------

% msg('E', procHierarchy);

end