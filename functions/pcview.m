function pcview(varargin)

% If no files are defined
if nargin == 0

    % Select file(s)    
    [files, path] = uigetfile('*.*', 'Select point cloud file(s)', 'MultiSelect', 'on');
    if ~iscell(files)
        if files == 0 % if no file was selected
            return;
        else % if only one file was selected
            file = files; clear files; files{1} = file;
        end
    end

    for i = 1:numel(files), pcData{i} = fullfile(path, files{i}); end
    
% If input data is defined
else
    pcData = varargin;
end
    
% Import and plot point cloud(s)
for i = 1:numel(pcData)
    pc = pointCloud(pcData{i});
    pc.plot;
end

end