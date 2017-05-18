classdef csm_nmr_experiment_info_entry
% CSM_NMR_EXPERIMENT_INFO_ENTRY - Container for NMR spectra info
%
% Usage:
%
% 	csm_nmr_experiment_info_entry( );
%
% Returns:
%
%   unique_id : (str) The unique ID, formed of experiment_folder + experiment_number.
%	sample_id : (str) The sample ID.
%	experiment_number : (str) The number given to the experiment.
%	experiment_folder : (str) The folder given to the experiment.
%	rack : (str) The rack number.
%	rack_position : (str) The rack position.
%	acquisition_batch : (1*1) The acquisition batch.
%	instrument : (1*1) The instrument used.
%   spectrometer_frequency : (1*1) spectratrometer frequency
%   peak_width : (m*1) The peak width values.
%
% Methods:
%
%   csm_nmr_experiment_info_entry.setUniqueID() : Set the unique_id.
%   csm_nmr_experiment_info_entry.setSampleID() : Set the sample_id.
%   csm_nmr_experiment_info_entry.setExperimentNumber() : Set the experiment_number.
%   csm_nmr_experiment_info_entry.setExperimentFolder() : Set the experiment_folder.
%   csm_nmr_experiment_info_entry.setRack() : Set the rack.
%   csm_nmr_experiment_info_entry.setRackPosition() : Set the rack_position
%   csm_nmr_experiment_info_entry.setAcquisitionBatch() : Set the acquisition_batch.
%   csm_nmr_experiment_info_entry.setInstrument() : Set the instrument.
%   csm_nmr_experiment_info_entry.setPeakWidth() : Set the peak_width.
%
% Description:
%
%	Container for an NMR experiment info entry.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        unique_id;
        sample_id;
        experiment_number;
        experiment_folder;
        rack;
        rack_position;
        acquisition_batch;
        instrument;
        spectrometer_frequency;
        peak_width;

    end

    methods

        function [obj] = csm_nmr_experiment_info_entry( )

        end

        function [obj] = setUniqueID( obj, unique_id )

            obj.unique_id = unique_id;

        end

        function [obj] = setSampleID( obj, sample_id )

            obj.sample_id = num2str( sample_id );

        end

        function [obj] = setExperimentNumber( obj, experiment_number )

            obj.experiment_number = num2str( experiment_number );

        end

        function [obj] = setExperimentFolder( obj, experiment_folder )

            obj.experiment_folder = experiment_folder;

        end

        function [obj] = setRack( obj, rack )

            obj.rack = rack;

        end

        function [obj] = setRackPosition( obj, rack_position )

            obj.rack_position = rack_position;

        end

        function [obj] = setInstrument( obj, instrument )

            obj.instrument = instrument;

        end

        function [obj] = setPeakWidth( obj, peak_width )

            obj.peak_width = peak_width;

        end

        function [obj] = setAcquisitionBatch ( obj, acquisition_batch )

            obj.acquisition_batch = acquisition_batch;

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

