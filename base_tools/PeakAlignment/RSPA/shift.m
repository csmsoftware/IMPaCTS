%shift segments----------------------------------------------------------
function shiftedSeg = shift(seg, lag)

if lag == 0 || lag >= length(seg)
    shiftedSeg = seg;
    return
end

if lag > 0
    ins = ones(1,lag) * seg(1);
    shiftedSeg = [ins seg(1:(length(seg) - lag))];
elseif lag < 0
    lag = abs(lag);
    ins = ones(1,lag) * seg(end);
    shiftedSeg = [seg((lag+1):length(seg)) ins];
end

