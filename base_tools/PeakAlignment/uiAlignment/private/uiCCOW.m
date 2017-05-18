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

%% Parameters for constrained correlation optimized warping
CCOWpar.averagePeakWidth  = ppmToPt(metadata.COW.averagePeakWidth,0,metadata.ppm(2)-metadata.ppm(1));
CCOWpar.maxPeakShift      = ppmToPt(metadata.COW.maxPeakShift,0,metadata.ppm(2)-metadata.ppm(1));
if isempty(metadata.COW.slack)
    CCOWpar.slack = [] ;
else
    CCOWpar.slack = ppmToPt(metadata.COW.slack,0,metadata.ppm(2)-metadata.ppm(1));
end

peakBndrs = metadata.peakBndrs;
if ~isempty(peakBndrs)
    count    = length(peakBndrs);
    for i=1:2:count
        if ~isempty(CCOWpar.maxPeakShift)
            peakExpBndrs = getExpandedSegIndcs(CCOWpar,[peakBndrs(i) peakBndrs(i+1)]);
            if peakExpBndrs(1)<0
                peakExpBndrs = 1;
            end
            if peakExpBndrs(1)>length(metadata.ppm)
                peakExpBndrs = length(metadata.ppm);
            end
        else
            peakExpBndrs = [peakBndrs(i) peakBndrs(i+1)];
        end
        
        AL = CCOW(metadata.Sp(:,peakExpBndrs(1):peakExpBndrs(2)),...
            metadata.T(peakExpBndrs(1):peakExpBndrs(2)),'maxPeakShift',CCOWpar.maxPeakShift,...
            'Slack',CCOWpar.slack,'SegLength',CCOWpar.averagePeakWidth);
        peakBndrsOrg =  peakBndrs(i:i+1) - peakExpBndrs(1)+1;
        metadata.SpAL(:,peakBndrs(i):peakBndrs(i+1)) = AL(:,peakBndrsOrg(1):peakBndrsOrg(2));
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

function segExpBndrs = getExpandedSegIndcs(CCOWpar,segBndrs)

nVrbls               = segBndrs(2)-segBndrs(1) + 1;
SegLength            = CCOWpar.averagePeakWidth;
nSgnts               = floor((nVrbls-1)/(SegLength-1));
SegLengths(1:nSgnts) = SegLength-1;
SegLengths(nSgnts)   = SegLengths(nSgnts)+rem(nVrbls-1,SegLength-1); %add remaining points to the last segment

if CCOWpar.maxPeakShift==0
    error('ERROR: The maximum segment shift must not be set to zero');
    return;
end

%% Calculate the warping constraints on segment boundaries:
if isempty(CCOWpar.slack)
    if any(CCOWpar.maxPeakShift + 2 > SegLengths)
        CCOWpar.slack = SegLength - 4; % the slack parameter is set to the segment length -4
    else
        CCOWpar.slack = CCOWpar.maxPeakShift;
    end
elseif any(CCOWpar.slack +2 > SegLengths)
    error('the slack parameter must be smaller that the average peak width by at least two data points'); end

offs           = CCOWpar.slack * (0:nSgnts);                             % Calculate the segment boundary variation.
nDP            = find(offs>CCOWpar.maxPeakShift,1,'first') * SegLength;
if isempty(nDP)
    nDP = ceil(SegLength*(CCOWpar.maxPeakShift./CCOWpar.slack));
end
segExpBndrs(1) = segBndrs(1) - nDP;
segExpBndrs(2) = segBndrs(2) + nDP;