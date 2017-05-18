classdef csm_import_jres_spectra < csm_import_generic_folder
%CSM_IMPORT_JRES_SPECTRA - CSM Import NMR spectra Class
%
% Usage:
%
%	importedspectra = csm_import_jres_spectra( 'folder', folder )
%
% Arguments:
%
%	folder : (str) Full path to experiment folder
%   
% Returns:
%
%   folder : (str) Full path to the experiment folder.
%   imaginary_file_path : (str) Full path to imaginary spectra file.
%   real_file_path : (str) Full path to real spectra file.
%   procs_file_path : (str) Full path to procs file.
%   spectra_folder : (str) spectra folder.
%   offset : (1*1) offset var.
%   sw : (1*1) sw var.
%   sf : (1*1) sf var. 
%   si : (1*1) si var.
%   bytordp : (1*1) bytorp var.
%   NC_proc : (1*1) NC_proc var.
%   spectra_real : (m*n) Real spectra.
%   spectra_imaginary : (m*n) Imaginary spectra.
%
% Description:
%
%	Imports the raw spectra from the bruker acquisition folder.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties
        
        imaginary_file_path;
        real_file_path;
        procs_file_path;
        spectra_folder;
        offset;
        sw;
        sf;
        si;
        bytordp;
        NC_proc;
        ppm;
        spectra_real;
        spectra_imaginary;


    end

    methods

        % Constructor
        function [obj] = csm_import_jres_spectra( varargin )
            
            obj  = obj @ csm_import_generic_folder(varargin{:});

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj = findSpectraFolder( obj );

            % 2rr file path
            obj.real_file_path = fullfile( obj.spectra_folder, '2rr' );

            % procs file path
            obj.procs_file_path = fullfile( obj.spectra_folder, 'proc2s' );


            obj = importParams( obj );

            obj = checkParams( obj );

            obj = importSpectra( obj );

        end

        % Find the pdata/1/ folder.
        function [obj] = findSpectraFolder( obj )

            specFolder = strcat( obj.folder, filesep, 'pdata', filesep, '1' );

            if isdir( specFolder )

                obj.spectra_folder = specFolder;

            else

                throw( 'spectra folder missing' );

            end

        end

        % Import the necessary spectral data.
        % 1. Open the rt file
        % 2. Use regexes to find the necessary parameters.
        function [obj] = importParams( obj )

            fid = fopen( obj.procs_file_path, 'rt' );

            line = fgetl( fid );

            while ischar( line )


                % Find the offset
                [start,last] = regexp( line, '##\$OFFSET=' );

                if start ~= 0 & last ~= 0

                    obj.offset = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the SW_p
                [start,last] = regexp( line, '##\$SW_p=' );

                if start ~= 0 & last ~= 0

                    obj.sw = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the SF
                [start,last] = regexp( line, '##\$SF=' );

                if start ~= 0 & last ~= 0

                    obj.sf = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the SI
                [start,last] = regexp( line, '##\$SI=' );

                if start ~= 0 & last ~= 0

                    obj.si = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the BYTORDP
                [start,last] = regexp( line, '##\$BYTORDP=' );

                if start ~= 0 & last ~= 0

                    obj.bytordp = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the NC_proc
                [start,last] = regexp( line, '##\$NC_proc=' );

                if start ~= 0 & last ~= 0

                    obj.NC_proc = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                line = fgetl( fid );


            end

            fclose( fid );

        end

        % Check if all the parameters have been populated
        function [obj] = checkParams( obj )

            if( isempty( obj.offset ) || isempty( obj.sw ) || isempty( obj.sf ) || isempty( obj.si ) || isempty( obj.bytordp ) )

                throw( MException( 'CSM_IMPORT_NMR:csm_import_nmr_spectra', 'Unable to load all parameters from: %s', obj.procs_file_path) );

            end

        end

        % Import real and imaginary spectra from lr and and li files, calculate ppm
        function [obj] = importSpectra( obj )

            if( obj.bytordp == 0 )

                machine_format = 'l';

            else

                machine_format = 'b';

            end

            % If the 'real' file exists, import the 'real' spectra.
            if( exist( obj.real_file_path, 'file' ) == 2 )

                fid = fopen( obj.real_file_path, 'r', machine_format );

                obj.spectra_real =( fread( fid, inf, 'int32' ) * realpow( 2, obj.NC_proc ) )' ;

                fclose( fid );

            end

            % If the 'imaginary' file exists, import the 'imaginary' spectra.
            if( exist( obj.imaginary_file_path, 'file' ) == 2 )

                fid = fopen( obj.imaginary_file_path, 'r', machine_format );

                obj.spectra_imaginary = ( fread( fid, inf, 'int32' ) * realpow( 2, obj.NC_proc ) )';

                fclose( fid );

            end

            % and calculate the ppm scale.
            swp = obj.sw / obj.sf;

            dppm = swp / (obj.si - 1);

            obj.ppm = flipud( obj.offset : -dppm :( obj.offset - swp) ) ;

        end

        % Dynamic property loader ** REQUIRED FUNCTION **
        function [obj] = setProperty( obj, fieldName, fieldValue )

            if isprop( obj, fieldName )

                if ischar( fieldValue )

                    eval( strcat( 'obj.', fieldName, ' = ''', fieldValue, ''' ;' ) );

                else

                    eval( strcat( 'obj.', fieldName, ' = fieldValue ;' ) );

                end

            end

        end


    end

end

