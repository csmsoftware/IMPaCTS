function [offset] = reference(ppm,re,rreg,refppm)
% roffset = reference(ppm,re[,rreg,refppm]) - ref spectra to TSP
% re = real part of phased spectrum
% ppm = digitized ppm values
% offset = OFFSET correction (ppm)
%
% Written 09/05/01 HCK
% Revised 171001 TMDE to optionally specify region used to find ref peak
% Revised 091101 TMDE to optionally specify ppm of reference peak
% Revised 161202 TMDE to warn if can't find any data points in reference
% peak region
% (c) 2001-2003 Dr. Timothy M D Ebbels & Dr. Hector Keun, Imperial College, London

if (nargin<3) rreg = [0.2 -0.2]; end
if (nargin<4) refppm = 0; end
rreg = sort(rreg,2);
rreg = rreg(end:-1:1);
kpind = find(ppm<rreg(1) & ppm>rreg(2))
if (isempty(kpind))
    warning('reference: no regions found - check reference peak region');
    specp = [];
    return
end

[height,index] =  max(re(kpind(1:end)))
offset = ppm(kpind(index)) - refppm;