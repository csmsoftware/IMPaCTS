classdef csm_import_nmr_spectra < csm_import_generic_folder
%CSM_IMPORT_NMR_SPECTRA - CSM Import NMR spectra Class
%
% Usage:
%
%	imported_spectra = csm_import_nmr_spectra( varargin )
%
% Arguments:
%
%	folder : (str) Full path to experiment folder
%
% Returns:
%
%   folder : (str) Full path to experiment folder.
%   spectra_folder : (str) Full path to spectra folder
%   real_file_path : (str) Full path to real spectra file.
%   imaginary_file_path : (str) Full path to imaginary spectra file.
%   procs_file_path : (str) Full path to procs file
%   procs2_file_path : (str) Full path to 2D procs files
%   offset : (1*1) offset var.
%   sw : (1*1) sw var.
%   sf : (1*1) sf var.
%   si : (1*1) si var.
%   bytordp : (1*1) bytordp var.
%   xdim : (1*1) xdim var.
%   NC_proc : (1*1) NC_proc var.
%   spectra_real : (m*n) Real spectra.
%   spectra_imaginary : (m*n) Imaginary spectra.
%   ppm : (m*1) ppm.
%   dimension : (1*1) dimension var.
%   ppm_2D : (m*1) ppm_2D.
%   offset2D : (1*1) offset2D var.
%   sw2D : (1*1) sw2D var.
%   sf2D : (1*1) sf2D var.
%   si2D : (1*1) si2D var.
%   bytordp2D : (1*1) bytordp2D var.
%   xdim2D : (1*1) xdim2D var.
%   NC_proc2D : (1*1) NC_proc2D var.
%
% Description:
%
%	Imports the spectra from the bruker acquisition folder.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart, Jake Pearce 2015

    properties

        spectra_folder;
        real_file_path;
        imaginary_file_path;
        procs_file_path;
        procs2_file_path;
        offset;
        sw;
        sf;
        si;
        bytordp;
        xdim;
        NC_proc;
        spectra_real;
        spectra_imaginary;
        ppm;
        dimension;
        ppm_2D;
        offset2D;
        sw2D;
        sf2D;
        si2D;
        bytordp2D;
        xdim2D;
        NC_proc2D;

    end

    methods

        % Constructor
        function [obj] = csm_import_nmr_spectra( varargin )
            
            obj = obj@csm_import_generic_folder(varargin{:});

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
                        
            obj = findSpectraFolder( obj );

            % 1D or 2D ?
            if exist( fullfile( obj.spectra_folder, '1r' ), 'file') == 2

                obj.dimension = 1;
                obj.real_file_path = fullfile( obj.spectra_folder, '1r' );
                obj.imaginary_file_path = fullfile( obj.spectra_folder, '1i');
    
            elseif exist( fullfile( obj.spectra_folder, '2rr' ), 'file') == 2

                obj.dimension = 2;
                obj.real_file_path = fullfile( obj.spectra_folder, '2rr');
                obj.imaginary_file_path = fullfile( obj.spectra_folder, '2ii');
                obj.procs2_file_path = fullfile( obj.spectra_folder, 'proc2s');
                
            else
                
                error( strcat('spectra file missing for ', obj.spectra_folder));

            end

            obj.procs_file_path = fullfile( obj.spectra_folder, 'procs');

            obj = import1D( obj );

            if obj.dimension == 2

                obj = import2D( obj );

            end

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

        % 1D importer
        function [obj] = import1D( obj )

            obj = importParams1D( obj );

            obj = checkParams1D( obj );

            obj = importSpectra1D( obj );

        end

        % Import the necessary spectral data.
        % 1. Open the rt file
        % 2. Use regexes to find the necessary parameters.
        function [obj] = importParams1D( obj )

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

                % Find the XDIM
                [start,last] = regexp( line, '##\$XDIM=' );

                if start ~= 0 & last ~= 0

                    obj.xdim = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                line = fgetl( fid );


            end

            fclose( fid );

        end

        % Check if all the parameters have been populated
        function [obj] = checkParams1D( obj )

            if( isempty( obj.offset ) || isempty( obj.sw ) || isempty( obj.sf ) || isempty( obj.si ) || isempty( obj.bytordp ) )

                throw( MException( 'CSM_IMPORT_NMR:csm_import_nmr_spectra', 'Unable to load all parameters from: %s', obj.procs_file_path) );

            end

        end

        % Import real and imaginary spectra from lr and and li files, calculate ppm
        function [obj] = importSpectra1D( obj )

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


        % 2D importer
        function [obj] = import2D( obj )

            fid = fopen( obj.procs2_file_path, 'rt' );

            line = fgetl( fid );

            while ischar( line )

                % Find the offset
                [start,last] = regexp( line, '##\$OFFSET=' );

                if start ~= 0 & last ~= 0

                    obj.offset2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end

                % Find the XDIM
                [start,last] = regexp( line, '##\$XDIM=' );

                if start ~= 0 & last ~= 0

                    obj.xdim2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the SW_p
                [start,last] = regexp( line, '##\$SW_p=' );

                if start ~= 0 & last ~= 0

                    obj.sw2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the SF
                [start,last] = regexp( line, '##\$SF=' );

                if start ~= 0 & last ~= 0

                    obj.sf2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the SI
                [start,last] = regexp( line, '##\$SI=' );

                if start ~= 0 & last ~= 0

                    obj.si2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the BYTORDP
                [start,last] = regexp( line, '##\$BYTORDP=' );

                if start ~= 0 & last ~= 0

                    obj.bytordp2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                % Find the NC_proc
                [start,last] = regexp( line, '##\$NC_proc=' );

                if start ~= 0 & last ~= 0

                    obj.NC_proc2D = str2double( strtrim( line( ( last + 1) : end ) ) );

                end


                line = fgetl( fid );


            end

            fclose( fid );

            swp2D = obj.sw2D / obj.sf2D;
            dppm2D = swp2D / (obj.si2D - 1);
            obj.ppm_2D  = flipud(obj.offset2D : -dppm2D : (obj.offset2D - swp2D));


            %Borrowed from Nils T. Nyberg, University of Copenhagen

            NoSM = (obj.si * obj.si2D) / (obj.xdim * obj.xdim2D );    % Total number of Submatrixes
            NoSM2 = obj.si2D / obj.xdim2D;		 			% No of SM along F1

            obj.spectra_real = reshape(...
                    permute(...
                        reshape(...
                            permute(...
                                reshape(obj.spectra_real,obj.xdim,obj.xdim2D,NoSM),...
                            [2 1 3]),...
                        obj.xdim2D,obj.si,NoSM2),...
                    [2 1 3]),...
                    obj.si,obj.si2D)';

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

