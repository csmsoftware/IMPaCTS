function segmentVld=segmentate(Sp, peaks, peakParam,debug)
% Combination of adjacent peaks into larger segments
%  Input: SpSmooth - spectrum of interest
%
%                 peaks.  maxPos - peak maxium position
%                         startPos - starting position
%                         endPos - ending position
%                         maxVal - maximum value
%                         startVal - starting value
%                         endVal - ending value
%                         basl - baseline value
%                         index - peak index
%
%                 peakParam.ppmDist - distance to combine adjacent peaks
%
% Author: Kirill Veselkov, Imperial College London

peakCount=length(peaks);
segments(peakCount).start=[];
ppmDist=peakParam.ppmDist;

segmentIndex=1;
peakIndex=1;
while peakIndex<=peakCount
    segments(segmentIndex).start=peaks(peakIndex).startPos;
    segments(segmentIndex).PeakLeftBoundary=peaks(peakIndex).LeftEdge;
    segments(segmentIndex).PeakRightBoundary=peaks(peakIndex).RightEdge;
    segments(segmentIndex).Peaks=peaks(peakIndex);
    while peakIndex<=peakCount
        % check whether the next peak is part of the same segment
        %TODO: optimise no matter to store PeakLeft(Right)Boundary if we
        %store segment peaks themeselves.
        includePeak = (peakIndex<peakCount) && (peaks(peakIndex+1).maxPos-peaks(peakIndex).maxPos<ppmDist);

        if includePeak
          peakIndex=peakIndex+1;
          segments(segmentIndex).PeakLeftBoundary=[segments(segmentIndex).PeakLeftBoundary...
              peaks(peakIndex).LeftEdge];
          segments(segmentIndex).PeakRightBoundary=[segments(segmentIndex).PeakRightBoundary...
          peaks(peakIndex).RightEdge];
          segments(segmentIndex).Peaks=[segments(segmentIndex).Peaks peaks(peakIndex)];
          segments(segmentIndex).end=[];
        else
            segments(segmentIndex).end=peaks(peakIndex).endPos;
            segments(segmentIndex).centre=ceil((segments(segmentIndex).start+...
                segments(segmentIndex).end)/2);
            segmentIndex=segmentIndex+1;
            peakIndex=peakIndex+1;
            break;
        end
    end
end

segmentCount=segmentIndex-1;
segments=segments(1:segmentCount);

index=1;
segmentVld=segments;

 for i=1:segmentCount
        segmentVld(i).start=min([ segmentVld(i).start ...
            segmentVld(i).PeakLeftBoundary]);
        segmentVld(i).end=max([ segmentVld(i).end ...
            segmentVld(i).PeakRightBoundary]);
 end


if ~isempty(debug);
    peakStartPositions=[];
    peakEndPositions=[];
    for i=1:segmentCount
        peakStartPositions=[peakStartPositions segmentVld(i).start];
        peakEndPositions=[peakEndPositions segmentVld(i).end];
    end

    plotPeaksOrSegments(Sp,[],peakStartPositions,...
        peakEndPositions,debug,4)
end

return;