function hLineObjects = drawLineObjects(peakBndrs,metadata)

if isempty(peakBndrs)
    hLineObjects = [];
    return;
end

nPeakBndrs   = length(peakBndrs);
hLineObjects = repmat(NaN,[6,nPeakBndrs/2]);
for iBndr = 1:2:nPeakBndrs
    % Drawing the first used defined segment boundary
    iPeak = (iBndr+1)./2;
    hLineObjects(1,iPeak)= line([peakBndrs(iBndr),peakBndrs(iBndr)],metadata.SubPlot(1).ylim,'parent',metadata.h.SubPlot(1),...
        'LineWidth',metadata.linewidth,'Color',metadata.linecolors(1,:),'LineStyle',metadata.linestyle{1});
    hLineObjects(2,iPeak)= line([peakBndrs(iBndr),peakBndrs(iBndr)],metadata.SubPlot(2).ylim,'parent',metadata.h.SubPlot(2),...
        'LineWidth',metadata.linewidth,'Color',metadata.linecolors(1,:),'LineStyle',metadata.linestyle{1});
    hLineObjects(3,iPeak)= line([peakBndrs(iBndr),peakBndrs(iBndr)],metadata.SubPlot(3).ylim,'parent',metadata.h.SubPlot(3),...
        'LineWidth',metadata.linewidth,'Color',metadata.linecolors(1,:),'LineStyle',metadata.linestyle{1});
    % Drawing the first used defined segment boundary
    hLineObjects(4,iPeak)= line([peakBndrs(iBndr+1),peakBndrs(iBndr+1)],metadata.SubPlot(1).ylim,'parent',metadata.h.SubPlot(1),...
        'LineWidth',metadata.linewidth,'Color',metadata.linecolors(2,:),'LineStyle',metadata.linestyle{2});
    hLineObjects(5,iPeak)= line([peakBndrs(iBndr+1),peakBndrs(iBndr+1)],metadata.SubPlot(2).ylim,'parent',metadata.h.SubPlot(2),...
        'LineWidth',metadata.linewidth,'Color',metadata.linecolors(2,:),'LineStyle',metadata.linestyle{2});
    hLineObjects(6,iPeak)= line([peakBndrs(iBndr+1),peakBndrs(iBndr+1)],metadata.SubPlot(3).ylim,'parent',metadata.h.SubPlot(3),...
        'LineWidth',metadata.linewidth,'Color',metadata.linecolors(2,:),'LineStyle',metadata.linestyle{2});
end