% [X, factor] = JTPnormalise(X, kind, ...)
%
% Normalise (nmr) matrix X according to 'kind'. 
% 'area' sets the total area under the spectrum to 1; 'medianFold' uses 
% Roches probable quotient normalisation, 'Peak' set the area under a 
% selected peak to 1 (defaults to TSP); 'totalExcretion' normalises to an 
% internal standard (see 'Peak') then multiplies by volume of excretion.
% 'Noise' uses the standard deviations of a region of noise only (< 0 ppm
% by default.) to standarise the noise
% 
%
% Arguments:
% X             The data matrix.
% kind          The type of normalisation, currently only 'area', 
%               'medianFold', 'Peak', 'totalExcretion', 'Noise',
%               'HistogramMatch' or 'none' are supported. 
%
%
% ----- Only required if kind is 'Peak', 'Noise' or 'totalExcretion' -----
% If kind is 'Peak', 'HistogramMatch' or 'Noise' the ppm scale must be
% suplied:
% If kind is 'totalExcretion' an ppm scale and urine volumes must be
% supplied.
%
% ppm           The ppm scale of the spectra to locate the normalisation 
%               peak.
%               
% Volumes       An array of the sample volumes of each sample.
%
% Optional Arguments:
% Direction     'r' to normalise along rows, otherwise, 'c' for columns.
% Peak          Specify a peak to normalise to, defaults to TSP, 
%               -0.8 to 0.8 ppm. 
%               Only effects 'Peak' and 'totalExcretion' normalisation.
% NoiseRegion   Specify a region of the spectra containing only noise to
%               normalise to. Defaults to [-1 -0.3]
% MedianSpectra Speify how to generate the median spectra used in median-
%               fold-change normalisation. Not set: Median of all spectra.
%               One number: Use this spectra from X. Vector: Use this as
%               the median.
%               
%
% Return Values:
% X             The normalised data matrix.
% factor        The normalisation factor applied to the data.
% 
% Last Revision 27/04/2009
% (C) 2005 Jake Thomas Midwinter Pearce

% Adding code to call entropy minimisation

% Added error checking for ppm scale.

% Added histogram matching.

% Added MedianSpectra option

% Case insensitive type matching

% Added noise normalisation

% Added error checking for ppm in JTPtsp

% Started adding hidden 'help' option, that returns a list of supported
% normalisation type.

% Tidied up, rename Vol to totalExcretion.

% Added error id.

% Added Vol normalisation (X ./ tsp_area .* urine volume)

function [X, factor] = JTPnormalise(X, kind, varargin)

[noSpectra, noVars] = size(X);

% Beginings of a MWparseargs implementation.
% defaults
args.Direction = {'r', 'c'};
args.ppm = [];
args.Volumes = [];
args.Peak = [-0.08 0.08];
args.NoiseRegion = [-1 -0.3];
args.TargetSpectra = [];
args.HistogramIntervals = 64;
args.SearchInterval = [0.05 10];
% For Entropy normalisation
args.BucketSpectra = false();
args.Minimiser = 'Grid';
args.Resolution = 0.005;
args.PreNormalise = true();
args.Notify = false();


args = MWparseargs(args, varargin{:});

% Simple stub function to rearrage matrices.
if(args.Direction == 'r')
    [X, factor] = JTPnormaliseSub(X, kind, args);
elseif(args.Direction == 'c')
    [X, factor] = JTPnormaliseSub(X', kind, args);
    X = X';
    factor = factor';
end

end
    
% Normalisation subroutine to do the work
function [X, factor] = JTPnormaliseSub(X, kind, args)

%Normalise to unit area.
if(strcmpi(kind, 'area'))
    % Sum rows (by transpose)
    factor = sum(X, 2);
    [dummy, noObservations] = size(X);

    % Scale the spectra back up to the median of there area
    factor = factor ./ median(factor);
    X = X ./ factor(:, ones(1, noObservations));
    
    
%Normalise to mean-fold change. 
elseif(strcmpi(kind, 'medianFold'))
   
    [X, factor] = JTPmeanFoldChange(X, args);
    
    
% Normalise to TSP and urine volume
elseif(strcmpi(kind, 'totalExcretion'))
    
    [X, factor] = JTPtotalExcreation(X, args);
 
% Normalise to TSP
elseif(strcmpi(kind, 'Peak'))
    
    [X, factor] = JTPtsp(X, args);
    
% Normalise by the noise method
elseif(strcmpi(kind, 'Noise'))
    
    [X, factor] = JTPnoise(X, args);
    
% Entropy normalisation
elseif(strcmpi(kind, 'Entropy'))
    [X, factor] = JTPentropyNormalisation(X, ...
        'BucketSpectra', args.BucketSpectra, 'TargetSpectra', args.TargetSpectra, ...
        'Minimiser', args.Minimiser, 'Resolution', args.Resolution, ...
        'Scale', args.ppm, 'PreNormalise', args.PreNormalise, ...
        'SearchInterval', args.SearchInterval, 'Notify', args.Notify);
    
% Don't normalise
elseif(strcmpi(kind, 'none'))
    [samples, dummy] = size(X); %#ok<NASGU>
    factor = ones(samples, 1);
    return;
    
elseif(strcmpi(kind, 'HistogramMatch'))
    % Error checking
    if(isempty(args.ppm))
        error('JTPcode:JTPnormalise:noPPM', 'A ppm scale must be supplied in order to normalise by histogram matching.\n');
    end
    
    [X, factor] = JTPhistogramMatching(args.ppm, X, args);
    % Inverse of factor as here it is a multiplication.
    factor = factor .^-1;
    
% Error trap.
else
    error('JTPcode:JTPnormalise', '%s is an unknown normalisation type!\n    See JTPnormalise.m for acceptable options.', ...
        kind);
end
   
end

%
% Sub to normalise by mean-fold change
%
function [X, factor] = JTPmeanFoldChange(X, args)

% Prep work
[noSamples, noObservations] = size(X);

[X, areaFactor] = JTPnormalise(X, 'area', 'Direction', 'r');

% Determine the median spectra.
if(isempty(args.TargetSpectra))
    medianSpectra = median(X);
elseif(strcmpi(args.TargetSpectra, 'median'))
    medianSpectra = median(X);
elseif(length(args.TargetSpectra) == 1)
    medianSpectra = X(args.TargetSpectra,:);
else
    medianSpectra = args.TargetSpectra;
end
    
% Determine the fold-change for each data point
factor = X ./ medianSpectra(ones(1, noSamples), :);
% And then take the mean fold-change for each spectra
% Take absolute median-change to account for the odd occasion where a
% negative change resulted in a negative spectra.
factor = abs(median(factor, 2));

% Finaly divide each spectra by it's mean fold-change.
X = X ./ factor(:, ones(1, noObservations));

% Combine the two factors.
factor = areaFactor .* factor;

end

%
% Sub to normalise to TSP area
%
function [X, factor] = JTPtsp(X, args)

% Error checking
if(isempty(args.ppm))
    error('JTPcode:JTPnormalise:noPPM', 'A ppm scale must be supplied in order to normalise by peak area.\n');
end

% Normalise to area of TSP peak.
factor = JTPintergratePPMregion(X, args.ppm, args.Peak);

% normalise to TSP
[dummy, noObservations] = size(X);
factor = factor ./ median(factor);
X = X ./ factor(:, ones(1, noObservations));

% Scale the spectra back up to the median of their area
% X = X .* median(factor);
% factor = factor ./ median(factor);

end

%
% Sub to normalise to TSP area
%
function [X, factor] = JTPtotalExcreation(X, args)

% Normalise to area of TSP peak.
factor = JTPintergratePPMregion(X, args.ppm, args.Peak);

% normalise to TSP
[dummy, noObservations] = size(X);
X = X ./ factor(:, ones(1, noObservations));

% Normalise to volume
X = X ./ args.Volumes(:, ones(1, noObservations));

factor = factor .* args.Volumes;

end

function [X, factor] = JTPnoise(X, args)

% Prep work
[noSamples, noObservations] = size(X);

% Error checking
if(isempty(args.ppm))
    error('JTPcode:JTPnormalise:noPPM', 'A ppm scale must be supplied in order to normalise by noise.\n');
end

noiseMask = args.ppm > args.NoiseRegion(1) & args.ppm < args.NoiseRegion(2);

factor = std(X(:,noiseMask), 0, 2);

X = X ./ factor(:, ones(1, noObservations));

% Scale the spectra back to the median of the noise
X = X .* median(factor);
factor = factor ./ median(factor);

end