function map2ecefTrafo(obj, mstruct, varargin)
% MAP2ECEFTRAFO Coordinate transformation from ecef to map coordinates.
%
% Example: definition of mstruct for UTM33N
% mstruct       = defaultm('utm');
% mstruct.zone  = '33n';
% mstruct.geoid = referenceEllipsoid('GRS 80');
% mstruct       = defaultm(mstruct);

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'mstruct');
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

% Update coordinates -----------------------------------------------------------

obj.X = [xEcef yEcef zEcef];
obj.info;

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end