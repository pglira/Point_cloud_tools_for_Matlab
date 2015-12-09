function dAlpha = angVector(v1, v2)

% Product of vectors
prod = dot(v1', v2');

% Some elements can be slightly greater than 1 or smaller than -1
% Should not be the case if normals are normalized, but happens anyway.
% If not corrected, dAlpha has some imaginary values.
prod( prod >  1 ) =  1;
prod( prod < -1 ) = -1;

% Angle between normals of corresponding points
dAlpha = acosg(prod)';

end