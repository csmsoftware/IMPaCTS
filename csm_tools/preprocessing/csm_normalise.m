classdef csm_normalise < csm_wrapper
% CSM_NORMALISE - Normalise the matrix X according to normalise_type.
%
% Usage:
%
% 	model = csm_normalise( spectra, normalise_type );
%
% 	model = csm_normalise( spectra, normalise_type, 'urine_volumes', urine_volumes, 'direction', direction, 'peak', peak, 'noise_region', noise_region, 'target_spectra', target_spectra );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*normalise_type : (str) 'area', 'median fold', 'peak', 'probabilistic', 'total excretion', 'noise', or 'none'.
%
%	urine_volumes : (1*n) Urine volumes, required for 'total excretion'. Default [].
%	direction : (str) 'r' for rows, 'c' for columns.
%	peak : (1*1) Which peak to normalise against, defaults to TSP, -0.8 to 0.8 ppm. Used in 'peak' and 'total excretion'.
%	noise_region : (1*2) specify a region containing only noise to normalise to. Defaults to [-1 -0.3].
%	target_spectra : (m*1) Either column index for which spectra in X to use, set to 0 to use median of all spectra for 'median fold' normalisation, or entire spectra vector to use as median.
%
% Returns:
%
%	model : (obj) csm_wrapper with some stored inputs, the outputs and auditInfo.
%	model.output.normalised_spectra : (csm_nmr_spectra) Normalised spectra object.
%	model.output.normalisation_factor : (1*1) Normalisation factor.
%
% Description:
%
%	Utilises the JTPnormalise function written by Jake Pearce and a bespoke
%	probabilistic normalisation function.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_normalise
        function [obj] = csm_normalise( spectra,  normalise_type, varargin  )

            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj = assignDefaults( obj, spectra, normalise_type, varargin );

            obj = parseInput( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs and default options
        function [obj] = assignDefaults( obj, spectra, normalise_type, varargin )

            obj.input.spectra = spectra;

            obj.input.normalise_type = normalise_type;

            obj.input.kind = 'none';

            switch normalise_type

                case 'area'
                    obj.input.kind = 'area';

                case 'probabilistic'
                    obj.input.kind = 'prob';

                case 'median fold'
                    obj.input.kind = 'medianFold';

                case 'peak'
                    obj.input.kind = 'Peak';

                case 'total excretion'
                    obj.input.kind = 'totalExcretion';

                case 'noise'
                    obj.input.kind = 'Noise';

                case 'none'
                    obj.input.kind = 'none';

                otherwise

                    error( [ 'normalise_type : ', normalise_type, ' not recognised '] );

            end
            
            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'urine_volumes' ) = [];
            obj.optional_defaults( 'direction' ) = 'r';
            obj.optional_defaults( 'peak' ) = [ -0.08 0.08 ];
            obj.optional_defaults( 'noise_region' ) = [ -1 -0.3 ];
            obj.optional_defaults( 'target_spectra' ) = [];
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
            % If normalise_type is 'total excretion', urine_volumes is required
            if strcmp( normalise_type, 'total excretion' ) && ~obj.input.urine_volumes

                error( [ 'urine_volumes is required for normalise_type : ', normalise_type ] );

            end

        end
        
        function [obj] = parseInput ( obj )
            
            obj.inputparser = inputParser;
            
            expected_type = { 'area', 'median fold', 'peak', 'probabilistic', 'total excretion', 'noise', 'none' };
            expected_direction = { 'r', 'c' };
            
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'normalise_type' , @( x ) any( validatestring( x, expected_type ) ) );
            addRequired( obj.inputparser , 'urine_volumes' , @( x ) ismatrix( x ) )
            addRequired( obj.inputparser , 'direction' , @( x ) any( validatestring( x, expected_direction ) ) );
            addRequired( obj.inputparser , 'peak' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'noise_region' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'target_spectra' , @( x ) ismatrix( x ) );
                                                
            parse( obj.inputparser, obj.input.spectra, obj.input.normalise_type, obj.input.urine_volumes, obj.input.direction, obj.input.peak, obj.input.noise_region, obj.input.target_spectra );
                        
        end  


        % Call the normalise functions
        function [obj] = callBaseTool( obj )

            if strcmp( obj.input.normalise_type, 'probabilistic' )

                [ obj.tmp.normalised_X, obj.tmp.factor ] = csm_normalise_probabilistic( obj.input.spectra.X, obj.input.direction, obj.input.target_spectra );

            else

                [ obj.tmp.normalised_X, obj.tmp.factor ] = JTPnormalise( obj.input.spectra.X, obj.input.kind, 'ppm', obj.input.spectra.x_scale, 'Volumes', obj.input.urine_volumes, 'Direction', obj.input.direction, 'Peak', obj.input.peak, 'NoiseRegion', obj.input.noise_region, 'TargetSpectra', obj.input.target_spectra );

            end

        end

        % Parse the model output
        function [obj] = parseOutput( obj )

            normalised_spectra = obj.input.spectra;

            normalised_spectra = normalised_spectra.setName( 'csm_normalise normalised data' );

            normalised_spectra = normalised_spectra.setX( obj.tmp.normalised_X );

            obj.output.normalised_spectra = normalised_spectra;

            obj.output.normalisation_factor = obj.tmp.factor;

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end

    end

end	

function [ normalised_X, factor ] = csm_normalise_probabilistic( X, direction, target_spectra )
% CSM_NORMALISE_PROBABILISTIC - Normalisation adapated from RSPA normalise by Kiril Veselkov 

    if strcmp( direction, 'c' )

        X = X';

    end

    [ obs dim ] = size( X );

    factor = repmat( NaN, [ 1 obs ] );

    for i = 1 : obs

        factor( i ) = sum( X( i, : ) );
        X( i, : ) = X( i, : ) ./ factor( i );

    end

    X( 0 == X ) = 0.00000001;

    if isempty( target_spectra )

        normRef = median( X );

    elseif length( target_spectra ) == 1 && target_spectra <= obs

        normRef = X( target_spectra, : );

    elseif length( target_spectra ) == size( X, 2 )

        normRef = target_spectra;

    end

    F = X ./( normRef( ones( 1, obs ), : ) );

    for i = 1 : obs

        X( i, : ) = 10000 .* X( i, : ) ./ median( F( i, :) );
        factor( i ) =( factor( i ) * median( F( i, : ) ) ) ./ 10000;

    end

    if strcmp( direction, 'c' )

        X = X';

    end

    normalised_X = X;

end	