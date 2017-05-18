function selectTarget(hObject,method)
%% selectTarget computes a target sample with respect to peak positions of
%% which all other samples are to be aligned 

metadata = guidata(hObject);
if isempty(metadata.peakBndrs)
    metadata.T = [];
    return;
end

if (metadata.alignBetweenUserDefinedRegns)
    X    = metadata.Sp;
else
    X    = getDataMatrix(metadata.Sp,metadata.peakBndrs);
end

switch lower(method)
    case {'mean'}
        metadata.T = mean(metadata.Sp);
    case 'median'
        metadata.T = median(metadata.Sp);
    case 'simtomean'
        X           = [X;mean(X)];
        CCs         = corrcoeffs(X(1:end-1,:)',X(end,:)',[]);
        metadata.T  = metadata.Sp(CCs==max(CCs),:);
    case 'simtomedian'
        X           = [X;median(X)];
        CCs         = corrcoeffs(X(1:end-1,:)',X(end,:)',[]);
        metadata.T  = metadata.Sp(CCs==max(CCs),:);
    case 'simtoallsamples'
        CCs          = corrcoef(X');
        CCs(CCs<0)   = 0.1;
        metadata.T   = metadata.Sp(sum(CCs)==max(sum(CCs)),:);
end
guidata(hObject,metadata);
return;

function X = getDataMatrix(Sp,peakBndrs)

nBndrs     = length(peakBndrs); 
DiffPB     = diff(peakBndrs);
nPeakIndcs = sum(DiffPB(1:2:end)+1); 
nSmpls     = size(Sp,1);
X          = repmat(NaN,[nSmpls,nPeakIndcs]);
iStart     = 1; 
iEnd       = 0;
for iBndr = 1:2:nBndrs
    iEnd  =  iEnd + peakBndrs(iBndr+1) - peakBndrs(iBndr) +1; 
    X(:,iStart:iEnd) = Sp(:,peakBndrs(iBndr):peakBndrs(iBndr+1));
    iStart = iEnd +1;
end
return; 