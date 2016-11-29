function CP = runICPWeighting(p, g, CP)

msg('S', {g.procICP{:} 'WEIGHTING'}, 'LogLevel', 'basic');
    
for i = 1:size(p.PairList,1)

    if p.WeightByRoughness , CP{i} = CP{i}.weight('Roughness');  end
    if p.WeightByDeltaAngle, CP{i} = CP{i}.weight('DeltaAngle'); end

end

msg('E', {g.procICP{:} 'WEIGHTING'}, 'LogLevel', 'basic');

end