function plotTwoWithSegmentsD(refKvant,iKvant,rSegment,iSegment,...
    xValues,debug);

if isempty(debug);
    return
end

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