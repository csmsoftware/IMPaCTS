classdef csm_sample_metadata
%CSM_SAMPLE_METADATA - CSM Sample Metadata Container
%
% Usage:
%
% 	sample_metadata = csm_sample_metadata( );
%
% Returns:
%
%   entries : (map) Container for csm_sample_metadata_entry, keys are sample ids.
%   filename : (str) Full path to original file if exists.
%
% Methods:
%
%   csm_sample_metadata.getTable() : Get the metadata as a table.
%	csm_sample_metadata.getClassVector( class ) : Return an m*1 vector of class.
%
% Description:
%
%	Imports the sample info file used for sample metadata
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        % key = sampleID, value = csm_sample_metadata_entry()
        entries;
        
        filename;
        
        dynamic_field_names;
        
        sample_id_order;

    end

    methods


        % Constructor
        function [obj] = csm_sample_metadata(  )

            obj.entries = containers.Map;
            obj.sample_id_order = {};
           
        end
        
        function [obj] = setFilename( obj, filename )
           
            obj.filename = filename;
            
        end   


        % Gets a tabular version of the sample info rows.
        function [table] = getTable( obj )

            cell_arr = {};
            col_names = {};

            % Loop through all the sample IDs
            % Get the sampleInfo for that sample
            % Assign the sampleID and sampleType and other required fields
            % Loop through the dynamic fields and add those as columns
            % If the first row (loop), build the col_names.
            for i = 1 : length( obj.sample_id_order )
                
                if ~isKey( obj.entries, obj.sample_id_order )
                    error( 'Key mismatch, please check and reimport your metadata');
                end    

                sample_metadata = obj.entries( obj.sample_id_order{ i } );
                dynamic_field_names = keys( sample_metadata.dynamic_fields );

                set_sample_id = false;

                % If there are not sample ids in the table, add them.
                if ~any(strcmp(dynamic_field_names,'Sample_ID'))

                    set_sample_id = true;

                    if i == 1

                        col_names{ end + 1 } = 'Sample_ID';

                    end

                    cell_arr{ i, 1 } = strrep(obj.sample_id_order( i ),'''','');

                    p0 = 2;
                else
                    p0 = 1;
                end

                %for p = p0 : length( dynamic_field_names )
                for p = p0 : length( dynamic_field_names )

                    if i == 1

                        field_name = strrep( dynamic_field_names{ p }, ' ', '_' );

                        field_name = strrep( field_name, '-', '_' );

                        col_names{ end + 1 } = field_name;

                    end
                    
                    entry = sample_metadata.dynamic_fields( dynamic_field_names{ p } );
                    
                    if ischar(entry)

                        cell_arr{ i, p } = strrep(entry,'''','');
                        
                    else
                        
                         cell_arr{ i, p } = entry;
                    
                    end    

                end
                
                % If sample ids were added, just push the missed first
                % column onto the end
                if p0 == 2
                    if i == 1
                        col_names{ end + 1 } = dynamic_field_names{1};
                        
                    end
                    
                    entry = sample_metadata.dynamic_fields( dynamic_field_names{ 1 } );
                    
                    if ischar(entry)
                        cell_arr{ i, length(col_names) } = strrep(entry,'''','');
                    else
                        cell_arr{ i, length(col_names) } = entry;
                    end    

                end    

            end
            
            warning ('off','all');

            table = cell2table( cell_arr );
            
            warning ('on','all');

            table.Properties.VariableNames = col_names;

        end

        % Removes any entries that are not in the sampleID list.
        function [obj] = removeMissingEntries( obj, sample_ids )

            all_sample_ids = keys( obj.entries );

            % Nothing to do, they should match.
            if length( all_sample_ids ) == length (sample_ids)

                return;

            end

            index = ismember( all_sample_ids, sample_ids );

            for i = 1 : length( index )

                if index( i ) == 0

                    % It wasnt imported....

                    remove( obj.entries, all_sample_ids{ i } );

                end

            end

        end
        
         % Gets a classes vector for plotting functions
        function [ classes ] = getClassVector( obj, class )

            sample_table = obj.getTable();

            classes = [];

            for i = 1 : length( obj.sample_id_order )

                tempTable = sample_table( strcmp( sample_table.Sample_ID, obj.sample_id_order{ i } ), {class} );

                if ~ isnumeric( tempTable.(class)(1) )

                    error ('Classes must be numeric');

                end

                classes( i, 1 ) = tempTable.(class)(1);

            end

        end

        % Dynamic property loader ** REQUIRED FUNCTION **
        function [obj] = setProperty( obj, field_name, fieldValue )

            if isprop( obj, field_name )

                if ischar( fieldValue )

                    eval( strcat( 'obj.', field_name, ' = ''', fieldValue, ''' ;' ) );

                else

                    eval( strcat( 'obj.', field_name, ' = fieldValue ;' ) );

                end

            end

        end

    end

end

