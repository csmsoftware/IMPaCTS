function [thetar] = d2r(thetad)
% [thetar] = d2r(thetad) - Convert degrees to radians
%
%   thetad = (nxm) matrix of angle in degrees
%
%   thetar = (nxm) matrix of angle in radians
%
% Written 300999 TMDE
% Revised 300999 TMDE
% (c) 1999 Dr. Timothy M D Ebbels, Imperial College, London

thetar = thetad .* (pi/180);
