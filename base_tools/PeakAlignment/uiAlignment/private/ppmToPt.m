function pt = ppmToPt(ppmValues, firstPtPpm, resolution)
%
%
%

if(nargin < 2 || isempty(firstPtPpm))
    error('nargin < 2 || isempty(firstPtPpm)');
end;
if(nargin < 3 || isempty(resolution))
    resolution = ppmValues(2) - ppmValues(1);
end;

if(~isscalar(firstPtPpm))
    error('First ppm should be a number, got non-scalar value: %d', firstPtPpm);
end;
if(~isscalar(resolution))
    error('Resolution ppm should be a number, got non-scalar value: %d', resolution);
end;

ppmShift = ppmValues - firstPtPpm;

pt = round(ppmShift ./ resolution) + 1;

return