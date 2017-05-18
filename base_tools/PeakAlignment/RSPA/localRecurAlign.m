function alignedSegment = localRecurAlign(testSegment, refSegment,recursion,...
    isSegment,lookahead,debug)

% Input: recursion.minSegWidth
%                  minInbetweenWidth
%                  resamblance
%                  acceptance
%                  segShift
%                  inbetweenShift
%       isSegment == true takes segment parameters
% Author: K.Veselkov, Imperial College London

if(~isvector(testSegment))
    error('~isvector(testSegment)');
end;

if(~isvector(refSegment))
    error('~isvector(refSegment)');
end;

if length(refSegment) ~= length(testSegment)
    error('Reference and testSegment of unequal lengths');
elseif length(refSegment)== 1
    error('Reference cannot be of length 1');
end

recursion.minWidth=recursion.minSegWidth;

if isSegment==true
    recursion.shift=recursion.segShift;
else
    recursion.shift=recursion.inbetweenShift;
end

alignedSegment=recurAlign(testSegment,refSegment,recursion,lookahead,debug);

%Recursive segmentation----------------------------------------------------
function alignedSegment = recurAlign(testSegment, refSegment, recursion, lookahead,debug)

if length(testSegment) < recursion.minWidth
    alignedSegment = testSegment;
    return;
end
if var(testSegment)==0 || var(refSegment)==0
    alignedSegment=testSegment;
    return
end

lag = FFTcorr(testSegment,refSegment,recursion.shift);
%stop if the segment is perfectly aligned and there is no need to lookahead
alignedSegment = testSegment;

if abs(lag) < length(testSegment)

    alignedTemp = shift(testSegment,lag);
    if var(alignedTemp)<0.000001
        return
    end
    CorrCoef=corrcoef_aligned(refSegment,alignedTemp,recursion.step);
    if CorrCoef>=recursion.acceptance;
        alignedSegment =alignedTemp;
    else
        if var(testSegment)==0 || var(refSegment)==0
            alignedSegment=testSegment;
            return
        end
        CorrCoef=corrcoef_aligned(refSegment,alignedSegment,recursion.step);
    end
end

CorrCoef=corrcoef_aligned(refSegment,alignedSegment,recursion.step);


plotTwoA(refSegment,alignedSegment,[],recursion.step,debug);
% Can be adjusted the recursion stops if the resemblance between the
% referebce and the segment of interest is e.g. 98%
if CorrCoef>=recursion.resamblance
    return;
end

% If the middle point is not the local min then divide
mid = findMid(alignedSegment,refSegment);
if isempty(mid)
    return;
end
firstSH= alignedSegment(1,1:mid);
firstRH= refSegment(1,1:mid);
secSH = alignedSegment(1,mid+1:length(alignedSegment));
secRH = refSegment(1,mid+1:length(refSegment));
alignedSeg1 = recurAlign(firstSH,firstRH,recursion, lookahead,debug);
alignedSeg2 = recurAlign(secSH,secRH,recursion, lookahead,debug);
alignedSegment = [alignedSeg1 alignedSeg2];