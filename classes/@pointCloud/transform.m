function transform(obj, m, A, t, varargin)
% TRANSFORM Coordinate transformation of point cloud.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * Transformation model:
%   ----------------------------
%    xNew = m * A * xActual + t
%   ----------------------------
%   where m ... 1-by-1 scale
%         A ... 3-by-3 matrix
%         t ... 3-by-1 translation vector -> [tx; ty; tz]
%
%  * If coordinates should only be scaled, use the identity matrix as A (command
%    'eye(3)') and a null vector as translation vector (command 'zeros(3,1)').
%
%  * If present, also the normal vectors are transformed.
% ------------------------------------------------------------------------------
% INPUT
% 1 [m]
%   Scale as scalar.
% 
% 2 [A]
%   Any matrix of size 3-by-3.
%
% 3 [t]
%   Translation vector of size 3-by-1.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 [obj]
%   Updated object.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Rotate point cloud by 100 gradians (=90 degree) about z axis.
%   pc = pointCloud('Lion.xyz');
%   R = opk2R(0, 0, 100); % create rotation matrix
%   pc.transform(1, R, zeros(3,1)); % no scale, no translation
%   pc.plot;
%
% 2 Apply only scale.
%   pc = pointCloud('Lion.xyz');
%   pc.transform(1e-3, eye(3), zeros(3,1)); % transformation from mm -> m
%   pc.plot;
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('m', @(x) isnumeric(x));
p.addRequired('A', @(x) isnumeric(x) && size(x,1)==3 && size(x,2)==3);
p.addRequired('t', @(x) isnumeric(x) && numel(x)==3); 
p.parse(m, A, t);
p = p.Results;
% Clear required inputs to avoid confusion
clear m A t

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'TRANSFORM'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Report transformation parameters ---------------------------------------------

msg('I', procHierarchy, 'Transformation parameters:');

% Check if A is an orthogonal matrix
T = p.A'-inv(p.A) < 1e-10; % each element should be 1 if A is orthogonal
if all(T)
    
    % omega, phi, kappa from matrix A
    try
        [om, phi, ka] = R2opk(p.A); % fails sometimes
    catch
        om  = NaN;
        phi = NaN;
        ka  = NaN;
    end
    
    msg('V', om , 'omega', 'Prec', 4);
    msg('V', phi, 'phi'  , 'Prec', 4);
    msg('V', ka , 'kappa', 'Prec', 4);
    
else
    
    msg('V', p.A(1,1), 'a11', 'Prec', 4);
    msg('V', p.A(1,2), 'a12', 'Prec', 4);
    msg('V', p.A(1,3), 'a13', 'Prec', 4);
    msg('V', p.A(2,1), 'a21', 'Prec', 4);
    msg('V', p.A(2,2), 'a22', 'Prec', 4);
    msg('V', p.A(2,3), 'a23', 'Prec', 4);
    msg('V', p.A(3,1), 'a31', 'Prec', 4);
    msg('V', p.A(3,2), 'a32', 'Prec', 4);
    msg('V', p.A(3,3), 'a33', 'Prec', 4); 
    
end
    
msg('V', p.t(1), 't / x', 'Prec', 3);
msg('V', p.t(2), 't / y', 'Prec', 3);
msg('V', p.t(3), 't / z', 'Prec', 3);
msg('V', p.m   , 'm'    , 'Prec', 9);

% Transformation of points -----------------------------------------------------

% Homogeneous transformation matrix
H = homotrafo(p.m, p.A, p.t);

% Euclidean coordinates
X = obj.X;

% Homogeneous coordinates
Xh = homocoord(X);

% Transformation of reduced coordinates!
XhTrafo = H * Xh';

% Transformed non homogeneous coordinates
XNewRed    = homocoord(XhTrafo'); % reduced
% XNewNonRed = [XNewRed(:,1)+obj.redPoi(1) XNewRed(:,2)+obj.redPoi(2) XNewRed(:,3)+obj.redPoi(3)]; % non reduced

obj.X = XNewRed;

% Transformation of normals (if present) ---------------------------------------

if isstruct(obj.A)
    
    attributes = fields(obj.A);

    if any(strcmpi(attributes, 'nx'))

        % Homogeneous coordinates
        Nh = homocoord([obj.A.nx obj.A.ny obj.A.nz]);

        % Homogeneous transformation matrix (without scale and translation!)
        H = homotrafo(1, inv(p.A'), [0 0 0]);

        % Transformation of normals!
        NhTrafo = H * Nh';

        % Euclidean coordinates
        n = homocoord(NhTrafo');

        % Save to object
        obj.A.nx = n(:,1);
        obj.A.ny = n(:,2);
        obj.A.nz = n(:,3);

        obj.correctNormals;

    end
    
end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end