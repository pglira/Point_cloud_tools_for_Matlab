function save2(p2File, data, formatSpec)
% SAVE2 Save data to textfile.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% This function can be used to save arrays or vectors to an ascii textfile.
% ------------------------------------------------------------------------------
% INPUT
% 1 [p2File]
%   Path to textfile.
%
% 2 [data]
%   Data to write into textfile.
%
% 3 [formatSpec]
%   String with the format specification for fprintf.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Save coordinates given as (n,3) array to a xyz file.
%   save2('Y:\strip1.xyz', X, '%.3f %.3f %.3f\n');
% ------------------------------------------------------------------------------
% ACKNOWLEDGMENTS
% Fork of function 'save2', written by CaR.
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('p2File'    , @ischar);
p.addRequired('data'      , @isnumeric);
p.addRequired('formatSpec', @ischar);
p.parse(p2File, data, formatSpec);
p = p.Results;

% Write file -------------------------------------------------------------------

fid = fopen(p.p2File, 'wt');
if fid > -1
    fprintf(fid, p.formatSpec, p.data');
    fclose(fid);
else
    warning(['Can not open file ' p.p2File]);
end