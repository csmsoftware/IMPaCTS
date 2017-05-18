classdef csm_sample_metadata_entry
% CSM_SAMPLE_METADATA_ENTRY - Entry for sample metadata.
%
% Usage:
%
%	sample_metadata = csm_sample_metadata_entry( );
%
% Returns:
%   
%   sample_id : (str) The sample ID.
%   dynamic_fields : (containers.Map) The metadata fields.
%
% Methods:
%
%	csm_sample_metadata_entry.addDynamicField( dynamic_field_name, dynamic_field_value ) : Add to the dynamic field map.
%
% Description:
%
%	Entry for the sample metadata.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        sample_id;

        % Contains all the extra metadata
        dynamic_fields;

    end

    methods
        
        function [obj] = csm_sample_metadata_entry( )
            
            % Overwrites the previous ones. Matlab is so lame.
            obj.dynamic_fields = containers.Map;
            
        end    

        function [obj] = setSampleID( obj, sample_id )

            obj.sample_id = num2str( sample_id );

        end


        % Add dynamic fields. Check if for various conditions and convert as necessary.
        function [obj] = addDynamicField( obj, dynamic_field_name, dynamic_field_value )
            
            if isnumeric( dynamic_field_value )
                
               %dynamic_field_name
               %dynamic_field_value
                
               obj.dynamic_fields( dynamic_field_name ) = dynamic_field_value;
            
            elseif strcmp( dynamic_field_value, '')
                
               obj.dynamic_fields( dynamic_field_name ) = ''; 
               
        %    elseif is_str_numeric( dynamic_field_value )

         %       obj.dynamic_fields( dynamic_field_name ) = str2double( dynamic_field_value );

            elseif strcmpi(dynamic_field_value,'true')
                
                obj.dynamic_fields( dynamic_field_name ) = true;
                
            elseif strcmpi(dynamic_field_value,'false')
                
                obj.dynamic_fields( dynamic_field_name ) = false;
               
            else

                obj.dynamic_fields( dynamic_field_name ) = dynamic_field_value;

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

