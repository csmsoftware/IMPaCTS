classdef csm_plot_orth_pls < csm_figure
% CSM_PLOT_OrthPLS - Generate the OrthPLS Summary Plot
%
% Usage:
%
% 	figure = csm_plot_orth_pls( csm_orth_pls_model );
%
% 	figure = csm_plot_orth_pls( csm_orth_pls_model, 'plot_type', plot_type, );
%
% Arguments:
%
%	*csm_orth_pls_model : (csm_orth_pls) OrthPLS model created by csm_orth_pls.
%
%   plot_type : (str) 'all','scores','loadings', 'stats','perm'. Default 'all'.
% 	sample_ids : (cell) Sample Labels for plotting. Default sample_ids from csm_orth_pls spectra input.
%   name : (str) Name to annotate the figure with. Default date.
%   save_dir : (str) Save directory. Default none.
%
% Returns:
%
%	figure : (obj) csm_figure_handle with some stored inputs, the handle and metadata.
%   figure.output.association_XY.cor : (m*n) Correlation matrix of X and Y.
%   figure.output.association_XY.cov : (m*n) Covariance matrix of X and Y.
%   figure.output.association_XY.cor_p_value : (1*1) P Value of the correlation between X and Y.
%
% Description:
%
%	Utilises the mjrO2plsSummaryPlot function written by Mattias Rantalainen.
%
%   If loadings plots are generated (with plot_type = 'loadings' or 'all'),
%   Statistics about the association between X and Y are calculated and
%   returned in figure.output.association_XY.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016


    methods

        % Constructor for csm_plot_spectra
        function [obj] =  csm_plot_orth_pls( csm_orth_pls_model, varargin )
            
            obj = obj @ csm_figure( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            obj = assignDefaults( obj, csm_orth_pls_model, varargin );

            obj = parseInput ( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end
        
        function [obj] = assignDefaults( obj, csm_orth_pls_model, varargin )

            % Required arguments
            if isa( csm_orth_pls_model, 'csm_orth_pls' )

                obj.input.csm_orth_pls_model_for_plot = csm_orth_pls_model.output;

            elseif 	isa( csm_orth_pls_model, 'csm_orth_pls_permutate' )

                obj.input.csm_orth_pls_model_for_plot = csm_orth_pls_model.output.orth_pls_model;

            end
            
            obj.input.csm_orth_pls_model = csm_orth_pls_model;
            
            obj.optional_defaults = containers.Map;
            
            % Optional arguments with defaults
            obj.optional_defaults( 'plot_type' ) = 'all';
            obj.optional_defaults( 'name' ) = 'OrthPLS';
            obj.optional_defaults( 'sample_ids' ) = 'none';
            obj.optional_defaults( 'save_dir' ) = 'none';
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
            
            % If the sample_ids have been left to default but the spectra has sample_ids, set the sample_ids.
            if ~ismember( 'sample_ids', obj.set_options ) && ~isempty( csm_orth_pls_model.input.spectra.sample_ids )
                
                obj.input.sample_ids = csm_orth_pls_model.input.spectra.sample_ids;

            end

        end
                
        % Check the input
        function [obj] = parseInput( obj )
            
            obj.inputparser = inputParser;
            
            expected_plot_type =  { 'all','scores','loadings', 'stats','perm' };
                        
            addRequired( obj.inputparser , 'plot_type' , @( x ) any( validatestring( x, expected_plot_type ) ) );
                        
            parse( obj.inputparser, obj.input.plot_type );
            
        end    

        % Call the mjrO2plsSummaryPlot function
        function [obj] = callBaseTool( obj )
            
            if ~strcmp( obj.input.sample_ids, 'none' ) & ~strcmp( obj.input.save_dir, 'none' )

                CJSo2plsPlot( obj.input.csm_orth_pls_model_for_plot, obj.input.csm_orth_pls_model.input.spectra.X, obj.input.csm_orth_pls_model.input.Y, obj.input.csm_orth_pls_model.input.spectra.getXScale(), 'plotthis', obj.input.plot_type, 'name', obj.input.name, 'sample_labels', obj.input.sample_ids, 'savedir', obj.input.save_dir );
            
            elseif ~ strcmp( obj.input.sample_ids, 'none' ) & strcmp( obj.input.save_dir, 'none' )
                    
                CJSo2plsPlot( obj.input.csm_orth_pls_model_for_plot, obj.input.csm_orth_pls_model.input.spectra.X, obj.input.csm_orth_pls_model.input.Y, obj.input.csm_orth_pls_model.input.spectra.getXScale(), 'plotthis', obj.input.plot_type, 'name', obj.input.name, 'sample_labels', obj.input.sample_ids );
                
            elseif strcmp( obj.input.sample_ids, 'none' ) & ~strcmp( obj.input.save_dir, 'none' )
                
                CJSo2plsPlot( obj.input.csm_orth_pls_model_for_plot, obj.input.csm_orth_pls_model.input.spectra.X, obj.input.csm_orth_pls_model.input.Y, obj.input.csm_orth_pls_model.input.spectra.getXScale(), 'plotthis', obj.input.plot_type, 'name', obj.input.name, 'savedir', obj.input.save_dir );
           
            else    
                
                CJSo2plsPlot( obj.input.csm_orth_pls_model_for_plot, obj.input.csm_orth_pls_model.input.spectra.X, obj.input.csm_orth_pls_model.input.Y, obj.input.csm_orth_pls_model.input.spectra.getXScale(), 'plotthis', obj.input.plot_type, 'name', obj.input.name );
                
            end

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_figure( obj );

        end

    end

end