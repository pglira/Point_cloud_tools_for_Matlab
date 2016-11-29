function info(obj, varargin)
% INFO Report informations about the point cloud to the command window.
% ------------------------------------------------------------------------------
% INPUT
% 1 ['ExtInfo', extInfo]
%   If true, extended informations about the point cloud are reported.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Report only standard informations.
%   pc = pointCloud('Lion.xyz');
%   pc.info;
%
% 2 Report also extended informations.
%   pc = pointCloud('Lion.xyz');
%   pc.info('ExtInfo', true);
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'INFO'};
msg('S', procHierarchy);

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addParameter('ExtInfo', false, @islogical);
p.parse(varargin{:});
p = p.Results;

% Output of standard info ------------------------------------------------------

msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

msg('V', obj.noPoints , 'number of             points', 'Prec', 0);
msg('V', sum(obj.act) , 'number of   activated points', 'Prec', 0);
msg('V', sum(~obj.act), 'number of deactivated points', 'Prec', 0);

msg('V', obj.lim.min(1), 'min / x');
msg('V', obj.lim.max(1), 'max / x');
msg('V', obj.lim.min(2), 'min / y');
msg('V', obj.lim.max(2), 'max / y');
msg('V', obj.lim.min(3), 'min / z');
msg('V', obj.lim.max(3), 'max / z');

% Output of extended info ------------------------------------------------------

if p.ExtInfo

    msg('V', obj.lim.max(1)-obj.lim.min(1), 'max-min / x');
    msg('V', obj.lim.max(2)-obj.lim.min(2), 'max-min / y');
    msg('V', obj.lim.max(3)-obj.lim.min(3), 'max-min / z');
    
    msg('V', obj.cog(1), 'center of gravity / x');
    msg('V', obj.cog(2), 'center of gravity / y');
    msg('V', obj.cog(3), 'center of gravity / z');

end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end