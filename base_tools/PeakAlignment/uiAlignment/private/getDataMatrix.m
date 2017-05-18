function X = getDataMatrix(Sp,peakBndrs)

nBndrs    = length(metadata.peakBndrs); 
DiffPB     = diff(peakBndrs);
nPeakIndcs = sum(DiffPB(1:2:end)+1); 
nSmpls     = size(Sp,1);
X          = repmat(1,nSmpls,nPeakIndcs);
iStart     = 1; 
for iBndr = 1:2:nBndrs
    iEnd  =  peakBndrs(iBndr+1) - peakBndrs(iBndr) +1; 
    X(:,iStart:iEnd) = Sp(:,peakBndrs(iBndr):peakBndrs(iBndr+1));
    iStart = iEnd +1;
end
return; 