function ecef2mapTrafo(obj, mstruct, varargin)
% ECEF2MAPTRAFO Coordinate transformation from ecef to map coordinates.
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

procHierarchy = {'POINTCLOUD' 'ECEF2MAPTRAFO'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Conversion to map coordinates ------------------------------------------------

[lat, lon, hEll] = ecef2geodetic(obj.X(:,1), obj.X(:,2), obj.X(:,3), p.mstruct.geoid); % lat, lon in radian!

[xm, ym] = mfwdtran(p.mstruct, lat*180/pi, lon*180/pi, hEll); % lat, lon in degrees!

% Update coordinates -----------------------------------------------------------

obj.X = [xm ym hEll];
obj.info;

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end