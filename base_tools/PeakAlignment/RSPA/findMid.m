%find position to divide segment--------------------------------------
function mid = findMid(testSeg,refSeg)
specLn=length(testSeg);
M=ceil(length(testSeg)/2);
specM=testSeg(1,M-floor(M/4):M+floor(M/4));
refM=refSeg(1,M-floor(M/4):M+floor(M/4));

[C,I]=min(specM.*refM);
%[C,I]=min(specM);
mid = I(1,1)+M-floor(M/4);
% move to a point of a local minima
index=1;

while (1)
    if mid-1<=1||mid+1>=specLn
        mid=[];
        break;
    end
    if testSeg(mid)<=testSeg(mid+1)&&testSeg(mid)<=testSeg(mid-1)
        break;
    end
    if testSeg(mid)>=testSeg(mid+1)
        mid=mid+1;
    elseif testSeg(mid)>=testSeg(mid-1)
        mid=mid-1;
    end
end
return;