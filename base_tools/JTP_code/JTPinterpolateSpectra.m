% [interpolatedSpectra, newPPM] = JTPinterpolateSpectra(spectra, ppm, kind, newPPM)
%
% Use cubic-spline interpolation to increase / decrease the number of
% points in an NMR spectrum. If you wish to re-size the a spectrum with
% both imaginary and real parts, simple run the function seperatly for each
% part.
% 
% If extra ppm axes are specified like so:
% [interpolatedSpectra, newPPM, newPPM2] = JTPinterpolateSpectra(spectra, ppm, 'kind', newPPM1, ppm2, newPPM2) spectra is
% interpreted as a single 2D spectrum.
%
% Arguments:
% spectra       NMR spectra.
% ppm           The ppm scale
% kind          Either 'Points', to reduce or expand the existing spectral
%               width to a set number of points, or 'PPM' to interploate
%               the spectra onto a new scale.
%
% newPPM        If kind is 'Points', the number of points to interpolate
%               the spectrum into. If kind is 'PPM', the new ppm to apply
%               the spectra to.
%
% Return Values:
% interpolatedSpectra   The re-sized spectrum.
% newPPM                The corasponding PPM scale.
%
% Last Revision 15/1/2014
% (c) 2006 Jake Thomas Midwinter Pearce

% Updated errors.

function [interpolatedSpectra, newPPM, varargout] = JTPinterpolateSpectra(spectra, ppm, kind, newPPM, varargin)

[noSpectra, spectralWidth] = size(spectra);

is2D = false();

% Check number or arguments
if isempty(varargin);
    % Do nothing
    varargout(1) = {NaN};
elseif length(varargin) == 2;
    is2D = true();
    ppm2 = varargin{1};
    newPPM2 = varargin{2};    
else
    error('JTPcode:JTPinterpolateSpectra:unknownMode', ...
    'Output is undefined for %n inputs, see JTPinterpolateSpectra for acceptable options.\n', length(varargin)+4);
end

% Do the work
if strcmpi(kind, 'Points')
    spectralWidth = max(ppm) - min(ppm);
    spectralWidth = spectralWidth / (newPPM - 1);

    newPPM = max(ppm):-spectralWidth:min(ppm);
    
    if is2D
        spectralWidth = max(ppm2) - min(ppm2);
        spectralWidth = spectralWidth / (newPPM2 - 1);

        newPPM2 = max(ppm2):-spectralWidth:min(ppm2);
        varargout = {newPPM2};
    end
elseif strcmpi(kind, 'PPM')
    if is2D
        varargout = {newPPM2};
    end
else
    error('JTPcode:JTPinterpolateSpectra:unknownMode', ...
        'Error kind: %s unkown, see JTPinterpolateSpectra for acceptable options.\n', kind);
end


% Do the work
if is2D
    [X, Y] = meshgrid(newPPM, newPPM2);
    interpolatedSpectra = interp2(ppm,ppm2,spectra,X, Y, 'linear');
    
elseif(noSpectra == 1)
    interpolatedSpectra = interp1(ppm, spectra, newPPM);
else
    interpolatedSpectra = zeros(noSpectra, length(newPPM));
    for i = 1:noSpectra

        interpolatedSpectra(i,:) = interp1(ppm, spectra(i,:), newPPM);

    end
end
end