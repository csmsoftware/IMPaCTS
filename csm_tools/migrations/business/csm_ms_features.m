classdef csm_ms_features
%CSM_MS_FEATURES Container for MS features
%
% Usage:
%
%	ms_features = csm_ms_features( )
%
% Returns:
%
%   ms_features : (containers.Map) Map container of the features.
%
% Methods:
%
%	csm_ms_features.addMSFeature ( obj, featureIdentifier, featureName,	featureValue ) : Add an MS feature.
%
% Description:
%
%	Container for the MS feature information.
%   
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014 

% Author - Gordon Haggart 2014
    
    properties
        
        features;
        feature_identifiers;
        
    end
       
    methods
        
        function [obj] = csm_ms_features()
            
           obj.features = containers.Map; 
            
        end    
        
        % Returns a table of the features.
        function [table] = getTable( obj )
            
            feature_types = keys( obj.features );
            
            colNames = {};
            cellArr = {};
            
            for i = 1 : length( feature_types )
                
                feature = obj.features( feature_types{ i } );
                
                field_name = strrep( feature_types{ i }, '/', '_' );
                
                field_name = strrep( field_name, ' ', '_' );
                
                field_name = strrep( field_name, '-', '_' );
                
                field_name = strrep( field_name, '(', '' );
                
                field_name = strrep( field_name, ')', '' );
                
                field_name = strrep( field_name, '%', '_percent' );
                
                colNames{ end + 1 } = field_name;
                
                for p = 1 : size(feature,2)
                
                    cellArr{ p, i } = feature{ p };
                    
                end
                
            end
            
            table = cell2table( cellArr );
                        
            table.Properties.VariableNames = colNames;
            
        end   
                
    end
    
end

