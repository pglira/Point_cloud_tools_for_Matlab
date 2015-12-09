function angOut = ang0400(angIn)
% ANG0400 Angle transformation to the value range [0, 400).
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% With this function a single angle or a vector of angles can be transformed to
% the value range [0, 400).
% ------------------------------------------------------------------------------
% SYNTAX
% angOut = ang0400(angIn)
% ------------------------------------------------------------------------------
% INPUT
% angIn
%   Single angle or angle vector to convert.
% ------------------------------------------------------------------------------
% OUTPUT
% angOut
%   Single angle or angle vector converted to the value range [0, 400).
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Transform a single angle.
%     angOut = ang0400(602);
%     angOut = ang0400(-1940);
% 
% 2 Transform a vector of angles.
%     angOut = ang0400([602 -1940]);
% ------------------------------------------------------------------------------
% TODO
% 1 Code vectorization.
% ------------------------------------------------------------------------------
% pg@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

for r = 1:size(angIn,1)

    for c = 1:size(angIn,2)
    
        if angIn(r,c) < 0 % value is negative
            n = fix( abs(angIn(r,c))/400 );
            angOut(r,c) = angIn(r,c) + (n+1)*400;
        elseif angIn(r,c) >= 400 % when value is bigger/equal 400
            n = fix( angIn(r,c)/400 );
            angOut(r,c) = angIn(r,c) - n*400;
        else
            angOut(r,c) = angIn(r,c);
        end

    end
    
end