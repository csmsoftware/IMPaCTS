% FFT cross-correlation------------------------------------------------
function lag = FFTcorr(testSegment, target,shift)
%padding
M=size(testSegment,2);
diff = 2^(ceil(log2(M))) - M;
testSegment=testSegment-min(testSegment);
target=target-min(target);
% append our ref & test segments with zeros at the end.
target(1,M+diff)=0;
testSegment(1,M+diff)=0;
M= M+diff;
X=fft(target);
Y=fft(testSegment);
R=X.*conj(Y);
R=R./(M);
rev=ifft(R);
vals=real(rev);
maxpos = 1;
maxi = -1;
if M<shift
    shift = M;
end

for i = 1:shift
    if (vals(1,i) > maxi)
        maxi = vals(1,i);
        maxpos = i;
    end
    if (vals(1,length(vals)-i+1) > maxi)
        maxi = vals(1,length(vals)-i+1);
        maxpos = length(vals)-i+1;
    end
end

if maxpos > length(vals)/2
    lag = maxpos-length(vals)-1;
else
    lag =maxpos-1;
end

