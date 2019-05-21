classdef csm_orth_pls < csm_wrapper
% CSM_OrthPLS - Performs Orthogonal Partial Least-Squares analysis on matrix X.
%
% Usage:
%
% 	model = csm_orth_pls( spectra, Y );
% 	model = csm_orth_pls( spectra, Y, 'num_pred_comp', num_pred_comp, 'num_Y_orth_comp', num_Y_orth_comp, 'num_cv_rounds',num_cv_rounds, 'cvType',cvType, 'scale_type',scale_type, 'cv_frac',cv_frac, 'model_type',model_type, 'cv_pred',cv_pred, 'orth_pls_type',orth_pls_type, 'largeBlockSize',largeBlockSize);
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*Y : (m*1) Matrix of predictors - Orthogonal components (For discriminant analysis this is a vector of 0/1's to define class)
%
%	num_pred_comp : (1*1) Number of predictive components. Default 1.
%	num_Y_orth_comp : (1*1) Number of Y-orthogonal components (OC in X). The number of components in num_pred_comp+numYorthComp should be kept to a minimum to prevent overfitting. Default 3.
%	num_cv_rounds : (1*1) Number of cross-validation rounds. Often set to zero. Default 7.
%	scale_type : (str) 'uv' for unit variance scaling, 'pa' for pareto, 'mc' for mean centred, 'none' for no scaling. Default 'mc'.
%	model_type : (str) 'da' for discriminant analysis, 're' for regression. if 'da', sensitivity and specificity will be calculated. Default 'da'.
%
% Returns:
%
%	csm_orth_pls : (csm_wrapper) csm_wrapper with some stored inputs, the outputs and metadata.
%	csm_orth_pls.output.da : (str) if model is of model_type='da' (discriminant analysis) - contains sensitivity / specificity info and confusion matrix etc.
% 	csm_orth_pls.output.o2pls_model : (struct) the full o2pls model with all it's parameters
% 	csm_orth_pls.output.cv : (struct) cross-validation results, such as Q^2 values,
% 	csm_orth_pls.output.release : (str) version information
%
% Description:
%
%	Utilises the mjrMainO2PLS function written by Mattias Rantalainen.
%
% Reference:
%
%   O2PLS
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_orth_pls
        function [obj] = csm_orth_pls( spectra, Y, varargin )

            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            obj = assignDefaults( obj, spectra, Y, varargin );

            obj = parseInput ( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs
        function [obj] = assignDefaults( obj, spectra, Y, varargin )

            % Required arguments
            obj.input.spectra = spectra;
            obj.input.Y = Y;
            
            obj.optional_defaults = containers.Map;
            
            % Optional arguments with defaults
            obj.optional_defaults( 'num_pred_comp' ) = 1;
            obj.optional_defaults( 'num_Y_orth_comp' ) = 3;
            obj.optional_defaults( 'num_cv_rounds' ) = 7;
            obj.optional_defaults( 'cvType' ) = 'nfold';
            obj.optional_defaults( 'scale_type' ) = 'mc';
            obj.optional_defaults( 'cv_frac' ) = [];
            obj.optional_defaults( 'model_type' ) = 'da';

            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
            if strcmp(obj.input.scale_type, 'uv')
                obj.input.scale_type = 'uv';
                obj.input.centre_type = 'mc';
            elseif strcmp(obj.input.scale_type, 'mc')
                obj.input.scale_type = 'no';
                obj.input.centre_type = 'mc';
            elseif strcmp(obj.input.scale_type, 'pa')
                obj.input.scale_type = 'pa';
                obj.input.centre_type = 'mc';    
            else
                obj.input.scale_type = 'no';
                obj.input.centre_type = 'no';
            end
        end

        % Assign the input expected values
        function [obj] = parseInput( obj )

            obj.inputparser = inputParser;

            expected_scale_type = { 'uv', 'pa', 'mc', 'no' };
            expected_model_type = { 'da', 're' };
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'Y' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'num_pred_comp' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'num_Y_orth_comp' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'num_cv_rounds' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'scale_type' , @( x ) any( validatestring( x, expected_scale_type ) ) );
            addRequired( obj.inputparser , 'model_type' , @( x ) any( validatestring( x, expected_model_type ) ) );
            
            parse( obj.inputparser, obj.input.spectra, obj.input.Y, obj.input.num_pred_comp, obj.input.num_Y_orth_comp, obj.input.num_cv_rounds, obj.input.scale_type, obj.input.model_type );

        end

        % Call the mjrMainO2Pls function
        function [obj] = callBaseTool( obj )

          %  (X,Y,A,oax,oay,nrcv,cvType,centerType,scaleType,cvFrac,modelType,cvPred,orth_plsType,largeBlockSize)
            
            obj.tmp = mjrMainO2pls( obj.input.spectra.X, obj.input.Y, obj.input.num_pred_comp, obj.input.num_Y_orth_comp, 0, obj.input.num_cv_rounds, 'nfold', obj.input.centre_type, obj.input.scale_type,  [], obj.input.model_type, 'y', 'standard', [] );

        end


        % Parse the model output
        function [obj] = parseOutput( obj )

            obj.output = obj.tmp;
            
            obj.output.args.centre_type = obj.input.centre_type;
            obj.output.args.scale_type = obj.input.scale_type;
            obj.output.args.centreType = obj.input.centre_type;
            obj.output.args.scaleType = obj.input.scale_type;

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end


    end

end

