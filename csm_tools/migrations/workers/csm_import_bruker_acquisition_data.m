classdef csm_import_bruker_acquisition_data < csm_import_generic_folder
%CSM_IMPORT_BRUKER_ACQUISITION_DATA - CSM Import Bruker Acquisition Data Class
%
% Usage:
%
% 	acquisitionData = csm_import_bruker_acquisition_data( 'experimentPath', experimentPath );
%
% Arguments:
%
%	folder : (str) Full path to experiment folder.
%
% Returns:
%
%   folder : (str) Full path to experiment folder.
%	bruker_acquisition_data : (csm_bruker_acquisition_data) Container for acquisition data.
%	pulse_programs : (cell) Array of the distinct pulse programs.
%	pulse_program_experiment_lookup : (cell) Array of the distinct pulse programs.
%
% Methods:
%
%	csm_import_bruker_acquisition_data.loopAndScan(folder) : Loop over the folders and scan for data.
%	csm_import_bruker_acquisition_data.importExperimentMetadata(folder) : Import the bruker data from the folder.
%	csm_import_bruker_acquisition_data.createPulseProgramLookup() : Create the necessary pulse program lookup array.
%
% Description:
%
%	Scans experiment directories and imports Bruker NMR metadata.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        % key = unique_id, value = csm_bruker_acquisition_data()
        bruker_acquisition_data;
        folder_map;
        current_parent_folder;
        folder_keys_to_import;

    end

    methods

        
        % Constructor
        function [obj] = csm_import_bruker_acquisition_data( varargin )

            obj = obj@csm_import_generic_folder(varargin{:});

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.folder_keys_to_import = false;
            
            k = 1;
            while k < numel( varargin )

                if strcmp( varargin{k}, 'folder_keys_to_import')
                    
                    obj.folder_keys_to_import = varargin{k+1};
                    
                end

                k = k + 2;

            end
            
            obj.bruker_acquisition_data = csm_bruker_acquisition_data();
            
            if iscell(obj.folder_keys_to_import)
            
                obj.folder_map = containers.Map;

                for i = 1 : size(obj.folder_keys_to_import,2)

                    split_key = strsplit(obj.folder_keys_to_import{i},'-');
                    parent_folder = split_key{1};
                    experiment_folder = split_key{2};

                    if ~isKey(obj.folder_map,parent_folder)

                       obj.folder_map(parent_folder) = {};

                    end
                    
                    cell_ar = obj.folder_map(parent_folder);

                    cell_ar{end + 1} = experiment_folder;
                    
                    obj.folder_map(parent_folder) = cell_ar;

                end
            end    
            

            obj = loopAndScan( obj, obj.folder );

            obj = createPulseProgramLookup( obj );

        end


        % Loop through folders in current_folder and scan for Bruker files
        %
        % 1. Loop through all files in folder and check for acqus file
        % 2. If exists, import as experiment.
        % 3. If not exists, loop through files,
        % 4. If folder, loop and scan!
        function [obj] = loopAndScan( obj, current_folder )

            this_is_experiment_folder = false;

            % get all files
            files = dir( fullfile( current_folder ));


            % 1. Loop through all files and check for acqus files
            for i = 1 : length( files )

                % This is an experiment folder! - Once imported, go back out of folder
                if ~ isempty( strfind( files( i ).name, 'acqus' ))

                    this_is_experiment_folder = true;
                    break;

                end

            end

            % 2. We are in an experiment folder, import!
            if true( this_is_experiment_folder )
                
                % Check if we should be checking for these entries at all
                if iscell(obj.folder_keys_to_import) && isKey(obj.folder_map,obj.current_parent_folder)
                   
                    experiment_folders = obj.folder_map(obj.current_parent_folder);
                    
                    [~,folder_name,~] = fileparts(current_folder);
                    
                    should_be_imported = 0;
                    for c = 1 : length(experiment_folders)
                        if strcmp(folder_name,experiment_folders{c})
                            should_be_imported = 1;
                            break;
                        end
                    end    

                    if (should_be_imported == 0)
                      % if (cellfun(@(s) ~isempty(strfind(folder_name, s)), experiment_folders) == 0)
                        % DONT IMPORT!
                        return;

                    end    
                end    
                

                obj = importExperimentMetadata( obj, current_folder );

                return;


            % 3. Otherwise, if it's a folder, loop and scan!
            else

                % Loop through all files and check if we are a folder
                for i = 1 : length( files )


                    % If is a hidden file (ie starting with a .)
                    if strncmpi( files( i ).name, '.', 1)

                        continue;

                    end


                    % 4. Folder found, loop and scan.
                    if isdir( strcat( current_folder, filesep, files( i ).name ) )

                        
                        [~,obj.current_parent_folder,~] = fileparts(current_folder);
                        obj = loopAndScan( obj, strcat( current_folder, filesep, files( i ).name ));

                    end

                end

            end

        end


        % Opens acqus file and sets parameters into acquisition object.
        function [obj] = importExperimentMetadata( obj, current_folder )

            [ ~, experiment_number, ~ ] = fileparts( current_folder );

            bruker_data_entry = csm_bruker_acquisition_data_entry( );


            % Set the spectrum Path
            bruker_data_entry = bruker_data_entry.setspectrumPath( current_folder );

            % Set the Experiment Folder
            full_path = strsplit( current_folder, filesep );
            experiment_folder_cell = full_path( end - 1 );
            bruker_data_entry = bruker_data_entry.setExperimentFolder( experiment_folder_cell{ 1 } );

            % Set the Experiment Number (Folder Name)
            bruker_data_entry = bruker_data_entry.setExperimentNumber( str2double( experiment_number ) );

            % Set the unique ID.
            bruker_data_entry = bruker_data_entry.setUniqueID( strcat( bruker_data_entry.experiment_folder, '-', experiment_number ) );

            % Open the acqus file
            acqus = fopen( fullfile( current_folder, 'acqus' ));
            readvar = fscanf( acqus, '%c' );

            % Set the Pulse program
            [~,temp] = regexp( readvar, '##\$PULPROG=\s*<(.*?)>', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setPulseProgram( char( temp{ 1 } ));
            end
        
            % Set the spectratrometer frequency
            [~,temp] = regexp( readvar, '##\$BF1=\s*(\d*.\d*)', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setspectratrometerFrequency( char( temp{ 1 } ));
            end
        
            % Set the Computer
            [~,temp] = regexp( readvar, '\$\$\s*\d*-\d*-\d*\s*\d*:\d*:\d*.\d*\s*\+\d*\s*(.*?)\n', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setComputer( char( temp{ 1 } ));
            end


            % Set the Acquisition time
            [~,temp] = regexp( readvar, '\$\$\s*(\d*-\d*-\d*\s*\d*:\d*:\d*.\d*)', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setTimeOfAcquisition( char( temp{ 1 } ));
            end
        
            % Set the Automation file
            [~,temp] = regexp (readvar, '##\$AUNM=\s*<(.*?)>', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setAutomationFile( char( temp{ 1 } ));
            end
        
            % Set the P1
            [~,temp] = regexp (readvar, '##\$P=.*?\n(\d*.\d*)', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setP1Value( char( temp{ 1 } ));
            end
        
            % Set the O1
            [~,temp] = regexp (readvar, '##\$O1=\s*(\d*.\d*)', 'match', 'tokens' );
            if ~ isempty( temp )
                bruker_data_entry = bruker_data_entry.setO1Value( char( temp{ 1 } ));
            end
        
            fclose( acqus );


            % Title file information
        
            if( exist( fullfile( current_folder, 'pdata', '1', 'title' ), 'file' ))

                % Read in information from title file:
                title = fopen( fullfile( current_folder, 'pdata', '1', 'title' ));

                % Set the title file content
                bruker_data_entry = bruker_data_entry.setTitleFileContent( fscanf( title, '%c' ) );

                fclose( title );
        
            end

            % Push onto the bruker_acquisition_data (Pulse Program/Experiment Number is the index)
            obj.bruker_acquisition_data.entries( bruker_data_entry.unique_id ) = bruker_data_entry;


            % Add any new pulse programs to the pulse program cell array
            if ~ ismember( bruker_data_entry.pulse_program, obj.bruker_acquisition_data.pulse_programs )

                obj.bruker_acquisition_data.pulse_programs{ end + 1 } = bruker_data_entry.pulse_program;
                obj.bruker_acquisition_data.pulse_program_experiment_lookup{ end + 1 } ={ } ;

            end;

        end

        % Create the Pulse program Lookup cell array. This is for grouping uniqueIDs by pulse_program
        function [obj] = createPulseProgramLookup( obj )

            % Get the uniqueIDs
            bruker_keys = keys( obj.bruker_acquisition_data.entries );

            for i = 1 : length( bruker_keys )

                bruker_data_entry = obj.bruker_acquisition_data.entries( bruker_keys{ i } );

                % Find the pulse_program Index from obj.pulse_programs
                pulseProgramIndex = find( ismember( obj.bruker_acquisition_data.pulse_programs, bruker_data_entry.pulse_program ) );

                if ~ isempty( pulseProgramIndex )

                    % Add the unique ID to a 2D cell array.
                    obj.bruker_acquisition_data.pulse_program_experiment_lookup{ pulseProgramIndex }{ end + 1 } = bruker_data_entry.unique_id;

                end

            end

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
