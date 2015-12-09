function angOut = angpm200(angIn)
% ANGPM200 Angle transformation to the value range [-200, 200).
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% With this function a single angle or a vector of angles can be transformed to
% the value range [-200, 200).
% ------------------------------------------------------------------------------
% SYNTAX
% angOut = angpm200(angIn)
% ------------------------------------------------------------------------------
% INPUT
% angIn
%   Single angle or angle vector to convert.
% ------------------------------------------------------------------------------
% OUTPUT
% angOut
%   Single angle or angle vector converted to the value range [-200, 200).
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Transform a single angle.
%     angOut = angpm200(302);
%     angOut = angpm200(-1940);
%
% 2 Transform a vector of angles.
%     angOut = angpm200([302 -1940]);
% ------------------------------------------------------------------------------
% TODO
% 1 Code vectorization.
% ------------------------------------------------------------------------------
% pg@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

for i = 1:numel(angIn)
    if angIn(i) <= -200
        angOut(i) = angIn(i) + (floor(abs(angIn(i))/400)+1)*400;
    elseif angIn(i) > 200
        angOut(i) = angIn(i) - (floor(angIn(i)/400)+1)*400;
    else
        angOut(i) = angIn(i);
    end
end

end