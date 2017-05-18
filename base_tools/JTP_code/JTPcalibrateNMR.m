% [ppm, spectra, ...] = JTPcalibrateNMR(type, ppm, spectra, ...)
% 
% Function to take a bunch of NMR spectra, correct the ppm scale of each 
% one, then align them onto a common ppm scale. By defualt aligns by
% shifting points of the left end of the spectra onto the right, or
% vice-versa.
%
% Arguments:
% type          What method of calibration to use. May be 'glucose' to
%               calibrate to the a-anomeric glucose doublet at 5.233, or
%               'TSP' to calibrate to the TSP singlet at 0 ppm.
% ppm           Vector containg the orginal ppm scale.
% spectra       Matrix of spectra to be calibrated.
%
% Optional Arguments:
%   In the form 'option', value
% Align         Method used to align multiple spectra. May be
%               'circularShift' (default), 'interpolate' or 'none'.
% RefTo         Overide the defualt reference point and set it to this
%               value.
% SearchRange   Overide the defaults and search within this range:
%               [HighPPM lowPPM]
% Kind          By defualt JTPcalibrateNMR works on an array of 1D spectra,
%               by setting 'Kind' to 'J-RES', it will calibrate a single
%               J-RES spectrum.
% imaginarySpectra
% 
%
% Return Values:
% ppm           The new ppm scale.
% spectra       The aligned spectra.
% 
% Last Revision 10/01/2014
% (c) 2006 Jake Thomas Midwinter Pearce

% Added documentation for options.

% Now to adapted handle to spectra runing low -> high and high -> low.


function [ppm, spectra, varargout] = JTPcalibrateNMR(type, ppm, spectra, varargin)
% Defaults
args.Align = {'circularShift', 'interpolate', 'none'};
args.imaginarySpectra = [];
args.RefTo = [];
args.SearchRange = [];
args.Kind = {'1D' 'J-RES'};

[noSpectra, noPoints] = size(spectra);

args = MWparseargs(args, varargin{:});

% If the ppm scale is descending, flip the data matrixes l<>r.
descending = ppm(1) > ppm(2);
if(descending)
    ppm = fliplr(ppm);
    spectra = fliplr(spectra);
end

% Get the global PPM scale

% If its a JRES we get the shift once outside the main loop.
if(strcmpi(args.Kind, 'J-RES'))

    
    if(ndims(spectra) ~= 2)
        error('J-RES spectra must be calibrated one at a time', 'JTPcalibrateNMR')
    end
    
    if(isempty(args.SearchRange))
        args.SearchRange = [5.5 5];
    end
    if(isempty(args.RefTo))
        args.RefTo = 5.233;
    end

    summation = sum(spectra,1);

    deltaPPM = JTPreferenceToLargestPeak(summation, ppm, args.SearchRange);
    ppmAim = find(ppm <= args.RefTo, 1, 'last' );
    deltaPPM = deltaPPM - ppmAim;
    deltaPPM = deltaPPM *-1;
    
    if(strcmpi(args.Align, 'circularShift'))
        spectra = circshift(spectra, [0, deltaPPM]);
        if(~isempty(args.imaginarySpectra))
            args.imaginarySpectra = circshift(args.imaginarySpectra, [0, deltaPPM]);
        end        
    elseif(strcmpi(args.Align, 'interpolate'))
        % Reinterpolate to match global ppm bounds.
        newPPM = ppm - deltaPPM;
        [spectra, newPPM] = JTPinterpolateSpectra(spectra, newPPM, 'PPM', ppm, 1:noSpectra, 1:noSpectra);
        if(isempty(args.imaginarySpectra))
            [args.imaginarySpectra, newPPM] = JTPinterpolateSpectra(args.imaginarySpectra, newPPM, 'PPM', ppm, 1:noSpectra, 1:noSpectra);
        end
    else

    end
    
elseif(strcmpi(args.Kind, '1D'))

    % Align each spectra by type
    for i = 1:noSpectra

        if(strcmpi(type, 'glucose'))
            if(isempty(args.SearchRange))
                args.SearchRange = [5.733 4.9];
            end
             if(isempty(args.RefTo))
                args.RefTo = 5.233;
            end
            deltaPPM = JTPcalibrateToGlucose(spectra(i,:), ppm, args.SearchRange);

            deltaPPM = deltaPPM - find(ppm < args.RefTo, 1, 'last' );
            deltaPPM = deltaPPM *-1;

        elseif(strcmpi(type, 'TSP'))
            if(isempty(args.SearchRange))
                args.SearchRange = [0.5 -0.5];
            end
            if(isempty(args.RefTo))
                args.RefTo = 0;
            end
            deltaPPM = JTPreferenceToLargestPeak(spectra(i, :), ppm, args.SearchRange);
            deltaPPM = deltaPPM - find(ppm < args.RefTo, 1, 'last' );
            deltaPPM = deltaPPM *-1;

        elseif(strcmpi(type, 'powerSpectra'))
            if(isempty(args.imaginarySpectra))
                error('JTPcode:JTPcalibrateNMR:noIspectra', 'The imaginary part of the spectra is required for Power-Spectra alignment');
            end
            deltaPPM = JTPpowerSpectraCalibration(spectra(i,:), args.imaginarySpectra(i,:), ppm);

        else
            error('JTPcode:JTPcalibrateNMR:unkowncal', '%s is an unknown calibration type.\n', type);
        end

        if(strcmpi(args.Align, 'circularShift'))
            spectra(i,:) = circshift(spectra(i,:), [0, deltaPPM]);
            if(~isempty(args.imaginarySpectra))
                args.imaginarySpectra(i,:) = circshift(args.imaginarySpectra(i,:), [0, deltaPPM]);
            end        
        elseif(strcmpi(args.Align, 'interpolate'))
            % Reinterpolate to match global ppm bounds.
            newPPM = ppm - deltaPPM;
            [spectra(i,:), newPPM] = JTPinterpolateSpectra(spectra(i,:), newPPM, 'PPM', ppm);
            if(isempty(args.imaginarySpectra))
                [args.imaginarySpectra(i,:), newPPM] = JTPinterpolateSpectra(args.imaginarySpectra(i,:), newPPM, 'PPM', ppm);
            end
        else

        end

        % or crop

    end
   
else
    % MWparseargs means we should never get here, but check in case
    error('JTPcode:JTPcalibrateNMR:unkownckind', '%s is an unknown spectrum kind.\n', args.Kind);
end

% If circular shift is used, adjust the ppm scale for its offset.
if(strcmpi(args.Align, 'circularShift'))
    ppm = ppm - (ppm(find(ppm < args.RefTo, 1, 'last')) - args.RefTo);
end

% If we fliped the spectra, flip back
if(descending)
    ppm = fliplr(ppm);
    spectra = fliplr(spectra);
end

if(nargout == 3)
    varargout{1} = imaginarySpectra;
end
end

% sub to simply ref to the largest peak in a region.
function deltaPPM = JTPreferenceToLargestPeak(spectra, ppm, peakRange)

% Locate the target region (n ppm either side of x)
regionMask = (ppm < peakRange(1)) & (ppm > peakRange(2));
maskOffset = find(ppm < peakRange(2));
maskOffset = maskOffset(length(maskOffset));

spectra = spectra(regionMask);

% Find the max
[dummy, maxIndex] = max(spectra);

% Ref to the downfeild peak of the glucose doublet.
deltaPPM = maskOffset + maxIndex;

end

% ppm = JTPcalibrateToGlucose(realSpectra, ppm)
%
% Calibrate spectra to the glucose doublet at 5.233 ppm. This function
% modifies the ppm scale but does not align data-points, this must be done
% as a second step using interpolation or cropping (if the resolution
% is the same).
%
% Arguments:
% realSpectra       Vector of the real part of a single 1D NMR spectra.
% ppm               A vector labelling the ppm value of each point in 
%                   'realSpectra'.
%


function deltaPPM = JTPcalibrateToGlucose(realSpectra, ppm, peakRange)

% Locate the target region (n ppm either side of 5.233)
regionMask = (ppm < peakRange(1)) & (ppm > peakRange(2));
maskOffset = find(ppm < peakRange(2));
maskOffset = maskOffset(length(maskOffset));

% Take the approximate second derivative
realSpectra2 = diff(realSpectra(regionMask), 2);

% Find the two lowest points, corresponding to the top of the two sharpest
% peaks.
[dummy, min1Index] = min(realSpectra2); 

peak1PPM = ppm(maskOffset + min1Index);

% Having found the first peak, flatten it so we can locate the second.
peak1Mask = (ppm(regionMask) > (peak1PPM - 0.004)) & ...
    (ppm(regionMask) < (peak1PPM + 0.004));
realSpectra2(peak1Mask) = 0;

[dummy, min2Index] = min(realSpectra2);

% Reference to the midpoint of peak 1 and 2.
deltaPPM = round(mean([(min2Index + maskOffset + 1),(min1Index + maskOffset + 1)]));

end
