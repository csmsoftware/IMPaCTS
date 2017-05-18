
classdef csm_ms_spectra < csm_spectra
%CSM_MS_SPECTRA - CSM MS spectra Data object.
%
% Usage:
%
% 	spectra = csm_ms_spectra( X, x_scale, x_scale_name );
%
% 	spectra = csm_ms_spectra( X, x_scale, x_scale_name, 'ms_type', ms_type, 'name', name, 'is_continous', is_continuous, 'sample_ids', sample_ids, 'sample_metadata', sample_metadata, 'ms_features', ms_features );
%
% Arguments:
%
%	*X : (m*n) spectral matrix.
%	*x_scale : (1*n) X Scale, the X scale used in this dataset, ie retentionTime_mz.
%   *x_scale_name : (str) The name of X scale, ie 'retentionTime_mz'.
%
%   ms_type : (str) The type of MS, 'LC-MS', 'HPLC-MS', 'GC-MS', 'UPLC-MS', 'Direct Injection','HPLC-MS'.
%   name : (str) Name of the data structure.
%   is_continuous : (bool) Whether the x scale is continuous. Default true.
%	sample_ids : (cell) Sample IDs, Use the numeric index to match to the row. Default {}.
%	csm_sample_metadata : (csm_sample_metadata) Sample Metadata. Default [].
%   ms_features : (map) Container of features. Default empty.
%
% Returns:
%
%	csm_ms_spectra : (csm_ms_spectra) CSM MS spectra object.
%	csm_ms_spectra.X : (m*n) spectral Matrix.
%	csm_ms_spectra.x_scale : (1*n) PPM Scale.
%   csm_ms_spectra.name : (str) Name of the object.
%	csm_ms_spectra.sample_ids : (cell) Sample IDs, using a numeric index.
%	csm_ms_spectra.sample_metadata : (csm_import_sample_metadata) Metadata from import.
%	csm_ms_spectra.auditInfo : (csm_audit_info) Audit Info object.
%   csm_ms_spectra.ms_features : (csm_ms_features) Container of features. Default empty.
%
% Methods:
%   
%
% Description:
%
%	MS spectral Object. Contains X, X scale and various metadata.
%   ms_features object is accessed using the identifier specified in the
%   x_scale and x_scale_name. It's up to you make sure you do this correctly.
%
%	Extends csm_spectra; see csm_spectra for more information.
%
%	csm_nmr_spectra.getSubSpectra( conditions ) will return a spectra based on the fields in sample_metadata.
%	conditions is the format {{ field, condition }}, and multiple conditions can be specified
%	ie:
%	conditions = {{ 'HistoScore', 'HS2' } ,{ 'RatNumber', '34' }}
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014 

% Author - Gordon Haggart 2014

    properties
       
        ms_type;
        ms_features;
        
    end    

    methods

        % Constructor
        function [obj] = csm_ms_spectra( X, x_scale, x_scale_name, varargin )

            % Allows creation of empty objects for cloning
            if nargin == 0
                X = [];
                x_scale = [];
                x_scale_name = '';
            end
                            
            obj = obj @ csm_spectra( X, varargin );
            
           % checkInput( obj, ms_type );
            
           % obj.ms_type = ms_type;
            
            obj = setXScale( obj, x_scale, x_scale_name );
            
            obj = setFeatureContainer( obj, varargin );
            
            obj = setClassName( obj, class( obj ) );

        end
        
        function [obj] = setFeatureContainer( obj, varargin )
            
            isSet = false;
            k = 1;
            while k <= numel( varargin{1} )
                
                % If it exists, set it and break
                if strcmp( varargin{1}{k}, 'ms_features')
                    
                    isSet = true;
                    
                    obj.ms_features = varargin{1}{k+1};
                   
                    % Check the input is of correct type.
                    inputparser = inputParser;
                    addRequired( inputparser , 'ms_features' , @( x ) isa(obj.ms_features,'csm_ms_features' ));
                    parse( inputparser, obj.ms_features );
                   
                    break;
                    
                end
                
                k = k + 1;
                
            end
            
        end    
        
        function [obj] = checkInput( obj, ms_type )
            
            inputparser = inputParser;

            expected_msTypes = { 'LC-MS', 'HPLC-MS', 'GC-MS', 'UPLC-MS', 'Direct Injection','HPLC-MS' };

            addRequired( inputparser , 'msTypes' , @( x ) any( validatestring( x, expected_msTypes ) ) );

            parse( inputparser, ms_type );
            
        end  

    end    

end
