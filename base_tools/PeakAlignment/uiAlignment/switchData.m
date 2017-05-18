function switchData(hObject,ignore)
%% The button is used to switch between aligned/non-aligned data modes

metadata       = guidata(hObject);
if (metadata.plotNonAlignedData)
    set(metadata.h.hPeakAlignTBbuttons(12),'TooltipString','Show non-aligned data');
    metadata.plotNonAlignedData = 0;
else
    set(metadata.h.hPeakAlignTBbuttons(12),'TooltipString','Show aligned data');
    metadata.plotNonAlignedData = 1;
end
xlims = get(gca,'XLim');
ylims = get(metadata.h.SubPlot(1),'YLim');

[ignore,metadata]     = plotPeakStats(metadata);
hlineObjects          = drawLineObjects(metadata.peakBndrs,metadata);
metadata.hlineObjects = hlineObjects;
set(gca,'XLim',xlims);
set(metadata.h.SubPlot(1),'YLim',ylims);
zoomcallback(metadata.h.SubPlot(1))
guidata(hObject,metadata);