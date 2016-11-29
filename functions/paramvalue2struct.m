function s = paramvalue2struct(varargin)

for i = 1:2:numel(varargin)
   
    s.(varargin{i}) = varargin{i+1};
    
end

end