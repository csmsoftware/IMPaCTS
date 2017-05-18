function definePeakBndrs(hObject,ignore)
%% defineRSPAPrmtrs - passing user-defined boundaries for segments

%% Author: Kirill, Veselkov 2010.

metadata                = guidata(hObject);
[peakID,Y]              = ginput(2);
if peakID(2) < peakID(1)
    temp         = round(peakID(1));
    peakID(1)    = round(peakID(2));
    peakID(2)    = temp;
end
metadata.peakBndrs        = [metadata.peakBndrs peakID(1) peakID(2)];
hlineObjects = drawLineObjects(metadata.peakBndrs(end-1:end),metadata);
metadata.hlineObjects =     [metadata.hlineObjects,hlineObjects];
guidata(hObject,metadata);