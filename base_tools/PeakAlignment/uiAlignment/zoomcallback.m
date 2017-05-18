function zoomcallback(obj,axes)

metadata        = guidata(obj);

% step 1:
[xTickIndcs,ppmTicks]       = getXTickMarks(metadata.h.SubPlot(1),metadata.ppm);
set(metadata.h.SubPlot(1),'XTick',[]);            % delete all the current indices
set(metadata.h.SubPlot(2),'XTick',[]);
set(metadata.h.SubPlot(3),'XTick',[]);
set(metadata.h.SubPlot(1),'XTick',xTickIndcs);
set(metadata.h.SubPlot(2),'XTick',xTickIndcs);
set(metadata.h.SubPlot(3),'XTick',xTickIndcs);
set(metadata.h.SubPlot(1),'XTickLabel',[]);
set(metadata.h.SubPlot(2),'XTickLabel',[]);
set(metadata.h.SubPlot(3),'XTickLabel',ppmTicks);