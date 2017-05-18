classdef csm_import_spectra_xcms < csm_import_spectra_base
% CSM_IMPORT_WORKER_XCMS - Import worker for XCMS format
%
% Usage:
%
% 	imported = csm_import_worker_xcms( 'filename', filename );
%
% Arguments:
%
%	filename : (str) The file to import.
%
% Returns:
%
%	imported : (csm_import_worker_xcms) Import worker with imported spectra.
%   imported.spectra : (csm_ms_spectra) Imported spectra object
%
% Description:
%
%	Import worker for importing from XCMS. Only imports MS objects.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016, 2016

% Author - Gordon Haggart 2016
 
    properties
       
        %ms_features;
        
    end    

    methods
        
        function [obj] = csm_import_spectra_xcms(varargin)
                     
            obj = obj@csm_import_spectra_base(varargin);
         
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.spec_type = 'ms';
            
            feature_columns = {'mzmed','mzmin','mzmax','rtmed','rtmin','rtmax','npeaks','QC','QCdil','Samples','CV'};
            
            data = importdata(obj.filename);
            
            tmp = data.textdata(:,1);
            
            mass_retention = tmp(2:end);
            
            features = containers.Map;
            features('mass/retention') = mass_retention;
            
            X_matrix = [];
            sample_ids = {};
            
            X_counter = 1;
            
            for i = 2 : size(data.textdata,2)
                
                col_name = strrep(data.textdata{1,i},'"','');
                col_pos = i - 1;
                
                if find(ismember(feature_columns,col_name)) > 0
               
                    features(col_name) = data.data(:,col_pos);
                    
                else
                    
                    sample_ids{ X_counter } = col_name;
                    X_matrix( X_counter , : ) = data.data(:,col_pos);
                    
                    X_counter = X_counter + 1;
                    
                end
            end
            
            ms_features = csm_ms_features();
            ms_features.features = features;
            ms_features.feature_identifiers = mass_retention;
            
            obj.spectra = csm_ms_spectra( X_matrix, mass_retention', 'mass/retention','sample_ids', sample_ids, 'ms_features', ms_features );
            
        end    
        
    end
    
end

