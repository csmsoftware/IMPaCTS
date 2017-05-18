function uiRSPA(hObject, ignore)
% This function performs user defined recursive segment wise alignment

% Input: hObject
%               .Sp                               - spectra [observation x variables]
%               .ppm                              - chemical shift scale [1 x variables]
%               .PreProcSp                        - pre-processed spectra [observation x variables]
%               .PeakAlignment.segBndrs           - segment boundaries for local peak alignment in ppm
%               .PeakAlignment.maxPeakShift       - max peak shift allowed for the local alignment [1 x number of segments]
%               .PeakAlignment.RSPA.recursion     - true or false, simple shifting is performed if recursion is false
%               .PeakAlignment.RSPA.acceptance    - acceptance parameters  [1 x number of segments]
%               .PeakAlignment.RSPA.resemblance   - resemblance parameter  [1 x number of segments]
%               .PeakAlignment.RSPA.minSegWidth   - minimum segment width  [1 x number of segments]
%               .PeakAlignment.RSPA.userDefSgmnts - user defined segments, TRUE or FALSE
%               .PeakAlignment.RefSp              - reference spectrum
% Author: Kirill Veselkov, Imperial College 2010

metadata          = guidata(hObject);

RSPA.minSegWidth  = ppmToPt(metadata.RSPA.minSegWidth,0, metadata.ppm(2)- metadata.ppm(1));
RSPA.maxPeakShift = ppmToPt(metadata.RSPA.maxPeakShift,0, metadata.ppm(2)- metadata.ppm(1));
RSPA.acceptance   = metadata.RSPA.acceptance;
RSPA.resemblance  = metadata.RSPA.resemblance;
RSPA.recursion    = metadata.RSPA.recursion;

peakBndrs = metadata.peakBndrs;
if ~isempty(peakBndrs)
    count    = length(peakBndrs);
    nSmpls   = size(metadata.Sp,1);
    for i=1:2:count
        for j=1:nSmpls
            metadata.SpAL(j,peakBndrs(i):peakBndrs(i+1)) = localRSPA(metadata.Sp(j,peakBndrs(i):peakBndrs(i+1)),...
                metadata.T(peakBndrs(i):peakBndrs(i+1)),RSPA,RSPA.recursion,[]);
        end
    end
else
    disp('...Please define peak position variation boundaries...');
end

set(metadata.h.hPeakAlignTBbuttons(12),'TooltipString','Show non-aligned data');
metadata.plotNonAlignedData = 0;
xlims = get(gca,'XLim');
ylims = get(metadata.h.SubPlot(1),'YLim');
[ignore,metadata]     = plotPeakStats(metadata);
hlineObjects          = drawLineObjects(metadata.peakBndrs,metadata);
metadata.hlineObjects = hlineObjects;
set(gca,'XLim',xlims);
set(metadata.h.SubPlot(1),'YLim',ylims);
zoomcallback(metadata.h.SubPlot(1));
guidata(hObject,metadata);
return;