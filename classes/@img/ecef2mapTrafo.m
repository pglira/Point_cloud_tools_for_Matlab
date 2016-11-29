function objNew = ecef2mapTrafo(obj, mstruct, varargin)
% ECEF2MAPTRAFO Transform exterior orientation from map to ecef coordinates.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('mstruct');
p.parse(mstruct);
p = p.Results;
% Clear required inputs to avoid confusion
clear mstruct

% Start ------------------------------------------------------------------------

% procHierarchy = {'IMG' 'ECEF2MAPTRAFO'};
% msg('S', procHierarchy);
% msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Conversion of position to ecef coordinates -----------------------------------

X0Ecef = obj.X0;
Y0Ecef = obj.Y0;
Z0Ecef = obj.Z0;

[lat, lon, Z0Map] = ecef2geodetic(X0Ecef, Y0Ecef, Z0Ecef, p.mstruct.geoid); % lat, lon in radian!
[X0Map, Y0Map] = mfwdtran(p.mstruct, lat*180/pi, lon*180/pi, Z0Map); % lat, lon in degrees!

obj.X0 = X0Map;
obj.Y0 = Y0Map;
obj.Z0 = Z0Map;

% Conversion of angles to ecef coordinates -------------------------------------

REcef = obj.R;

xUnitVectorEcef = REcef(:,1);
yUnitVectorEcef = REcef(:,2);
zUnitVectorEcef = REcef(:,3);

coordSysAxesEcef = [X0Ecef                    Y0Ecef                    Z0Ecef                      % origin
                    X0Ecef+xUnitVectorEcef(1) Y0Ecef+xUnitVectorEcef(2) Z0Ecef+xUnitVectorEcef(3)   % endpoint x unit vector
                    X0Ecef+yUnitVectorEcef(1) Y0Ecef+yUnitVectorEcef(2) Z0Ecef+yUnitVectorEcef(3)   % endpoint y unit vector
                    X0Ecef+zUnitVectorEcef(1) Y0Ecef+zUnitVectorEcef(2) Z0Ecef+zUnitVectorEcef(3)]; % endpoint z unit vector
                   
[lat, lon, coordSysAxesMap(:,3)] = ecef2geodetic(coordSysAxesEcef(:,1), coordSysAxesEcef(:,2), coordSysAxesEcef(:,3), p.mstruct.geoid); % lat, lon in radian!
[coordSysAxesMap(:,1), coordSysAxesMap(:,2)] = mfwdtran(p.mstruct, lat*180/pi, lon*180/pi, coordSysAxesMap(:,3)); % lat, lon in degrees!

xUnitVectorMap = [coordSysAxesMap(2,:) - coordSysAxesMap(1,:)]';
yUnitVectorMap = [coordSysAxesMap(3,:) - coordSysAxesMap(1,:)]';
zUnitVectorMap = [coordSysAxesMap(4,:) - coordSysAxesMap(1,:)]';

RMap = [xUnitVectorMap yUnitVectorMap zUnitVectorMap];

[ome, phi, kap] = R2opk(RMap);

obj.ome = ome;
obj.phi = phi;
obj.kap = kap;
 
objNew = obj;

% End --------------------------------------------------------------------------

% msg('E', procHierarchy);

end