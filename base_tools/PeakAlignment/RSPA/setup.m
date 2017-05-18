function setupRSPA(ppm)
% setup of alignment parameters
% input: ppm - chemical shift scale
% K.Veselkov, Imperial, 2007
% Configuration of the algorithm invariant parameters 
configureRSPA(ppm);
%%% These parameters can be changed to improve the algorithm performance
%%%%%%%%%%%%%%%%%%%% Recursive alignment parameters %%%%%%%%%%%%%%%%%%%%%%%%
recursion.resamblance=0.95; % Stop criterium of the recursion indicating
%the complete alignment of segment peaks
% default 98% 
recursion.minSegWidth=0.01; % Stop criteria of the recursion - the size of the smallest peak

%%%%%%%%%%%%%%%%%%%%%%%% Segmentation parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%
peakParam.ppmDist = 0.03;% (ppm)  %distance to concatenate adjacent peaks 
%to represent a multiplet in a single segment %%% default 0.03% 
peakParam.ampThr = 0.5; % amplitude value to threshold small peaks % 

%%%%%%%%%%%%Prevention of Misalignment on a local scale%%%%%%%%%%%%%%
recursion.segShift=0.01;% max peak shift for large peaks
recursion.inbetweenShift=0.01;% max shift for small peaks
recursion.acceptance=0.5; % if resamblance after the alignment ...
% is less than the acceptance value the alignment is not accepted; 
%higher value is more stringent

if ~isempty(ppm)
    peakParam.ppmDist=ppmToPt(peakParam.ppmDist,0,ppm(2)-ppm(1));
    recursion.segShift=ppmToPt(recursion.segShift,0,ppm(2)-ppm(1));
    recursion.inbetweenShift=ppmToPt(recursion.inbetweenShift,0,ppm(2)-ppm(1));  
end

assignin('caller', 'recursion',   recursion);
assignin('caller', 'peakParam',   peakParam);
assignin('caller', 'MAX_DIST_FACTOR',   MAX_DIST_FACTOR);
assignin('caller', 'MIN_RC',   MIN_RC);
return;