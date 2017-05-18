function alignedTestSeg = localRSPA(testSegment, refSegment, RSPA, recursion,debug)
%%  The function performs Local Recursive Segment Wise Peak Alignment (RSPA)
%    Input:  testSegment - test segment for peak alignment
%            refSegment  - reference segment
%            RSPA.maxPeakShift  - max peak shift allowed for local peak alignment
%            RSPA.acceptance    - acceptance parameters
%            RSPA.resemblance   - resemblance parameter
%            RSPA.minSegWidth   - minimum segment width
%            recursion          = [TRUE or FALSE] if true, simple segment
%                                 shifting is peformed
% Reference: Recursive segment-wise peak alignment for improved information
%            recovery
%% Author: Kirill Veselkov, Imperial College London

if var(testSegment)==0 || var(refSegment)==0
    alignedTestSeg=testSegment;
    return
end

if (recursion)
    alignedTestSeg = testSegment;
    if length(testSegment) < RSPA.minSegWidth
        return;
    end
    testSegShift            = FFTCrossCorr(testSegment,refSegment,RSPA.maxPeakShift);
    if abs(testSegShift) < length(testSegment)
        alignedTemp  = doSegShift(testSegment,testSegShift);
        plotTwo(refSegment, alignedTemp, [],RSPA,debug)
        if var(alignedTemp)<0.000001; return; end
        CorrCoef     = VarScCorrCoef(refSegment,alignedTemp,RSPA);
        if CorrCoef >= RSPA.acceptance; alignedTestSeg = alignedTemp;  end
    else
        return;
    end
    
    if CorrCoef>=RSPA.resemblance; return; end
    
    % get the point to divide reference and target segments
    divPoint = getDivPoint(alignedTestSeg,refSegment);
    plotTwo(refSegment, alignedTemp, [],RSPA,debug,divPoint)
    
    if isempty(divPoint);  return; end
    
    testSeg1       = alignedTestSeg(1,1:divPoint);
    refSeg1        = refSegment(1,1:divPoint);
    testSeg2       = alignedTestSeg(divPoint+1:end);
    refSeg2        = refSegment(divPoint+1:end);
    alignedSeg1    = localRSPA(testSeg1,refSeg1,RSPA, recursion,debug);
    alignedSeg2    = localRSPA(testSeg2,refSeg2,RSPA, recursion,debug);
    alignedTestSeg = [alignedSeg1 alignedSeg2];
else
    testSegShift            = FFTCrossCorr(testSegment,refSegment,RSPA.maxPeakShift);
    alignedTestSeg = testSegment;
    
    if abs(testSegShift) < length(testSegment)
        alignedTemp  = doSegShift(testSegment,testSegShift);
        if var(alignedTemp)<0.000001; return; end
        CorrCoef     = VarScCorrCoef(refSegment,alignedTemp,RSPA);
        if CorrCoef >= RSPA.acceptance; alignedTestSeg = alignedTemp;  end
    else
        return;
    end
end
return

function divPoint = getDivPoint(testSeg,refSeg)

%% The function finds the position to divide reference and test segments
%     Input:  testSegment - test segment for peak alignment
%             refSegment  - reference segment

%     Output: divPoint    - the point to divide reference and test segment
%                           into parts for the subsequent recursive alignment
% Author: Kirill Veselkov, Imperial College 2010

%%
segLength = length(testSeg);
M         = ceil(segLength/2);
midCnst  =  floor(M/4);
midTest   = testSeg(1,M-midCnst:M+midCnst);
midRef    = refSeg(1,M-midCnst:M+midCnst);

[ignore,tempMPIndex]     = min(midTest.*midRef);
divPoint = tempMPIndex(1,1) + M - midCnst - 1;

% move the temp to a point of a local minima
%% TODO USE SIMPLE FIND TOOL
while (1)
    if divPoint-1<=1||divPoint+1>=segLength
        divPoint=[];
        break;
    end
    if testSeg(divPoint)<=testSeg(divPoint+1)&&testSeg(divPoint)<=testSeg(divPoint-1)
        break;
    end
    if testSeg(divPoint)>=testSeg(divPoint+1)
        divPoint=divPoint+1;
    elseif testSeg(divPoint)>=testSeg(divPoint-1)
        divPoint=divPoint-1;
    end
end

return;

function shift = FFTCrossCorr(testSeg, refSeg, maxPeakShift)
%% The function searches for the shift between a test segment and a reference segments
%     Input:  testSegment - test segment for peak alignment
%             refSegment  - reference segment

%     Output: shift       - the shift between a test segment and a
%                           reference segment
% Author: Kirill Veselkov, Imperial College 2010

% zero padding for FFT if segment length > 64 (for relatively small segment lengths the zero padding is of advantage)
segLength          = length(testSeg);
if segLength > 64
    diff                    = 2^(ceil(log2(segLength))) - segLength;
    testSeg                 = testSeg - min(testSeg);
    refSeg                  = refSeg  - min(refSeg);
    refSeg(segLength+diff)  = 0;
    testSeg(segLength+diff) = 0;
    segLength               = segLength + diff;
end

fftRefSeg   = fft(refSeg);
fftTestSeg  = fft(testSeg);
R           = fftRefSeg.*conj(fftTestSeg);
R           = R./(segLength);
corrFunTR   = real(ifft(R));

maxpos = 1;
maxi = -1;

if segLength < maxPeakShift
    maxPeakShift = segLength;
end

%%TODO: Delete this code
for i = 1:maxPeakShift
    if (corrFunTR(1,i) > maxi)
        maxi = corrFunTR(1,i);
        maxpos = i;
    end
    if (corrFunTR(1,segLength-i+1) > maxi)
        maxi = corrFunTR(1,segLength-i+1);
        maxpos = segLength-i+1;
    end
end

maxSearchIndcs = [1:maxPeakShift, segLength-maxPeakShift+1:segLength];
[maxCorrFunValue,maxCorrFunIndex] = max(corrFunTR(maxSearchIndcs));
maxPosTemp     = maxSearchIndcs(maxCorrFunIndex);

%if (maxPosTemp ~= maxpos); error('check max ccf algorithm'); end

if maxpos > segLength/2
    shift = maxpos-segLength-1;
else
    shift =maxpos-1;
end

return;

function [CC,testSeg,refSeg] = VarScCorrCoef(testSeg,refSeg,RSPA)
%% The function scales all peaks in test and reference segments to
%% equal height, equalises the difference in metabolite concentrations
%% between related samples.
%    Input:  testSegment - test segment for peak alignment
%            refSegment  - reference segment
%            RSPA.maxPeakShift  - max peak shift allowed fshiftor the local peak alignment
%            RSPA.acceptance    - acceptance parameters
%            RSPA.resemblance   - resemblance parameter
%            RSPA.minSegWidth   - minimum segment width
%    Author: Kirill Veselkov, Imperial College 2010.
%%
segLength    = length(testSeg);
minPeakWidth = RSPA.minSegWidth*2;
if segLength < minPeakWidth
    CC         = corrcoef(testSeg,refSeg);
    CC         = CC(1,2);
    corrFactor = adjustCCs(segLength);
    CC         = CC + corrFactor;
    return;
end

[testSeg,refSeg] = getVarScalSeg(testSeg,refSeg,minPeakWidth,segLength);
[CC,p]           = corrcoef(testSeg,refSeg);
CC               = CC(1,2);
corrFactor       = adjustCCs(segLength);
CC               = CC + corrFactor;
return;

function [testSeg,refSeg] = getVarScalSeg(refSeg,testSeg, minPeakWidth,segLength)

maxNSgmnts = ceil(segLength/minPeakWidth);
segBndrs = [0 cumsum(minPeakWidth*ones(1,maxNSgmnts))];
if segBndrs(end) > segLength
    segBndrs(end-1) = segLength;
    segBndrs        = segBndrs(1:end-1);
end

NSgmnts = length(segBndrs)-1;
for iSeg = 1:NSgmnts
    refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)) = refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)) - mean(refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)));
    if var(refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)))~=0
        refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1))= refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1))./std( refSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)));
    end
    testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)) = testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)) - mean(testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)));
    if var(testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)))~=0
        testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1))= testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1))./std(testSeg(segBndrs(iSeg)+1:segBndrs(iSeg+1)));
    end
end
return;

function shiftedTestSeg = doSegShift(testSeg, testSegShift)
%% The function searches for the shift between a test segment and a reference segments
%     Input:  testSegment    - a test segment for peak alignment
%             testSegShift   - a shift for peak alignment

%     Output: shiftedTestSeg - a shift between a test segment and a
%                              reference segment
% Author: Kirill Veselkov, Imperial College 2010
%%
if testSegShift == 0 || testSegShift >= length(testSeg)
    shiftedTestSeg = testSeg;
    return
end

if testSegShift > 0
    ins = ones(1,testSegShift) * testSeg(1);
    shiftedTestSeg = [ins testSeg(1:(length(testSeg) - testSegShift))];
elseif testSegShift < 0
    testSegShift = abs(testSegShift);
    ins = ones(1,testSegShift) * testSeg(end);
    shiftedTestSeg = [testSeg((testSegShift+1):length(testSeg)) ins];
end

return;

function plotTwo(signal1, signal2, xValues,RSPA,debug,divPoint)


if isempty(debug)
    return;
end

if nargin<6
    ignore=0;
else
    ignore=1;
end
if isempty(xValues)
    xValues = 1:length(signal1);
end

if isempty(xValues)
    xValues = 1:length(signal1);
end

[CorrCoef,testSeg,refSeg]     = VarScCorrCoef(signal1,signal2,RSPA);

if debug<0
    subplot(1,2,1);
    plot(xValues, signal1, 'r');
    hold on;
    plot(xValues, signal2, 'b');
    title(sprintf('resemblance %.2f',CorrCoef),'FontSize',16);
    legend('reference','current');
    if (ignore)
        if ~isempty(divPoint)
            line([divPoint divPoint],[min([signal1 signal2]),max([signal1 signal2])],'LineWidth',4,'Color','k');
        end
    end
    hold off;
    subplot(1,2,2);
    plot(xValues, refSeg, 'r');
    hold on;
    plot(xValues, testSeg, 'b');
    if (ignore)
        if ~isempty(divPoint)
            line([divPoint divPoint],[min([testSeg refSeg]),max([testSeg refSeg])],'LineWidth',4,'Color','k');
        end
    end
    hold off;
    pause();
else
    subplot(1,2,1)
    plot(xValues, signal1, 'r');
    hold on;
    plot(xValues, signal2, 'b');
    title(sprintf('resemblance %.2f',CorrCoef),'FontSize',16);
    legend('reference','current');
    hold off;
    subplot(1,2,2);
    plot(xValues, refSeg, 'r');
    hold on;
    plot(xValues, testSeg, 'b');
    hold off;
    pause(debug);
end

return;

function corrFactor = adjustCCs(nv)
% Testing of no correlation
% zalpha(nv>3) = (-erfinv(0.05 - 1)) .* sqrt(2) ./ sqrt(nv(nv>3)-3); adjust
%corrFactor = 0;
%return;
if nv>9
    corrFactor = 0.05-((-erfinv(0.05 - 1)) .* sqrt(2) ./ sqrt(nv(nv>3)-3))./2;
else
    corrFactor = -0.5;
end
return;