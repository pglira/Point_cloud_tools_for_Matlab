function obj = addAttribute(obj, attribute)
% ADDATTRIBUTE Add an attribute to the object.
% ------------------------------------------------------------------------------
% INPUT
% 1 [attribute]
%   Name of attribute which should be added. Actually, possible choices are:
%     * 'slope'
%        Slope (from 0 to 100 gradian) of each point based on its normal vector.
%        This attribute requires the components of the normal vectors nx, ny,
%        and nz for each point. They can be calculated with the method 'normals'
%        (see 'help pointCloud.normals').
%     * 'exposition'
%        Exposition (from 0 to 400 gradian) of each point based on its normal
%        vector. This attribute requires the components of the normal vectors
%        nx, ny, and nz for each point. They can be calculated with the method
%        'normals' (see 'help pointCloud.normals').
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Calculate and visualize the slope attribute of a point cloud.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%   pc.addAttribute('slope');
%   pc.plot('Color', 'A.slope', 'MarkerSize', 5);
%
% 2 Calculate and visualize the exposition attribute of a point cloud.
%   pc = pointCloud('Lion.xyz', 'Attributes', {'nx' 'ny' 'nz' 'roughness'});
%   pc.addAttribute('exposition');
%   pc.plot('Color', 'A.exposition', 'MarkerSize', 5);
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

validAttribute = {'slope' 'exposition'};

p = inputParser;
p.addRequired('attribute', @(x) any(strcmpi(x, validAttribute)));
p.parse(attribute);
p = p.Results;
% Clear required input to avoid confusion
clear attribute

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'ADDATTRIBUTE'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Add attribute ----------------------------------------------------------------

% Slope
if strcmpi(p.attribute, 'slope')
    
    % Points with no normal (i.e. with normal components equal to NaN)
    idxNoNormal = isnan(obj.A.nx) | isnan(obj.A.ny) | isnan(obj.A.nz);

    obj.A.slope = NaN(size(obj.X,1),1); % initialize with NaNs
    obj.A.slope(~idxNoNormal) = acosg(abs(obj.A.nz(~idxNoNormal))); % attention: abs introduced to make sure, slope ranges between 0 and 100, but in TLS slope > 100 may be useful

% Exposition    
elseif strcmpi(p.attribute, 'exposition')
    
    % Points with no normal (i.e. with normal components equal to NaN)
    idxNoNormal = isnan(obj.A.nx) | isnan(obj.A.ny) | isnan(obj.A.nz);
    
    polar = xyz2polar([obj.A.nx(~idxNoNormal) obj.A.ny(~idxNoNormal) obj.A.nz(~idxNoNormal)]);
    obj.A.exposition = NaN(size(obj.X,1),1); % initialize with NaNs
    obj.A.exposition(~idxNoNormal) = polar(:,2);

    % Set exposition to zero if normal points upwards (otherwise it is equal to NaN)
    obj.A.exposition(obj.A.nx == 0 & obj.A.ny == 0 & obj.A.nz == 1) = 0;

end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end