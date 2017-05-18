function [alignedSpectrum, extendedSegments]  = ...
    alignSp(refSp, refSegments, intSp,...
    intSegments,recursion,MAX_DIST_FACTOR, MIN_RC,debug)

% Input: refSp - reference spectrum
%        intSp - spectrum of interest
%        refSegments.used - reference
%        intSegments.refInd - matched reference segments
%        recursion - parameters for recursive alignment
% Output: alignedSpectrum
%         extendedSegments
%Author: Kirill Veselkov, Imperial College London

if(length(refSp) ~= length(intSp))
    error('length(refSp) ~= length(intSp)');
end;

specLen = length(refSp);

alignedSpectrum = repmat(NaN, 1, specLen);
prevGeneralEnd = 0;

iSegmentInd = 1;
extendedSegments = [];
intSegLength=length(intSegments);
refSegLength=length(refSegments);
extensionCount=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while iSegmentInd <= intSegLength
    iSegment = intSegments(iSegmentInd);
    if(isempty(iSegment.refIndex))
        iSegmentInd = iSegmentInd + 1;
        continue;
    end;
    %%%%%%% Segment of interest %%%%%%%%%
    iLeftB=iSegment.PeakLeftBoundary;
    iRightB=iSegment.PeakRightBoundary;
    iPeaks=iSegment.Peaks;
    
    %%%%%%% Corresponding Reference segment %%%%%%%%
    referenceInd=iSegment.refIndex;
    refSegment = refSegments(referenceInd);
    refLeftB=refSegment.PeakLeftBoundary;
    refRightB=refSegment.PeakRightBoundary;
    rPeaks=refSegment.Peaks;
    iStart = iSegment.start;
    refStart = refSegment.start;

    %%%%%%% Find joint starting position %%%%%%%
    iSegmentIndex=iSegmentInd;
    refIndex=referenceInd;
    generalStart = min([iStart, refStart]);

    % search for the general start preventing overlapping with the previous segments
    while (1)
        % no segments before
        if iSegmentIndex<=1 && refIndex<=1
            break;
        end

        % the segment of interest is first
        if iSegmentIndex<=1
            if generalStart<refSegments(refIndex-1).end
                generalStart=min(generalStart,refSegments(refIndex-1).start);
                refLeftB=[refSegments(refIndex-1).PeakLeftBoundary refLeftB ];
                refRightB=[refSegments(refIndex-1).PeakRightBoundary refRightB ];
                rPeaks=[refSegments(refIndex-1).Peaks rPeaks ];
                extensionCount=extensionCount+1;
            end
            break;
        end

        % the reference segment is first
        if refIndex<=1
            if generalStart<intSegments(iSegmentIndex-1).end;
                generalStart=min(generalStart,intSegments(iSegmentIndex-1).start);
                iLeftB=[intSegments(iSegmentIndex-1).PeakLeftBoundary iLeftB ];
                iRightB=[intSegments(iSegmentIndex-1).PeakRightBoundary iRightB ];
                iPeaks=[ intSegments(iSegmentIndex-1).Peaks iPeaks];
                extensionCount=extensionCount+1;
            end
            break;
        end

        % both segments end before the general start
        if intSegments(iSegmentIndex-1).end<=generalStart&&...
                refSegments(refIndex-1).end<=generalStart
            break;
        end

        % both segments end after the general start (in fact impossible)
        if generalStart<intSegments(iSegmentIndex-1).end&&generalStart<=refSegments(refIndex-1).end
            generalStart=min([generalStart,refSegments(refIndex-1).start,intSegments(iSegmentIndex-1).start]);

            iLeftB=[intSegments(iSegmentIndex-1).PeakLeftBoundary iLeftB ];
            iRightB=[intSegments(iSegmentIndex-1).PeakRightBoundary iRightB ];
            refLeftB=[refSegments(refIndex-1).PeakLeftBoundary refLeftB ];
            refRightB=[refSegments(refIndex-1).PeakRightBoundary refRightB ];
            iPeaks=[ intSegments(iSegmentIndex-1).Peaks iPeaks];
            rPeaks=[refSegments(refIndex-1).Peaks rPeaks ];
            iSegmentIndex=iSegmentIndex-1;
            refIndex=refIndex-1;
            extensionCount=extensionCount+1;
            continue;
        end

        % the segment of interest ends after the general start
        if generalStart<intSegments(iSegmentIndex-1).end
            generalStart=min(generalStart,intSegments(iSegmentIndex-1).start);
            
            iLeftB=[intSegments(iSegmentIndex-1).PeakLeftBoundary iLeftB ];
            iRightB=[intSegments(iSegmentIndex-1).PeakRightBoundary iRightB ];
            iPeaks=[ intSegments(iSegmentIndex-1).Peaks iPeaks];
            iSegmentIndex=iSegmentIndex-1;
            extensionCount=extensionCount+1;
            continue;
        end

        % the reference segment ends after the general start
        if generalStart<refSegments(refIndex-1).end
            generalStart=min(generalStart,refSegments(refIndex-1).start);
            
            extensionCount=extensionCount+1;
            refLeftB=[refSegments(refIndex-1).PeakLeftBoundary refLeftB ];
            refRightB=[refSegments(refIndex-1).PeakRightBoundary refRightB ];
            rPeaks=[refSegments(refIndex-1).Peaks rPeaks ];
            refIndex=refIndex-1;
            continue;
        end
    end

    % search for 'generalEnd' preventing overlapping with the following segments
    iEnd = iSegment.end;
    refEnd = refSegment.end;
    generalEnd = max([iEnd, refEnd]);

    while(true)

        % No segments ahead
        if iSegmentInd>=intSegLength&&referenceInd>=refSegLength
            break;
        end

        % No segment ahead in spectrum of interest
        if iSegmentInd>=intSegLength
            if generalEnd>refSegments(referenceInd+1).start
                generalEnd= max(generalEnd,refSegments(referenceInd+1).end);
                refLeftB=[ refSegments(referenceInd+1).PeakLeftBoundary refLeftB];
                refRightB=[ refSegments(referenceInd+1).PeakRightBoundary refRightB];
                rPeaks=[ rPeaks refSegments(referenceInd+1).Peaks];
                                extensionCount=extensionCount+1;
                break;
            end
            break;
        end

        % No segment ahead in reference spectrum
        if referenceInd>=refSegLength
            if generalEnd>intSegments(iSegmentInd+1).start

                generalEnd=max(generalEnd,intSegments(iSegmentInd+1).end);
                iLeftB=[ iLeftB intSegments(iSegmentInd+1).PeakLeftBoundary ];
                iRightB=[ iRightB intSegments(iSegmentInd+1).PeakRightBoundary ];
                iPeaks=[  iPeaks intSegments(iSegmentInd+1).Peaks];
                                extensionCount=extensionCount+1;
                break;
            end
            break;
        end

        % Both subsequent segments start after the current general end
        if generalEnd<=intSegments(iSegmentInd+1).start&&...
                generalEnd<=refSegments(referenceInd+1).start
            break;
        end

        % Both segments starts before the General End
        if generalEnd>intSegments(iSegmentInd+1).start&&...
                generalEnd>refSegments(referenceInd+1).start
            
            generalEnd=max([generalEnd,intSegments(iSegmentInd+1).end,...
                refSegments(referenceInd+1).end]);
            iLeftB=[ iLeftB intSegments(iSegmentInd+1).PeakLeftBoundary ];
            iRightB=[ iRightB intSegments(iSegmentInd+1).PeakRightBoundary ];
            refLeftB=[ refLeftB refSegments(referenceInd+1).PeakLeftBoundary ];
            refRightB=[  refRightB refSegments(referenceInd+1).PeakRightBoundary];
            iPeaks=[  iPeaks intSegments(iSegmentInd+1).Peaks];
            rPeaks=[ rPeaks refSegments(referenceInd+1).Peaks];
            referenceInd=referenceInd+1;
            iSegmentInd=iSegmentInd+1;
            extensionCount=extensionCount+1;
            continue;
        end

        % If the next segment in intSp starts before the general end
        if generalEnd>intSegments(iSegmentInd+1).start&&...
                isempty(intSegments(iSegmentInd+1).refIndex)
            generalEnd=max(generalEnd,intSegments(iSegmentInd+1).end);
            iLeftB=[ iLeftB intSegments(iSegmentInd+1).PeakLeftBoundary ];
            iRightB=[ iRightB intSegments(iSegmentInd+1).PeakRightBoundary ];
            iPeaks=[  iPeaks intSegments(iSegmentInd+1).Peaks];
            iSegmentInd=iSegmentInd+1;
            extensionCount=extensionCount+1;
            continue;
        elseif generalEnd>intSegments(iSegmentInd+1).start
            refInd=referenceInd+1;
            referenceInd=intSegments(iSegmentInd+1).refIndex;
            generalEnd=max([generalEnd,intSegments(iSegmentInd+1).end,...
                refSegments(referenceInd).end]);
            iLeftB=[ iLeftB intSegments(iSegmentInd+1).PeakLeftBoundary ];
            iRightB=[ iRightB intSegments(iSegmentInd+1).PeakRightBoundary ];
            iPeaks=[  iPeaks intSegments(iSegmentInd+1).Peaks];
            for i=refInd:referenceInd
                refLeftB=[ refLeftB refSegments(i).PeakLeftBoundary ];
                refRightB=[  refRightB refSegments(i).PeakRightBoundary];
                rPeaks=[ rPeaks refSegments(i).Peaks];

            end
            iSegmentInd=iSegmentInd+1;
            extensionCount=extensionCount+1;
            continue;
        end

        % If the next segment in refSp starts before the general end
        if generalEnd>refSegments(referenceInd+1).start&&...
                isempty(refSegments(referenceInd+1).used)
            
            generalEnd=max(generalEnd,refSegments(referenceInd+1).end);
            refLeftB=[ refLeftB refSegments(referenceInd+1).PeakLeftBoundary ];
            refRightB=[  refRightB refSegments(referenceInd+1).PeakRightBoundary];
            rPeaks=[ rPeaks refSegments(referenceInd+1).Peaks];
            referenceInd=referenceInd+1;
            extensionCount=extensionCount+1;
            continue;
        elseif generalEnd>refSegments(referenceInd+1).start
            iSegIndex=iSegmentInd+1;
            iSegmentInd=refSegments(referenceInd+1).used;
            generalEnd=max([generalEnd,intSegments(iSegmentInd).end,...
                refSegments(referenceInd+1).end]);
            for i=iSegIndex:iSegmentInd
                iLeftB=[ iLeftB intSegments(i).PeakLeftBoundary ];
                iRightB=[ iRightB intSegments(i).PeakRightBoundary ];
                iPeaks=[  iPeaks intSegments(i).Peaks];

            end
            refLeftB=[ refLeftB refSegments(referenceInd+1).PeakLeftBoundary ];
            refRightB=[  refRightB refSegments(referenceInd+1).PeakRightBoundary];
            rPeaks=[ rPeaks refSegments(referenceInd+1).Peaks];
            referenceInd=referenceInd+1;
            extensionCount=extensionCount+1;
            continue;
        end
    end

    refSegment    = refSp(generalStart : generalEnd);
    testSegment   = intSp(generalStart : generalEnd);

    Bnd.refLeftB=refLeftB-generalStart+1;
    Bnd.refRightB=refRightB-generalStart+1;
    Bnd.iLeftB=iLeftB-generalStart+1;
    Bnd.iRightB=iRightB-generalStart+1;

    plotTwoWithSegmentD(refSegment,testSegment,Bnd,[],debug);
    
    alignedSegment = localRecurAlign(testSegment, refSegment, recursion, 1,1,debug);
    

    if any(isnan(alignedSegment))
        pause;
    end
    alignedSpectrum(generalStart : generalEnd) = alignedSegment;
   plotTwoA(refSegment,alignedSegment,[],recursion.step,debug);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%-- align 'grass':
    grassStart  = prevGeneralEnd + 1;
    grassEnd    = generalStart - 1;
    if( grassEnd > grassStart )
        refSegment    = refSp( grassStart : grassEnd );
        testSegment      = intSp( grassStart : grassEnd );

        %do not want to visualize grass
        plotTwoA(refSegment,testSegment,[],recursion.step,debug);

        alignedSegment = localRecurAlign(testSegment, refSegment, recursion, 0,1,debug);
        alignedSpectrum( grassStart : grassEnd ) = alignedSegment;
    end;
    prevGeneralEnd = generalEnd;

    % don't forget to increase the counter!!!
    iSegmentInd = iSegmentInd + 1;
end;

if(extensionCount > 0)
    extensionInfo.extensionCount = extensionCount;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(extendedSegments))
    maxExtensionCount = -1;
    maxExtInd = [];
    for extendedSegment = extendedSegments
        if(extendedSegment.extensionCount > maxExtensionCount)
            maxExtensionCount = extendedSegment.extensionCount;
            maxExtInd = extendedSegment.extensionSegmentInd;
        end;
    end;
    maxExtensionInfo.extensionSegmentInd = maxExtInd;
    maxExtensionInfo.extensionCount = maxExtensionCount;
    extendedSegments = [extendedSegments, maxExtensionInfo];
end;

grassStart  = prevGeneralEnd + 1;
grassEnd    = specLen;
if( grassEnd > grassStart )
    refSegment    = refSp( grassStart : grassEnd );
    testSegment      = intSp( grassStart : grassEnd );
    plotTwoA(refSegment,testSegment,[],recursion.step,debug);

    alignedSegment = localRecurAlign(testSegment, refSegment, recursion, 0,1,debug);
    alignedSpectrum( grassStart : grassEnd ) = alignedSegment;
end
if isnan(alignedSpectrum(1))
    alignedSpectrum(1)=alignedSpectrum(2);
end
if isnan(alignedSpectrum(end))
    alignedSpectrum(end)=alignedSpectrum(end-1);
end
return