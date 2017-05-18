classdef csm_export_spectra_base
% CSM_IMPORT_WORKER_BASE - Base class for migration code
%
% Arguments:
%
%	*spectra : (csm_spectra) CSM spectra object.
%	
%   filename : (str) The file to import.
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
        spectra;
        spectra_class;
        
    end    

    methods

        % Constructor for csm_migration
        function [obj] = csm_export_spectra_base( spectra, varargin )
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            obj.spectra = spectra;
            
            obj.spectra_class = class( spectra );
            
            % Set the output filename
            found = false;
            k = 1;
            
            while k < numel( varargin{1} )
                
                % If it exists, set it and break
                if strcmp( varargin{1}{k}, 'filename')
                    
                    obj.filename = varargin{1}{k+1} ;
                    
                    found = true;
                    break;
                    
                end
                
                k = k + 1;
                
            end
            
            if ~found
                
                [FileName,PathName,~] = uiputfile({'*.hdf'},'Save file name');
                obj.filename = strcat(PathName,FileName);
                
            end    
            
        end
        
        
    end
    
    methods (Static)
        
      % function import_ms( ) end
     %  function import_nmr( ) end
         
    end

end
