function [segments,peakParam,minsegwidth]=segmentateSp(Sp,peakParam,debug)
% Determination of highly intensive peaks in the spectrum of interest and 
% subsequent concatenation of closely located peaks into 
% larger segments 
% Algorithm: - smooth spectrum X using SG
%            - locate peak maxima when the first 
%              derivative crosses zero, i.e. sign(X'(i))>sing(X'(i+1))
%            - validate peaks (/or eliminate noisy peaks)
%            - concatenate closely located peaks into larger segments
% Input: 
%                             Sp - spectrum
% Peak parameters:  peakParam.                             
%                             ampThr - amplitude threshold   [default 2*median(peaksMaxValues)] 
%                             iFrameLen - Savitzky-Golay frame length
%                             iOrder - polynomial order of Savitzky - Golay filter
%                             minPeakWidth - min peak size
%                             ppmDist - distance to concatenate adjacent peaks
% Output:                     segments
% Author: K.Veselkov, Imperial College London 2007 

% perform Savitzkiy Golay smoothing
SpDerivs = sgolayDeriv(Sp,peakParam.iOrder,peakParam.iFrameLen,2);
SpSmooth = sgolayDeriv(Sp,peakParam.iOrder,peakParam.iFrameLen,1);

% indentify peaks
peaks=peakPeaks(SpSmooth,SpDerivs,Sp,[]);
% validate peaks
[peaksValidated,peakParam,minsegwidth]=validatePeaks(SpSmooth,peaks,peakParam,debug);
% locate segments
segments=segmentate(Sp,peaksValidated,peakParam,debug);

return