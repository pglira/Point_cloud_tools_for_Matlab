function plot_addPC(~, event_obj)
        
% Select file(s)
[files, path] = uigetfile('*.*', 'Select point cloud file(s)', 'MultiSelect', 'on');
if ~iscell(files), if files == 0, return; end, end % if no file was selected
if ischar(files), files = {files}; end % convert to cell if only one file was selected

% Import and plot point cloud(s)
for i = 1:numel(files)
    pc = pointCloud(fullfile(path, files{i}));
    pc.plot;
end

end
