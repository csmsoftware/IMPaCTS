function hlink = uiAlignment(ppm,Sp,SpAL)

%% This function performs local recursive segment wise (RSPA) or constrained correlation
%% optimized warping (CCOW) alignment on the user pre-defined segments  

%   Input: Sp   - 1H-NMR spectral data set [observations x variables]
%          SpAL - 1H-NMR automatically aligned spectral data set (used if one wants to
%          re-align the position of certain peaks in the aligned data set)  
%          ppm  - chemical shift scale [1 x varibles]

%% Author: Kirill Veselkov, 2010

currentFolder = pwd;
cd(currentFolder);

%% Initialize input data parameters
fullscreen              = get(0,'ScreenSize');
metadata.h.Main         = figure('Position',fullscreen);
metadata.Sp       = 13000.*Sp./median(median(Sp));
metadata.ScFactor = median(median(Sp))./13000;
metadata.nSmpls   = size(Sp,1);
metadata.ppm      = ppm; 

if nargin < 3
    metadata.SpAL = 13000.*Sp./median(median(Sp));
else
    metadata.SpAL = 13000.*SpAL./median(median(SpAL));
end

metadata = setupdefaults(metadata);     % set default parameters
metadata = setFigureToolBars(metadata); % customizate and install figure toolbars
guidata(metadata.h.Main,metadata);      % stores the variable data as GUI data
h.zoom   = zoom;
set(h.zoom,'ActionPostCallback',@zoomcallback);
h.Pan    = pan(metadata.h.Main);
set(h.Pan,'ActionPostCallback',@zoomcallback);
hlink    = plotPeakStats(metadata);     % link x-axis of all subplots