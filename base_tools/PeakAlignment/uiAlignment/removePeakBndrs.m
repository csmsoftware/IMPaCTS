function removePeakBndrs(hObject,ignore)

metadata = guidata(hObject);
if isempty(metadata.hlineObjects)
    return;
end
delete(metadata.hlineObjects(:,end));
metadata.hlineObjects(:,end) = [];
metadata.peakBndrs(end-1:end) = [];
guidata(hObject,metadata);