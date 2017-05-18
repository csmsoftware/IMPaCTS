classdef csm_jres_spectra < csm_nmr_spectra
%CSM_JRES_SPECTRA - CSM JRES spectra Data object.
%
% Usage:
%
% 	spectra = csm_jres_spectra( X, ppm, ppm_2D );
%	spectra = csm_jres_spectra( X, ppm, ppm_2D, 'name', name, 'is_continous', is_continuous, 'sample_ids', sample_ids, 'sampleInfo', sampleInfo, 'is_continuous', is_continuous )
%
% Arguments:
%
%	*X : (m*n) spectral matrix.
%	*ppm : (1*n) PPM Scale.
%	*ppm_2D : (1*n) JRES 2D PPM scale.
%
%	name : (str) Name of the data structure.
%   is_continuous : (bool) Whether the x scale is continuous. Default true.
%	sample_ids : (cell) Sample IDs, use the numeric index to match to the row. Default {}.
%	sample_metadata : (csm_sample_metadata) Metadata from import.
%
% Returns:
%
%	csm_nmr_spectra : (csm_nmr_spectra) Csm NMR spectra object.
%	csm_nmr_spectra.X : (m*n) spectral Matrix.
%	csm_nmr_spectra.ppm : (1*n) PPM Scale.
%	csm_nmr_spectra.ppm_2D : (1*n) PPM JRES Scale.
%	csm_nmr_spectra.name : (str) Name for the spectra.
%	csm_nmr_spectra.sample_ids : (cell) Sample IDs, using a numeric index.
%	csm_nmr_spectra.sample_metadata : (csm_import_sample_metadata) Metadata from import.
%	csm_nmr_spectra.audit_info : (csm_audit_info) Audit Info object.
%
% Methods:
%   
%	csm_nmr_spectra.setPPM2D( ppm_2D ) : Assign a new JRES PPM to the object.
%
% Description:
%
%	NMR JRES spectral Object. Contains X, PPM, PPM 2D scale and various metadata.
%
%	Extends csm_nmr_spectra; see csm_nmr_spectra for more information.
%   
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        ppm_2D

    end

    methods

        % Constructor
        function [obj] = csm_jres_spectra( X, ppm, ppm_2D, varargin )
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                X = [];
                ppm = [];
                ppm_2D = [];
            end    

            obj = obj @ csm_nmr_spectra( X, ppm, varargin{:} );

            obj = setPPM2D( obj, ppm_2D );

        end


        % Assigns JRES info
        function [obj] = setPPM2D( obj, ppm_2D )

            obj.ppm_2D = ppm_2D;

        end

    end

end

