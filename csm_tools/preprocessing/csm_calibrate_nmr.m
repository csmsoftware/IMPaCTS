classdef csm_calibrate_nmr < csm_wrapper
% CSM_CALIBRATE_NMR - Calibrate raw NMR spectra
%
% Usage:
%
% 	model = csm_calibrate_nmr( spectra, type );
%
% 	model = csm_calibrate_nmr( spectra, type, 'circular_shift', circular_shift, 'reference_peak', reference_peak, 'search_range', search_range, 'kind', kind );
%
% Arguments:
%
%	*spectra : (csm_nmr_spectra) csm_nmr_spectra object containing spectral matrix.
%	*type : (str) 'glucose' (doublet at 5.233), 'TSP' (singlet at 0), 'single' (must specify search_range and reference_peak). 
%
%	circular_shift : (bool) Whether to perform circular shift. Default True.
%	reference_peak : (1*1) Override the default reference point to this value. Required for 'single' type.
%	search_range : (1*2) Override the default search range. Required for 'single' type.
%	kind : (str) Set to 'jres' to work on 2D spectra.
%
% Returns:
%
%	csm_calibrate_nmr : (csm_wrapper) stored inputs, model and auditInfo.
%	csm_calibrate_nmr.output.calibrated_spectra : (csm_nmr_spectra) Calibrated spectra.
%
% Description:
%
%	Utilises the JTPcalibrateNMR function written by Jake Pearce.
%	Calibration ensures the spectra align along a common scale.
%
%	By defualt aligns by shifting points of the left end of the spectra onto the right, or vice-versa.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        function [obj] = csm_calibrate_nmr( spectra, type, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
                        
            if ~spectra.isContinuous( )
                
               error( 'This function only works with continuous data' );
                
            end
            
            obj = assignDefaults( obj, spectra, type, varargin );
            
            obj = parseInput( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the defaults
        function [obj] = assignDefaults( obj, spectra, type, varargin )

            % Required arguments
            obj.input.spectra = spectra;
            obj.input.type = type;
            
            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'circular_shift' ) = 0.1;
            obj.optional_defaults( 'reference_peak' ) = csm_calibrate_nmr.getDefaultCalibrationReferencePeak(type);
            
            min = csm_calibrate_nmr.getDefaultCalibrationSearchMin(type);
            max = csm_calibrate_nmr.getDefaultCalibrationSearchMax(type);
            
            obj.optional_defaults( 'search_range' ) = [max,min];
            obj.optional_defaults( 'kind' ) = '1D';
            obj.optional_defaults( 'setLabels' ) = true;

            obj = overwriteSpecifiedOptions( obj , varargin{:} );

            % Set dependant defaults
         
            if strcmp( obj.input.type, 'single' )
                
                obj.input.base_type = 'TSP';
                    
            else
                
                obj.input.base_type = obj.input.type;
          
            end    
            
            if obj.input.circular_shift ~= 1

                obj.input.align = 'none';
                obj.input.circular_shift = 1;

            else
                
                obj.input.align = 'circular_shift';

            end
            
            if strcmpi( obj.input.kind , 'jres')
                
                obj.input.base_kind = 'J-RES';
                
            else
                
                obj.input.base_kind = obj.input.kind;
                
            end

        end
        
        function [obj] = parseInput ( obj )
            
            obj.inputparser = inputParser;
            
            expected_type = { 'glucose', 'TSP', 'single' };
            expected_kind = { '1D', 'jres' };
            
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'type' , @( x ) any( validatestring( x, expected_type ) ) );
            addRequired( obj.inputparser , 'reference_peak' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'search_range' , @( x ) ( numel( x ) ==  2 || isempty ( x ) ) );
            addRequired( obj.inputparser , 'kind' , @( x ) any( validatestring( x, expected_kind ) ) );
                                    
            parse( obj.inputparser, obj.input.spectra, obj.input.type, obj.input.reference_peak, obj.input.search_range, obj.input.kind );
                        
        end    


        % Call the mjrMainO2Pls function
        function [obj] = callBaseTool( obj )

            [ obj.tmp.ppm, obj.tmp.X ] = JTPcalibrateNMR( obj.input.base_type, obj.input.spectra.x_scale, obj.input.spectra.X, 'RefTo', obj.input.reference_peak, 'SearchRange', obj.input.search_range, 'Kind', obj.input.base_kind );

        end


        % Parse the model output
        function [obj] = parseOutput( obj )

            calibrated_spectra = obj.input.spectra;

            calibrated_spectra = calibrated_spectra.setName( 'csm_calibrate_nmr calibrated data' );
            calibrated_spectra = calibrated_spectra.setX( obj.tmp.X );

            calibrated_spectra = calibrated_spectra.setXScale( obj.tmp.ppm, 'ppm' );

            obj.output.calibrated_spectra = calibrated_spectra;

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end


    end

    methods (Static)

        % Get the default calibration ref point
        function [ calibration_reference_peak ] = getDefaultCalibrationReferencePeak( calibration_type )

            if strcmp( calibration_type, 'glucose' )

                calibration_reference_peak = 5.233;

            elseif strcmp( calibration_type, 'TSP' )

                calibration_reference_peak = 0;
                
            else
                
                calibration_reference_peak = 0;    

            end

        end

        % Get the default calibration search min point
        function [ calibration_search_min ] = getDefaultCalibrationSearchMin( calibration_type )

            if strcmp( calibration_type, 'glucose' )

                calibration_search_min = 4.9;

            elseif  strcmp( calibration_type, 'TSP' )

                calibration_search_min = -0.5;
                
            else
                
                calibration_search_min = 0;

            end

        end

        % Get the default calibration search max point
        function [ calibration_search_max ] = getDefaultCalibrationSearchMax( calibration_type )

            if strcmp( calibration_type, 'glucose' )

                calibration_search_max = 5.733;

            elseif strcmp( calibration_type, 'TSP' )

                calibration_search_max = 0.5;
                
            else
                
                calibration_search_max = 0;    

            end

        end



    end

end
