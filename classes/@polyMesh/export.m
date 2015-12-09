function export(obj, path)
% EXPORT Export mesh to a file.

% Start ------------------------------------------------------------------------

procHierarchy = {'POLYMESH' 'EXPORT'};
msg('S', procHierarchy);

% Export -----------------------------------------------------------------------

fid = fopen(path, 'wt');

% Header
fprintf(fid, 'ply\n');
fprintf(fid, 'format ascii 1.0\n');
fprintf(fid, 'element vertex %d\n', size(obj.vertices,1)); % start vertices
fprintf(fid, 'property float x\n');
fprintf(fid, 'property float y\n');
fprintf(fid, 'property float z\n');
fprintf(fid, 'element face %d\n', size(obj.faces,1)); % start faces
fprintf(fid, 'property list uchar int vertex_indices\n'); 
fprintf(fid, 'end_header\n');
    
% Write vertices
fprintf(fid, '%.3f %.3f %.3f\n', obj.vertices');

% Write faces
fprintf(fid, '3 %d %d %d\n', obj.faces' - 1); % reduce IDs by one!

fclose(fid);

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end