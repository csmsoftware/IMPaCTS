classdef csm_settings
%CSM_SETTINGS - CSM Toolbox settings methods
%
% Usage:
%
%   csm_settings.loadSettings();
%   properties = csm_settings.setting_fields;
%   property_value = csm_settings.getValue(property_name);
%   csm_settings.setValue(property_name,property_value);
%   csm_settings.isDev();
%   csm_settings.checkLicence();
%
% Methods:
%
%   csm_settings.loadSettings() : Reloads the settings into memory.
%	csm_settings.getValue() : Get the current value of the setting field.
%   csm_settings.setValue(property_name,property_value) : Save the value into the config file.
%	csm_settings.isDev() : Check whether on development environment.
%	csm_settings.checkLicence() : Checks the user is licenced.
%
% Description:
%
%	CSM Settings class. See methods.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

    properties (Constant)

        setting_fields = {  'workspace_path',...
                            'toolbox_path',...
                            'registered_email',...
                            'licence_last_checked',...
                            'toolbox_version',...
                            'unit_test_path',...
                            'test_data_path',...
                            'licence_server',...
                            'dev_version',...
                            'collect_stats'};
        
    end    

    methods (Static)
        
        function [csm_config] = loadSettings( )
                    
            [folder, ~, ~] = fileparts(which('csm_settings'));
            csm_config = yaml.ReadYaml( strcat( folder , '/config.yaml'));
            
            assignin('base','csm_config',csm_config);
                        
        end
        
        function [value] = getValue(field)
            
            if find(ismember(csm_settings.setting_fields,field)) > 0
                
                if evalin('base','exist(''csm_config'')')
                
                    csm_config = evalin('base','csm_config');
                
                else
                    
                    csm_config = csm_settings.loadSettings();
                
                end
                
                value = csm_config.(field);
                
            end    
            
        end
        
        % Sets the value and updates the loaded settings
        function setValue(field,value)
            
            [folder, ~, ~] = fileparts(which('csm_settings'));
            
            csm_config = yaml.ReadYaml( strcat( folder , '/config.yaml'));

            csm_config.(field) = value;

            yaml.WriteYaml( strcat( folder , '/config.yaml'), csm_config);
            
            assignin('base','csm_config',csm_config);
            
        end
        
        % Is this development?
        function [bool] = isDev()
           
            if strcat(csm_settings.getValue('dev_version'), 'yes')
                bool = true;
            else
                bool = false;
            end    
            
        end    
        
        % Checks the licence server every 2 days.
        % Submits usage statistics
       % function checkLicence( )
            
       %     csm_settings.loadSettings();
            
       % end    
        
    end
    
end

