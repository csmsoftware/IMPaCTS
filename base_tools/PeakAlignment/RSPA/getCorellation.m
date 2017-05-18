function corellation = getCorellation(dpReferencePeak, dpInputPeak, maxShift)

if nargin<3
    error('Invalid input parameters count');
end
if length(dpReferencePeak)~=length(dpInputPeak)
    error('dpReferencePeak and dpInputPeak sizes must agree');
end
%evaluate lag by Wong
lag = FFTcorr( dpInputPeak,dpReferencePeak, maxShift);
aligned = shift(dpInputPeak,lag);

%get corellation coefficients
corellation = corrcoef(dpReferencePeak, aligned);
corellation= corellation(1,2);

return;