function obj = removeVertices(obj, idxVertices2del)
% REMOVEVERTICES Remove vertices (and corresponding faces) from mesh.

% Start ------------------------------------------------------------------------

procHierarchy = {'POLYMESH' 'REMOVE VERTICES'};
msg('S', procHierarchy);

% Remove vertices and faces ----------------------------------------------------
% Loop was avoided with function ismember

if islogical(idxVertices2del), idxVertices2del = find(idxVertices2del); end % conversion if a logical vector is given

idxVertices2keep                  = [1:size(obj.vertices,1)]'; % all indices
idxVertices2keep(idxVertices2del) = [];

[Lia, Locb] = ismember(obj.faces, idxVertices2keep);

obj.faces = Locb;

% Delete faces
idxFaces2del = sum(Lia,2) < 3;
obj.faces(idxFaces2del,:) = [];

% Delete vertices
obj.vertices = obj.vertices(idxVertices2keep,:);

% End --------------------------------------------------------------------------

msg('V', numel(idxVertices2del), 'number of removed vertices', 'Prec', 0);
msg('E', procHierarchy);

end