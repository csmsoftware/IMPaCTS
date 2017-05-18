function definePeakPickingPrmtrs(hObject,ignore)

metadata            = guidata(hObject);
options.Resize      = 'on';
options.WindowStyle = 'normal';
options.Interpreter = 'tex';

prompt = {'Peak height threshold (should be defined based on heights of small or noisy peaks):','Minimum peak width:',...
    'Frame length of Savitzky-Golay smoothing filter (in ppm):','Polynomial order of Savitzky-Golay smoothing filter',...
    'Maximum peak width (the peak width is the distance between two adjacent minima to a peak)','Offset for log-trasnform (should approximately be equal to the peak height thr value):',...
    'ppm-axis tick label interval'};
def = {num2str(metadata.peakPickingParams.ampThr),num2str(metadata.peakPickingParams.minPeakWidth),num2str(metadata.peakPickingParams.iFrameLen),...
    num2str(metadata.peakPickingParams.iOrder),num2str(metadata.peakPickingParams.iMaxPeakWidthWindow),num2str(metadata.peakPickingParams.offset),...
    num2str(metadata.peakPickingParams.XTickLabels)};
dlg_title = 'Change default parameters for peak peaking';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,def,options);

% Peak peaking parameters
metadata.peakPickingParams.ampThr              = str2num(answer{1}); 
metadata.peakPickingParams.minPeakWidth        = str2num(answer{2}); 
metadata.peakPickingParams.iFrameLen           = str2num(answer{3}); 
metadata.peakPickingParams.iOrder              = str2num(answer{4}); 
metadata.peakPickingParams.iMaxPeakWidthWindow = str2num(answer{5}); 
metadata.peakPickingParams.offset              = str2num(answer{6}); 
metadata.peakPickingParams.XTickLabels         = str2num(answer{7}); 
guidata(hObject,metadata);