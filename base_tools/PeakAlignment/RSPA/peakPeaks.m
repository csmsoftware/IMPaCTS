function peaks=peakPeaks(SpSmooth,dpDerivs,Sp,debug)
% Peak peaking:
% Input: SpSmooth - smoothed spectrum
%        dpDerivs - smoothed derivative of the spectrum
%        debug - yes
% - the peak is identified if derivative crosses zero,
% i.e. sign(X'(i))>sing(X'(i+1))

% Author Kirill Veselkov, Imperial 2007

if nargin<2
    % TODO: remove comment
    %error('Invalid number of input arguments')
end

iSpecLen=length(SpSmooth);
iPeakInd =1;

% Matrix pre-location
peaks(iSpecLen).maxPos=[];

for i=1:iSpecLen-1
    % coarse peak maximum position
    if dpDerivs(i)>=0&&dpDerivs(i+1)<0
        peaks(iPeakInd).maxPos=i+1;
        % Temporary starting and ending peak positions
        iPeakInd=iPeakInd+1;
    end
end

peakCount=iPeakInd-1;
peaks=peaks(1:peakCount);

targetPkIdx=1;

for srcPkIdx=1:peakCount
    maxPos=peaks(srcPkIdx).maxPos;
    
    while (maxPos > 2 && maxPos < iSpecLen-2)
        if SpSmooth(maxPos-1)<=SpSmooth(maxPos)&&...
                SpSmooth(maxPos)>=SpSmooth(maxPos+1)
            
           if(targetPkIdx > 1 && peaks(targetPkIdx-1).maxPos==maxPos)
                % the same maximum value - just skip it
                break;
            end
            % save the new index:
            peaks(targetPkIdx).maxPos = maxPos;
            targetPkIdx = targetPkIdx + 1;
            break;
        end
        if SpSmooth(maxPos)<=SpSmooth(maxPos+1)
            maxPos=maxPos+1;
        elseif SpSmooth(maxPos)<=SpSmooth(maxPos-1)
            maxPos=maxPos-1;
        end
    end
end

peakCount=targetPkIdx-1;
peaks=peaks(1:peakCount);

for i=1:peakCount
    j=peaks(i).maxPos;
    k=peaks(i).maxPos;

    % left boundary
    while SpSmooth(j)>=SpSmooth(j-1) && j-1~=1 %first index
        j=j-1;
    end

    % right boundary
    while SpSmooth(k)>=SpSmooth(k+1) && k+1~=iSpecLen %last index
        k=k+1;
    end

    peaks(i).startPos=j;
    peaks(i).endPos=k;
    peaks(i).centre=ceil((k+j)/2);
    peaks(i).startVal=SpSmooth(j);
    peaks(i).endVal=SpSmooth(k);
    peaks(i).index=i;
    % Use peak maximum position from original spectrum
    % instead of smoothed one.
    %peaks(i).maxVal=SpSmooth(peaks(i).maxPos);
    [peaks(i).maxVal, maxInd]=max(Sp(j:k));
    peaks(i).maxPos=j+maxInd-1;

    %estimate the baseline as minimum value:
    peaks(i).basl = min([SpSmooth(k), SpSmooth(j)]);
end

if ~isempty(debug);
    peakStartPositions=[];
    peakEndPositions=[];
    peakMaxPositions=[];
    for i=1:peakCount
        peakStartPositions=[peakStartPositions peaks(i).startPos];
        peakEndPositions=[peakEndPositions peaks(i).endPos];
        peakMaxPositions=[peakMaxPositions peaks(i).maxPos];
    end
    plotPeaksOrSegments(Sp,peakMaxPositions,peakStartPositions,...
        peakEndPositions,debug)
end

return;