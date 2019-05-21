classdef csm_stocsye < csm_wrapper
% CSM_STOCSYE - STOCSY editing, STOCSY editing scales highly correlated peaks to remove unwanted signals from NMR spectral data
%
% Usage:
%
% 	model = csm_stocsye( spectra, driver_peak );
%
% 	model = csm_stocsye( spectra, driver_peak, 'stocsy_cutoff', stocsy_cutoff, 'correlations', correlations, 'noise_region', noise_region, 'local_baseline_region', local_baseline_region, 'mode', mode );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*driver_peak : (m*1) Chemical shift value of target intensity variable, vector for multiple peaks.
%
%	stocsy_cutoff : (1*1) Correlation threshold above which( |r| > stocsy_cutoff ) associations are presented. Default 0.9.
%	correlations : (str) 'all' to include both positive and negative, 'pos' to only include positive. Default 'pos'.
%	noise_region : (1*2) Noise region for ppm. Default [9.5, 10].
%	local_baseline_region : (1*1) PPM region around peak to find local baseline. Default 0.02.
%	mode : (str) 'by_sample' calculates region to scale and replace for each sample, 'by_mean' calculates mean spectrum and uses for all samples. Default 'by_sample'.
%
% Returns:
%
%	model : (obj) csm_wrapper with some stored inputs, the outputs and auditInfo.
%	model.output.edited_X : (m*n) Scaled and background-corrected STOCSYE data.
%	model.output.cor : (m*n) Squared correlation vectors for each peak. n = number of driver_peaks
%
% Description:
%
%	STOCSY editing scales highly correlated peaks to remove unwanted signals (for example, from drug compounds) from NMR spectral data
%   STOCSY editing scales peaks by their correlation coefficient to the driver_peak.
%   This allows highly correlated peaks (above a certain threshold) to be removed from the spectrum.
%   However, where peak overlap results in decreased correlation, after scaling, the remaining peaks can be helpful in deconvolving for example, endogenous from removed exogenous signal
%
% Reference:
%
%   Caroline J. Sands, Muireann Coen, Anthony D. Maher, Timothy M. D. Ebbels, Elaine Holmes, John C. Lindon and Jeremy Nicholson
%   Statistical Total Correlation Spectroscopy Editing of 1H NMR Spectra of Biofluids: Application to Drug Metabolite Profile Identification and Enhanced Information Recovery
%   Analytical Chemistry, 2009, 81 (15), pp 6458?6466
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

	methods

		% Constructor for csm_stocsye
		function [obj] = csm_stocsye( spectra, driver_peak, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

			obj = assignDefaults( obj, spectra, driver_peak, varargin );

            obj = parseInput ( obj );

			obj = callBaseTool( obj );

			obj = runAuditInfoMethods( obj );

			obj = parseOutput( obj );

		end

		% Assign the inputs and default options
		function [obj] = assignDefaults( obj, spectra, driver_peak, varargin )

			% Required arguments
			obj.input.spectra = spectra;
			obj.input.driver_peak = driver_peak;
            
            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'stocsy_cutoff' ) = 0.9;
            obj.optional_defaults( 'correlations' ) = 'pos';
            obj.optional_defaults( 'noise_region' ) = [ 9.5, 10 ];
            obj.optional_defaults( 'local_baseline_region' ) = 0.02;
            obj.optional_defaults( 'mode' ) = 'by_sample';

            obj = overwriteSpecifiedOptions( obj , varargin{:} );

		end

		 % Assign the input expected values
		function [obj] = parseInput( obj )

			obj.inputparser = inputParser;

			expected_correlations = { 'all', 'pos' };
			expected_mode = { 'by_sample', 'by_mean' };

			addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
			addRequired( obj.inputparser , 'driver_peak' , @( x ) isnumeric( x ) );
			addRequired( obj.inputparser , 'stocsy_cutoff' , @( x ) isnumeric( x ) );
			addRequired( obj.inputparser , 'correlations' , @( x ) any( validatestring( x, expected_correlations ) ) );
			addRequired( obj.inputparser , 'noise_region' , @( x ) isnumeric( x ) );
			addRequired( obj.inputparser , 'local_baseline_region' , @( x ) isnumeric( x ) );
			addRequired( obj.inputparser , 'mode' , @( x ) any( validatestring( x, expected_mode ) ) );
			
			parse( obj.inputparser, obj.input.spectra, obj.input.driver_peak, obj.input.stocsy_cutoff, obj.input.correlations, obj.input.noise_region, obj.input.local_baseline_region, obj.input.mode);

		end


		% Call the STOCSY function
		function [obj] = callBaseTool( obj )

			[ obj.tmp.edited_X, obj.tmp.corr, ~ ]  = STOCSYE( obj.input.spectra.X, obj.input.spectra.x_scale, obj.input.driver_peak, obj.input.stocsy_cutoff, obj.input.correlations, obj.input.noise_region, obj.input.local_baseline_region, obj.input.mode );
			
		end

		% Parse the model output
		function [obj] = parseOutput( obj )
			    	
			obj.output.edited_X = obj.tmp.edited_X;
			obj.output.corr = obj.tmp.corr;
			
			obj.tmp = '';

		end

		% Run the auditInfo methods (must be run)
		function [obj] = runAuditInfoMethods( obj )

			obj.class_name = class( obj );

			runAuditInfoMethods @ csm_wrapper( obj );

		end	

	end

end

