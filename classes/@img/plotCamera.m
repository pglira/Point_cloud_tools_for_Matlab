function plotCamera(obj, varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParameter('Scale', 50, @isnumeric);
p.parse(varargin{:});
p = p.Results;

% Start ------------------------------------------------------------------------

procHierarchy = {'IMG' 'PLOTCAMERA'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Plot -------------------------------------------------------------------------

% Projection center
plot3(obj.X0, obj.Y0, obj.Z0, '.m', 'MarkerSize', 10);
hold on;
axis equal;

xUnitVector = obj.R(:,1);
yUnitVector = obj.R(:,2);
zUnitVector = obj.R(:,3);

% Note: interior orientation is not considered here, i.e. origin of image
%       coordinate system is projection center.

% Plot xUnitVector
X = [obj.X0                        obj.Y0                        obj.Z0
     obj.X0+xUnitVector(1)*p.Scale obj.Y0+xUnitVector(2)*p.Scale obj.Z0+xUnitVector(3)*p.Scale];
plot3(X(:,1), X(:,2), X(:,3), '-r');

% Plot yUnitVector
X = [obj.X0                        obj.Y0                        obj.Z0
     obj.X0+yUnitVector(1)*p.Scale obj.Y0+yUnitVector(2)*p.Scale obj.Z0+yUnitVector(3)*p.Scale];
plot3(X(:,1), X(:,2), X(:,3), '-g');

% Plot zUnitVector
X = [obj.X0                        obj.Y0                        obj.Z0
     obj.X0+zUnitVector(1)*p.Scale obj.Y0+zUnitVector(2)*p.Scale obj.Z0+zUnitVector(3)*p.Scale];
plot3(X(:,1), X(:,2), X(:,3), '-b');

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end