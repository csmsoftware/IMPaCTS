function [a] = signal2(top,bottom,data2,ppm)
% [a] = signal(top,bottom,data2,ppm)
% top,bottom - limits of ppm range you wish to sum over
% data2 - series of spectra
% ppm - ppm values
% a - sum at the range of interest for each spectrum
% written by Hector Keun 12/7/05


if top<bottom
    z = bottom;
    bottom = top;
    top = z;
end


[n,k] = size(data2);
a = sum((data2(:,intersect(find(ppm<top),find(ppm>bottom))))')';
%Now take off the area under the baseline - this is defined by the
%trapezoid from the top and bottom of the range to he end values of the
%peaks
a=a-(.5*(data2(:,find(ppm<top,1,'first')))+data2(:,find(ppm>bottom,1,'last'))*(top-bottom));