classdef csm_rspa < csm_wrapper
% CSM_RSPA - Performs Recursive Segment-wise Peak Alignment for accounting peak position variation across multiple 1H NMR biological spectra.
%
% Usage:
%
% 	model = csm_rspa( spectra, 'ref_spectrum', ref_spectrum, 'normalise', normalise, 'debug_interval', debug_interval )
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%
%	ref_spectrum : (m*1) Vector of the reference spectrum to which all others are to be aligned ([], for automatic selection).
%	normalise : (bool) true or false, accounting for differential dilution	across biological spectra. Default 0.
%	debug_interval : (1*1) Visually debug alignment using interval ("debug_interval" seconds).
%
% Returns:
%
%	csm_rspa : (csm_wrapper) stored inputs, model and auditInfo.
%	csm_rspa.output.aligned_spectra : (csm_nmr_spectra) Aligned spectra.
%
% Description:
%
%	Utilises the RSPA function written by Kiril Veselkov.
%
% Reference:
%
%   Veselkov KA, Lindon JC, Ebbels TM, Crockford D, Volynkin VV, Holmes E, Davies DB, Nicholson JK.
%   Recursive segment-wise peak alignment of biological (1)h NMR spectra for improved metabolic biomarker recovery.
%   Analytical Chemistry 2009 Jan 1;81(1):56-66
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_rspa
        function [obj] = csm_rspa( spectra, varargin )
            
            obj = obj @ csm_wrapper( varargin{:} );

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            if ~spectra.isContinuous( )
                
               error( 'This function only works with continuous data' );
                
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
            obj.optional_defaults( 'ref_spectrum' ) = [];
            obj.optional_defaults( 'normalise' ) = false;
            obj.optional_defaults( 'debug_interval') = [];
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );

        end
        
        function [obj] = parseInput ( obj )
            
            obj.inputparser = inputParser;
                        
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'ref_spectrum' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'normalise' , @( x ) islogical( x ) );
            addRequired( obj.inputparser , 'debug_interval' , @( x ) ismatrix( x ) );
            
            parse( obj.inputparser, obj.input.spectra, obj.input.ref_spectrum, obj.input.normalise, obj.input.debug_interval );
                        
        end  


        % Call the doAlignment function
        function [obj] = callBaseTool( obj )

            obj.tmp = doAlignment( obj.input.spectra.X, obj.input.spectra.x_scale, obj.input.ref_spectrum, obj.input.normalise, obj.input.debug_interval );

        end


        % Parse the model output
        function [obj] = parseOutput( obj )

            aligned_spectra = obj.input.spectra;

            aligned_spectra = aligned_spectra.setName( 'csm_rspa aligned data' );

            aligned_spectra = aligned_spectra.setX( obj.tmp );

            obj.output.aligned_spectra = aligned_spectra;

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end


    end

end
