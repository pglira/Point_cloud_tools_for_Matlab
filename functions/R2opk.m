function [o, p, k] = R2opk(R)

% % phi --------------------------------------------------------------------------
% 
% try
% 
%     p = asing( R(1,3));
%     p = ang0400(p);
%     
% catch
%     
%     p = NaN;
%     
% end
% 
% % omega ------------------------------------------------------------------------
% 
% try
%     
%     o = asing(-R(2,3) / cosg(p));
%     
% catch
%     
%     o = NaN;
%     
% end
% 
% % kappa ------------------------------------------------------------------------
% 
% try
% 
%     k1_1 = asing(-R(1,2) / cosg(p)); % pos or neg
% 
%     if k1_1 >= 0, k1_2 = ang0400(200 - k1_1);      end
%     if k1_1 <  0, k1_2 = ang0400(200 + abs(k1_1)); end
% 
%     k1_1 = ang0400(k1_1); % always pos
% 
%     k2_1 = acosg(R(1,1) / cosg(p)); % always pos
%     k2_2 = ang0400(-k2_1);
% 
%     if abs(k1_1 - k2_1) < 1, k = mean([k1_1 k2_1]); end
%     if abs(k1_1 - k2_2) < 1, k = mean([k1_1 k2_2]); end
%     if abs(k1_2 - k2_1) < 1, k = mean([k1_2 k2_1]); end
%     if abs(k1_2 - k2_2) < 1, k = mean([k1_2 k2_2]); end
%     
%     if ~exist('k'), k = NaN; end
%     
% catch
%     
%     k = NaN;
%     
% end

% From omphika.m
o = atan2(-R(2,3), R(3,3)) * 200/pi;
p = asin(R(1,3))           * 200/pi;
k = atan2(-R(1,2), R(1,1)) * 200/pi;
    
end