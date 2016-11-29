function obj = rejection(obj, mode, varargin)

% Input parsing ----------------------------------------------------------------

validMode = {'Attribute' 'dAlphaNaN'};

p = inputParser;
p.addRequired( 'mode'                , @(x) any(strcmpi(x, validMode)));
p.addParameter('AttributeName'  , '' , @ischar);          % for mode 'Attribute'
p.addParameter('AttributeMinMax', [] , @(x) numel(x)==2); % for mode 'Attribute'
p.parse(mode, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear mode

% Start ------------------------------------------------------------------------

procHierarchy = {'CORRPOINTS' 'REJECTION'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Corr. points label = ''%s''', obj.label));
msg('I', procHierarchy, sprintf('IN: Mode = ''%s''', p.mode));
if strcmpi(p.mode, 'Attribute')
    msg('I', procHierarchy, sprintf('IN: AttributeName = ''%s''', p.AttributeName));
    msg('V', p.AttributeMinMax(1), 'IN: AttributeMinMax(1)', 'Prec', 3);
    msg('V', p.AttributeMinMax(2), 'IN: AttributeMinMax(2)', 'Prec', 3); 
end

% Correspondences present? -----------------------------------------------------

if obj.noCP == 0
    msg('I', procHierarchy, 'no correspondences present!');
    msg('E', procHierarchy);
    return;
end

% Rejection of all correspondences where isnan(dAlpha) -------------------------

if strcmpi(p.mode, 'dAlphaNaN')
    
    idxRejection = isnan(obj.dAlpha);
    
end

% Rejection based on an attribute ----------------------------------------------

if strcmpi(p.mode, 'Attribute')
    
    att = obj.getAttribute(p.AttributeName);
    
    idxRejection = att >= min(p.AttributeMinMax) & att <= max(p.AttributeMinMax);
    
end

% Rejection --------------------------------------------------------------------

msg('V', sum(idxRejection), 'no. of rejected correspondences', 'Prec', 0);

obj.X1  = obj.X1(~idxRejection,:);
obj.X2  = obj.X2(~idxRejection,:);

% Rejection of attributes
if ~isempty(obj.A) , att  = fields(obj.A) ; else att  = []; end
if ~isempty(obj.A1), att1 = fields(obj.A1); else att1 = []; end
if ~isempty(obj.A2), att2 = fields(obj.A2); else att2 = []; end
for a = 1:numel(att) , obj.A.(att{a})   = obj.A.(att{a})(~idxRejection);   end
for a = 1:numel(att1), obj.A1.(att1{a}) = obj.A1.(att1{a})(~idxRejection); end
for a = 1:numel(att2), obj.A2.(att2{a}) = obj.A2.(att2{a})(~idxRejection); end

if ~isempty(obj.idxPC1), obj.idxPC1 = obj.idxPC1(~idxRejection,:); end
if ~isempty(obj.idxPC2), obj.idxPC2 = obj.idxPC2(~idxRejection,:); end

% End --------------------------------------------------------------------------

msg('E', procHierarchy);
obj.info

end