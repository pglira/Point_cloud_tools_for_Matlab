function H = homotrafo(m, R, t)
% HOMOTRAFO Creates a transformation matrix for homogeneous coordinates.

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('m', @(x) numel(m)==1);
p.addRequired('R', @(x) isnumeric(x) && size(x,1)==3 && size(x,2)==3);
p.addRequired('t', @(x) isnumeric(x) && numel(x)==3); 
p.parse(m, R, t);
p = p.Results;
% Clear required input to avoid confusion
clear m R t

% Homogeneous transformation matrix --------------------------------------------

H = [p.m * p.R   [p.t(1); p.t(2); p.t(3)]
     zeros(1,3)                       1 ];

end