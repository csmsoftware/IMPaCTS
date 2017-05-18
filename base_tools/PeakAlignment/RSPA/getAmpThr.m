function  ampThr=getAmpThr(peaks)
% Automatic determination of amplitude threshold for peak peaking
% based on the 5% of the most intensive peaks 
% Author, K.Veselkov, Imperial College London, 2007

PeakCount=length(peaks);
peakMaxValues = repmat(NaN, [1, PeakCount]);

for i=1:PeakCount
      peakMaxValues(i)=peaks(i).maxVal-peaks(i).basl;
end
%%% Select threshold based on 5% of the most intensive peaks
index=floor(PeakCount*0.95);
peakSortedValuess=sort(peakMaxValues);
ampThr=peakSortedValuess(index);
return;