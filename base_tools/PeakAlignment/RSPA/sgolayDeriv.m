function dpDerivs = sgolayDeriv(dpSpectr, iOrder,iFrameLen,j)
% Calculate smoothed derivates using Savitzky - Golay filter
% iFrameLen- the length of frame window

if nargin<1
    error('Incorrect number of input arguments');
end

if nargin<2 
    iOrder = 3; 
end

if nargin<3
    iFramLen=11;
end

if nargin<4
    j=2; %Derivative
end

iFrameLen=(floor(iFrameLen./2))*2+1; % iFramLen must be odd

iSpecLen = length(dpSpectr);

[b,g] = sgolay(iOrder,iFrameLen);

dpDerivs(1:iFrameLen) = 0;
dpDerivs(iSpecLen-(iFrameLen+1)/2:iSpecLen) =0;

for n = (iFrameLen+1)/2:iSpecLen-(iFrameLen+1)/2
    %calculate first order derivate
    dpDerivs(n)=g(:,j)'*dpSpectr(n - (iFrameLen+1)/2 + 1: n + (iFrameLen+1)/2 - 1)';   
end

return;