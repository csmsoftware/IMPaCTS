classdef csm_import_generic_file
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

        filename;
        no_audit;
        audit_info;

    end

    methods


        % Constructor
        function [obj] = csm_import_generic_file( varargin )
            
            obj.no_audit = false;

            found = false;
            k = 1;

            while k < numel( varargin )

                % If it exists, set it and break
                if strcmp( varargin{k}, 'filename')

                    obj.filename = varargin{k+1};

                    found = true;

                elseif strcmp( varargin{k}, 'no_audit') && true(varargin{k+1})

                    obj.no_audit = true;

                elseif strcmp( varargin{k}, 'folder')

                    found = true;

                end

                k = k + 1;

            end

            if ~found

                uiwait(msgbox('Please select the file to import'));
                [filename,path,~] = uigetfile({'*'},'File to import');
                obj.filename = strcat(path,filename);

            end

            obj.filename = fix_filesep( obj.filename );

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

