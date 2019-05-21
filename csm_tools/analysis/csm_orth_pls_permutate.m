classdef csm_orth_pls_permutate < csm_wrapper
%CSM_OrthPLS_PERMUTATE - Permutation test for OrthPLS, running p permutations of Y.
%
% Usage:
%
% 	model = csm_orth_pls_permutate( spectra, Y, p );
% 	model = csm_orth_pls( spectra, Y, p, 'num_pred_comp', num_pred_comp, 'num_Y_orth_comp', num_Y_orth_comp, 'num_cv_rounds',num_cv_rounds, 'scale_type', scale_type, 'model_type', model_type);
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*Y : (m*1) Matrix of predictors - Orthogonal components (For discriminant analysis this is a vector of 0/1's to define class)
%	*p : (1x1) Number of permutations.
%
%	num_pred_comp : (1*1) Number of predictive components.
%	num_Y_orth_comp : (1*1) Number of Y-orthogonal components (OC in X). The number of components in A+oax should be kept to a minimum to prevent overfitting.
%	num_cv_rounds : (1*1) Number of cross validation rounds (Default 7).
%	scale_type : (str) Preprocessing; 'mc' for mean-centering, 'pa' for pareto, 'uv' for unit-variance scaling, or 'none'. Default 'mc'.
%	model_type : (str) 'da' for discriminant analysis, 're' for regression. if 'da', sensitivity and specificity will be calculated. Default 'da'.
%
% Returns:
%
%	csm_orth_pls_permutate : (csm_wrapper) csm_wrapper with some stored inputs, the outputs and metadata.
%	csm_orth_pls_permutate.output.pv : (1*1) P-value (non-parametric).
%	csm_orth_pls_permutate.output.Q2p : (1*n) Q2 values for all permutations.
%	csm_orth_pls_permutate.output.R2p : (1*n) R2 values for all permutations.
%	csm_orth_pls_permutate.output.orth_pls_model : (obj) Canonical OrthPLS model.
%
% Description:
%
%	Utilises the JTPpermutate() method written by Jake Pearce.
%	Compares the OrthPLS model against a randomised version to test the validity.
%
% Reference:
%
%
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016


    methods

        % Constructor for csm_orth_pls_permutate
        function [obj] = csm_orth_pls_permutate( spectra, Y, p, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            obj = assignDefaults( obj, spectra, Y, p, varargin );

            obj = parseInput ( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs
        function [obj] = assignDefaults( obj, spectra,  Y, p, varargin )

            % Required arguments
            obj.input.spectra = spectra;
            obj.input.Y = Y;
            obj.input.p = p;
            
            obj.optional_defaults = containers.Map;
                        
            % Optional arguments with defaults
            obj.optional_defaults( 'num_pred_comp' ) = 1;
            obj.optional_defaults( 'num_Y_orth_comp' ) = 3;
            obj.optional_defaults( 'num_cv_rounds' ) = 7;
            obj.optional_defaults( 'scale_type' ) = 'mc';
            obj.optional_defaults( 'model_type' ) = 'da';

            obj = overwriteSpecifiedOptions( obj , varargin{:} );

        end
        
        % Assign the input expected values
        function [obj] = parseInput( obj )

            obj.inputparser = inputParser;

            expected_scale_type = {'mc', 'uv', 'pa', 'none' };
            expected_model_type = { 'da', 're' };

            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'Y' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'p' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'num_pred_comp' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'num_Y_orth_comp' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'num_cv_rounds' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'scale_type' , @( x ) any( validatestring( x, expected_scale_type ) ) );
            addRequired( obj.inputparser , 'expected_model_type' , @( x ) any( validatestring( x, expected_model_type ) ) );
            

            parse( obj.inputparser, obj.input.spectra, obj.input.Y, obj.input.p, obj.input.num_pred_comp, obj.input.num_Y_orth_comp, obj.input.num_cv_rounds, obj.input.scale_type, obj.input.model_type );

        end

            % Call the JTPpermutate function
        function [obj] = callBaseTool( obj )

            [ pv, Q2p, R2p, orth_pls_model ] = JTPpermutate( obj.input.spectra.X, obj.input.Y, obj.input.p, obj.input.num_pred_comp, obj.input.num_Y_orth_comp, obj.input.num_cv_rounds, obj.input.scale_type,obj.input.model_type );

            obj.tmp = struct;
            obj.tmp.pv = pv;
            obj.tmp.Q2p = Q2p;
            obj.tmp.R2p = R2p;
            obj.tmp.orth_pls_model = orth_pls_model;

        end


        % Parse the model output
        function [obj] = parseOutput( obj )

            obj.output = obj.tmp;

            obj.tmp = '';
            
            obj.output.orth_pls_model.args.centre_type = 'no';
            
            obj.output.orth_pls_model.args.scale_type = obj.input.scale_type;

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end

    end

end

