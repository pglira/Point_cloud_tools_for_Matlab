function objNew = map2ecefTrafo(obj, mstruct, varargin)
% MAP2ECEFTRAFO Coordinate transformation from ecef to map coordinates.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired(  'mstruct');
p.addParamValue('KDTree', true, @islogical);
p.parse(mstruct, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear mstruct

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'MAP2ECEFTRAFO'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Conversion to ecef coordinates -----------------------------------------------

[lat, lon, hEll] = minvtran(p.mstruct, obj.X(:,1), obj.X(:,2), obj.X(:,3)); % lat, lon in degrees!
[xEcef, yEcef, zEcef] = geodetic2ecef(lat*pi/180, lon*pi/180, hEll, p.mstruct.geoid); % lat, lon in radian!

% Create new object with transformed coordinates (and attributes) --------------

objNew     = pointCloud([xEcef, yEcef, zEcef], ...
                        'Label'     , obj.label, ...
                        'RedPoi'    , obj.redPoi, ...
                        'BucketSize', obj.BucketSize, ...
                        'KDTree'    , p.KDTree);

objNew.A   = obj.A;
objNew.act = obj.act;

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end