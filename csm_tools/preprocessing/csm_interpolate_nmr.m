classdef csm_interpolate_nmr < csm_wrapper
% CSM_INTERPOLATE_NMR - Interpolate NMR spectra
%
% Usage:
%
% 	model = csm_interpolate_nmr( spectra, ppm_common, 'ppm_common2D', ppm_common2D )
%
% Arguments:
%
%	*spectra : (csm_nmr_spectra) csm_nmr_spectra object containing spectral matrix.
%	*spectra : (csm_jres_spectra) csm_jres_spectra object containing 2D spectral matrix.
%	*ppm_common : (1*n) Common ppm scale.
%
%	ppm_common2D : (1*n) ppm scale for 2nd dimension of Common ppm scale.
%	useHash : (bool) Set to false if no hash is wanted (because it's slow).
%
% Returns:
%
%	csm_interpolate_nmr : (csm_wrapper) stored inputs, model and auditInfo.
%	csm_interpolate_nmr.output.interpolated_spectra : (csm_nmr_spectra) Interpolated spectra.
%
% Description:
%
%	Utilises the JTPinterpolateNMR function written by Jake Pearce.
%	Uses cubic-spline interpolation to increase / decrease the number of
%	points in an NMR spectrum. If you wish to re-size the a spectrum with
%	both imaginary and real parts, simple run the function seperatly for each
%	part.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor
        function [obj] = csm_interpolate_nmr( spectra, ppm_common, varargin )
           
            obj = obj @ csm_wrapper( varargin{:} );
 
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end

            if ~spectra.isContinuous( )
                
               error( 'This function only works with continuous data' );
                
            end
           
            obj = assignDefaults( obj, spectra, ppm_common, varargin );
            
            obj = parseInput( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs
        function [obj] = assignDefaults( obj, spectra, ppm_common, varargin )

            obj.input.spectra = spectra;
            obj.input.ppm_common = ppm_common;

            obj.optional_defaults = containers.Map;

            % Optional arguments with defaults
            obj.optional_defaults( 'ppm_common2D' ) = [];
            obj.optional_defaults( 'useHash' ) = true;
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );

        end
        
         function [obj] = parseInput ( obj )
            
            obj.inputparser = inputParser;
                        
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            addRequired( obj.inputparser , 'ppm_common' , @( x ) ismatrix( x ) );
                                    
            parse( obj.inputparser, obj.input.spectra, obj.input.ppm_common );
                        
        end  


        % Call the base function
        function [obj] = callBaseTool( obj )

            if isa( obj.input.spectra, 'csm_jres_spectra' )

                [ obj.tmp.X, obj.tmp.ppm, obj.tmp.vargout ] = JTPinterpolateSpectra( obj.input.spectra.X, obj.input.spectra.getXScale(), 'PPM', obj.input.ppm_common, obj.input.spectra.ppm_2D, obj.input.ppm_common2D );

            else

                [ obj.tmp.X, obj.tmp.ppm, obj.tmp.vargout ] = JTPinterpolateSpectra( obj.input.spectra.X, obj.input.spectra.getXScale(), 'PPM', obj.input.ppm_common );

            end

        end


        % Parse the model output
        function [obj] = parseOutput( obj )

            interpolated_spectra = obj.input.spectra;

            interpolated_spectra = interpolated_spectra.setName( 'csm_interpolate_nmr interpolated data' );
            interpolated_spectra = interpolated_spectra.setX( obj.tmp.X );

            interpolated_spectra = interpolated_spectra.setXScale( obj.tmp.ppm, 'ppm' );

            obj.output.interpolated_spectra = interpolated_spectra;

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_wrapper( obj );

        end


    end

end
