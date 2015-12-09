function objNew = reconstruct(obj)
% RECONSTRUCT Reconstruct object only with active points.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 [obj]
%   Updated object without deactivated points.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Thin out of point cloud and compare memory consumption before and after.
%   pc = pointCloud('Lion.xyz');
%   pc.info('ExtInfo', true); see 'memory consumption in Mbytes'
%   pc = pc.select('UniformSampling', 2);
%   pc = pc.reconstruct;
%   pc.info('ExtInfo', true); see 'memory consumption in Mbytes'
% ------------------------------------------------------------------------------
% philipp.glira@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'RECONSTRUCT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Create new object with only active points ------------------------------------

% Reduced and non reduced active points
XActRed = obj.X(obj.act,:); % reduced
XActNonRed = [XActRed(:,1)+obj.redPoi(1) XActRed(:,2)+obj.redPoi(2) XActRed(:,3)+obj.redPoi(3)]; % non reduced

% Create new object
objNew = pointCloud(XActNonRed, ...
                    'Label'     , obj.label, ...
                    'RedPoi'    , obj.redPoi, ...
                    'BucketSize', obj.BucketSize);

% Copy attributes
if isstruct(obj.A)
    att = fields(obj.A);
    for a = 1:numel(att)
        objNew.A.(att{a}) = obj.A.(att{a})(obj.act);
    end
end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end