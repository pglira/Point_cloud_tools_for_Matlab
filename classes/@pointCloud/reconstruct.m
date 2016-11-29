function reconstruct(obj, varargin)
% RECONSTRUCT Remove deactivated points from object.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 [obj]
%   Updated object without deactivated points.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Thin out of point cloud.
%   pc = pointCloud('Lion.xyz');
%   pc.select('UniformSampling', 2);
%   pc.reconstruct;
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'RECONSTRUCT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Create new object with only active points ------------------------------------

% Remove deactivated points from coordinates
obj.X = obj.X(obj.act,:);

% Remove deactivated points from attributes
if isstruct(obj.A)
    
    % Note: attributes can not be updated field by field due to validation
    % function 'set.A' in pointCloud
    
    A = obj.A;  % OLD attribute structure
    obj.A = []; % NEW attribute structure
    
    % Fill NEW attribute structure with values from OLD attribute structure
    att = fields(A);
    for a = 1:numel(att)
        obj.A.(att{a}) = A.(att{a})(obj.act);
        A = rmfield(A, att{a}); % save memory
    end
    
end

% Update act vector
obj.act = obj.act(obj.act);

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end