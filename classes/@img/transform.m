function transform(obj, A, t, varargin)
% TRANSFORM Transform image exterior orientation.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired(  'A'              , @(x) isnumeric(x) && size(x,1)==3 && size(x,2)==3);
p.addRequired(  't'              , @(x) isnumeric(x) && numel(x)==3); 
% p.addParameter('RedPoi', [0 0 0], @(x) numel(x)==3); % not supported yet!!!
p.parse(A, t, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear A t

% Start ------------------------------------------------------------------------

% procHierarchy = {'IMG' 'TRANSFORM'};
% msg('S', procHierarchy);
% msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Transform --------------------------------------------------------------------

% Unit vectors
xUnitVector = obj.R(:,1);
yUnitVector = obj.R(:,2);
zUnitVector = obj.R(:,3);

% Point cloud for transformation
X = [obj.X0                  obj.Y0                  obj.Z0                    % projection center
     obj.X0 + xUnitVector(1) obj.Y0 + xUnitVector(2) obj.Z0 + xUnitVector(3)   % projection center + xUnitVector
     obj.X0 + yUnitVector(1) obj.Y0 + yUnitVector(2) obj.Z0 + yUnitVector(3)   % projection center + yUnitVector
     obj.X0 + zUnitVector(1) obj.Y0 + zUnitVector(2) obj.Z0 + zUnitVector(3)]; % projection center + zUnitVector

% Homogeneous transformation matrix
H = homotrafo(1, p.A, p.t);

% Homogeneous coordinates
Xh = homocoord(X);

% Transformation of coordinates!
XhTrafo = H * Xh';

% Transformed non homogeneous coordinates
XNew = homocoord(XhTrafo');

% New projection center
X0New = XNew(1,1);
Y0New = XNew(1,2);
Z0New = XNew(1,3);

% New unit vectors
xUnitVectorNew = [XNew(2,1)-X0New XNew(2,2)-Y0New XNew(2,3)-Z0New]'; 
yUnitVectorNew = [XNew(3,1)-X0New XNew(3,2)-Y0New XNew(3,3)-Z0New]'; 
zUnitVectorNew = [XNew(4,1)-X0New XNew(4,2)-Y0New XNew(4,3)-Z0New]';

% New rotation matrix
RNew = [xUnitVectorNew yUnitVectorNew zUnitVectorNew];

% New rotation angles
[omeNew, phiNew, kapNew] = R2opk(RNew);

% Save to object
obj.X0  = XNew(1,1); 
obj.Y0  = XNew(1,2);
obj.Z0  = XNew(1,3);
obj.ome = omeNew;
obj.phi = phiNew;
obj.kap = kapNew;

% End --------------------------------------------------------------------------

% msg('E', procHierarchy);

end