classdef csm_peak_width < csm_wrapper
% CSM_PEAK_WIDTH - Calculate the peak width.
%
% Usage:
%
% 	model = csm_peak_width( spectra, spectrometer_frequency );
% 	model = csm_peak_width( spectra, spectrometer_frequency, 'LWpeak', LWpeak, 'LWthreshold', LWthreshold, 'plot_results', plot_results, 'save_dir', save_dir );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*spectrometer_frequency : (1*1) Frequency of the spectrometer in Hz.
%
%	LWpeak : (str) Peak to calculate line width from, either 'glucose', 'lactate', 'TSP'. Default 'TSP'.
%   LWthreshold : (1*1) The threshold for acceptable peak width. Default 1.4 Hz.
%	plot_results : (bool) Whether to plot the results. Default false.
%	save_dir : (str) Directory to save the plots to. Default current working	directory.
%
% Returns:
%
%	model : (obj) csm_wrapper with some stored inputs, the outputs and auditInfo.
%   model.output : (struct) = variables generated during run.
%   model.output.peakwidthHz : (m*1) peakwidth values.
%   model.output.outliers : (m*1) logical vector indicating outlying samples.
%
% Description:
%
%	Calculate the peak width for QA.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_normalise
        function [obj] = csm_peak_width( spectra, spectrometer_frequency, varargin  )

            obj = obj @ csm_wrapper( varargin{:} );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj = assignDefaults( obj, spectra, spectrometer_frequency, varargin );

            obj = parseInput( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs and default options
        function [obj] = assignDefaults( obj, spectra, spectrometer_frequency, varargin )

            obj.input.spectra = spectra;
            obj.input.spectrometer_frequency = spectrometer_frequency;

            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'LWpeak' ) = 'TSP';
            obj.optional_defaults( 'LWthreshold' ) = 1.4;
            obj.optional_defaults( 'plot_results' ) = false;
            obj.optional_defaults( 'save_dir' ) = pwd;
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
        end
        
        function [obj] = parseInput ( obj )
            
            obj.inputparser = inputParser;
            
            expected_lwpeak = { 'glucose', 'lactate', 'TSP' };
            
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') );
            addRequired( obj.inputparser , 'X' , @( x ) ~isempty( x ) );
            addRequired( obj.inputparser , 'spectrometer_frequency' , @( x ) ismatrix( x ));
            addRequired( obj.inputparser , 'LWpeak' , @( x ) any( validatestring( x, expected_lwpeak ) ) );
            addRequired( obj.inputparser , 'LWthreshold' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'plot_results' , @( x ) islogical( x ) );
            addRequired( obj.inputparser , 'save_dir' , @( x ) ischar( x ) );
                                                
            parse( obj.inputparser, obj.input.spectra,obj.input.spectra.X, obj.input.spectrometer_frequency, obj.input.LWpeak, obj.input.LWthreshold, obj.input.plot_results, obj.input.save_dir);

            obj.input.args = struct;
            obj.input.args.LWpeak = obj.input.LWpeak;
            obj.input.args.LWthreshold = obj.input.LWthreshold;
            
        end  


        % Call the normalise functions
        function [obj] = callBaseTool( obj )

            if true(obj.input.plot_results)
               
                [obj.tmp.peakwidthHz, obj.tmp.outliers, obj.tmp.output] = CJSpeakwidth(obj.input.spectra.X,obj.input.spectra.x_scale,obj.input.args,obj.input.spectrometer_frequency,'savedir',obj.input.save_dir);
                
            else    

                [obj.tmp.peakwidthHz, obj.tmp.outliers, obj.tmp.output] = CJSpeakwidth(obj.input.spectra.X,obj.input.spectra.x_scale,obj.input.args,obj.input.spectrometer_frequency,'noPlots','noPlots');

            end

        end

        % Parse the model output
        function [obj] = parseOutput( obj )

            obj.output = obj.tmp.output;
            obj.output.peakwidthHz = obj.tmp.peakwidthHz;
            obj.output.outliers = obj.tmp.outliers;

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end

    end

end	
