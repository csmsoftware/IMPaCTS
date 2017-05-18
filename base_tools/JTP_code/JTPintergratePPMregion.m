% [intergratedValues] = JTPintergratePPMregion(spectra, ppm, regions)
%
% Intergrate regions of an array of spectra, as defined by the area
% enclosed in regions.
%
% Arguments:
% spectra       NMR spectra.
% ppm           The ppm scale
% regions       An array of regions to intergrate, low ppm to high ppm,
%               with aditional regions on new lines
%
% Return Values:
% intergratedValues    An array of intergrate values, with one line per
%                      spectra.
%
% Last Revision 16/03/2009
% (c) 2006 Jake Thomas Midwinter Pearce

% Somehow peak selection was broken.

% Cleaned up mlint messsages.

function [intergratedValues] = JTPintergratePPMregion(spectra, ppm, regions)

[noRegions, endPoint] = size(regions);
[noSpectra, dummy] = size(spectra); %#ok

% Error checking, if endPoint is not == 2 quit.
if(endPoint ~= 2)
    error('Each ppm region must have an opening and closeing value!'); %#ok
end

% Preallocate intergratedValues for speed.
intergratedValues = zeros(noSpectra, noRegions);

% Delete areas between the ppm regions
for i = 1:noRegions
    
    regionMask = (ppm > min(regions(i,:))) & (ppm < max(regions(i,:)));
    % Interpolate areas
    intergratedValues(:,i) = sum(spectra(:,regionMask),2);
    
end

end