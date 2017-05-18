classdef csm_bruker_acquisition_data_entry
% CSM_BRUKER_ACQUISITION_DATA_ENTRY - Container for Bruker Acquisition Metadata
%
% Usage:
%
% 	brukerData = csm_bruker_acquisition_data_entry( )
%
% Returns:
%
%	unique_id : (str) The sample Unique ID. Formed of experiment_folder +	experiment_number.
%	spectrum_path : (str) The full path the spectrum.
%	experiment_folder : (str) The experiment Folder.
%	experiment_number : (str) The experiment Number.
%	pulse_program : (str) The Pulse Program.
%	spectrometer_frequency : (str) The spectrometer Frequency.
%	computer : (str) The computer used.
%	time_of_acquisition : (str) The Time of Acquisition.
%	automation_file : (str) The Automation File.
%	P1_value : (str) The P1 Value.
%	O1_value : (str) The O1 Value.
%	title_file_content : (str) The Title File content.
%
% Methods:
%
%   csm_bruker_acquisition_data_entry.setspectrumPath() : Set the spectrum_path;
%   csm_bruker_acquisition_data_entry.setExperimentFolder() : Set the experiment_folder;
%   csm_bruker_acquisition_data_entry.setExperimentNumber() : Set the experiment_number;
%   csm_bruker_acquisition_data_entry.setUniqueID() : Set the unique_id;
%   csm_bruker_acquisition_data_entry.setPulseProgram() : Set the pulse_program;
%   csm_bruker_acquisition_data_entry.setspectratrometerFrequency() : Set the spectrometer_frequency;
%   csm_bruker_acquisition_data_entry.setComputer() : Set the computer;
%   csm_bruker_acquisition_data_entry.setTimeOfAcquisition() : Set the time_of_acquisition;
%   csm_bruker_acquisition_data_entry.setAutomationFile() : Set the automation_file;
%   csm_bruker_acquisition_data_entry.setP1Value() : Set the P1_value;
%   csm_bruker_acquisition_data_entry.setO1Value() : Set the O1_value;
%   csm_bruker_acquisition_data_entry.setTitleFileContent() : Set the title_file_content;
%
% Description:
%
%	This container is used for holding the Bruker spectral metadata during csm_import_nmr.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014 

% Author - Gordon Haggart 2014

    properties( SetAccess = private, GetAccess = public )

        unique_id;
        spectrum_path;
        experiment_folder;
        experiment_number;
        pulse_program;
        spectrometer_frequency;
        computer;
        time_of_acquisition;
        automation_file;
        P1_value;
        O1_value;
        title_file_content;

    end

    methods

        function [obj] = setUniqueID( obj, unique_id )

            obj.unique_id = unique_id;

        end

        function [obj] = setspectrumPath( obj, spectrum_path )

            obj.spectrum_path = spectrum_path;

        end

        function [obj] = setExperimentNumber( obj, experiment_number )

            obj.experiment_number = experiment_number;

        end

        function [obj] = setExperimentFolder( obj, experiment_folder )

            obj.experiment_folder = experiment_folder;

        end

        function [obj] = setPulseProgram( obj, pulse_program )

            obj.pulse_program = pulse_program;

        end

        function [obj] = setspectratrometerFrequency( obj, spectrometer_frequency )

            obj.spectrometer_frequency = spectrometer_frequency;

        end

        function [obj] = setComputer ( obj, computer )

            obj.computer = computer;

        end

        function [obj] = setTimeOfAcquisition( obj, time_of_acquisition )

            obj.time_of_acquisition = time_of_acquisition;

        end

        function [obj] = setAutomationFile( obj, automation_file )

            obj.automation_file = automation_file;

        end

        function [obj] = setP1Value( obj, P1_value )

            obj.P1_value = P1_value;

        end

        function [obj] = setO1Value( obj, O1_value )

            obj.O1_value = O1_value;

        end

        function [obj] = setTitleFileContent( obj, title_file_content )

            obj.title_file_content = title_file_content;

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

