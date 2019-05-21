function [F] = objphase(p,ppm,re,im,pbreg,step)
% objphase - calculate objective function (used by autophase)
% [F] = objphase(p,ppm,re,im,[pbreg,step])
%
% re,im = (nX1) real and imag parts of zero phase spectrum
% p = (1X2) phase constants: [p0 p1]
% pbreg = (mX2) regions to use for flattening baseline
%
% F = (1X1) returned objective function
%
% Written 170101 TMDE  
% Revised 161202 TMDE to give warning if can't find any data points in
% autophasing baseline regions.
% (c) 2001-2003 Dr. Timothy M D Ebbels, Imperial College, London

% Defaults

if (nargin<5) pbreg = [13.5 10; -0.5 -4]; end
if (nargin<6) step = 4; end
method = 1;

% Rephase spectrum with current params

rep = phase(re,im,p,0);

% Objective functions:

switch method
 
 case 1
  % Squared deviation from straight line fit to means of two edge regions
  % reg = [13.5 10;
  %     -0.5 -4];
  kpind1 = find(ppm<pbreg(1,1) & ppm>pbreg(1,2));
  kpind2 = find(ppm<pbreg(2,1) & ppm>pbreg(2,2));
  if (isempty(kpind1) | isempty(kpind2))
      warning('autophase: no regions found for autophasing - check autophase baseline regions');
      specp = [];
      return
  end
  
  ym1 = mean(rep(kpind1(1:step:end)));
  ym2 = mean(rep(kpind2(1:step:end)));
  x1 = 0.5*(2*kpind1(1)+length(kpind1)-1);
  x2 = 0.5*(2*kpind2(1)+length(kpind2)-1);
  m = (ym2-ym1)/(x2-x1);
  c = ym1-m*x1;
  resid1 = rep(kpind1)-m*kpind1-c;
  resid2 = rep(kpind2)-m*kpind2-c;
  F = sum(resid1.*resid1) + sum(resid2.*resid2);
  
% $$$   fprintf('p=(%.1f %.1f) F1=%.3e F2=%.3e F=%.3e\n',p,F1,F2,F);

end