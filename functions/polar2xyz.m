function X = polar2xyz(P)
% POLAR2XYZ Transformation of polar coordinates to cartesian coordinates.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% Transformation of polar coordinates [distance, horizontal angle, vertical
% angle] to cartesian coordinates [x, y, z].
% ------------------------------------------------------------------------------
% INPUT
% P
%   Matrix of polar coordinates distace, horizontal angle and vertical angle.
%   Each point in a row.
%   Horizontal angle is defined mathematically positive starting from x-axis.
%   Vertical   angle is defined as angle between point and zenith.
% ------------------------------------------------------------------------------
% OUTPUT
% X
%   Matrix of cartesian coordinates x, y and z. Each point in a row.
% ------------------------------------------------------------------------------
% EXAMPLES
% Transformation of randomly generated points into polar coordinates and back.
%   X1   = [rand(10,1)*10 rand(10,1)*5 rand(10,1)];
%   P    = xyz2polar(X1);
%   X2   = polar2xyz(P);
%   Diff = X1-X2;
% ------------------------------------------------------------------------------
% pg@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('P', @(x) isreal(x) && size(x,2) == 3);
p.parse(P);
p = p.Results;
% Clear required inputs to avoid confusion
clear P

% Transformation ---------------------------------------------------------------

d  = p.P(:,1);
ha = p.P(:,2);
va = p.P(:,3);

x = d .* cosg(ha) .* sing(va);
y = d .* sing(ha) .* sing(va);
z = d .* cosg(va);

% Output -----------------------------------------------------------------------

X = [x y z];

end