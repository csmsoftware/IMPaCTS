function displaypeak(sp,ppm,shift)

%displaypeak(sp,ppm,shift)
%
%Input: sp: stack of 1D spectra
%       ppm: chemical shift vector
%       shift: one or more chemical shifts, takes scalar or vector 
%
% displaypeak plots a set of chemical shift values as circles on a set of
% 1D spectra.  Use this script to assign correlated peaks.
%
%Author: Steven L Robinette, University of Florida & Imperial College
%London

figure, plot(ppm,sp)
set(gca,'XDir','reverse')
hold on
for k=1:length(shift)
[a,b(k)]=min(abs(ppm-shift(k)));
end
scatter(shift,max(sp(:,b)));