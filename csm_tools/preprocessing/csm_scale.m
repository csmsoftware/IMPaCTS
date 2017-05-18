classdef csm_scale < csm_wrapper
%CSM_SCALE - Scale matrix X according to scale_type
%
% Usage:
%
% 	model = csm_scale( spectra, 'direction', direction, 'scale_type', scale_type )
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
% 	
%   direction : (str) 'r' to scale along rows, 'c' for columns. Default 'r'.
%	scale_type : (str) The type of scaling, currently only 'uv', 'mc' or 'none' supported. Default 'none'.
%
% Returns:
%
%	csm_scale : (csm_wrapper) Object with some stored inputs, the outputs and auditInfo.
%	csm_scale.output.scaledX : (csm_data) Scaled csm_data object.
%	csm_scale.output.scaledX.matrix : (m*n) Scaled spectral matrix.
%	csm_scale.output.means : (1*n) Means of each vector.
%	csm_scale.output.sDeviations : (1*n) Standard Deviation of each vector.
%
% Description:
%
%	Utilises the JTPscale method written by Jake Pearce.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_scale
        function [obj] =  csm_scale( spectra, varargin )

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
        
        % Assign the inputs
        function [obj] = assignDefaults( obj, spectra, varargin )

            obj.input.spectra = spectra;
            
            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'direction' ) = 'r';
            obj.optional_defaults( 'scale_type' ) = 'none';
                        
            obj = overwriteSpecifiedOptions( obj , varargin{:} );

        end

        % Assign the inputs and default options
        function [obj] = parseInput( obj )
            
            obj.inputparser = inputParser;

            expected_direction = { 'r', 'c' };
            expected_scale_type = { 'uv', 'mc', 'none' };

            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'direction' , @( x ) any( validatestring( x, expected_direction ) ) );
            addRequired( obj.inputparser , 'scale_type' , @( x ) any( validatestring( x, expected_scale_type ) ) );
            
            parse( obj.inputparser, obj.input.spectra, obj.input.direction, obj.input.scale_type );
            
        end


        % Call the normalise functions
        function [obj] = callBaseTool( obj )

            [ obj.tmp.Xout, obj.tmp.means, obj.tmp.s_deviations ] =  JTPscale( obj.input.spectra.X, obj.input.direction, obj.input.scale_type );

        end

        % Parse the model output
        function [obj] = parseOutput( obj )

            scaled_spectra = obj.input.spectra;

            scaled_spectra = scaled_spectra.setName( 'csm_scaled scaled data' );

            scaled_spectra = scaled_spectra.setX( obj.tmp.Xout );

            obj.output.scaled_spectra = scaled_spectra;

            obj.output.means = obj.tmp.means;
            obj.output.s_deviations = obj.tmp.s_deviations;

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end

    end

end
