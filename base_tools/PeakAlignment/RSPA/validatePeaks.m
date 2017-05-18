function [validatedPeaks,peakParam,minsegwidth]=validatePeaks(SpSmooth,peaks,...
    peakParam,debug)
% input:          Peak peaking details
%                 peaks.  maxPos - peak maxium position
%                         startPos - start position
%                         endPos - end position
%                         maxVal - maximum value
%                         startVal - start value
%                         endVal - end value
%                         basl - baseline value
%                         index - peak index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Peak validation parameters
%             peakParam.  minPeakWidth - minimum peak width
%             ampThr - amplitude threshold; automatically determined if it
%             is zero
% Author, K.Veselkov, Imperial College London

peakCount=length(peaks);
% Matrix pre-location
validatedPeaks=peaks;
minPeakWidth=peakParam.minPeakWidth;

if isempty(peakParam.ampThr)||peakParam.ampThr==false
    ampThr=getAmpThr(peaks);
    peakParam.ampThr=ampThr;
else
    ampThr=peakParam.ampThr;
end

if peakParam.ampThr>0.9*max(SpSmooth)||peakParam.ampThr<1.1*min(SpSmooth)
    error('Peak validation threshold exceeds spectrum maximum and minimum values');
end

index=1;
for i=1:peakCount
    if peaks(i).endPos-peaks(i).startPos > minPeakWidth &&...
            peaks(i).maxVal-peaks(i).basl > ampThr
        validatedPeaks(index)=peaks(i);
        index=index+1;
    end
end

if index > 1
    PeakCount=index-1;
    validatedPeaks=validatedPeaks(1:PeakCount);
else
    error('wrong peak peaking parameters: No Validated peaks')
end


minsegwidth=10.^10;
for i=1:PeakCount
    startPos=validatedPeaks(i).startPos;
    maxPos=validatedPeaks(i).maxPos;
    endPos=validatedPeaks(i).endPos;
    segwidth=endPos-startPos;
    % Determine the peak boundaries
    edgeVal=validatedPeaks(i).maxVal.*peakParam.peakEdgeMax;
    LeftEdge=find(SpSmooth(startPos:maxPos)-validatedPeaks(i).basl>=...
        edgeVal,1,'first');
    if isempty(LeftEdge)
        validatedPeaks(i).LeftEdge=startPos;
    else
        validatedPeaks(i).LeftEdge=startPos+LeftEdge-1;
    end
    RightEdge=find(SpSmooth(maxPos:endPos)-validatedPeaks(i).basl>=...
        edgeVal,1,'last');
    if isempty(RightEdge)
        validatedPeaks(i).RightEdge=endPos;
    else
        validatedPeaks(i).RightEdge=maxPos+RightEdge-1;
    end
    if minsegwidth>segwidth
       minsegwidth=segwidth;
    end
end


if ~isempty(debug);
    peakStartPositions=[];
    peakEndPositions=[];
    peakMaxPositions=[];
    for i=1:PeakCount
        peakStartPositions=[peakStartPositions  validatedPeaks(i).LeftEdge];
        peakEndPositions=[peakEndPositions validatedPeaks(i).RightEdge];
        peakMaxPositions=[peakMaxPositions validatedPeaks(i).maxPos];
    end
    plotPeaksOrSegments(SpSmooth,peakMaxPositions,...
        peakStartPositions,peakEndPositions,debug)
end

return;