classdef csm_import_sample_metadata < csm_import_generic_file
%CSM_IMPORT_SAMPLE_METADATA - CSM Import Sample Metadata worker
%
% Usage:
%
% 	imported = csm_import_sample_metadata( 'filename', filename );
%
% Arguments:
%
%	filename : (str) Full path to sample metadata file.
%
% Returns:
%
%	imported.sample_metadata : (csm_sample_metadata) The sample metadata.
%
% Description:
%
%	Imports the sample info file used for sample metadata.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        sample_metadata;

        dynamic_field_names;

    end

    methods


        % Constructor
        function [obj] = csm_import_sample_metadata( varargin )

            obj = obj@csm_import_generic_file(varargin{:});
            
            obj.dynamic_field_names ={ };

            obj.sample_metadata = csm_sample_metadata();
            obj.sample_metadata = obj.sample_metadata.setFilename( obj.filename );

            [~,~,ext] = fileparts( obj.filename );
            
            if( strcmp( ext , '.csv' ) )
                                
                obj = loadAndReadCSV( obj );
            
            else
            
                obj = loadAndReadXLS( obj );
                
            end 

        end
        
        function [obj] = loadAndReadXLS( obj )
            
            [ a, b, content] = xlsread( obj.filename );
            
            unfiltered_header = content(1,:);
            
            header = {};
            
            for i = 1 : size(unfiltered_header,2)
                
                if ~isnan(unfiltered_header{1,i})
                    
                   header{ end + 1 } = unfiltered_header{1,i};
                   
                end
            end    
            
            obj = validateHeader( obj, header );
            
            obj = setDynamicFieldNames( obj, header );
            
            for i = 2 : size(content,1)
                
                % Check the sample id, if its NaN then stop!
                if isnan(content{ i , 1 })
                   
                    warning(strcat('NaNs in sample metadata file, import stopped at line ',num2str(i)));
                    continue;
                    
                end    
                
                sample_metadata_entry = csm_sample_metadata_entry();
                
                sample_metadata_entry = sample_metadata_entry.setSampleID(content{ i, 1 });

                % Set the optional extras in the dynamic field map
                for p = 2 : size(content,2 )
                    
                    % Handle the NaNs
                    if isnan(content{ 1 , p })
                        continue;
                    end    

                    sample_metadata_entry = sample_metadata_entry.addDynamicField( obj.dynamic_field_names{ p }, content{ i, p } );

                end

                obj.sample_metadata.sample_id_order{ end + 1 } = sample_metadata_entry.sample_id;
                % Push onto the sample_info map
                obj.sample_metadata.entries( sample_metadata_entry.sample_id ) = sample_metadata_entry;
                
            end    
                        
        end   

        % Read in file, loop, build sample_info map.
        function [obj] = loadAndReadCSV( obj )

            % Open the file
            fid = fopen( obj.filename );

            % Get the 1st line, trim and split
            line = fgetl( fid );
            line = strrep( line, '"', '' );
            header = strsplit( line, ',' );

            % Validate the necessary columns
            obj = validateHeader( obj, header );

            % Grab the optional (dynamic) columns
            obj = setDynamicFieldNames( obj, header );

            line = fgetl( fid );

            while ischar( line )

                % Trim and Split
                line = strrep( line, '"', '' );

                % Hack to ensure empty cells are included
                line = strrep( line, ',,', ', ,' );
                lineCell = strsplit( line, ',' );

                % New Sample Info Object
                sample_metadata_entry = csm_sample_metadata_entry( );

                % Set the optional extras in the dynamic field map
                for p = 2 : length( lineCell )

                    sample_metadata_entry.addDynamicField( obj.dynamic_field_names{ p }, lineCell{ p } );

                end

                % Push onto the sample_info map
                obj.sample_metadata.entries( sample_metadata_entry.sample_id ) = sample_metadata_entry;

                line = fgetl( fid );

            end

            % Close the file
            fclose( fid );

        end

        %Sample Label	Class	Class Label
        % Checks the headers of the csv file
        function [obj] = validateHeader( obj, header )

            if ~ strcmpi( header( 1 ), 'Sample ID' )

                error( 'Sample Metadata file is incorrect - first column must be Sample ID, please check documentation for more information' );

            end

        end

        % Sets the necessary dynamic field names that exist in the file.
        function [obj] = setDynamicFieldNames( obj, header )

            for i = 2 : length( header )

                obj.dynamic_field_names( i ) = header( i );

            end

        end


        % Dynamic property loader ** REQUIRED FUNCTION **
        function setProperty( obj, fieldName, fieldValue )

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

