classdef csm_baseline_diff < csm_wrapper
% CSM_BASELINE_DIFF - Calculate the baseline differences.
%
% Usage:
%
% 	model = csm_baseline_diff( spectra, region );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*region : (1*2) The region to search.
%
%	alpha : (1*1) Critical value for defining the rejection region. Default 0.05.
%	threshold : (1*1) The percentage of samples in the region allowed to exceed the alpha value. Default 90.
%	save_dir : (str) Path to the save directory.
%	saveName : (str) Name of the file to save.
%
% Returns:
%
%	model : (obj) csm_wrapper with some stored inputs, the outputs and auditInfo.
%	model.output.outliers : (1*m) Vector indicating outliers.
%	model.output.region : (1*2) region.
%	model.output.area : (1*1) area.
%	model.output.regionIX : (1*1) minR:maxR;
%	model.output.area : (1*1) area;
%	model.output.alpha : (1*1) alpha;
%	model.output.threshold : (1*1) threshold;
%	model.output.area_crit : (1*1) area_crit;
%	model.output.fail_area : (1*1) fail_area;
%	model.output.fail_neg : (1*1) fail_neg;
%
% Description:
%
%   Function to determine baseline differences from either end of the (removed) presaturated water peak for a set of spectra, and plot results
%
%   Samples are defined as outliers if either:
%
%   1. 'threshold' percent of the area (0.1 ppm) either side of the removed water region exceeds the critical value 'alpha'
%   2. 'threshold' percent of the signal (0.1 ppm) either side of the removed water region is negative
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_baseline_diff
        function [obj] = csm_baseline_diff( spectra, region, varargin  )

            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
           
            obj = assignDefaults( obj, spectra, region, varargin );

            obj = parseInput( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs and default options
        function [obj] = assignDefaults( obj, spectra, region, varargin )

            obj.input.spectra = spectra;

            obj.input.region = region;
            
            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'alpha' ) = 0.05;
            obj.optional_defaults( 'threshold' ) = 90;
            obj.optional_defaults( 'save_dir' ) = pwd;
            obj.optional_defaults( 'saveName' ) = 'BL';
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
           
        end
        
        function [obj] = parseInput ( obj )
            
            obj.inputparser = inputParser;
            
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'region' , @( x ) ismatrix( x ) )
            addRequired( obj.inputparser , 'alpha' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'threshold' , @( x ) isnumeric( x ) );
            addRequired( obj.inputparser , 'save_dir' , @( x ) ischar( x ) );
            addRequired( obj.inputparser , 'saveName' , @( x ) ischar( x ) );
                                                
            parse( obj.inputparser, obj.input.spectra, obj.input.region, obj.input.alpha, obj.input.threshold, obj.input.save_dir, obj.input.saveName );
                        
        end  


        % Call the normalise functions
        function [obj] = callBaseTool( obj )

            [ obj.tmp.outliers, obj.tmp.output ] = CJSbaseline(obj.input.spectra.X, obj.input.spectra.x_scale, obj.input.region, 'alpha', obj.input.alpha, 'threshold', obj.input.threshold, 'savedir', obj.input.save_dir );

        end

        % Parse the model output
        function [obj] = parseOutput( obj )
            
            obj.output.outliers = obj.tmp.outliers;
            obj.output.region = obj.tmp.output.region;
            obj.output.area = obj.tmp.output.area;
            obj.output.regionIX = obj.tmp.output.regionIX;
            obj.output.area = obj.tmp.output.area;
            obj.output.alpha = obj.tmp.output.alpha;
            obj.output.threshold = obj.tmp.output.threshold;
            obj.output.area_crit = obj.tmp.output.areaCrit;
            obj.output.fail_area = obj.tmp.output.failArea;
            obj.output.fail_neg = obj.tmp.output.failNeg;

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end

    end

end