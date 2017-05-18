classdef csm_import_raw_nmr
%CSM_IMPORT_RAW_NMR - CSM Import Raw NMR Class.
%
% Usage:
%
%   imported_experiment = csm_import_raw_nmr()
% 	imported_experiment = csm_import_raw_nmr( 'experiment_info', experiment_info, 'line_width_qc',line_width_qc, 'save_dir', save_dir, 'spectra_size', spectra_size, 'spectra_bounds', spectra_bounds, 'spectra_size_2D', spectra_size_2D, 'spectra_bounds_2D', spectra_bounds_2D, 'LW_peak', LW_peak 'LW_threshold', LW_threshold )
%
% Arguments:
%
%	experiment_info : (struct) Structure for holding experimental information.
%	experiment_info.experiment_path : (str) Full path to experiment folder.
%	experiment_info.nmr_experiment_info_path : (str) Full path to nmr experiment info csv file.
%   experiment_info.nmr_calibration_info_path : (str) Full path to the nmr calibration info path.
%	experiment_info.sample_metadata_path : (str) Full path to sample metadata csv file.
%
%   line_width_qc : (bool) Whether to run the LW QC. Default true.
%	save_dir : (str) Full path of output dir. Default 'current working directory'+'_import_data'.
%	spectra_size : (1*1) Number of points of ppm. Default 20000.
%	spectra_bounds : (1*2) Range of ppm (min and max). Default [-1 10].
%	spectra_size_2D : (1*1) Number of points of 2D ppm. Default 20000.
%	spectra_bounds_2D : (1*2) Range of 2D ppm (min and max). Default [-1 10].
%		 : (str) Which peak to use for LW calc, uses 'lactate' for plasma and 'TSP' for urine. Default 'TSP'. 
%	LW_threshold : (1*1) Linewidth threshold. Default 1.4.
%
% Returns:
%
%   experiment_path : (str) Full path to experiment.
%   sample_metadata_path : (str) Full path to sample metadata file.
%   nmr_experiment_info_path : (str) Full path to NMR experiment file.
%   nmr_calibration_info_path : (str) Full path to NMR calibration file.
%   save_dir : (str) Full path to save directory.
%   log_file : (str) Full path to log file.
%   imported_bruker_metadata : (csm_import_bruker_acquisition_data) Imported bruker acquisition data.
%   imported_sample_metadata : (csm_sample_metadata) Imported sample metadata.
%   imported_nmr_calibration_info : (csm_import_nmr_experiment_info) Imported NMR experiment info.
%   imported_nmr_experiment_info : (csm_import_nmr_calibration_info) Imported NMR calibration info.
%   raw_spectra : (containers.Map) Container of raw spectra.
%   missing_bruker_experiments : (cell) Missing bruker experiment data.
%   missing_nmr_experiment_info : (cell) Missing NMR experiment data.
%   missing_nmr_calibration_info : (cell) Missing NMR calibration data.
%   missing_samples_in_spectra : (cell) Missing samples in spectra data.
%   missing_sample_metadata : (cell) Missing sample metadata.
%   exceptions : (cell) Exceptions from import.
%   spectrometer_frequency : (1*1) The spectratrometer Frequency.
%   spectra_size : (1*1) Calculated size of the spectra.
%   spectra_bounds : (1*2) Upper and lower limits of the spectra.
%   spectra_resolution : (1*1) Resolution of the spectra.
%   ppm_common : (1*n) PPM common scale.
%   spectra_size_2D : (1*1) Calculated size of the JRES 2D spectra.
%   spectra_bounds_2D : (1*2) 2D Upper and lower limits of the JRES 2D spectra.
%   spectra_resolution_2D : (1*1) Resolution of the JRES 2D spectra.
%   ppm_common_2D : (1*n) PPM common scale of JRES 2D spectra.
%   LW_peak : (1*1) Linewidth peak.
%   LW_threshold : (1*1) Linewidth threshold.
%   pulse_programs : (cell) Cell array of the imported pulse programs.
%   import_failed : (containers.Map) Container of failed imports.
%   import_errors : (containers.Map) Container of import errors.
%   pulse_program_lookup : (containers.Map) Pulse program short name lookup.
%   sample_types : (cell) Cell array of imported sample types.
%   cpmg : (containers.Map) Container of final CPMG spectra.
%   oneDWS : (containers.Map) Container of final 1D Water Suppressed spectra.
%   diff_edited : (containers.Map) Container of diffusion edited spectra.
%   jres : (containers.Map) Container of final JRES spectra.
%   peak_width_output_cpmg : (containers.Map) Container of QC output.
%   peak_width_output_oneDWS : (containers.Map) Container of QC output.
%   peak_width_output_jres : (containers.Map) Container of QC output.
%   peak_width_output_diff_edited : (containers.Map) Container of QC output.						        
%
% Description:
%
%	Import NMR experiment into csm_nmr_spectra objects. Optionally Run QC checks.
%
%   Leave arguments blank for pop-up selection boxes.
% 
%   experimentInfo is a struct containing paths to the required files; the NMR Experiment Info file, the NMR Calibration Info file, and the Sample Metadata file.
%   These files are .xls files containing the data for import, ie, the path to the experiment folder, the calibration type, and extra sample metadata.
%
%	NMR Experiment Info template:
%		Sample ID, Experiment Number, Experiment Folder, Rack, Rack Position, Instrument, Acquisition Batch
%
%	NMR Calibration Info template:
%		Sample ID, Sample Type, Calibration Type, Calibration Ref Point, Calibration Search Min, Calibration Search Max
%
%   Sample Metadata template example:
%       Sample ID, Case/control, gender, age, etc
%
%	Will only import 1 pdata folder, as for small molecules this is all that is required.
%
%   Spectra objects are contained in the relevant map properties and are grouped by sample_type, ie 'plasma'.
%      
%      eg. cpmg_plasma = imported.cpmg('plasma');
%          oneDWS_urine = imported.oneDWS('urine');
%          diffEdited_serum = imported.diffEdited('serum');
%          jres_plasma = imported.plasma('plasma');
%       
%   Errors are saved to file, and can be found into the importErrors map using the same syntax as above.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2017

% Author - Gordon Haggart 2016

    properties

        experiment_path;
        sample_metadata_path;
        nmr_experiment_info_path;
        nmr_calibration_info_path;
        save_dir;
        log_file;
        imported_bruker_metadata;
        imported_sample_metadata;
        imported_nmr_calibration_info;
        imported_nmr_experiment_info;
        raw_spectra;
        final_spectra;
        missing_bruker_experiments;
        missing_nmr_experiment_info;
        missing_nmr_calibration_info;
        missing_samples_in_spectra;
        missing_sample_metadata;
        exceptions;
        spectrometer_frequency;
        spectra_size;
        spectra_bounds;
        spectra_resolution;
        ppm_common;
        spectra_size_2D;
        spectra_bounds_2D;
        spectra_resolution_2D;
        ppm_common_2D;
        line_width_qc;
        LW_peak;
        LW_threshold;
        pulse_programs;
        import_failed;
        import_errors;
        pulse_program_lookup;
        sample_types;
        cpmg;
        oneDWS;
        jres;
        diff_edited;
        peak_width_output_cpmg;
        peak_width_output_oneDWS;
        peak_width_output_jres;
        peak_width_output_diff_edited;
        audit_info;
        set_options;

    end

    methods

        % Constructor
        function [obj] = csm_import_raw_nmr( varargin )
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                %return
            end

            obj = setExperimentInfo( obj, varargin );
            
            obj = buildDefaults( obj );
            
            obj = setParams( obj, varargin );
            
            obj = parseInput( obj );
            
            obj = buildPulseProgramLookup( obj );

            obj = initialisation( obj );

            obj = importMetadata( obj );

            obj = metadataSimpleQC( obj );

            obj = importExperiments( obj );
            
            obj = calculateLineWidths( obj );
            
            obj = runBasicQC( obj );

            save( fullfile( obj.save_dir, 'imported_data.mat' ), 'obj' );

            obj = runAuditInfoMethods( obj );
            

        end
        
        function [obj] = runBasicQC( obj )
            
           
            
            
        end    
        
        function [obj] = buildDefaults( obj )
            
            obj.raw_spectra = containers.Map;
            obj.final_spectra = containers.Map;
            obj.missing_bruker_experiments = {};
            obj.missing_nmr_experiment_info = {};
            obj.missing_nmr_calibration_info = {};
            obj.missing_samples_in_spectra = {};
            obj.missing_sample_metadata = {};
            obj.exceptions = {};
            obj.pulse_programs = {};
            obj.import_failed = containers.Map;
            obj.import_errors = containers.Map;
            obj.pulse_program_lookup = containers.Map;
            obj.sample_types = {};
            obj.cpmg = containers.Map;
            obj.oneDWS = containers.Map;
            obj.jres = containers.Map;
            obj.diff_edited = containers.Map;
            obj.peak_width_output_cpmg = containers.Map;
            obj.peak_width_output_oneDWS = containers.Map;
            obj.peak_width_output_jres = containers.Map;
            obj.peak_width_output_diff_edited = containers.Map;
            
            obj.audit_info = csm_audit_info();
            
        end    
        
        % Function to calculate the line widths
        function [obj] = calculateLineWidths( obj )
        
            if true(obj.line_width_qc)
            
                obj = calculateLineWidth( obj, 'cpmg' );
                obj = calculateLineWidth( obj, 'oneDWS' );
                obj = calculateLineWidth( obj, 'jres' );
                obj = calculateLineWidth( obj, 'diff_edited' );
            
            end    
        end
        
        % Function to calculate the line width
        function [obj] = calculateLineWidth( obj , short_pulse_program_name )
            
            sample_types = keys(obj.(short_pulse_program_name));
           
            for i = 1 : length(sample_types)
               
                spectra = obj.(short_pulse_program_name)(sample_types{i});
                
                if isempty(spectra.X)
                   
                    warning(strcat(short_pulse_program_name,' ',sample_types{i},' spectra X matrix is empty'));
                    return;
                    
                end    
                
                save_dir = strcat(obj.save_dir,'QC',filesep,short_pulse_program_name,filesep,sample_types{i});
                
                mkdir(save_dir);
                
                if strcmpi(sample_types{i},'urine')
                    
                    LW_peak = 'TSP';
                    
                elseif strcmpi(sample_types{i},'plasma')
                   
                    LW_peak = 'lactate';
                    
                else    
                    
                    LW_peak = obj.LW_peak;
                end
                
                name = strcat('peak_width_output_',short_pulse_program_name);
               
                obj.(name)(sample_types{i}) = csm_peak_width(spectra,obj.spectrometer_frequency,'LW_peak',LW_peak,'LW_threshold',obj.LW_threshold,'plotResults',true,'save_dir',save_dir);
              
            end
            
        end    
        
        % Set the experimental information. If none specified, use a dialog box
        function [obj] = setExperimentInfo( obj, varargin )
            
            found = false;
            
            k = 1;
            while k < numel( varargin{1} )
                
                % If it exists, set it and break
                if strcmp( varargin{1}{k}, 'experiment_info')
                    
                    experiment_info = varargin{1}{k+1};
                    
                    if ~isstruct(experiment_info)
                       
                        error('If specifying experiment_info, it must be a struct');
                        
                    end
                    
                    obj.experiment_path = fix_filesep( experiment_info.experiment_path );
                    obj.sample_metadata_path = fix_filesep( experiment_info.sample_metadata_path );
                    obj.nmr_experiment_info_path = fix_filesep( experiment_info.nmr_experiment_info_path );
                    obj.nmr_calibration_info_path = fix_filesep( experiment_info.nmr_calibration_info_path );
                    found = true;
                    break;
                    
                end
                
                k = k + 1;
                
            end    
            
            % If it doesn't exist, use a dialog box to set the options.
            if ~found
                
                uiwait(msgbox('Please select the experiment path'));
                obj.experiment_path = uigetdir('dialog_title', 'Please select the Experiment Path');
                
                uiwait(msgbox('Please select the NMR experiment info file'));
                [filename,path,~] = uigetfile({'*.xls*;*.csv'},'Please select the NMR Experiment Info File');
                obj.nmr_experiment_info_path = strcat(path,filename);
                
                uiwait(msgbox('Please select the NMR calibration info file'));
                [filename,path,~] = uigetfile({'*.xls*;*.csv'},'Please select the NMR Calibration Info File');
                obj.nmr_calibration_info_path = strcat(path,filename);
                
                uiwait(msgbox('Please select the sample metadata file'));
                [filename,path,~] = uigetfile({'*.xls*;*.csv'},'Please select the Sample Metadata File');
                obj.sample_metadata_path = strcat(path,filename);
                                
            end    
            
        end    
        
        % Set the parametersz
        function [obj] = setParams( obj, varargin )
        
            optional_defaults = containers.Map;

            % Optional arguments with defaults
            optional_defaults( 'line_width_qc' ) = true;
            optional_defaults( 'save_dir' ) = strcat( csm_settings.getValue('workspace_path'), filesep, 'import_data', filesep );
            optional_defaults( 'spectra_size' ) = 20000;
            optional_defaults( 'spectra_bounds') = [ -1, 10 ];
            optional_defaults( 'spectra_size_2D' ) = 256;
            optional_defaults( 'spectra_bounds_2D') = [ -0.06, 0.06 ];
            optional_defaults( 'LW_peak') = 'TSP';
            optional_defaults( 'LW_threshold') = 1.4;
            
            obj.set_options = {};
            
            k = 1;
            while k < numel( varargin{1} )

                % Check its in the options map
                if isKey( optional_defaults , varargin{ 1 }{ k } )
                    
                    optional_defaults( varargin{ 1 }{ k } ) = varargin{ 1 }{ k + 1 }; 
                    obj.set_options{ end + 1 } = optional_defaults( varargin{ 1 }{ k } );
                    
                    k = k + 1;
                    
                end
                
                k = k + 1;
                
            end
            
            % get the keys
            cell_of_keys = keys( optional_defaults );

            % loop over the keys and assign the overwritten values
            for k = 1 : numel( cell_of_keys )
                
                eval(strcat ( 'obj.', cell_of_keys{ k }, ' = optional_defaults( cell_of_keys{ k } )'));

            end


            % Calculate and build the master PPM scale
            obj.spectra_resolution = 1 / ceil( obj.spectra_size / range_x( obj.spectra_bounds ) );

            obj.ppm_common = obj.spectra_bounds( 1 ) : obj.spectra_resolution : obj.spectra_bounds( 2 );

            obj.spectra_size = length( obj.ppm_common );


            % Calculate and build the master PPM scale
            obj.spectra_resolution_2D = 1 / ceil( obj.spectra_size_2D / range_x( obj.spectra_bounds_2D ) );

            obj.ppm_common_2D = obj.spectra_bounds_2D( 1 ) : obj.spectra_resolution_2D : obj.spectra_bounds_2D( 2 );

            obj.spectra_size_2D = length( obj.ppm_common_2D );

            
            % Linewidth threshold for analytical QC
            found = false;
            k = 1;
            while k < numel( varargin{1} )
                
                % If it exists, set it and break
                if strcmp( varargin{1}{k}, 'LW_threshold')
                    
                    obj.LW_threshold = varargin{1}{k+1} ;
                    found = true;
                    break;
                    
                end
                
                k = k + 1;
                
            end 
            
            if ~found
                
                if strcmp( obj.LW_peak, 'lactate' )

                    obj.LW_threshold = 1.2;

                else

                    obj.LW_threshold = 1.9;

                end
                
            end
            
        end    
            
        function [obj] = buildPulseProgramLookup( obj )
            
           obj.pulse_program_lookup('cpmg') = 'cpmg';
           obj.pulse_program_lookup('cpmgpr1d') = 'cpmg';
           
           obj.pulse_program_lookup('oneDWS') = 'oneDWS';
           obj.pulse_program_lookup('noesy') = 'oneDWS';
           obj.pulse_program_lookup('noesypr1d') = 'oneDWS';
           obj.pulse_program_lookup('noesygppr1d') = 'oneDWS';
           
           obj.pulse_program_lookup('jres') = 'jres';
           obj.pulse_program_lookup('jresgpprqf') = 'jres';
           
           obj.pulse_program_lookup('diff_edited') = 'diff_edited';
           obj.pulse_program_lookup('ledbpgppr2s1d') = 'diff_edited';
            
        end   

        function [obj] = parseInput( obj )
            
            inputparser = inputParser;

            addRequired( inputparser , 'experiment_path' , @( x ) ischar( x ) );
            addRequired( inputparser , 'sample_metadata_path' , @( x ) ischar( x ) );
            addRequired( inputparser , 'nmr_experiment_info_path' , @( x ) ischar( x ) );
            addRequired( inputparser , 'nmr_calibration_info_path' , @( x ) ischar( x ) );
            addRequired( inputparser , 'save_dir' , @( x ) ischar( x ) );
            addRequired( inputparser , 'spectra_size', @( x ) isnumeric( x ) );
            addRequired( inputparser , 'spectra_bounds', @( x ) ismatrix( x ) );
            addRequired( inputparser , 'spectra_size_2D', @( x ) isnumeric( x ) );
            addRequired( inputparser , 'LW_peak', @( x ) ischar( x ) );
            
            parse( inputparser, obj.experiment_path, obj.sample_metadata_path, obj.nmr_experiment_info_path, obj.nmr_calibration_info_path, obj.save_dir, obj.spectra_size, obj.spectra_bounds, obj.spectra_size_2D, obj.LW_peak );
            
        end    


        % Initialise the import, create directories etc
        function [obj] = initialisation( obj )

            % Create the save directory
            if ~ exist( obj.save_dir, 'dir' )

                mkdir( obj.save_dir );

            end

            % Create the log_file
            obj.log_file = strcat( obj.save_dir, 'importNMRlog.txt' );

            write_log( obj.log_file, sprintf( 'Log file for importing NMR data from: %s\n\n ', obj.experiment_path ), true );

        end


        % Scan and import spectral info, bruker metadata and sample info.
        function [obj] = importMetadata( obj )

            % Import the NMR Experiment info file
            import_nmr_experiment_worker = csm_import_nmr_experiment_info( 'filename', obj.nmr_experiment_info_path );
            obj.imported_nmr_experiment_info = import_nmr_experiment_worker.nmr_experiment_info;
            
            

            write_log( obj.log_file, sprintf( 'NMR experiment information imported from: %s\n\n', obj.nmr_experiment_info_path ) );
            write_log( obj.log_file, sprintf( '\t NMR experiment information imported for %g experiments\n\n', length( obj.imported_nmr_experiment_info.entries ) ) );

            
            % Import the NMR calibration file
            import_nmr_calibration_worker = csm_import_nmr_calibration_info( 'filename', obj.nmr_calibration_info_path );
            obj.imported_nmr_calibration_info = import_nmr_calibration_worker.nmr_calibration_info;


            write_log( obj.log_file, sprintf( 'NMR calibration information imported from: %s\n\n', obj.nmr_calibration_info_path ) );
            write_log( obj.log_file, sprintf( '\t NMR calibration imported for %g samples\n\n', length( obj.imported_nmr_calibration_info.entries ) ) );

                        
            % Import the bruker acquisition data
            import_bruker_metadata_worker = csm_import_bruker_acquisition_data( 'folder', obj.experiment_path, 'folder_keys_to_import', keys( obj.imported_nmr_experiment_info.entries ));
            obj.imported_bruker_metadata = import_bruker_metadata_worker.bruker_acquisition_data;
            
            bkeys = keys(obj.imported_bruker_metadata.entries);
            obj.spectrometer_frequency = str2num(obj.imported_bruker_metadata.entries(bkeys{1}).spectrometer_frequency);

            % Import the sample info file
            import_sample_metadata_worker = csm_import_sample_metadata( 'filename', obj.sample_metadata_path );
            obj.imported_sample_metadata = import_sample_metadata_worker.sample_metadata;
            
            
            write_log( obj.log_file, sprintf( '\nSample information imported from: %s\n\n', obj.sample_metadata_path ) );
            write_log( obj.log_file, sprintf( '\t Sample information imported for %g samples\n\n', length( obj.imported_sample_metadata.entries ) ) );
            
           
            sample_ids = keys(obj.imported_nmr_calibration_info.entries);
            
            for p = 1 : length(sample_ids)
                
                nmr_calibration_info_entry = obj.imported_nmr_calibration_info.entries(sample_ids{p});
                
                if isempty(find(ismember(obj.sample_types,nmr_calibration_info_entry.sample_type),1))
                    
                    obj.sample_types{end+1} = nmr_calibration_info_entry.sample_type;
                    
                end
            end    

        end


        % Simple QC on what expected metadata is missing.
        function [obj] = metadataSimpleQC( obj )

            obj = findMissingBrukerAcquisitionData( obj );

            obj = findMissingNMRExperimentInfo( obj );

            obj = findMissingNMRCalibrationInfo ( obj );
            
            obj = findMissingSampleMetadata( obj );

        end

        % Check to see if all the experiments specified in Spectral Info exist in the bruker acquisition data
        function [obj] = findMissingBrukerAcquisitionData( obj )

            nmr_experiment_info_keys = keys( obj.imported_nmr_experiment_info.entries );

            bruker_key_check = isKey( obj.imported_bruker_metadata.entries, nmr_experiment_info_keys );

            % If the key doesn't exist, add it to the missing bruker array.
            if ~ all( bruker_key_check )

                indexes = find( bruker_key_check == 0 );

                for i = 1 : length( indexes )

                    obj.missing_bruker_experiments{ end + 1 } = nmr_experiment_info_keys{ indexes( i ) };

                end

            end

            % Write information to logs

            write_log( obj.log_file, sprintf( '\nNumber of missing Experiments: %d\n(Experiment Info exists, no Bruker folder)\n\n', length( obj.missing_bruker_experiments ) ) );

            for i = 1 : length( obj.missing_bruker_experiments )

                write_log( obj.log_file, sprintf( '\t\tExperiment: %s\n', obj.missing_bruker_experiments{ i } ) );

            end

        end


        % 1. Check to see if all the experiments that exist in the folder have an entry in the spectral info CSV
        % 2. Check to see if all the samples listed in the sample info file have entries in the nmr_experiment_info file
        function [obj] = findMissingNMRExperimentInfo( obj )

            % 1. Experiment Data Check
            bruker_keys = keys( obj.imported_bruker_metadata.entries );

            experiment_key_check = isKey( obj.imported_nmr_experiment_info.entries, bruker_keys );

            % If the key doesn't exist, add it to the missing bruker array.
            if ~ all( experiment_key_check )

                indexes = find( experiment_key_check == 0 );

                for i = 1 : length( indexes )

                    obj.missing_nmr_experiment_info{ end + 1 } = bruker_keys{ indexes( i ) };

                end

            end

            % Write information to logs.

            write_log( obj.log_file, sprintf( '\n\nNumber of missing NMR Experiment Info Rows: %d\n(Bruker folder exists, no entry in CSV)\n\n', length( obj.missing_nmr_experiment_info ) ) );

            for i = 1 : length( obj.missing_nmr_experiment_info )

                write_log( obj.log_file, sprintf( '\t\tExperiment: %s\n', obj.missing_nmr_experiment_info{ i } ) );

            end

            sampleMetadataSampleIDs = keys( obj.imported_sample_metadata.entries );


            % 2. Sample ID check
            sample_key_check = ismember( sampleMetadataSampleIDs, obj.imported_nmr_experiment_info.sample_ids );

            % If the key doesn't exist, add it to the missing bruker array.
            if ~ all( sample_key_check )

                indexes = find( sample_key_check == 0 );

                for i = 1 : length( indexes )

                    obj.missing_samples_in_spectra{ end + 1 } = sampleMetadataSampleIDs{ indexes( i ) };

                end

            end

            % Write information to logs.

            write_log( obj.log_file, sprintf( '\n\nNumber of missing NMR Experiment Info Sample IDs: %d\n(Listed in sample CSV, no entry in spectra CSV)\n\n', length( obj.missing_samples_in_spectra ) ) );

            for i = 1 : length( obj.missing_samples_in_spectra )

                write_log( obj.log_file, sprintf( '\t\tSample ID: %s\n', obj.missing_samples_in_spectra{ i } ) );

            end

        end

        % Check to see if all the samples listed in spectra info have an entry in the sample info CSV
        function [obj] = findMissingNMRCalibrationInfo( obj )

            sample_key_check = isKey( obj.imported_nmr_calibration_info.entries, obj.imported_nmr_experiment_info.sample_ids );

            % If the key doesn't exist, add it to the missing bruker array.
            if ~ all( sample_key_check )

                indexes = find( sample_key_check == 0 );

                for i = 1 : length( indexes )

                    obj.missing_nmr_calibration_info{ end + 1 } = obj.imported_nmr_experiment_info.sample_ids{ indexes( i ) };

                end

            end

            % Write information to logs.

            write_log( obj.log_file, sprintf( '\n\nNumber of missing NMR Calibration Rows: %d\n(Listed in spectra CSV, no entry in sample CSV)\n\n', length( obj.missing_nmr_calibration_info ) ) );

            for i = 1 : length( obj.missing_nmr_calibration_info )

                write_log( obj.log_file, sprintf( '\t\tSample ID: %s\n', obj.missing_nmr_calibration_info{ i } ) );

            end

        end

        % Check to see if all the samples listed in spectra info have an entry in the sample info CSV
        function [obj] = findMissingSampleMetadata( obj )

            sample_key_check = isKey( obj.imported_sample_metadata.entries, obj.imported_nmr_experiment_info.sample_ids );

            % If the key doesn't exist, add it to the missing bruker array.
            if ~ all( sample_key_check )

                indexes = find( sample_key_check == 0 );

                for i = 1 : length( indexes )

                    obj.missing_sample_metadata{ end + 1 } = obj.imported_nmr_experiment_info.sample_ids{ indexes( i ) };

                end

            end

            % Write information to logs.

            write_log( obj.log_file, sprintf( '\n\nNumber of missing Sample IDs Rows: %d\n(Listed in spectra CSV, no entry in sample CSV)\n\n', length( obj.missing_sample_metadata ) ) );

            for i = 1 : length( obj.missing_sample_metadata )

                write_log( obj.log_file, sprintf( '\t\tSample ID: %s\n', obj.missing_sample_metadata{ i } ) );

            end

        end

        % 1. Grab the index of pulse programs
        % 2. Per pulse program, grab all the experiments for that pulse program
        % 3. Per experiment, import the spectra for that experiment.
        % 4. Calibrate, Interpolate.
        function [obj] = importExperiments( obj )

            for i = 1 : length( obj.imported_bruker_metadata.pulse_programs )
                
                pulse_program = obj.imported_bruker_metadata.pulse_programs{ i };
                
                % If the pulseprogram is unrecognised, prompt to pick one.
                if isempty(find(ismember(keys(obj.pulse_program_lookup),pulse_program),1))
                    
                    choices = {'cpmg','oneDWS','jres','diff_edited'};
                    
                    pulseProgramChoice = menu(strcat('What type of pulse program is',{' '},pulse_program),choices);
                    
                    obj.pulse_program_lookup(pulse_program) = choices{pulseProgramChoice};
                    
                end

                obj.pulse_programs{ end + 1 } = pulse_program;
                
                pulse_program_experiments = obj.imported_bruker_metadata.pulse_program_experiment_lookup{ i };

                processed_spectra = containers.Map;

                fprintf( 'Importing %d %s experiments: \n', length( pulse_program_experiments  ), pulse_program );
                %progBar = csm_progress_bar( length( pulse_program_experiments  ) );


                pulse_progam_import_failed = {};
                pulse_progam_import_errors = {};

                for p = 1 : length( pulse_program_experiments )

                    bruker_data = obj.imported_bruker_metadata.entries( pulse_program_experiments{ p } );
                    
                    try 

                        % Main spectrum Import Method
                        [obj,processed_spectra( bruker_data.unique_id )] = importAlign( obj, bruker_data );

                    catch ex

                        pulse_progam_import_failed{ end + 1 } = bruker_data.unique_id;
                        pulse_progam_import_errors{ end + 1 } = ex;

                    end
                    
                    %progBar.update( p );

                end

                obj.import_failed( pulse_program ) = pulse_progam_import_failed;
                obj.import_errors( pulse_program ) = pulse_progam_import_errors;


                % Push all the spectrum's together into an X matrix
                obj = buildSpectra( obj, pulse_program, processed_spectra );

                %pulseProgramSimpleQC( obj, pulse_program );

            end

        end

        % Import the spectra, calibrate, interpolate
        function [obj,processed_spectrum] = importAlign( obj, bruker_data )

            raw_spectrum = csm_import_nmr_spectra( 'folder', bruker_data.spectrum_path, 'no_audit', true );

           % obj.raw_spectra( bruker_data.unique_id ) = raw_spectrum;
           
             % If its not in the experiment info file it will just return,  not error
            if ~isKey ( obj.imported_nmr_experiment_info.entries, bruker_data.unique_id )
                return;
            end
            
            % Load the nmr_experiment_info and sample_metadata
            nmr_experiment_info_entry = obj.imported_nmr_experiment_info.entries( bruker_data.unique_id );
            nmr_calibration_info_entry = obj.imported_nmr_calibration_info.entries( nmr_experiment_info_entry.sample_id );
            
            % If not single, set the required range and peak
            if ~strcmp( nmr_calibration_info_entry.calibration_type, 'single' )
                
                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationRefPoint( csm_calibrate_nmr.getDefaultCalibrationReferencePeak( nmr_calibration_info_entry.calibration_type ) );
                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationSearchMin( csm_calibrate_nmr.getDefaultCalibrationSearchMin( nmr_calibration_info_entry.calibration_type ) );
                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationSearchMax( csm_calibrate_nmr.getDefaultCalibrationSearchMax( nmr_calibration_info_entry.calibration_type ) );

            end
            
            % If it's a JRES, set these varargin options set the extra varargin options
            if strcmp( obj.pulse_program_lookup(bruker_data.pulse_program), 'jres' )
                
                uncalibrated_spectrum = csm_jres_spectra( raw_spectrum.spectra_real, raw_spectrum.ppm, raw_spectrum.ppm_2D, 'Raw spectrum', 'no_audit', true );
                
                calibrated_spectrum = csm_calibrate_nmr( uncalibrated_spectrum , nmr_calibration_info_entry.calibration_type, 'reference_peak',nmr_calibration_info_entry.calibration_ref_point,'search_range',[ nmr_calibration_info_entry.calibration_search_max, nmr_calibration_info_entry.calibration_search_min ], 'kind', 'jres', 'no_audit', true );
                
                interpolated_spectrum = csm_interpolate_nmr( calibrated_spectrum.output.calibrated_spectra, obj.ppm_common, 'ppm_common2D', obj.ppm_common_2D );
                               
            else

                uncalibrated_spectrum = csm_nmr_spectra( raw_spectrum.spectra_real, raw_spectrum.ppm, 'no_audit', true );
                
                calibrated_spectrum = csm_calibrate_nmr( uncalibrated_spectrum , nmr_calibration_info_entry.calibration_type, 'reference_peak',nmr_calibration_info_entry.calibration_ref_point,'search_range',[ nmr_calibration_info_entry.calibration_search_max, nmr_calibration_info_entry.calibration_search_min ], 'no_audit', true);
                
                interpolated_spectrum = csm_interpolate_nmr( calibrated_spectrum.output.calibrated_spectra, obj.ppm_common, 'no_audit', true );

            end

            processed_spectrum = interpolated_spectrum.output.interpolated_spectra;

        end

        % Build the csm_nmr_spectra objects for the final spectra
        % Breaks spectra into the sample types
        function [obj] = buildSpectra( obj, pulse_program, processed_spectra )
            
            unique_ids = obj.imported_nmr_experiment_info.unique_id_order;
            
            if isempty(unique_ids)
                return;
            end
            
            if isempty( keys( processed_spectra ) )
                return;
            end    
            
            
            for p = 1 : length (obj.sample_types)
            
                X = [];
                sample_ids = {};
                
                for i = 1 : length( unique_ids )

                    nmr_experiment_info_entry = obj.imported_nmr_experiment_info.entries(unique_ids{i});

                    nmr_calibration_info_entry = obj.imported_nmr_calibration_info.entries(nmr_experiment_info_entry.sample_id);

                    % If this the right sample type
                    if strcmp( nmr_calibration_info_entry.sample_type , obj.sample_types{p})
                               
                        % If the key doesn't exist, don't try to import
                        if ~isKey( processed_spectra, unique_ids{i}) 
                            
                            continue;
                            
                        end    
                        
                        processed_spectrum = processed_spectra( unique_ids{ i } );

                        % In this case, the output of csm_interpolate_spectra is a 1*n matrix
                        X( end + 1, : ) = processed_spectrum.X( 1, : );

                        sample_ids{ end + 1 } = nmr_experiment_info_entry.sample_id;

                    end

                end

                sample_metadata = obj.imported_sample_metadata.removeMissingEntries(sample_ids);
                nmr_experiment_info = obj.imported_nmr_experiment_info.removeMissingEntries(sample_ids);
                nmr_calibration_info = obj.imported_nmr_calibration_info.removeMissingEntries(sample_ids);


                short_pulse_program_name = obj.pulse_program_lookup(pulse_program);
                
                if strcmp( short_pulse_program_name, 'jres' )

                    obj.(short_pulse_program_name)(obj.sample_types{p}) = csm_jres_spectra( X, obj.ppm_common, obj.ppm_common_2D,'pulse_program', short_pulse_program_name, 'sample_type',obj.sample_types{p},'name', strcat( short_pulse_program_name, ' spectra' ), 'sample_ids', sample_ids, 'sample_metadata', sample_metadata, 'nmr_experiment_info', nmr_experiment_info, 'nmr_calibration_info', nmr_calibration_info );

                else

                    obj.(short_pulse_program_name)(obj.sample_types{p}) = csm_nmr_spectra( X, obj.ppm_common, 'pulse_program', short_pulse_program_name, 'sample_type',obj.sample_types{p}, 'name', strcat( short_pulse_program_name, ' spectra' ), 'sample_ids', sample_ids, 'sample_metadata', sample_metadata, 'nmr_experiment_info', nmr_experiment_info, 'nmr_calibration_info', nmr_calibration_info );
                    % TODO! Fix this bit where we want to get the missing metadata files
                    %obj.(short_pulse_program_name)(obj.sample_types{p}) = csm_nmr_spectra( X, obj.ppm_common, 'pulse_program', short_pulse_program_name, 'sample_type',obj.sample_types{p}, 'name', strcat( short_pulse_program_name, ' spectra' ), 'sample_ids', sample_ids);

                end	
            
            end

        end

        % Write the pulse program breakdown to the log
        function [obj] = pulseProgramSimpleQC( obj, pulse_program )

            final_spectra_temp = obj.final_spectra( pulse_program );

            pulse_program_import_failed = obj.import_failed( pulse_program );

            write_log( obj.log_file, sprintf( '\n\nData for %s:\n\n ', pulse_program ) );

            write_log( obj.log_file, sprintf( 'Number of matched experimental files acquired: %g\n\n', size( final_spectra_temp.X, 1 ) ) );

            write_log( obj.log_file, sprintf( 'Number of described experiments that were unable to be imported: %g\n\n', size( pulse_program_import_failed, 2 ) ) );

            for i = 1 : length( pulse_program_import_failed )

                write_log( obj.log_file, sprintf( '\t\tUnique ID: %s\n', pulse_program_import_failed{ i } ) );

            end

            obj = findDuplicateSampleRuns( obj, final_spectra_temp );

        end

        % Some samples are run in duplicate, this helps ID those that have been run twice
        function [obj] = findDuplicateSampleRuns( obj, final_spectra )

            % Use the spectra rowLabels for this.

            [ unique_sample_ids, ~, idx ] = unique( final_spectra.sample_ids );

            write_log( obj.log_file, sprintf( 'Duplicate Sample Runs: \n\n' ) );

            if length( unique_sample_ids ) == length( final_spectra.sample_ids )

                write_log( obj.log_file, sprintf( '\t\tNone \n' ) );

            else

                counts = accumarray( idx( : ), 1, [], @sum );

                for i = 1 : length( counts )

                    % THIS IS A DUPLICATE
                    if counts( i ) > 1

                        write_log( obj.log_file, sprintf( '\t\tUnique ID: %s\n', unique_sample_ids{ i } ) );

                    end

                end

            end

        end
        
        function [obj] = runAuditInfoMethods( obj )
            
            obj.audit_info.setExecutionTime( );
            obj.audit_info.setFunctionStack( dbstack_convert( dbstack ) );
            obj.audit_info.setName( 'csm_import_raw_nmr' );
            obj.audit_info.setOptionalInputs( obj.set_options );
            obj.audit_info.writeToLogFile(); 
            
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