classdef csm_istocsy < csm_wrapper
% CSM_ISTOCSY - Automated iterative STOCSY on X by peak intensity variable defined by the chemical shift driver_peak.
%
% Usage:
%
% 	model = csm_istocsy( spectra, driver_peak, 'peak_inds', peak_inds, 'istocsy_cutoff', istocsy_cutoff, 'structural_cutoff', structural_cutoff, 'n_rounds', n_rounds, 'save_name', save_name, 'plot_method', plot_method )
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*driver_peak : (1*1) Chemical shift value of target intensity variable.
%
%	peak_inds : (1*n) Peak picked indices, if not included peak list generated through detection at zero crossings of a smoothed spectral derivative calculated using a Savitzky-Golay third order polynomial filter of the mean spectrum. Default [].
%	istocsy_cutoff : (1*1) Correlation threshold above which( |r| > istocsy_cutoff ) associations are presented. Default 0.8.
%	structural_cutoff : (1*1) For each set of newly identified peaks at each round, groups those which correlate with absolute value > structural_cutoff. Default 0.95.
%	n_rounds : (1*1) Number of iterations. Default 10.
%	save_name : (str) Name for saving results and plots.
%	plot_method : (str) Colour scale for plot. 'all' colours from -1 to 1, else colours on scale from min to max corr. Default 'all'.
%
% Returns:
%
%	csm_istocsy : (csm_wrapper) Object with some stored inputs, the outputs and auditInfo.
%	csm_istocsy.output.results : (m*2) Results of which peaks where detected in each round. Columns correspond to round | index or representative peak.
%	csm_istocsy.output.sets : (m*n) 'structural' or highly related sets, each row contains the indices of highly related peaks (represented by one node in the interactive plot).
%	csm_istocsy.output.connections : (m*n) 'structural' or highly related sets, each row contains the indices of highly related peaks (represented by one node in the interactive plot).
%	csm_istocsy.output.correlates : (m*n) Node connectivities; for each row, the first number corresponds to the driver node, and subsequent values to those connected nodes (where all numbers relate to row indices in the results matrix).
%	csm_istocsy.output.peaks_plot : (m*n) Plotting peaks information, each row corresponds to a row in connections, and all peaks from the same structural set have the same index.
%	csm_istocsy.output.all_peaks_plot : (1*n) All identified peaks.
%	csm_istocsy.output.round_peaks_plot : (m*n) Peaks identified in each round -( rows = n_rounds ).
%	csm_istocsy.output.plot_xy : (m*2) x and y locations for each node in the interactive plot.
%
% Description:
%
%	Iterates multiple rounds of STOCSY initially from a given driver peak of interest.
%	In subsequent rounds from all peaks correlating above a certain threshold to driver/s in the previous round. 
%	Highly correlating (putatively structural) peaks are grouped together and the results automatically plotted in the istocsy_iplot interactive plot (showing node-to-node associations alongside the corresponding spectral data)
%
% Reference:
%
%   Sands CJ, Coen M, Ebbels TM, Holmes E, Lindon JC, Nicholson JK.
%   Data-driven approach for metabolite relationship recovery in biological 1H NMR data sets using iterative statistical total correlation spectroscopy.
%   Analytical Chemistry 2011 Mar 15;83(6):2075-82
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016
	
	properties

		tmpIn;
		classDescription = 'CSM ISTOCSY model generated using ISTOCSY function';

	end	

	methods

		% Constructor for csm_istocsy
		function [obj] = csm_istocsy( spectra, driver_peak, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

			obj = assignDefaults( obj, spectra, driver_peak, varargin );

            obj = parseInput( obj );

			obj = callBaseTool( obj );

			obj = runAuditInfoMethods( obj );

			obj = parseOutput( obj );

		end

		% Assign the inputs and default options
		function [obj] = assignDefaults( obj, spectra, driver_peak, varargin )

			% Required arguments
			obj.input.spectra = spectra;
			obj.input.driver_peak = driver_peak;

			% Optional arguments with defaults
            obj.optional_defaults( 'peak_inds' ) = [];
            obj.optional_defaults( 'n_rounds' ) = 10;
			obj.optional_defaults( 'istocsy_cutoff' ) = 0.8;
            obj.optional_defaults( 'structural_cutoff' ) = 0.95;
			obj.optional_defaults( 'save_name' ) = '';
            obj.optional_defaults( 'plot_method' ) = 'all';
		
			% Loop over the varargin and overwrite the optional defaults
			obj = overwriteSpecifiedOptions( obj , varargin{:} );

		end


        % Assign the input expected values
		function [obj] = parseInput( obj )

            obj.inputparser = inputParser;

            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'driver_peak' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'peak_inds' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'n_rounds' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'istocsy_cutoff' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'structural_cutoff' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'plot_method' , @( x ) isstr( x ) );
            addRequired( obj.inputparser , 'save_name' , @( x ) isstr( x )||isempty( x ) );

            parse( obj.inputparser, obj.input.spectra, obj.input.driver_peak,obj.input.peak_inds,obj.input.n_rounds,obj.input.istocsy_cutoff,obj.input.structural_cutoff,obj.input.plot_method,obj.input.save_name);

        end


		% Call the ISTOCSY function
		function [obj] = callBaseTool( obj )

			obj.tmpIn = struct;
            obj.tmpIn.peak_inds = obj.input.peak_inds;
			obj.tmpIn.ISTOCSY_cutoff = obj.input.istocsy_cutoff;
			obj.tmpIn.struct_cutoff = obj.input.structural_cutoff;
			obj.tmpIn.Nrounds = obj.input.n_rounds;
			obj.tmpIn.name = obj.input.save_name;
			obj.tmpIn.plot_method = obj.input.plot_method;

			obj.tmp = ISTOCSY( obj.input.spectra.X, obj.input.spectra.x_scale,obj.input.driver_peak, obj.tmpIn );

		end

		% Parse the model output
		function [obj] = parseOutput( obj )

			obj.output.results = obj.tmp.results;
			obj.output.sets = obj.tmp.sets;
			obj.output.connections = obj.tmp.connections;
			obj.output.peaks_plot = obj.tmp.peaksplot;
			obj.output.correlations = obj.tmp.correlations;
			obj.output.all_peaks_plot = obj.tmp.allpeaksplot;
			obj.output.round_peaks_plot = obj.tmp.roundpeaksplot;
			obj.output.plot_xy = obj.tmp.plot_xy;

			obj.tmp = '';

		end

		% Run the auditInfo methods (must be run)
		function [obj] = runAuditInfoMethods( obj )

			obj.class_name = class( obj );

			runAuditInfoMethods @ csm_wrapper( obj );

		end	

	end

end

