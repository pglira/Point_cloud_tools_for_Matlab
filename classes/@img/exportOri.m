function obj = exportOri(obj, file, varargin)
% EXPORTORI Export image (exterior and inner) orientation to file.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'file'  , @ischar);
p.addParameter('append', true, @islogical);
p.parse(file, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear file

% Start ------------------------------------------------------------------------

% procHierarchy = {'IMG' 'EXPORTORI'};
% msg('S', procHierarchy);
% msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Export orientation -----------------------------------------------------------

% Open file
if p.append
    fid = fopen(p.file, 'at');
else
    fid = fopen(p.file, 'wt');
end

fprintf(fid, '# %s\n', obj.label);

properties2write = {'X0' 'Y0' 'Z0' 'ome' 'phi' 'kap' 'c' 'x0' 'y0' 'a3' 'a4' 'a5' 'a6' 'rho0'};

for i = 1:numel(properties2write)
    
    if ~isempty(obj.(properties2write{i}))
        fprintf(fid, '%s = %.5f;\n', properties2write{i}, obj.(properties2write{i})); % precision is hard coded!
    end
    
end

% Close file
fclose(fid);

% End --------------------------------------------------------------------------

% msg('E', procHierarchy);

end