function doStocsyUIAlignment(hObject,h2)
%% doStocsy: user interface statistical total correlation spectroscopy (STOCSY)
%           Input: 
%                   hObject - the figure handle 
%% Author: Kirill A. Veselkov, Imperial College London 2010

metadata             = guidata(hObject);
%smplIndcs            = get(metadata.ax(2),'YLim');
%y                    = floor(smplIndcs(1)):ceil(smplIndcs(2));
[peakID] = ginput(1);
if metadata.plotNonAlignedData == 1
    STOCSY(metadata.Sp,metadata.ppm,metadata.ppm(floor(peakID(1))),...
        metadata.stocsy.pThr,metadata.stocsy.cc);
else
    STOCSY(metadata.SpAL,metadata.ppm,metadata.ppm(floor(peakID(1))),...
        metadata.stocsy.pThr,metadata.stocsy.cc);
end