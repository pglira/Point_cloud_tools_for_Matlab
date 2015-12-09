function obj = weight(obj, mode, varargin)
% Note: w must be always within the range 0 and 1! 0 <= w <= 1

% Input parsing ----------------------------------------------------------------

validMode = {'NormalsProduct' 'Roughness'};

p = inputParser;
p.addRequired('mode', @(x) any(strcmpi(x, validMode)));
p.parse(mode, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear mode

% Start ------------------------------------------------------------------------

procHierarchy = {'CORRPOI' 'WEIGHT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('pc1id = ''%d'', pc2id = ''%d''', obj.pc1id, obj.pc2id));
msg('I', procHierarchy, sprintf('IN: Mode = ''%s''', p.mode));

% Correspondences present? -----------------------------------------------------

if size(obj.X1,1) == 0
    msg('I', procHierarchy, 'termination of function due to missing correspondences');
    return;
end

% Weight -----------------------------------------------------------------------

if strcmpi(p.mode, 'NormalsProduct')
   
    w = abs(cosg(obj.dAlpha));
    
elseif strcmpi(p.mode, 'Roughness')
    
    roughnessMax    = max([obj.A1.roughness  obj.A2.roughness], [], 2); % max for each row
    roughnessMaxAll = max([obj.A1.roughness; obj.A2.roughness]);        % max of all points
    
    w = 1 - roughnessMax./roughnessMaxAll;
    
end

% Update weights
obj.A.w = obj.A.w .* w;

% End --------------------------------------------------------------------------

msg('E', procHierarchy);
obj.info

end