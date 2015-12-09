function obj = runICPSaveCorr(obj, p, g, CP)

% Pre ICP (= first correspondences)
if g.nItICP == 1

    obj.CP.PreICP = CP;

% Post ICP (= final correspondences)
elseif (g.nItICP == p.MaxNoIt) || (obj.D.stats{g.nItICP}.normdx < p.StopConditionNormdx)

    obj.CP.PostICP = CP;

end

end