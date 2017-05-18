classdef csm_import_nmr_experiment_info < csm_import_generic_file
%CSM_IMPORT_NMR_EXPERIMENT_INFO - CSM Import NMR Experiment Info Class
%
% Usage:
%
% 	nmr_experiment_info_entry = csm_import_nmr_experiment_info( 'filename', filename )
%
% Arguments:
%
%	filename : (str) Full path to experiment info file.
%
% Returns:
%
%   filename : (str) Full path to calibration info file.
%   nmr_experiment_info : (csm_nmr_experiment_info) Container for calibration info.
%   sample_ids : (cell) Cell array of sample ids.
%
% Description:
%
%	Imports the spectra info file used for mapping samples to experiments
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        % key = unique_id, value = csm_nmr_experiment_info()
        nmr_experiment_info;
        
    end

    methods


        % Constructor
        function [obj] = csm_import_nmr_experiment_info( varargin )
            
            obj = obj@csm_import_generic_file(varargin{:});
            
            obj.nmr_experiment_info = csm_nmr_experiment_info();
            obj.nmr_experiment_info.filename = obj.filename;

            [~,~,ext] = fileparts( obj.filename );
            
            if( strcmp( ext , '.csv' ) )
                                
                obj = loadAndReadCSV( obj );
            
            else
            
                obj = loadAndReadXLS( obj );
                
            end    

        end
        
        function [obj] = loadAndReadXLS( obj )
            
            [a,b,content] = xlsread( obj.filename );
            
            obj = validateXlsHeaders( obj, content );
            
            for i = 2 : size(content,1)
                
                % Check the sample id, if its NaN then stop!
                if isnan(content{ i , 1 })
                   
                    warning(strcat('NaNs in experiment info file, import skipped at line ',num2str(i)));
                    continue;
                    
                end    
                
                nmr_experiment_info_entry = csm_nmr_experiment_info_entry( );
                
                nmr_experiment_info_entry = nmr_experiment_info_entry.setSampleID( content{ i , 1 } );

                obj = obj.addToSampleIDArray( nmr_experiment_info_entry.sample_id );

                nmr_experiment_info_entry = nmr_experiment_info_entry.setExperimentNumber( num2str( content{ i , 2 }));

                nmr_experiment_info_entry = nmr_experiment_info_entry.setExperimentFolder( num2str( content{ i , 3 } ));

                nmr_experiment_info_entry = nmr_experiment_info_entry.setRack( num2str( content{ i , 4 } ));

                nmr_experiment_info_entry = nmr_experiment_info_entry.setRackPosition( num2str( content{ i , 5 } ));

                nmr_experiment_info_entry = nmr_experiment_info_entry.setInstrument( num2str( content{ i , 6 } ));

                nmr_experiment_info_entry = nmr_experiment_info_entry.setAcquisitionBatch( num2str( content{ i , 7 } ));

                nmr_experiment_info_entry = nmr_experiment_info_entry.setUniqueID( strcat( nmr_experiment_info_entry.experiment_folder, '-', nmr_experiment_info_entry.experiment_number ) );
               
                obj.nmr_experiment_info.unique_id_order{ end + 1 } = nmr_experiment_info_entry.unique_id;
                
                obj.nmr_experiment_info.entries( nmr_experiment_info_entry.unique_id ) = nmr_experiment_info_entry;

            end    
                        
        end     

        % Read in
        function [obj] = loadAndReadCSV( obj )

            fid = fopen( obj.filename );

            content = textscan( fid, '%s %s %s %s %s %s %s', 'delimiter', ',' );

            fclose( fid );

            % Check columns are in correct order:

            obj = validateCsvHeaders( obj, content );

            % Loop through, assign values, build Map.
            for i = 2 : length( content{ 1 } )

                nmr_experiment_info_entry = csm_nmr_experiment_info_entry( );

                csv_check_field_not_empty( 'spectra Info', i, 'Sample ID', content{ :, 1 }{ i } )
                nmr_experiment_info_entry.setSampleID( content{ :, 1 }{ i } );

                obj.addToSampleIDArray( nmr_experiment_info_entry.sample_id );

                csv_check_field_not_empty( 'spectra Info', i, 'Experiment Number', content{ :, 2 }{ i } )
                nmr_experiment_info_entry.setExperimentNumber( content{ :, 2 }{ i } );

                csv_check_field_not_empty( 'spectra Info', i, 'Experiment Folder', content{ :, 3 }{ i } )
                nmr_experiment_info_entry.setExperimentFolder( content{ :, 3 }{ i } );

                csv_check_field_not_empty( 'spectra Info', i, 'Rack', content{ :, 4 }{ i } )
                nmr_experiment_info_entry.setRack( content{ :, 4 }{ i } );

                csv_check_field_not_empty( 'spectra Info', i, 'Rack position', content{ :, 5 }{ i } )
                nmr_experiment_info_entry.setRackPosition( content{ :, 5 }{ i } );

                csv_check_field_not_empty( 'spectra Info', i, 'Instrument', content{ :, 6 }{ i } )
                nmr_experiment_info_entry.setInstrument( content{ :, 6 }{ i } );

                csv_check_field_not_empty( 'spectra Info', i, 'Acquisition batch', content{ :, 7 }{ i } )
                nmr_experiment_info_entry.setAcquisitionBatch ( content{ :, 7 }{ i } );
                
                csv_check_field_not_empty( 'spectra Info', i, 'Line Width', content{ :, 9 }{ i } )
                nmr_experiment_info_entry.setLineWidth ( content{ :, 7 }{ i } );

                nmr_experiment_info_entry.setUniqueID( strcat( nmr_experiment_info_entry.experiment_folder, '-', nmr_experiment_info_entry.experiment_number ) );

                obj.nmr_experiment_info_entry.entries( nmr_experiment_info_entry.unique_id ) = nmr_experiment_info_entry;

            end

        end

        % Add sample ID to array of sample IDs
        function [obj] = addToSampleIDArray( obj, sample_id )

            if ~ ismember( sample_id, obj.nmr_experiment_info.sample_ids )

                obj.nmr_experiment_info.sample_ids{ end + 1 } = sample_id;

            end;

        end

        % Checks the headers of the csv file
        function [obj] = validateCsvHeaders( obj, content )

            if ~ strcmp( content{ :, 1 }( 1 ), 'Sample ID' )

                error( 'spectra Info csv format is incorrect - first column must be Sample ID, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 2 }( 1 ), 'Experiment Number' )

                error( 'spectra Info csv format is incorrect - second column must be Experiment Number, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 3 }( 1 ), 'Experiment Folder' )

                error( 'spectra Info csv format is incorrect - third column must be Experiment Folder, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 4 }( 1 ), 'Rack' )

                error( 'spectra Info csv format is incorrect - fourth column must be Rack, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 5 }( 1 ), 'Rack Position' )

                error( 'spectra Info csv format is incorrect - fifth column must be Rack Position, please check documentation for more information' );

            end

            if ~ strcmp( content{ :,  6 }( 1 ), 'Instrument' )

                error( 'spectra Info csv format is incorrect - sixth column must be Instrument, please check documentation for more information' );

            end

            if ~ strcmp( content{ :,  7 }( 1 ), 'Acquisition Batch' )

                error( 'NMR Experiment Info csv format is incorrect - seventh column must be Acquisition Batch, please check documentation for more information' );

            end

        end
        
        % Checks the headers of the csv file
        function [obj] = validateXlsHeaders( obj, content )

            if ~ strcmpi( content{ 1, 1 }, 'Sample ID' )

                error( 'NMR Experiment Info xls format is incorrect - first column must be Sample ID, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 2 }, 'Experiment Number' )

                error( 'NMR Experiment Info xls format is incorrect - second column must be Experiment Number, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 3 }, 'Experiment Folder' )

                error( 'NMR Experiment Info xls format is incorrect - third column must be Experiment Folder, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 4 }, 'Rack' )

                error( 'NMR Experiment Info xls format is incorrect - fourth column must be Rack, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 5 }, 'Rack Position' )

                error( 'NMR Experiment Info xls format is incorrect - fifth column must be Rack Position, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1,  6 }, 'Instrument' )

                error( 'NMR Experiment Info xls format is incorrect - sixth column must be Instrument, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1,  7 }, 'Acquisition Batch' )

                error( 'NMR Experiment Info xls format is incorrect - seventh column must be Acquisition Batch, please check documentation for more information' );

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

