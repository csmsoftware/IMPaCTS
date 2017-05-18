function exportProcData(hObject,ignore)

metadata                 = guidata(hObject);
uiAlignmentData.Sp        = metadata.Sp.*metadata.ScFactor; 
uiAlignmentData.SpAL      = metadata.SpAL.*metadata.ScFactor;
uiAlignmentData.ppm       = metadata.ppm;
uiAlignmentData.COW       = metadata.COW;
uiAlignmentData.RSPA      = metadata.RSPA;
uiAlignmentData.peakBndrs = metadata.ppm(metadata.peakBndrs);

assignin('caller','uiAlignmentData',uiAlignmentData);