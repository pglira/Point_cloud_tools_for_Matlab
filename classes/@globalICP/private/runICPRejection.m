function CP = runICPRejection(p, g, CP)

msg('S', {g.procICP{:} 'REJECTION'}, 'LogLevel', 'basic');
    
for i = 1:size(p.PairList,1)

    CP{i} = CP{i}.rejection('Attribute', ...
                            'AttributeName', 'dAlpha', ...
                            'AttributeMinMax', [p.MaxDeltaAngle*10/9 400]); % conversion from degree to gradian!

    % Rejection based on dp
    med = median(CP{i}.dp);
    sig_mad = 1.4826*mad(CP{i}.dp,1);

    CP{i} = CP{i}.rejection('Attribute', ...
                            'AttributeName', 'dp', ...
                            'AttributeMinMax', [-Inf med-p.MaxSigmaMad*sig_mad]);

    CP{i} = CP{i}.rejection('Attribute', ...
                            'AttributeName', 'dp', ...
                            'AttributeMinMax', [med+p.MaxSigmaMad*sig_mad Inf]);

    % Rejection based on ds
    CP{i} = CP{i}.rejection('Attribute', ...
                            'AttributeName', 'ds', ...
                            'AttributeMinMax', [p.MaxDistance Inf]);

    % Rejection based on roughness
    CP{i} = CP{i}.rejection('Attribute', ...
                            'AttributeName', 'roughness', ...
                            'AttributeMinMax', [p.MaxRoughness Inf]);

end

msg('E', {g.procICP{:} 'REJECTION'}, 'LogLevel', 'basic');

end