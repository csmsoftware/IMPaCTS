classdef csm_wrapper
%CSM_WRAPPER - Base class for CSM Wrappers. ie. PCA, OPLS etc.
%
% Usage:
%
%	model = csm_wrapper( );
%
% Arguments:
%
%   no_audit : (bool) Set to true to not run the audit_info methods. Default false;
%
% Returns:
%
%	csm_wrapper.audit_info : (csm_audit_info) The audit info for audit trails.
%	csm_wrapper.class_name : (str) The name of the child class.
%	csm_wrapper.input : (struct) The inputs of the object.
%	csm_wrapper.output : (struct) The outputs of the base methods
%	csm_wrapper.csm_data_hashes : (cell) The csm_data_hash of the data used in the object
%
% Description:
%
%	The base class for the CSM wrappers. These wrappers are the standardised access points to the underlying CSM functions.
%
%	In order to create a new wrapper, you must implement the following methods:
%
%       assignDefaults( obj );
%       parseInput( obj );
%       callBaseTool( obj );
%		parseOutput( obj );
%						
%	Your constructor should look similar to this:
%
%	function [obj] =  csm_example_wrapper( arg1, arg2, arg3 )
%       % Allows creation of empty objects for cloning
%       if nargin == 0
%           return
%       end
%       obj = obj @ csm_wrapper( varargin{:} );
%       assignDefaults( obj, arg1, arg2, arg3 );
%       parseInput( obj );
%       callBaseTool( obj );
%       runAuditInfoMethods( obj );
%       parseOutput( obj );
%	end
%
%	Have a look at the code for any of the existing wrappers for examples
%	of building your own, eg csm_opls()
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016



    properties

        inputparser;
        optional_defaults;
        set_options;
        audit_info;
        class_name;
        input;
        output;
        csm_data_hashes;
        no_audit;
        class_description;

    end


    properties( Access = protected )

        tmp;

    end


    methods
        
        % Main constructor. Always call this super class constructor first.
        function [obj] = csm_wrapper( varargin )

            obj = init( obj, varargin{:} );

        end

        % Initialisation method.
        function [obj] = init( obj, varargin )
            
            obj.no_audit = false;

            % Find the no_audit flag
            k = 1;
            while k < numel( varargin )
                
                % If it exists, set it and break
                if strcmp( varargin{k}, 'no_audit')
                    
                    obj.no_audit = varargin{(k+1)} ;
                    break;
                    
                end
                
                k = k + 1;
                
            end
            
            obj.audit_info = csm_audit_info('is_empty',obj.no_audit);
            
            obj.input = struct;
            
            obj.optional_defaults = containers.Map;
            obj.set_options = {};
            
            obj.csm_data_hashes = {};
            
        end
        
        % Overwrite the specified options
        function [obj] = overwriteSpecifiedOptions( obj, varargin )
           
            k = 1;
            while k < numel( varargin{1} )

                % Check its in the options map
                if isKey( obj.optional_defaults , varargin{ 1 }{ k } )
                    
                    obj.optional_defaults( varargin{ 1 }{ k } ) = varargin{ 1 }{ k + 1 }; 
                    obj.set_options{ end + 1 } = varargin{ 1 }{ k };
                    
                    k = k + 1;
                    
                end
                
                k = k + 1;
                
            end
            
            % get the keys
            cellOfKeys = keys( obj.optional_defaults );

            % loop over the keys and assign the overwritten values
            for k = 1 : numel( cellOfKeys )
                
                key = cellOfKeys{ k };

                obj.input.(key) = obj.optional_defaults( key );

            end
            
        end    

        % Called at the end of the method calls.
        function [obj] = runAuditInfoMethods( obj )

            if true(obj.no_audit)
                return;
            end    
            
            obj.audit_info.setExecutionTime( );
            obj.audit_info.setFunctionStack( dbstack_convert( dbstack ) );
            obj.audit_info.setName( obj.class_name );
            obj.audit_info.setDescription( obj.class_description );
            obj.audit_info.setOptionalInputs( obj.set_options );
            obj.audit_info.setspectraStats( obj.input );
            obj.audit_info.writeToLogFile();
           % obj.audit_info.inputUsed = false;
           
        end
        
        function [obj] = isAddOnPack( obj )
            
           
            
        end    

        % Used for saving the hashes of the input vars.
        function [obj] = setCsmDataHash( obj, name, csm_data_hash )
           
            csm_data_hash_struct = struct;
            csm_data_hash_struct.name = name;
            csm_data_hash_struct.csm_data_hash = csm_data_hash;
                        
            obj.csm_data_hashes{ end + 1 } = csm_data_hash_struct;
            
        end

        % Assign the defaults
        function [obj] = assignDefaults ( obj )  end

        % Set the inputparser settings.
        function [obj] = parseInput( obj )	end

        % Calls the underlying base tool.
        function [obj] = callBaseTool( obj ) end

        % Parses the output of the base tool.
        function [obj] = parseOutput( obj ) end

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

