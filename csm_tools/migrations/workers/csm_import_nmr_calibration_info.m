classdef csm_import_nmr_calibration_info < csm_import_generic_file
% CSM_IMPORT_NMR_CALIBRATION_INFO - CSM Import NMR Experiment Info Class
%
% Usage:
%
% 	calibrationInfo = csm_import_nmr_calibration_info( 'filename', filename );
%
% Arguments:
%
%	filename : (str) Full path to calibration info file.
%
% Returns:
%
%   filename : (str) Full path to calibration info file.
%   nmr_calibration_info : (csm_nmr_calibration_info) Container for calibration info.
%   sample_ids : (cell) Cell array of sample ids.
%
% Description:
%
%	Imports the spectra info file used for mapping samples to experiments
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        nmr_calibration_info;

        sample_ids;

    end

    methods


        % Constructor
        function [obj] = csm_import_nmr_calibration_info( varargin )
           
            obj = obj@csm_import_generic_file(varargin{:});

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.nmr_calibration_info = csm_nmr_calibration_info();
            obj.nmr_calibration_info.filename = obj.filename;
            
            obj.sample_ids = {};

            [~,~,ext] = fileparts( obj.filename );
            
            if( strcmp( ext , '.csv' ) )
                                
                obj = loadAndReadCSV( obj );
            
            else
            
                obj = loadAndReadXLS( obj );
                
            end    

        end
        
        function [obj] = loadAndReadXLS( obj )
            
            [~,~,content] = xlsread( obj.filename );
            
            obj = validateXlsHeaders( obj, content );
            
            for i = 2 : size(content,1)
                
                nmr_calibration_info_entry = csm_nmr_calibration_info_entry( );
                
                if isnan(content{ i , 1 })
                   
                    warning(strcat('NaNs in calibration info file, import skipped at line ',num2str(i)));
                    continue;
                    
                end    
                
                nmr_calibration_info_entry = nmr_calibration_info_entry.setSampleID( content{ i , 1 } );

                obj = addToSampleIDArray( obj, nmr_calibration_info_entry.sample_id );

                nmr_calibration_info_entry = nmr_calibration_info_entry.setSampleType( content{ i , 2 });

                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationType( content{ i , 3 } );

                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationRefPoint( content{ i , 4 } );

                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationSearchMin( content{ i , 5 });

                nmr_calibration_info_entry = nmr_calibration_info_entry.setCalibrationSearchMax( content{ i , 6 } );

                obj.nmr_calibration_info.sample_id_order{ end + 1 } = nmr_calibration_info_entry.sample_id;
                
                obj.nmr_calibration_info.entries( nmr_calibration_info_entry.sample_id ) = nmr_calibration_info_entry;

            end
            
            obj.nmr_calibration_info.sample_ids = obj.sample_ids;
                        
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

                nmr_calibration_info_entry = csm_nmr_calibration_info_entry( );

                csv_check_field_not_empty( 'NMR Calibration Info', i, 'Sample ID', content{ :, 1 }{ i } )
                nmr_calibration_info_entry = nmr_calibration_info_entry.setSampleID( content{ :, 1 }{ i } );

                obj = addToSampleIDArray( obj, nmr_calibration_info_entry.sample_id );

                csv_check_field_not_empty( 'NMR Calibration Info', i, 'Sample Type', content{ :, 2 }{ i } )
                nmr_calibration_info_entry.setExperimentNumber( content{ :, 2 }{ i } );

                csv_check_field_not_empty( 'NMR Calibration Info', i, 'Calibration Type', content{ :, 3 }{ i } )
                nmr_calibration_info_entry.setExperimentFolder( content{ :, 3 }{ i } );

                csv_check_field_not_empty( 'NMR Calibration Info', i, 'Calibration Ref Point', content{ :, 4 }{ i } )
                nmr_calibration_info_entry.setRack( content{ :, 4 }{ i } );

                csv_check_field_not_empty( 'NMR Calibration Info', i, 'Calibration Search Min', content{ :, 5 }{ i } )
                nmr_calibration_info_entry.setRackPosition( content{ :, 5 }{ i } );

                csv_check_field_not_empty( 'NMR Calibration Info', i, 'Calibration Search Max', content{ :, 6 }{ i } )
                nmr_calibration_info_entry.setInstrument( content{ :, 6 }{ i } );

                obj.nmr_calibration_info.entries( nmr_calibration_info_entry.sample_id ) = nmr_calibration_info_entry;

            end

        end

        % Add sample ID to array of sample IDs
        function [obj] = addToSampleIDArray( obj, sample_id )

            if ~ ismember( sample_id, obj.sample_ids )

                obj.sample_ids{ end + 1 } = sample_id;

            end

        end

        % Checks the headers of the csv file
        function [obj] = validateCsvHeaders( obj, content )

            if ~ strcmp( content{ :, 1 }( 1 ), 'Sample ID' )

                error( 'NMR Calibration Info csv format is incorrect - first column must be Sample ID, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 2 }( 1 ), 'Sample Type' )

                error( 'NMR Calibration Info csv format is incorrect - second column must be Sample Type, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 3 }( 1 ), 'Calibration Type' )

                error( 'NMR Calibration Info csv format is incorrect - third column must be Calibration Type, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 4 }( 1 ), 'Calibration Ref Point' )

                error( 'NMR Calibration Info csv format is incorrect - fourth column must be Calibration Ref Point, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 5 }( 1 ), 'Calibration Search Min' )

                error( 'NMR Calibration Info csv format is incorrect - fifth column must be Calibration Search Min, please check documentation for more information' );

            end

            if ~ strcmp( content{ :, 6 }( 1 ), 'Calibration Search Max' )

                error( 'NMR Calibration Info csv format is incorrect - sixth column must be Calibration Search Max, please check documentation for more information' );

            end

        end
        
        % Checks the headers of the csv file
        function [obj] = validateXlsHeaders( obj, content )

            if ~ strcmpi( content{ 1, 1 }, 'Sample ID' )

                error( 'NMR Calibration Info xls format is incorrect - first column must be Sample ID, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 2 }, 'Sample Type' )

                error( 'NMR Calibration Info xls format is incorrect - second column must be Sample Type, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 3 }, 'Calibration Type' )

                error( 'NMR Calibration Info xls format is incorrect - third column must be Calibration Type, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 4 }, 'Calibration Ref Point' )

                error( 'NMR Calibration Info xls format is incorrect - fourth column must be Calibration Ref Point, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1, 5 }, 'Calibration Search Min' )

                error( 'NMR Calibration Info xls format is incorrect - fifth column must be Rack Position, please check documentation for more information' );

            end

            if ~ strcmpi( content{ 1,  6 }, 'Calibration Search Max' )

                error( 'NMR Calibration Info xls format is incorrect - sixth column must be Calibration Search Max, please check documentation for more information' );

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

