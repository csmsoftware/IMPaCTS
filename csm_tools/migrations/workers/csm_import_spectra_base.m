classdef csm_import_spectra_base
% CSM_IMPORT_WORKER_BASE - Base class for migration code
%
% Arguments:
%
%	*spec_type : (str) spectra type. 'MS' or 'NMR'.
%	*filename : (str) The file to import.
%
% Description:
%
%	Extend this class when creating a new migration method.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties
       
        filename;
        imported_data;
        spectra;
        spec_type;
        spectra_class;
        
    end    

    methods

        % Constructor for csm_migration
        function [obj] = csm_import_spectra_base( varargin )
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            % Set the output filename
            found = false;
            k = 1;
            
            while k < numel( varargin{1} )
                
                % If it exists, set it and break
                if strcmp( varargin{1}{k}, 'filename')
                    
                    obj.filename = varargin{1}{k+1};
                    
                    found = true;
                
                elseif strcmpi( varargin{1}{k}, 'spec_type')
                    
                    obj.spec_type = varargin{1}{k+1};    
                    
                end
                                
                k = k + 1;
                
            end
            
            if ~found
                
                uiwait(msgbox('Please select the file to import'));
                [filename,path,~] = uigetfile({''},'File to import');
                obj.filename = strcat(path,filename);
                
            end
           
                       
        end
        
        
    end
    
end
