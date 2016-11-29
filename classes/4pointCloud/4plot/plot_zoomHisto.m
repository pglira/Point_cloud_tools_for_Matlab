function plot_zoomHisto(~, ~, hAxesHisto, hHisto)

idxVisible = hHisto.BinEdges(1:end-1) >= hAxesHisto.XLim(1) & hHisto.BinEdges(1:end-1) <= hAxesHisto.XLim(2);
ylim(hAxesHisto, [0 max(hHisto.Values(idxVisible))*1.05]); % plus 5 percent

end