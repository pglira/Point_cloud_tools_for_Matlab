function XOut = homocoord(X)
% HOMOCOORD Transformation from homogeneous to cartesian coordinates and vice versa.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('X', @(x) isnumeric(x) && (size(x,2)==3 || size(x,2)==4));
p.parse(X);
p = p.Results;
% Clear required input to avoid confusion
clear X

% Creation of homogeneous coordinates or cartesian coordinates -----------------

% From cartesion coordinates to homogeneous coordinates
if size(p.X,2) == 3, XOut = [p.X ones(size(p.X,1),1)]; end

% From homogeneous coordinates to cartesian coordinates
if size(p.X,2) == 4, XOut = p.X(:,1:3); end

end