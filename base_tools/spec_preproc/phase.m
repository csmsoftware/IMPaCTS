function [rep,imp] = phase(re,im,p,pvt)
% phase - phase a 1d spectrum 
% [rep,imp] = phase(re,im,p,pvt)
%
% re,im = (nX1) - real & imaginary parts of spectrum
% p = (1X2) - zeroth and first order coefficients in degrees [p0 p1] 
% pvt = (1X1) - phase pivot point (first order correction zero)
%    Phase at i'th point in the spectrum is calculated using:
%    phase = p0 + (i-pvt)*p1  radians
%
% rep,imp = (nX1) - real & imaginary parts of phased spectrum
%
% Written 150101 TMDE  
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

% Defaults

if (nargin<4) pvt = 0; end
np = length(re);

% Calc phase correction

p0 = d2r(p(1));
p1 = d2r(p(2));
phases = p0 + ([1:np]' - pvt)/np * p1;
rep = re.*cos(phases) - im.*sin(phases);
if (nargout>1)
  imp = re.*sin(phases) + im.*cos(phases);
end
