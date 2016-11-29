function objNew = map2ecefTrafo(obj, mstruct, varargin)
% MAP2ECEFTRAFO Transform exterior orientation from ecef to map coordinates.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('mstruct');
p.parse(mstruct);
p = p.Results;
% Clear required inputs to avoid confusion
clear mstruct

% Start ------------------------------------------------------------------------

% procHierarchy = {'IMG' 'MAP2ECEFTRAFO'};
% msg('S', procHierarchy);
% msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Conversion of position to ecef coordinates -----------------------------------

X0Map = obj.X0;
Y0Map = obj.Y0;
Z0Map = obj.Z0;

[lat, lon, hEll] = minvtran(p.mstruct, X0Map, Y0Map, Z0Map); % lat, lon in degrees!
[X0Ecef, Y0Ecef, Z0Ecef] = geodetic2ecef(lat*pi/180, lon*pi/180, hEll, p.mstruct.geoid); % lat, lon in radian!

obj.X0 = X0Ecef;
obj.Y0 = Y0Ecef;
obj.Z0 = Z0Ecef;

% Conversion of angles to ecef coordinates -------------------------------------

RMap = obj.R;

xUnitVectorMap = RMap(:,1);
yUnitVectorMap = RMap(:,2);
zUnitVectorMap = RMap(:,3);

coordSysAxesMap = [X0Map                   Y0Map                   Z0Map                     % origin
                   X0Map+xUnitVectorMap(1) Y0Map+xUnitVectorMap(2) Z0Map+xUnitVectorMap(3)   % endpoint x unit vector
                   X0Map+yUnitVectorMap(1) Y0Map+yUnitVectorMap(2) Z0Map+yUnitVectorMap(3)   % endpoint y unit vector
                   X0Map+zUnitVectorMap(1) Y0Map+zUnitVectorMap(2) Z0Map+zUnitVectorMap(3)]; % endpoint z unit vector
                   
[lat, lon, hEll] = minvtran(p.mstruct, coordSysAxesMap(:,1), coordSysAxesMap(:,2), coordSysAxesMap(:,3)); % lat, lon in degrees!
[coordSysAxesEcef(:,1), coordSysAxesEcef(:,2), coordSysAxesEcef(:,3)] = geodetic2ecef(lat*pi/180, lon*pi/180, hEll, p.mstruct.geoid); % lat, lon in radian!

xUnitVectorECEF = [coordSysAxesEcef(2,:) - coordSysAxesEcef(1,:)]';
yUnitVectorECEF = [coordSysAxesEcef(3,:) - coordSysAxesEcef(1,:)]';
zUnitVectorECEF = [coordSysAxesEcef(4,:) - coordSysAxesEcef(1,:)]';

RECEF = [xUnitVectorECEF yUnitVectorECEF zUnitVectorECEF];

[ome, phi, kap] = R2opk(RECEF);

obj.ome = ome;
obj.phi = phi;
obj.kap = kap;
  
objNew = obj;

% End --------------------------------------------------------------------------

% msg('E', procHierarchy);

end