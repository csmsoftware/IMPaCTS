classdef csm_bruker_acquisition_data
%CSM_IMPORT_BRUKER_ACQUISITION_DATA - CSM Import Bruker Acquisition Data Class
%
% Usage:
%
% 	acquisitionData = csm_bruker_acquisition_data(  );
%
% Returns:
%
%   experiment_path : (str) Full path to experiment folder.
%	entries : (map) Map of the acquired data. Key is sample uniqueID, value is csm_bruker_acquisition_data()
%	pulse_programs : (cell) Array of the distinct pulse programs.
%	pulse_program_experiment_lookup : (cell) Array of the distinct pulse programs.
%
% Description:
%
%	Scans experiment directories and imports Bruker NMR metadata.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        experiment_path;

        % key = uniqueID, value = csm_bruker_acquisition_data()
        entries;

        pulse_programs;

        pulse_program_experiment_lookup;

    end

    methods

        
        % Constructor
        function [obj] = csm_bruker_acquisition_data(  )

            obj.entries = containers.Map;

            obj.pulse_programs = {};

            obj.pulse_program_experiment_lookup = {};


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
