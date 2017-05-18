function plotTwoWithSegmentD(refKvant,iKvant,peaks,xValues,debug);

if isempty(debug);
    return
end

iSegment.start=peaks.iLeftB;
iSegment.end=peaks.iRightB;
rSegment.start=peaks.refLeftB;
rSegment.end=peaks.refRightB;
if debug<0
     plotTwoWithPeaks(refKvant, rSegment, iKvant,...
         iSegment, xValues);
     pause;
else
   plotTwoWithPeaks(refKvant, rSegment, iKvant,...
         iSegment, xValues);
     pause(debug);
end
return