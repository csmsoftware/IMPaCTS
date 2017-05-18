classdef csm_spectra
%CSM_SPECTRA - Abstract CSM spectra Base Class.
%
% Usage:
%
% 	nmr_spectra = csm_nmr_spectra( X, ppm );
% 	jres_spectra = csm_jres_spectra( X, ppm , ppm2D );
% 	ms_spectra = csm_ms_spectra( X, mz );
%
% Methods:
%
%	csm_spectra.setX( X ) : Assign a new spectral matrix to the object.	Resets csmDataHash.
%	csm_spectra.getSubSpectra( conditions ) : Return sub spec based on sampleInfo conditions. See description.
%	csm_spectra.addSpectra( spectra ) : Add a spectra object to this one.
%	csm_spectra.getTable( ) : Get a table of the X matrix.
%
% Description:
%
%	CSM spectra object. Abstract class, please use csm_nmr_spectra or
%	csm_ms_spectra, or csm_jres_spectra
%
%	csm_spectra.getSubSpectra( conditions ) will return a spectra based on the fields in sampleInfo.
%	conditions is the format {{ field, condition }}, and multiple conditions can be specified
%	ie:
%	conditions = { { 'HistoScore', 'HS2' }, { 'RatNumber', '34' } }
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014 

% Author - Gordon Haggart 2014

    properties

        inputparser;
        csm_data_hashes;
        X;
        x_scale;
        x_scale_name;
        is_continuous;
        sample_ids;
        sample_metadata;
        audit_info;
        use_hash;
        name;
        sample_type;
        
    end

    methods

         % Constructor
        function [obj] = csm_spectra( X, varargin )

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.csm_data_hashes = containers.Map;
            
            obj = setAuditInfo( obj, csm_audit_info () );

            obj = setX( obj, X );

            obj = setDefaults( obj );
            
            obj = setVarargin( obj, varargin );

        end

        function [obj] = setName( obj, name )

            obj.name = name;

        end
        
        function [obj] = setDefaults( obj )
            
            setIsContinuousDefault( obj );
            
        end    
        
        function [obj] = setVarargin( obj, varargin )
            
            if numel( varargin ) == 0
                return;
            end    
            
            nameSet = false;
            
            k = 1;
            while k < numel( varargin{1}{:} )
                                
                % If it exists, set it
                if strcmp( varargin{1}{:}{k}, 'sample_ids')
                    
                    obj.sample_ids = varargin{1}{:}{k+1};
                    
                elseif strcmp( varargin{1}{:}{k}, 'sample_metadata')
                        
                    obj.sample_metadata = varargin{1}{:}{k+1};  
                    
                elseif strcmp( varargin{1}{:}{k}, 'is_continuous')
                        
                    obj.is_continuous = varargin{1}{:}{k+1};
                       
                elseif strcmp( varargin{1}{:}{k}, 'name')
                    
                    nameSet = true;
                    setName( obj, varargin{1}{:}{k+1} );
                    
                elseif strcmp( varargin{1}{:}{k}, 'sample_type')
                    
                    obj.sample_type = varargin{1}{:}{k+1};
                       
                end     
                
                k = k + 2;
                
            end
            
            if false(nameSet)
                
                setName ( obj, 'Name not set' );
                
            end    
            
        end
        
        function [obj] = setIsContinuousDefault( obj )
           
            obj.is_continuous = false;
            
        end    
        
        % Set the x scale - ie ppm for NMR
        function [obj] = setXScale( obj, x_scale, x_scale_name )
            
           obj.x_scale = x_scale;
           obj.x_scale_name = x_scale_name;
                       
        end
        
        % Get the x Scale
        function [ x_scale ] = getXScale( obj )
           
            x_scale = obj.x_scale;
            
        end
        
        % Get the x scale name, ie 'ppm'
        function [ x_scale_name ] = getXScaleName( obj )
            
            x_scale_name = obj.x_scale_name;
            
        end
        
        % Check if the x scale is continuous
        function [ is_continuous ] = isContinuous( obj )
           
            is_continuous = obj.is_continuous;
            
        end    

        % Set the audit_info
        function [obj] = setAuditInfo( obj, audit_info )

            obj.audit_info = audit_info;

        end

        % Set whether to use the hash
        function [obj] = setUseHash( obj, use_hash )

            if isempty( use_hash )

                obj.use_hash = false;

            else

                obj.use_hash = use_hash;

            end

        end

        % Assigns the X matrix
        function [obj] = setX( obj, X )
           
            obj.X = X;

            if ~isempty( obj.use_hash )

                %buildDataHash( obj, 'X' );

            end

        end

        function [obj] = rebuildDataHashes( obj, varNames )

            for i = 1 : length( varNames )

                eval( strcat( 'obj.csm_data_hashes( ''', varNames{ i }, ''' ) = rptgen.hash( num2str( obj.', varNames{ i }, ' ) );'));

            end

        end
        
          % Sets the hash of the varriable.
        function [obj] = buildDataHash( obj, varName )
            
            eval( strcat( 'obj.csm_data_hashes( varName ) = rptgen.hash( num2str( obj.', varName, ' ) );'));

        end

        % Set the audit_info className
        function [obj] = setClassName( obj, className )

            %obj.audit_info.setName( className );

        end

        % Set the name and description in the audit_info
        function [obj] = setDescription( obj, options )

            if isfield( options, 'description' )
              
                %obj.audit_info.setDescription( options.description );

            else

                %obj.audit_info.setDescription( strcat( 'csm_spectra object for ', obj.audit_info.name ) );
               
            end
            
        end

        % Method for building a MATLAB table based on the data
        function table = getTable( obj )
            
            table = array2table( obj.X );
            
            table.Properties.RowNames = obj.sample_ids;
            table.Properties.Description = obj.audit_info.description;
            table.Properties.UserData = obj.audit_info;
                      
        end

        % Return a new spectra object based on table select condition.
        % ie { { 'HistoScore', 'HS2' } ,{ 'RatNumber', '34' } }
        function sub_spec = getSubSpectra( obj, conditions )

            if isempty( obj.sample_metadata )

                warning('sample metadata is empty');
                return;

            end

            sample_table = obj.sample_metadata.getTable();

            matching_sample_ids = {};

            % Extract the sample IDs that match

            for i = 1 : length( conditions )

                variable = conditions{ i }{ 1 };

                % Try and convert it to a number, does it work?
                if isnan( str2double( conditions{ i }{ 2 } ) )

                    condition = conditions{ i }{ 2 };

                else

                    condition = str2double( conditions{ i }{ 2 } );

                end

                % Here we need to work out what type the variable is and
                % use the relevant operator.

                specific_sample_ids = {};

                if isa( condition, 'char' )

                    specific_sample_ids = table2cell( sample_table( strcmp( sample_table.(variable), condition ),{'Sample_ID'}) );

                elseif isnumeric( condition )

                    specific_sample_ids = table2cell( sample_table( sample_table.(variable) == condition ,{'Sample_ID'} ) );

                else

                    continue;

                end

                % Add the newly matched ones to the array
                for i = 1 : length(specific_sample_ids)

                    matching_sample_ids{ end + 1 } = specific_sample_ids{ i };

                end

            end

            sample_ids = {};
            removed_sample_ids = {};
            subX = [];

            % If it's in the matching array, get the spectrum vector
            for i = 1 : length( obj.sample_ids )

                if ismember( obj.sample_ids{ i }, matching_sample_ids )

                    subX( end + 1, : ) = obj.X( i, : );

                    sample_ids{ end + 1 } = obj.sample_ids{ i };

                end

            end

            sample_metadata.removeMissingEntries( sample_ids );

            % Create a new sub spec from conditions
            if isa( obj, 'csm_jres_spectra' )
                
                sub_spec = csm_jres_spectra( subX, obj.get_x_scale(), obj.ppm2D,'name', 'sub selected X', 'sample_metadata', sample_metadata, 'sample_ids', sample_ids, 'nmrExperimentInfo', obj.nmrExperimentInfo, 'nmrCalibrationInfo', obj.nmrCalibrationInfo );
                
            elseif isa( obj, 'csm_nmr_spectra' )
                
                sub_spec = csm_nmr_spectra( subX, obj.get_x_scale(), 'sub selected X', 'sample_metadata', sample_metadata, 'sample_ids', sample_ids, 'nmrExperimentInfo', obj.nmrExperimentInfo, 'nmrCalibrationInfo', obj.nmrCalibrationInfo );
                                
            elseif isa( obj, 'csm_ms_spectra' )
                
                sub_spec = csm_ms_spectra( subX, obj.get_x_scale(), 'sub selected X', 'sample_metadata', sample_metadata, 'sample_ids', sample_ids, 'msFeatures', msFeatures );
               
            else
                
               error(' Unknown type of csm_spectra object!');
                
            end
            
        end

       
        % Add another spectra object to this one
        % Also adds sampleInfo & sample_ids if exists
        function [obj] = addSpectra( obj, spectra )

            if length( spectra.ppm ) ~= length( obj.ppm )

                error( 'PPM scales are different');

            end

            for i = 1 : length( spectra.sample_ids )

                obj.sample_ids{ end + 1 } = spectra.sample_ids{ i };

            end

            sample_metadata_keys = keys( spectra.sample_metadata.sample_metadata );

            for i = 1 : length( sample_metadata_keys )

                obj.sample_metadata.sample_metadata( spectra.sample_ids{ i } ) = spectra.sample_metadata.sample_metadata( spectra.sample_ids{ i } );

            end

            new_X = obj.X;

            for i = 1 : size( spectra.X, 1 )

                new_X( end + 1, : ) = spectra.X( 1, : );

            end

            obj.setX( new_X );

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
