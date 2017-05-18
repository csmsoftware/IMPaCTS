function peak = zeroPad(peak, maxLen)
zerosCnt = maxLen - length(peak);
if(zerosCnt > 0)
    leftPaddCnt = floor(zerosCnt /2 );
    rightPaddCnt = zerosCnt - leftPaddCnt;
    peak = [repmat(0,1,leftPaddCnt) peak repmat(0,1,rightPaddCnt)];
end;
return;