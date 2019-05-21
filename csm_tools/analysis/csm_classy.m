classdef csm_classy < csm_wrapper
% CSM_CLASSY - STOCSY with clustering
%
% Usage:
%
% 	model = csm_classy( spectra, 'corr_metric', corr_metric, 'corr_thresh', corr_thresh, 'cluster_metric', cluster_metric, 'hier_method', hier_method, 'ref_spectrum', ref_spectrum, 'peak_thresh' , peak_thresh )
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%
%	corr_metric : (str) 'pearson', 'spearman' or 'jackknife'. Default 'pearson'.
%	corr_thresh : (1*1) Minimum considered correlation threshold. Default 0.8 when pearson, 0.75 when spearman.
%	cluster_metric : (str) 'euclidean', 'topological' or 'correlation'. Default 'correlation'.
%	hier_method : (str) Linkage algorithm - 'single','complete','average','weighted'. Default 'average'.
%	ref_spectrum : (str) Reference spectrum of spectral set 'mean','median','max', 'min', 'var' a reference pointer for the X matrix. Default 'median'.
%	peak_thresh : (1*1) values between 0 and 1, controls peak picking threshold. Default 0.8.
%
% Returns:
%
%	csm_classy : (csm_wrapper) csm_wrapper with some stored inputs, the outputs and auditInfo.
%	csm_classy.output.R : (m*n) log change matrix Rij=log(Cij/Cjo) where Cij is the intensity of peak j in spectrum i and o is the median control spectrum.
%	csm_classy.output.hier_sets : (m*n) hierarchically clustered independent sets of statistical correlations between peaks.
%	csm_classy.output.cluster_sets : (m*n) independent sets in hierarchical order with peak indices and corresponding chemical shifts.
%	csm_classy.output.cluster_bio_correlations : (m*n) biological correlation matrices, independent sets collapse to single point.
%	csm_classy.output.targets : (1*n) indices in ppm vector of detected peaks
%	csm_classy.output.shifts : (m*n) all chemical shifts, ordered by appearance in plots
%
% Description:
%
% 	CLASSY identifies independent sets in the correlation matrix of the full set of experimental spectra.
%	It then calculates individual correlation matrices with the structural correlations (independent sets) collapsed to the first point to produce matrices of biological .correlations for each subset of spectra with the experiment
% 	It then hierarchically clusters the biological correlations, then re-expands them within the clusters and calculates the log-change matrix based on the cluster order.  
%	It then plots the individual indepdendent set clustered correlation matrices with independent sets boxed and chemical shift values superimposed and the R matrices with non-peak dimension in the input spectra order.
%
% Reference:
%
%   Robinette, S. L.; Veselkov, K. A.; Bohus, E.; Coen, M.; Keun, H. C.; Ebbels, T. M. D.; Beckonert, O.Holmes, E. C.; Lindon, J. C.; Nicholson, J. K.
%   Cluster Analysis Statistical Spectroscopy Using Nuclear Magnetic Resonance Generated Metabolic Data Sets from Perturbed Biological Systems. 
%   Analytical Chemistry 2009, 81, (16), 6581-6589. 
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

	
	properties

		classDescription = 'CSM CLASSY model generated using CLASSY function';

	end	

	methods

		% Constructor for csm_classy
		function [obj] = csm_classy( spectra, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
			
			obj = assignDefaults( obj, spectra, varargin );
            
            obj = parseInput( obj );

			obj = callBaseTool( obj );

			obj = runAuditInfoMethods( obj );

			obj = parseOutput( obj );

        end
        
        % Assign the input defaults
        function [obj] = assignDefaults( obj, spectra, varargin )
            
            % Required arguments
			obj.input.spectra = spectra;

			% Optional arguments with defaults
            obj.optional_defaults( 'corr_metric' ) = 'pearson';
            obj.optional_defaults( 'corr_thresh' ) = 0.8;
            obj.optional_defaults( 'cluster_metric' ) = 'correlation';
            obj.optional_defaults( 'heir_method' ) = 'average';
            obj.optional_defaults( 'ref_spectrum' ) = 'median';
            obj.optional_defaults( 'peak_thresh' ) = 0.8;
                        
            obj = overwriteSpecifiedOptions( obj, varargin{:} );
            
            % Set dependant defaults

            % If the corr_thresh wasn't set, set it to relevant corr_metric default.
            if ~ ismember( 'corr_thresh', obj.set_options )
               
                if strcmp( obj.input.corr_metric, 'spearman' )
                
                    obj.input.corr_thresh = 0.75;
                    
                else
                    
                    obj.input.corr_thresh = 0.8;
                                        
                end
                
            end   
            
        end
        

        % Assign the input expected values
		function [obj] = parseInput( obj )
            
            obj.inputparser = inputParser;
            
            expected_corrMetric = { 'spearman', 'pearson', 'jackknife' };
            expected_clusterMetric = { 'euclidean', 'topological', 'correlation' };
            expected_heirMethod = { 'single', 'complete', 'average', 'weighted' };
            expected_refSpectrum = { 'mean', 'median', 'max', 'min', 'var' };
                        
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'corr_metric' , @( x ) any( validatestring( x, expected_corrMetric ) ) );
            addRequired( obj.inputparser , 'corr_thresh' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'cluster_metric' , @( x ) any( validatestring( x, expected_clusterMetric ) ) );
            addRequired( obj.inputparser , 'heir_method' , @( x ) any( validatestring( x, expected_heirMethod ) ) );
            addRequired( obj.inputparser , 'ref_spectrum' , @( x ) any( validatestring( x, expected_refSpectrum ) ) );
            addRequired( obj.inputparser , 'peak_thresh' , @( x ) isnumeric( x ) );
            
            parse( obj.inputparser, obj.input.spectra, obj.input.corr_metric, obj.input.corr_thresh, obj.input.cluster_metric, obj.input.heir_method, obj.input.ref_spectrum, obj.input.peak_thresh );
                        
        end
        

		% Call the CLASSY function
		function [obj] = callBaseTool( obj )

			obj.tmp = CLASSY( obj.input.spectra.X, obj.input.spectra.x_scale, 'peak_picking', 'complex', 'corr_metric', obj.input.corr_metric, 'cluster_metric', obj.input.cluster_metric, 'heir_method', obj.input.heir_method, 'pearThresh', obj.input.corr_thresh, 'spearThresh', obj.input.corr_thresh, 'represent', obj.input.ref_spectrum, 'peak_thresh', obj.input.peak_thresh );

        end
        

		% Parse the model output
		function [obj] = parseOutput( obj )

			obj.output = obj.tmp;

			obj.tmp = '';

		end

		% Run the auditInfo methods (must be run)
		function [obj] = runAuditInfoMethods( obj )

			obj.class_name = class( obj );

			runAuditInfoMethods @ csm_wrapper( obj );

		end	

	end
	
end

