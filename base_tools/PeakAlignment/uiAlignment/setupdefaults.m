function metadata = setupdefaults(metadata)
%% The function is used to set default parameters for the peak alignment
%% performed on user pre-defined segments
%            Output: metadata - the variable data of peak picking parameters, figure
%                    plots, alignment algorithms 
%% Author: Kirill Veselkov, Imperial College 2010.

%% Parameters for local recursive segment wise peak alignment
metadata.RSPA.minSegWidth     = 0.01;
metadata.RSPA.maxPeakShift    = 0.03;
metadata.RSPA.acceptance      = 0.1;
metadata.RSPA.resemblance     = 0.9;
metadata.RSPA.recursion       = 1;

%% Parameters for constrained correlation optimized warping
metadata.COW.maxPeakShift     = 0.03;
metadata.COW.averagePeakWidth = 0.01;
metadata.COW.slack            = [];

%% Parameters for STOCSY
metadata.stocsy.cc   = 'spearman';
metadata.stocsy.pThr = 0.05; 

%% Selection of a reference sample for the peak alignment
metadata.T                            = mean(metadata.Sp);
metadata.alignBetweenUserDefinedRegns = 0; 
metadata.useVarScaling                = 2; % times of minimal segment width (~ 0.02ppm)

%% Peak peaking parameters
metadata.peakPickingParams.iFrameLen           = 0.005; % Frame length of the Savitzky-Golay smoothing filter (ppm scale)
metadata.peakPickingParams.iMaxPeakWidthWindow = 0.03;  % Maximum peak width( the peak width is the distance between two adjacent minima to a peak)
metadata.peakPickingParams.iOrder              = 3;     % Polynomial order of the Savitzky-Golay smoothing filter
metadata.peakPickingParams.ampThr              = 6000;  % Peak height threshold for eliminating noisy peaks
metadata.peakPickingParams.minPeakWidth        = 0.005; % Minimum peak width (ppm scale)
metadata.peakPickingParams.offset              = 5000;  % Offset for log-transformation log(abs(x)+offset) for peak maximum position visualization
metadata.peakPickingParams.XTickLabels         = 0.25;
load ColorMapPlotPeaks
metadata.peakPickingParams.colorMap            = colorMap;
metadata.plotNonAlignedData                    = 1;

%% Regions for peak alignment
metadata.peakBndrs                         = []; % regions for local peak alignment

%% icons 
load iconsnew;
metadata.icons = icons;

%% User defined segment boundaries
metadata.linecolors   = [0 0 0; 0 0 0];
metadata.linestyle    = {'--','-'};
metadata.linewidth    = 4;
metadata.hlineObjects = [];
metadata.Tlinewidth   = 3;       % linewidth of target profile;
metadata.TColor       = [0 0 0]; % linewidth of target profile;
metadata.showtarget   = 1;