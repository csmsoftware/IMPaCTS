classdef csm_import_generic_folder
% CSM_IMPORT_GENERIC_CLASS - CSM Import Generic Class
%
% Description:
%
%	Extend for generic imports. Has useful properties and methods.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        folder;
        no_audit;
        audit_info;

    end

    methods


        % Constructor
        function [obj] = csm_import_generic_folder( varargin )
            
            obj.no_audit = false;

            found = false;
            k = 1;

            while k < numel( varargin )

                if strcmp( varargin{k}, 'no_audit') && true(varargin{k+1})
                    
                    obj.no_audit = true;
                    
                elseif strcmp( varargin{k}, 'folder')
                    
                    found = true;
                    obj.folder = varargin{k+1};

                end

                k = k + 2;

            end

            if ~found
                
                uiwait(msgbox('Please select the folder to import'));
                obj.folder = uigetdir(csm_settings.getValue('workspace_path'),'Folder to import');

            end

            obj.folder = fix_filesep( obj.folder );

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

