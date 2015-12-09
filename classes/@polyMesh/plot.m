function plot(obj)
% PLOT Plot mesh.

% Start ------------------------------------------------------------------------

procHierarchy = {'POLYMESH' 'PLOT'};
msg('S', procHierarchy);

% Plot -------------------------------------------------------------------------

patch('Vertices', obj.vertices, 'Faces', obj.faces, 'FaceVertexCData', zeros(size(obj.vertices,1),1));

axis equal
shading flat
grid on
camlight
view(3)
hold on

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end