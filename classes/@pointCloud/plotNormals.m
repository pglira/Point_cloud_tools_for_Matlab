function plotNormals(obj, varargin)
% PLOTNORMALS Plot normal vectors of point cloud in 3d.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * Only the normals of active points are visualized.
% ------------------------------------------------------------------------------
% INPUT
% 1 ['Arrows', arrows]
%   Logical value defining if normals are visualized as arrows (true) or as
%   simple lines (false). The visualisation of arrows is faster than the one
%   with lines.
%
% 2 ['Scale', scale]
%   Scaling factor of normals.
%
% 3 ['Color', color]
%   Color of the normals. For possible values, look for 'ColorSpec' in the
%   documentation.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Plot normals scaled by factor of 10.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz'});
%   pc = pc.select('UniformSampling', 2);
%   pc.plot('Color', 'r', 'MarkerSize', 5);
%   pc.plotNormals('Scale', 10);
% ------------------------------------------------------------------------------
% philipp.glira@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParamValue('Arrows', true, @islogical);
p.addParamValue('Scale' , 1   , @isnumeric);
p.addParamValue('Color' , 'm');
p.parse(varargin{:});
p = p.Results;

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'PLOTNORMALS'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Plot of normals --------------------------------------------------------------

% Plot!
if p.Arrows
    quiver3(obj.X(obj.act,1), obj.X(obj.act,2), obj.X(obj.act,3), obj.A.nx(obj.act)*p.Scale, obj.A.ny(obj.act)*p.Scale, obj.A.nz(obj.act)*p.Scale, 0, 'Color', p.Color); % faster than plot3!
else
    plot3([obj.X(obj.act,1) obj.X(obj.act,1)+obj.A.nx(obj.act)*p.Scale]', ...
          [obj.X(obj.act,2) obj.X(obj.act,2)+obj.A.ny(obj.act)*p.Scale]', ...
          [obj.X(obj.act,3) obj.X(obj.act,3)+obj.A.nz(obj.act)*p.Scale]', 'Color', p.Color);
end

xlabel('x');
ylabel('y');
zlabel('z');
hold('on');
axis('equal');
grid('on');
set(gca, 'Color' , [0.3 0.3 0.3]);

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end