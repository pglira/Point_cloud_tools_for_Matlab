function P = xyz2polar(X)
% XYZ2POLAR Transformation of cartesian coordinates to polar coordinates.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% Transformation of cartesian coordinates [x, y, z] to polar coordinates
% [distance, horizontal angle, vertical angle].
% ------------------------------------------------------------------------------
% INPUT
% X
%   Matrix of cartesian coordinates x, y and z. Each point in a row.
% ------------------------------------------------------------------------------
% OUTPUT
% P
%   Matrix of polar coordinates distace, horizontal angle and vertical angle.
%   Each point in a row.
%   Horizontal angle is defined mathematically positive starting from x-axis.
%   Vertical   angle is defined as angle between point and zenith.
% ------------------------------------------------------------------------------
% EXAMPLES
% Transformation of randomly generated points into polar coordinates and back.
%   X1   = [rand(10,1)*10 rand(10,1)*5 rand(10,1)];
%   P    = xyz2polar(X1);
%   X2   = polar2xyz(P);
%   Diff = X1-X2;
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('X', @(x) isreal(x) && size(x,2) == 3);
p.parse(X);
p = p.Results;
% Clear required inputs to avoid confusion
clear X

% Distance ---------------------------------------------------------------------

d = sqrt(p.X(:,1).^2 + p.X(:,2).^2 + p.X(:,3).^2);

% Vertical angle ---------------------------------------------------------------

va = acosg(p.X(:,3) ./ d); % always positive [0,200]

% Horizontal angle -------------------------------------------------------------

% Compute all 4 solutions for the horizontal angle
hSol(:,1) = acosg( p.X(:,1) ./ (d.*sing(va)) ); % sol1: always positive [   0,200]
hSol(:,2) = 400 - hSol(:,1);                    % sol2: always positive [ 200,400]
hSol(:,3) = asing( p.X(:,2) ./ (d.*sing(va)) ); % sol3: can be negative [-100,100]
hSol(:,4) = 200 - hSol(:,3);                    % sol4: always positive [ 100,300]

% Eliminate complex part (occure if argument of acosg/asing is not in range
% [-1, 1]); should be the case just for few points
hSol = real(hSol);

% If some values of sol3 are negativ, transform them into positive range
idxNeg = hSol(:,3) < 0;
hSol(idxNeg,3) = hSol(idxNeg,3) + 400; % now positive

% Compute the differences between the solutions
% Pairs for comparisons: 1,3 1,4 2,3 2,4
diff = [hSol(:,1)-hSol(:,3), hSol(:,1)-hSol(:,4), hSol(:,2)-hSol(:,3), hSol(:,2)-hSol(:,4)];
% Find for each point the pair with the lowest difference
[~, idx] = min(abs(diff), [], 2); 

% If pair 1 (1,3) take column 1 of hSol (i.e. sol1)
% If pair 2 (1,4) take column 1 of hSol (i.e. sol1)
% If pair 3 (2,3) take column 2 of hSol (i.e. sol2)
% If pair 4 (2,4) take column 2 of hSol (i.e. sol2)
idx(idx == 2) = 1;
idx(idx == 3) = 2;
idx(idx == 4) = 2;

% Convert subscripts to linear indices to access the elements
idxLin = sub2ind(size(hSol), [1:size(hSol,1)]', idx);

% Get values
ha = hSol(idxLin);

% Output -----------------------------------------------------------------------

P = [d ha va];

end