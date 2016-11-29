function correctNormals(obj)
% CORRECTNORMALS Correct normal vectors.

% Start ------------------------------------------------------------------------

% procHierarchy = {'POINTCLOUD' 'CORRECTNORMALS'};
% msg('S', procHierarchy);

% Normalize normals ------------------------------------------------------------

% Normal vectors
n = [obj.A.nx obj.A.ny obj.A.nz];

% Length of all normal vectors
l = sqrt(dot(n',n')');

% Normalization
obj.A.nx = obj.A.nx ./ l;
obj.A.ny = obj.A.ny ./ l;
obj.A.nz = obj.A.nz ./ l;

% End --------------------------------------------------------------------------

% msg('E', procHierarchy);

end