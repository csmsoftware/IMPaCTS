function plot_1Ds(X,ppm)

%plot_1Ds(X,ppm)
%
%Input: X: stack of 1D spectra
%       ppm: chemical shift vector
%
% plot_1Ds generates a 3D figure plotting each 1D spectrum.  You can rotate
% the plot to see the spectral stack from any angle.
%
%Author: Steven L Robinette, University of Florida & Imperial College
%London

figure, line(ppm,ones(1,size(X,2)),X(1,:))
hold on
for k=2:size(X,1)
line(ppm,k*ones(1,size(X,2)),X(k,:),'Color',rand(1,3))
end