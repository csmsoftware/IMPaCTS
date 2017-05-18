function [intSegments,refSegments]=...
    matchSegments(refSp,intSp,intSegments,refSegments,...
    MAX_DIST_FACTOR, MIN_RC,debug)

% Matching of the segment of interest to the corresponding reference using
% Fuzzy logic approach

% Algorithm: - take segment of interest
%            - take reference segments
%            - calculate relative distance between them
%            - calculate relative resamblance between them
%            - find min value of relative distance and resamblance 
%            - use it as representative of similiarity between target...
%              and reference segments 
%            - find the segment that has the highest value of both relative
%            distance and resamblance

% Input:  intSegments - segments of spectrum of interest
%         refSegments- segments of reference spectrum
%         intSp - spectrum of interest
%         refSp - reference spectrum 
% Output: intsegment.refInd - reference segment or []
% Author: Kirill Veselkov, Imperial College London
% Author: Vladimir Volynkin, Sevastopol National Technical University
segments=[];
intSegLength=length(intSegments);
refSegments(1).used=[];
rC1=[];
for index=1:intSegLength
    [rC, iSimilarSegmentInd, distCoeff, corrCoeff]=...
        comparePeaks(refSp, refSegments, intSp, intSegments(index), MAX_DIST_FACTOR, 0);
    if rC>MIN_RC
        intSegments(index).refIndex=iSimilarSegmentInd;
        rC1=[rC1 rC];
        refSegments(iSimilarSegmentInd).used=index;
    else
        intSegments(index).refIndex=[];
    end
end

startPos=[];
endPos=[];
if ~isempty(debug)
    %  plotTwoWithSegments(refSp, refSegments, intSp, intSegments);
    index=1;
    for i=1:intSegLength
        if ~isempty(intSegments(i).refIndex)
            refInd=intSegments(i).refIndex;
            segments.start(index)=min(intSegments(i).start,refSegments(refInd).start);
            segments.end(index)=max(intSegments(i).end,refSegments(refInd).end);
            index=index+1;
        end
    end
    plotTwoWithSegmentsD(intSp,refSp,segments,segments,...
        [],debug)
    title(['Similarity: ' sprintf('%.2f ', rC1)]);
end
return



function [rC, iSimilarPeakInd, distCoeff, corrCoeff] = comparePeaks(dpReference,....
    refPeaks, dpSpectr, curIPeak, MAX_DIST_FACTOR, tryDoubleReference)
% function iSimilarPeakInd = comparePeaks(SPeakCurrent, refPeaks)
% compare current peak SPeakCurrent with all the peaks in refPeaks array and
% return index of similar peak
% dpReference - reference spectrum (whole!);
% dpSpectr - 'input' spectrum (whole!);
% curPeak - structure (.start, .end, .centre) of the current peak
% which we're aligning to our reference (one peak);
% refPeaks cell array of reference peak structures. We're looking for the
% best matching peak in these reference peak structures.
% MAX_DIST_FACTOR - 'zero' of distance
% Author: Vladimir Volynkin, Sevastopol National University, 2007

if (nargin < 5)
    DEBUG=1;
    disp('comparePeaks in debug mode!!!');
    MAX_DIST_FACTOR = 50;
    load('../data/testPeaks');
    dpReference = dpSpectr;
end

iPeaksCount = length(refPeaks);
if iPeaksCount<1
    error('Not enought peaks to compare');
end
%evuate comparison parameters

maxDistDeviation = (curIPeak.end - curIPeak.start) * MAX_DIST_FACTOR;
dMinParam   = repmat(NaN, iPeaksCount, 1);
corCoeffs   = repmat(NaN, iPeaksCount, 1);
distCoeffs  = repmat(NaN, iPeaksCount, 1);

for peakInd = 1:iPeaksCount
    if(~isempty(refPeaks(peakInd).used))
        % no matter to check this reference sicne it has been used already
        continue;
    end;
    if(refPeaks(peakInd).centre - curIPeak.centre < -maxDistDeviation)
        continue;
    end;
    if(refPeaks(peakInd).centre - curIPeak.centre > maxDistDeviation)
        break;
    end;
    if(tryDoubleReference && peakInd < iPeaksCount)
        refPeak.start   = refPeaks(peakInd).start;
        refPeak.end     = refPeaks(peakInd+1).end;
        refPeak.centre = mean([refPeak.start, refPeak.end]);
    else
        refPeak = refPeaks(peakInd);
    end;
    %evaluate relative distance
    dDistCurr = 1 - abs(refPeak.centre - curIPeak.centre) / maxDistDeviation;
    distCoeffs(peakInd) = dDistCurr;
    
    %%-- little optimisation: if we got negative 'dDistCurr' value (our
    %%peaks are TOO far from each other, no matter to do FFT
    %%cross-correlation for them since we're interested only in positive rC
    %%values;
    if(dDistCurr < 0)
        dMinParam(peakInd) = dDistCurr;
        continue;
    end;
    
    %evaluate cross-correlation
    refPeakShape = dpReference(refPeak.start : refPeak.end);
    if curIPeak.start<=0||curIPeak.end>length(dpSpectr)
        dMinParam(peakInd)=0;
    else
        targetPeak = dpSpectr( curIPeak.start : curIPeak.end );


        maxLen = max([length(refPeakShape), length(targetPeak)]);
        fCorrCurr = getCorellation(zeroPad(refPeakShape, maxLen), zeroPad(targetPeak, maxLen), maxDistDeviation);

        %get minimal parameter
        dMinParam(peakInd) = min([dDistCurr fCorrCurr]);

        corCoeffs(peakInd)  = fCorrCurr;
    end
end

%Get simillar peak index
[rC, iSimilarPeakInd] = max(dMinParam);
distCoeff = distCoeffs(iSimilarPeakInd);
corrCoeff = corCoeffs(iSimilarPeakInd);

return;