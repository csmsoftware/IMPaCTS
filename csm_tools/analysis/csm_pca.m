classdef csm_pca < csm_wrapper
% CSM_PCA - Performs Principal Component Analysis on matrix X.
%
% Usage:
%
%   model = csm_pca ( spectra, npc );
%
%   model = csm_pca ( spectra, npc, 'prep', prep );
%
% Arguments:
%
%   *spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%   *npc : (1*1) Number of components to be computed.
%
%   prep : (str) Preprocessing type; 'mc' for mean centering, 'uv' for univariance Scaling, 'par' for Paretto Scaling. Default 'none'.
%
% Returns:
%
%   csm_pca : (csm_wrapper) Object with some stored inputs, the outputs and auditInfo.
%   csm_pca.output.P : (m*n) Matrix of Loadings, components*loadings.
%   csm_pca.output.T : (m*n) Matrix of scores, scores*components.
%   csm_pca.output.Tcv : (m*n) Matrix of cross validated scores, scores*components.
%   csm_pca.output.Xr : (m*1) Model residuals, residuals*1.
%   csm_pca.output.R2 : (m*1) Modeled variation, componentvariance*1.
%   csm_pca.output.Q2 : (m*1) Cross-validated modeled variation, componentvariance*1.
%   csm_pca.output.ns : (1*1) Number of samples.
%   csm_pca.output.Residual : (m*1) Summed residuals for each sample.
%   csm_pca.output.TotalResidual : (1*1) Summed residuals for all samples.
%   csm_pca.output.DModX : (m*1) Distance from model for each sample.
%   csm_pca.output.Dcrit : (1*1) Critical value for DModX.
%
% Description:
%
%   Utilises the JTPcrossValidatedPCA. Cross Validates a JTPpca model.
%   Calculates residuals and DModX values. Can be used as input for
%   csm_plot_pca.
% 
% Reference:
%
%   NIPALS
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2017

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_pca
        function [obj] = csm_pca( spectra, npc, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );

            % Allows creation of empty objects for cloning
            if nargin == 0
               return
            end
            
            obj = assignDefaults( obj, spectra, npc, varargin );

            obj = parseInput( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the defaults
        function [obj] = assignDefaults( obj, spectra, npc, varargin )

            % Required arguments
            obj.input.spectra = spectra;
            obj.input.npc = npc;
            
            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'prep' ) = 'mc';
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );

        end

        % Assign the inputs and default options
        function [obj] = parseInput( obj )

            obj.inputparser = inputParser;
            
            expected_prep = {'mc','uv','par','none'};
            
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'prep' , @( x ) any( validatestring( x, expected_prep ) ) );
            addRequired( obj.inputparser , 'npc' , @( x ) isnumeric( x ) );
            
            parse( obj.inputparser, obj.input.spectra, obj.input.prep, obj.input.npc );

        end

        % Call the mypca function
        function [obj] = callBaseTool( obj )

            obj.tmp = JTPcrossValidatedPCA( obj.input.spectra.X, obj.input.prep, obj.input.npc );

        end

        % Parse the model output
        function [obj] = parseOutput( obj )

            obj.output.P = obj.tmp.P;
            obj.output.T = obj.tmp.T;
            obj.output.Tcv = obj.tmp.Tcv;
            obj.output.Xr = obj.tmp.Xr;
            obj.output.R2 = obj.tmp.R2;
            obj.output.Q2 = obj.tmp.Q2;

            obj.output.ns = size (obj.input.spectra.X,1);
            obj.output.Residual = sum( obj.output.Xr.^2, 2);
            obj.output.TotalResidual = sum( obj.output.Residual );
            obj.output.DModX = obj.output.Residual * obj.output.ns / obj.output.TotalResidual;
            obj.output.Dcrit = mean( obj.output.DModX) +1 * std( obj.output.DModX );

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end

        function [ pcaPlot ] = plot_pca( obj, plotType, options )

            pcaPlot = csm_plot_pca( obj, plotType, options );

        end

    end

end

 