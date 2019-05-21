classdef csm_stocsy < csm_wrapper
% CSM_STOCSY - Performs STOCSY analysis on X by peak intensity variable defined by the chemical shift driver_peak.
%
% Usage:
%
% 	model = csm_stocsy( spectra, driver_peak );
%
% 	model = csm_stocsy( spectra, driver_peak, 'p' , p , 'corr_metric' , corr_metric );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*driver_peak : (1*1) Chemical shift value of target intensity variable.
%
%	p : (1*1) p-value threshold for null hypothesis of no correlation. Default 0.1.
%	corr_metric : (str) Correlation coefficient measure - 'pearson' or 'spearman'. Default 'pearson'.
%
% Returns:
%
%	csm_scale : (csm_wrapper) Object with some stored inputs, the outputs and auditInfo.
%	csm_stocsy.output.cc : (m*1) Correlation coefficients between NMR and peakID
%
% Description:
%
%	Utilises the STOCSY function written by Kirill Veselkov
%
% Reference:
%
%   Olivier Cloarec, Marc-Emmanuel Dumas, Andrew Craig, Richard H. Barton, Johan Trygg, Jane Hudson, Christine Blancher, Dominique Gauguier, John C. Lindon, Elaine Holmes, and Jeremy Nicholson
%   Statistical Total Correlation Spectroscopy:?An Exploratory Approach for Latent Biomarker Identification from Metabolic 1H NMR Data Sets
%   Analytical Chemistry, 2005, 77 (5), pp 1282?1289
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

	methods

		% Constructor for csm_stocsy
		function [obj] = csm_stocsy( spectra, driver_peak, varargin )

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
            obj.optional_defaults( 'p' ) = 0.1;
            obj.optional_defaults( 'corr_metric' ) = 'pearson';

            obj = overwriteSpecifiedOptions( obj , varargin{:} );
               
        end
	
		% Assign the input expected values
		function [obj] = parseInput( obj )

			obj.inputparser = inputParser;

			expected_corr_metric = { 'spearman', 'pearson' };

    		addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
			addRequired( obj.inputparser , 'driver_peak' , @( x ) isnumeric( x ) );
			addRequired( obj.inputparser , 'p' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'corr_metric' , @( x ) any( validatestring( x, expected_corr_metric ) ) );

			parse( obj.inputparser, obj.input.spectra, obj.input.driver_peak, obj.input.p, obj.input.corr_metric);

		end


		% Call the STOCSY function
		function [obj] = callBaseTool( obj )

			obj.tmp.cc = STOCSY( obj.input.spectra.X, obj.input.spectra.x_scale, obj.input.driver_peak, obj.input.p, obj.input.corr_metric );

		end

		% Parse the model output
		function [obj] = parseOutput( obj )

			obj.output.cc = obj.tmp.cc;
			
			obj.tmp = '';

		end

		% Run the auditInfo methods (must be run)
		function [obj] = runAuditInfoMethods( obj )

			obj.class_name = class( obj );

			runAuditInfoMethods @ csm_wrapper( obj );

		end	

	end

end

