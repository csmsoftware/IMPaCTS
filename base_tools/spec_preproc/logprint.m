function [] = logprint(lfid,varargin)
% logprint - print to log file and screen
% [] = logprint(lfid,varargin)
%
% lfid = (1X1) log file identifier
% varargin = variable length arguments as to fprintf
%
% Written 171001 TMDE  
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

fprintf(lfid,varargin{:});
fprintf(varargin{:});