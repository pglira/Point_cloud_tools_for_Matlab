function obj = weight(obj, mode, varargin)
% Note: w must be always within the range 0 and 1! 0 <= w <= 1

% Input parsing ----------------------------------------------------------------

validMode = {'DeltaAngle' 'Roughness'};

p = inputParser;
p.addRequired('mode', @(x) any(strcmpi(x, validMode)));
p.parse(mode, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear mode

% Start ------------------------------------------------------------------------

procHierarchy = {'CORRPOINTS' 'WEIGHT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Corr. points label = ''%s''', obj.label));
msg('I', procHierarchy, sprintf('IN: Mode = ''%s''', p.mode));

% Correspondences present? -----------------------------------------------------

if obj.noCP == 0
    msg('I', procHierarchy, 'no correspondences present!');
    msg('E', procHierarchy);
    return;
end

% Weight -----------------------------------------------------------------------

if strcmpi(p.mode, 'DeltaAngle')
   
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

end