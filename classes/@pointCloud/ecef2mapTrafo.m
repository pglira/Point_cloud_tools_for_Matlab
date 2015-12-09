function objNew = ecef2mapTrafo(obj, mstruct, varargin)
% ECEF2MAPTRAFO Coordinate transformation from ecef to map coordinates.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired(  'mstruct');
p.addParamValue('KDTree', true, @islogical);
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

% Create new object with transformed coordinates (and attributes) --------------

objNew     = pointCloud([xm, ym, hEll], ...
                        'Label'     , obj.label, ...
                        'RedPoi'    , obj.redPoi, ...
                        'BucketSize', obj.BucketSize, ...
                        'KDTree'    , p.KDTree);

objNew.A   = obj.A;
objNew.act = obj.act;

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end