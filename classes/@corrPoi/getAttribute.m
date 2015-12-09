function att = getAttribute(obj, attributeName)

if strcmpi(attributeName, 'dAlpha')
    att = obj.dAlpha;
elseif strcmpi(attributeName, 'ds')
    att = obj.ds;
elseif strcmpi(attributeName, 'dp')
    att = obj.dp;
elseif strcmpi(attributeName, 'roughness')
    att = max([obj.A1.roughness  obj.A2.roughness], [], 2); % maximal roughness for each correspondence
else
    att = obj.A.(attributeName);
end

end