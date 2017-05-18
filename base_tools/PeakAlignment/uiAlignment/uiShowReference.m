function uiShowReference(hObject,ignore)

metadata = guidata(hObject);
if (metadata.showtarget)
    nVrbls   = length(metadata.T);
    if ~ishold(metadata.h.SubPlot(1))
        hold(metadata.h.SubPlot(1));
    end
    metadata.h.Target = plot(1:nVrbls,metadata.T,'parent',metadata.h.SubPlot(1),'LineWidth',...
        metadata.Tlinewidth,'Color',metadata.TColor);
    legend(metadata.h.Target,'reference');
    set(metadata.h.hPeakAlignTBbuttons(5),'CData',metadata.icons.showtargetoff,'TooltipString','Hide reference');
    metadata.showtarget = 0;
    hold off;
else
    set(metadata.h.hPeakAlignTBbuttons(5),'CData',metadata.icons.showtargeton,'TooltipString','Show reference');
    if ~isempty(metadata.h.Target)
        delete(metadata.h.Target);
        legend(metadata.h.SubPlot(1),'hide');
        metadata.showtarget = 1;
    end
end
guidata(hObject,metadata);
return;