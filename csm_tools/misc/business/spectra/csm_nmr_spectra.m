
classdef csm_nmr_spectra < csm_spectra
%CSM_NMR_SPECTRA - CSM NMR spectra Data object.
%
% Usage:
%
% 	spectra = csm_nmr_spectra( X, ppm );
%
% 	spectra = csm_nmr_spectra( X, ppm, 'sample_type',sample_type,'pulse_program', pulse_program, 'name', name, 'is_continous', is_continuous, 'sample_ids', sample_ids, 'sample_metadata', sample_metadata, 'nmr_experiment_info', nmr_experiment_info, 'nmr_calibration_info', nmr_calibration_info );
%
% Arguments:
%
%	*X : (m*n) spectral matrix.
%	*ppm : (1*n) PPM Scale.
%	
%   name : (str) Name of the data structure.
%   is_continuous : (bool) Whether the x scale is continuous. Default true.
%	sample_ids : (cell) Sample IDs. Use the numeric index to match to the row. Default {}.
%	sample_metadata : (csm_sample_metadata) Metadata from import.
%   nmr_experiment_info : (csm_nmr_experiment_info ) NMR experiment info from import.
%   nmr_calibration_info : (csm_nmr_calibration_info) NMR calibration info from import.
%   pulse_program : (str) Shortened version of the pulseprogram. Default None.
%   sample_type : (str) Sample Type. Default None.
%
% Returns:
%
%	csm_nmr_spectra : (csm_nmr_spectra) Csm NMR spectra object.
%	csm_nmr_spectra.X : (m*n) spectral Matrix.
%	csm_nmr_spectra.ppm : (1*n) PPM Scale.
%	csm_nmr_spectra.name : (str) Name of the data structure.
%	csm_nmr_spectra.sample_ids : (cell) Sample IDs, using a numeric index.
%	csm_nmr_spectra.sample_metadata : (csm_import_sample_metadata) Sample Metadata from import.
%	csm_nmr_spectra.nmr_experiment_info : (csm_import_nmr_experiment_info) NMR Experiment Info from import.
%	csm_nmr_spectra.nmr_calibration_info : (csm_import_nmr_calibration_info) NMR Calibration Info from import.
%	csm_nmr_spectra.audit_info : (csm_audit_info) Audit Info object.
%
% Methods:
%   
%	csm_nmr_spectra.setX( X ) : Assign a new X matrix to the object. 
%	csm_nmr_spectra.setxScale( name, scale ) : Assign a new PPM to the object.
%   csm_nmr_spectra.importSampleInfo( sample_metadata_path ) : Import sample metadata.
%	csm_nmr_spectra.getSubSpectra( conditions ) : Return sub spec based on sampleInfo conditions. See description.
%	csm_nmr_spectra.addSpectra( spectra ) : Add a spectra object to this one.
%   csm_nmr_spectra.cutRegion( start , stop ) : Remove a section from start to stop.
%   csm_nmr_spectra.removeTSP() : Removes the section -0.2 to 0.2.
%   csm_nmr_spectra.removeWater() : Removes the section 4.669 to 4.9 by default. See description for more information.
%   csm_nmr_spectra.removeUrea() : Removes the section 5.48 to 6.23.
%
% Description:
%
%	NMR spectral Object. Contains X, PPM scale and various metadata.
%
%	Extends csm_spectra; see csm_spectra for more information.
%
%	csm_nmr_spectra.getSubSpectra( conditions ) will return a spectra based on the fields in sampleInfo.
%	conditions is the format {{ field, condition }}, and multiple conditions can be specified
%	ie:
%	conditions = {{ 'HistoScore', 'HS2' } ,{ 'RatNumber', '34' }}
%
%   csm_nmr_spectra.removeWater() will cur 4.7-4.9 ppm if sample_type = urine, 4.55-4.9
%   if serum/plasma or 4.699 to 4.9 by default. 
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties
       
        nmr_experiment_info;
        nmr_calibration_info;
        pulse_program;
        
    end    

    methods

        % Constructor
        function [obj] = csm_nmr_spectra( X, ppm, varargin )
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                X = [];
                ppm = [];
            end

            obj = obj @ csm_spectra( X, varargin );

            obj = setXScale( obj, ppm, 'ppm' );

            obj = setClassName( obj, class( obj ) );

        end
        
        % By default, NMR is continuous
        function [obj] = setIsContinuousDefault( obj )
           
            obj.is_continuous = true;
            
        end
        
        % NMR specific options
        function [obj] = setVarargin( obj, varargin )
            
            if numel( varargin ) == 0
               
                return;
                
            end 
            
            obj = setVarargin @ csm_spectra( obj, varargin{:} );
            
            k = 1;
            while k < numel( varargin{1}{:} )
                                
                % If it exists, set it
                if strcmp( varargin{1}{:}{k}, 'nmr_experiment_info')
                        
                    obj.nmr_experiment_info = varargin{1}{:}{k+1};
                    
                elseif strcmp( varargin{1}{:}{k}, 'nmr_calibration_info')
                        
                    obj.nmr_calibration_info = varargin{1}{:}{k+1};    
                    
                elseif strcmp( varargin{1}{:}{k}, 'pulse_program')
                    
                    obj.pulse_program = varargin{1}{:}{k+1};
                       
                end     
                
                k = k + 2;
                
            end   
            
        end
        
        function [obj] = removeTSP( obj )
           
            obj = cutRegion(obj,-0.2,0.2);
            
        end
        
        %if urine, cut 4.7-49?, ?if serum/plasma cut 4.55-4.9?, else cut 4.699 to 4.9
        function [obj] = removeWater( obj )
                        
            if strcmpi( obj.sample_type , 'urine')
                
                obj = cutRegion(obj,4.7,4.9);
            
            elseif ( strcmpi( obj.sample_type , 'serum') || strcmpi( obj.sample_type,'plasma') )
                
                obj = cutRegion(obj,4.55,4.9);
                
            else   
                
                obj = cutRegion(obj,4.669,4.9);
                
            end    
            
        end
        
        function [obj] = removeUrea( obj )
           
            obj = cutRegion(obj,5.48,6.23);
            
        end
        
        function [obj] = cutRegion(obj,start,stop)
            
           obj.X = [ obj.X( :, 1: find( obj.x_scale >= start, 1,'first') ) , obj.X( :, find( obj.x_scale >= stop, 1,'first'):end)];
           obj.x_scale = [ obj.x_scale(: , 1: find( obj.x_scale >= start, 1, 'first') ), obj.x_scale(:, find( obj.x_scale >= stop, 1, 'first') : end) ];
 
           fprintf('Peak removed from %.2f:%.2f ppm\n',start,stop)
            
        end    

    end    

end
