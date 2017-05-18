classdef csm_nmr_calibration_info_entry
% CSM_NMR_CALIBRATION_INFO_ENTRY - Entry for csm_nmr_calibration data.
%
% Usage:
%
% 	csm_nmr_calibration_info_entry( );
%
% Returns:
%
%	sample_id : (str) The sample ID.
%	sample_type : (str) Urine/Plasma/Serum/etc.
%	calibration_type : (str) Peak to calibrate against, glucose, TSP, single.
%	calibration_ref_point : (str) Must be filled in if calibration_type is single.
%	calibration_search_min : (1*1) Must be filled in if calibration_type is single.
%	calibration_search_max : (1*1) Must be filled in if calibration_type is single.
%
% Methods:
%
%   csm_nmr_calibration_info_entry.setSampleID() : Set the sample_id;
%   csm_nmr_calibration_info_entry.setSampleType() : Set the sample_type;
%   csm_nmr_calibration_info_entry.setCalibrationType() : Set the calibration_type;
%   csm_nmr_calibration_info_entry.setCalibrationRefPoint() : Set the calibration_ref_point;
%   csm_nmr_calibration_info_entry.setCalibrationSearchMin() : Set the calibration_search_min;
%   csm_nmr_calibration_info_entry.setCalibrationSearchMax() : Set the calibration_search_max;
%
% Description:
%
%	Container for the NMR calibration info.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014 

% Author - Gordon Haggart 2014

    properties
        
        sample_id;

        % Urine/Plasma/Serum/etc
        sample_type;

        % Peak to calibrate against, glucose, TSP, single
        calibration_type;

        % Must be filled in if calibration_type is single.
        calibration_ref_point;

        % Must be filled in if calibration_type is single.
        calibration_search_min;

        % Must be filled in if calibration_type is single.
        calibration_search_max;

    end

    methods

        function [obj] = setSampleID( obj, sample_id )

            obj.sample_id = num2str( sample_id );

        end

        function [obj] = setSampleType( obj, sample_type )

            obj.sample_type = sample_type;

        end

        function [obj] = setCalibrationType( obj, calibration_type )

            obj.calibration_type = calibration_type;

        end

        function [obj] = setCalibrationRefPoint( obj, calibration_ref_point )

            if ischar( calibration_ref_point )

                obj.calibration_ref_point = str2double( calibration_ref_point );

            else

                obj.calibration_ref_point = calibration_ref_point;

            end

        end

        function [obj] = setCalibrationSearchMin( obj, calibration_search_min )

            if ischar( calibration_search_min )

                obj.calibration_search_min = str2double( calibration_search_min );

            else

                obj.calibration_search_min = calibration_search_min;

            end

        end

        function [obj] = setCalibrationSearchMax( obj, calibration_search_max )

            if ischar( calibration_search_max )

                obj.calibration_search_max = str2double( calibration_search_max );

            else

                obj.calibration_search_max = calibration_search_max;

            end

        end

        % Dynamic property loader ** REQUIRED FUNCTION **
        function [obj] = setProperty( obj, fieldName, fieldValue )

            if isprop( obj, fieldName )

                if ischar( fieldValue )

                    eval( strcat( 'obj.', fieldName, ' = ''', fieldValue, ''' ;' ) );

                else

                    eval( strcat( 'obj.', fieldName, ' = fieldValue ;' ) );

                end

            end

        end

    end

end

