function dR = opk2dR(o, p, k)
% Note: input angles in radian!!! (not gradian!!!)

dR = [ 1 -k  p
       k  1 -o
      -p  o  1];
 
end