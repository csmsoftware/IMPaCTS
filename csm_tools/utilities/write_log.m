function write_log( logFile, message, first )
%WRITE_LOG Write log messages to a file, and optionally to the screen
%
% Usage:
%
% 	write_log( logFile, message )
%
% 	write_log( logFile, message, True )
%
% Arguments:
%
%	logFile : (str) Full path to log file.
%
%	message : (str) Message to log.
%
%	screen : (bool) If 1, write to screen as well, default 0.
%
% Description:
%
%	Simple logging function
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014 

% Author: Gordon Haggart, 2014


    if nargin < 3

        first = false;

    end


    if true( first )

        fid = fopen( logFile, 'w' );

    else

        fid = fopen( logFile, 'a' );

    end

    fprintf( fid, '%s\n', message );

    fclose( fid );

end

