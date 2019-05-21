function [reb] = baseline(ppm,rep,breg)
% baseline(ppm,rep[,breg]) - correct baseline for 1d NMR spectrum
%
% rep = real part of phased spectrum
% ppm = ppm values
% breg = regions of baseline to fit
%
% [reb] = corrected real spectrum
%
% Written 170401 HCK
% Revised 171001 TMDE to optionally specify region used for baseline fit
% Revised 161202 TMDE to warn if cannot find any data points in baseline
% regions
% (c) 2001-2003 Dr. Timothy M D Ebbels & Dr. Hector Keun, Imperial College, London

if (nargin<3) breg = [13.5 10; -0.5 -4]; end

kpind1 = find(ppm<breg(1,1) & ppm>breg(1,2));
kpind2 = find(ppm<breg(2,1) & ppm>breg(2,2));
if (isempty(kpind1) | isempty(kpind2))
    warning('baseline: no regions found for autophasing - check baseline regions');
    reb = [];
    return
end

ym1 =  mean(rep(kpind1(1:4:end)));
ym2 =  mean(rep(kpind2(1:4:end)));
x1 = 0.5*(2*kpind1(1)+length(kpind1)-1);
x2 = 0.5*(2*kpind2(1)+length(kpind2)-1);
m = (ym2-ym1)/(x2-x1);
c = ym1-m*x1;

reb = rep -  m*[1:length(ppm)]' - c;

