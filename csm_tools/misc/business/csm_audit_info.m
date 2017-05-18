classdef csm_audit_info < matlab.mixin.Copyable
%CSM_AUDIT_INFO - Builds and stores the auditInfo for csm_model, csm_figure and csm_data
%
% Usage:
%
%	auditInfo = csm_audit_info( )
%
% Arguments:
%
%	is_empty : (bool) Create an empty object. Used for high throughput workfows and data import.
%
% Returns:
%
%	csm_audit_info.function_stack : (struct) The function stack of where the object wascreated.
%	csm_audit_info.datetime_created : (str) The datetime the object wascreated.
%	csm_audit_info.execution_time : (1*1) The amount of time the object took to build.
%	csm_audit_info.csm_toolbox_version : (str) What toolbox version was used.
%	csm_audit_info.matlab_version : (str) What matlab version was used.
%	csm_audit_info.operating_system : (str) What operating system was used.
%	csm_audit_info.username : (str) The username of the person who built the object.
%	csm_audit_info.registered_email : (str) The registered email.
%	csm_audit_info.description : (str) The description of the object.
%	csm_audit_info.function_name : (str) The name of the object.
%	csm_audit_info.set_options : (str) The optional inputs used.
%	csm_audit_info.licence_number : (str) The Matlab licence number.
%	csm_audit_info.java_version : (str) The java version used.
%	csm_audit_info.installed_toolboxes : (str) The toolboxes installed.
%	csm_audit_info.spec_stats : (str) Stats about the spectra.
%	csm_audit_info.headless_mode : (str) Whether it's a headless session.
%
% Methods:
%
%   csm_audit_info.writeToUsageLog() : Write to the usage log.
%	csm_audit_info.setToolboxVersion() : Set the toolbox version.
%	csm_audit_info.setMatlabVersion() : Set the matlab version.
%	csm_audit_info.setOperatingSystem() : Set the operating system.
%	csm_audit_info.setUsername() : Set the username.
%	csm_audit_info.setDatetime() : Set the datetime.
%	csm_audit_info.setExecutionTime() : Set the execution time.
%	csm_audit_info.setFunctionStack() : Set the function stack.
%	csm_audit_info.setFunctionName() : Set the function name.
%	csm_audit_info.setDescription() : Set the description.
%	csm_audit_info.setOptionalInputs() : Set the optional inputs used.
%	csm_audit_info.setLicenceNumber() : Set The Matlab licence number.
%	csm_audit_info.setJavaVersion() : Set the java version used.
%	csm_audit_info.setInstalledToolboxes() : Set the toolboxes installed.
%	csm_audit_info.setspectraStats() : Set stats about the spectra.
%	csm_audit_info.setHeadlessMode() : Set whether it's a headless session.
%
% Description:
%
%	See csm_wrapper for examples on using this object.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        function_stack;
        datetime_created;
        execution_time;
        csm_toolbox_version;
        matlab_version;
        operating_system;
        username;
        registered_email;
        description;
        function_name;
        set_options;
        licence_number;
        java_version;
        installed_toolboxes;
        spec_stats;
        headless_mode;
        
    end

    methods

        % Constructor
        function [obj] = csm_audit_info( varargin )
            
            % If is_empty, return empty object
            if nargin > 0
                if strcmp( varargin{1}, 'is_empty') & true( varargin{2})
                    return;
                end            
            end    
           
            obj = setToolboxVersion( obj );
            obj = setMatlabVersion( obj );
            obj = setOperatingSystem( obj );
            obj = setUsername( obj );
            obj = setDatetime( obj );
            obj = setLicenceNumber( obj );
            obj = setInstalledToolboxes( obj );
            obj = setJavaVersion( obj );
            obj = setHeadlessMode( obj );
         
        end
        
        function [obj] = setspectraStats( obj, input )
           
            if isfield(input,'spectra')
                
                obj.spec_stats = struct;
                obj.spec_stats.spec_type = class(input.spectra);
                obj.spec_stats.X_dimensions = size(input.spectra.X);
                obj.spec_stats.x_scale_length = size(input.spectra.x_scale);
                obj.spec_stats.sample_id_length = size(input.spectra.sample_ids);
                                
            end
                        
        end 
        
        function [obj] = setHeadlessMode( obj )
            
           if (usejava('desktop') == 0)
               
               obj.headless_mode = 'yes';
               
           else
               
               obj.headless_mode = 'no';
               
           end    
            
        end
        
        function [obj] = setLicenceNumber( obj )
            
           obj.licence_number = license; 
            
        end
        
        function [obj] = setInstalledToolboxes( obj )
           
            obj.installed_toolboxes = ver;
            
        end    
        
        function [obj] = setJavaVersion( obj )
            
           obj.java_version = version('-java'); 
            
        end        

        % Sets the toolbox version out of the settings.
        function [obj] = setToolboxVersion( obj )

            obj.csm_toolbox_version = csm_settings.getValue('toolbox_version');
            
        end	
        
        % Sets the current matlab version
        function [obj] = setMatlabVersion( obj )

            obj.matlab_version = version;

        end

        % Sets the operating system
        function [obj] = setOperatingSystem( obj )

            obj.operating_system = computer;

        end

        % Sets the username, depending on the OS
        function [obj] = setUsername( obj )

            switch computer

                case 'MACI64'

                    obj.username = getenv( 'USER' );

                case 'GLNXA64'

                    obj.username = getenv( 'USER' );

                case 'PCWIN'

                    obj.username = getenv( 'USERNAME' );

                case 'PCWIN64'

                    obj.username = getenv( 'USERNAME' );

            end

        end

        % Sets the current time
        function [obj] = setDatetime( obj )

            obj.datetime_created = datestr( now );

        end

        % Calculates the time taken to execute
        function [obj] = setExecutionTime( obj )

            obj.execution_time = etime( clock, datevec( obj.datetime_created ) );

        end

        % Set the function stack
        function [obj] = setFunctionStack( obj, stack )

            obj.function_stack = stack;

        end
        
        % Set what optional variables were used
        function [obj] = setOptionalInputs( obj, set_options )
            
            obj.set_options = set_options;
            
        end    
        
        % Set the name of the object
        function [obj] = setName( obj, function_name )
           
            obj.function_name = function_name;
            
        end    

        % Set the description of the object 
        function [obj] = setDescription( obj, description )
           
            obj.description = description;
            
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
        
        function [obj] = writeToLogFile( obj )
            
            return;

            % Only record if collect stats is on.
            if strcmp(csm_settings.getValue('collect_stats'),'off')
                return;
            end    
            
            logstruct = struct;
            
            now = strcat('id_', datestr(datevec(datetime('now')),'ddmmyyHHMMSSFFF',2000));
            
            logstruct.(now) = struct;
            logstruct.(now).datetime_created = obj.datetime_created;
            logstruct.(now).execution_time = obj.execution_time;
            logstruct.(now).csm_toolbox_version = obj.csm_toolbox_version;
            logstruct.(now).matlab_version = obj.matlab_version;
            logstruct.(now).operating_system = obj.operating_system;
            logstruct.(now).username = obj.username;
            logstruct.(now).function_name = obj.function_name;
            logstruct.(now).function_stack = obj.function_stack;
            logstruct.(now).set_options = obj.set_options;
            logstruct.(now).licence_number = obj.licence_number;
            logstruct.(now).java_version = obj.java_version;
            logstruct.(now).installed_toolboxes = obj.installed_toolboxes;
            logstruct.(now).spec_stats = obj.spec_stats;
           % logstruct.logEntry.workspaceData = obj.workspaceData;
            
            [folder, ~, ~] = fileparts(which('csm_settings'));
            
            yaml.WriteYaml( strcat( folder , '/usage_log.yaml'), logstruct, 1 );
                        
        end
        
        
    end

end
