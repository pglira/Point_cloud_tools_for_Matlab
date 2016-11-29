function hPlot = plotNormals(obj, varargin)
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
%   pc.select('UniformSampling', 2);
%   pc.plot('Color', 'r', 'MarkerSize', 5);
%   pc.plotNormals('Color', 'y', 'Scale', 10);
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParameter('Arrows', true, @islogical);
p.addParameter('Scale' , 1   , @isnumeric);
p.addParameter('Color' , 'm');
% Undocumented
p.addParameter('Axes', gca);
p.parse(varargin{:});
p = p.Results;

% Plot of normals --------------------------------------------------------------

% Plot!
if p.Arrows
    hPlot = quiver3(p.Axes, obj.X(obj.act,1), obj.X(obj.act,2), obj.X(obj.act,3), obj.A.nx(obj.act)*p.Scale, obj.A.ny(obj.act)*p.Scale, obj.A.nz(obj.act)*p.Scale, 0, 'Color', p.Color); % faster than plot3!
else
    hPlot = plot3(p.Axes, [obj.X(obj.act,1) obj.X(obj.act,1)+obj.A.nx(obj.act)*p.Scale]', ...
                          [obj.X(obj.act,2) obj.X(obj.act,2)+obj.A.ny(obj.act)*p.Scale]', ...
                          [obj.X(obj.act,3) obj.X(obj.act,3)+obj.A.nz(obj.act)*p.Scale]', 'Color', p.Color);
end

end