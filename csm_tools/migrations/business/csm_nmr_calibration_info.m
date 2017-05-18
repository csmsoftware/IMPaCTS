classdef csm_nmr_calibration_info
% CSM_NMR_CALIBRATION_INFO - CSM Import NMR Experiment Info Class
%
% Usage:
%
% 	calibration_info = csm_nmr_calibration_info( calibrationInfoPath );
%
% Arguments:
%
%	filename : (str) Full path to calibration info file.
%
% Returns:
%
%   filename : (str) Full path to calibration info file.
%   entries : (containers.Map) Container for calibration info.
%   sample_ids : (cell) Cell array of sample ids.
%
% Description:
%
%	Imports the spectra info file used for mapping samples to experiments
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        % key = sampleID, value = csm_nmr_experiment_info()
        entries;

        sample_ids;
        
        filename;
        
        sample_id_order;

    end

    methods


        % Constructor
        function [obj] = csm_nmr_calibration_info(  )

            obj.entries = containers.Map ();

            obj.sample_ids = {};
            obj.sample_id_order = {};
        
        end

        % Gets a tabular version of the spectra info rows.
        function table = getTable( obj )

            cell_arr = {};
            col_names = {};

            % Loop through all the unique IDs

            for i = 1 : length( obj.sample_id_order )

                if i == 1

                    col_names{ end + 1 } = 'Sample_ID';
                    col_names{ end + 1 } = 'Sample_Type';
                    col_names{ end + 1 } = 'Calibration_Type';
                    col_names{ end + 1 } = 'Calibration_Ref_Point';
                    col_names{ end + 1 } = 'Calibration_Search_Min';
                    col_names{ end + 1 } = 'Calibration_Search_Max';

                end

                nmr_calibration_info_entry = obj.entries( obj.sample_id_order{ i } );

                cell_arr{ i, 1 } = nmr_calibration_info_entry.sample_id;

                cell_arr{ i, 2 } = nmr_calibration_info_entry.sample_type;

                cell_arr{ i, 3 } = nmr_calibration_info_entry.calibration_type;

                cell_arr{ i, 4 } = nmr_calibration_info_entry.calibration_ref_point;

                cell_arr{ i, 5 } = nmr_calibration_info_entry.calibration_search_min;

                cell_arr{ i, 6 } = nmr_calibration_info_entry.calibration_search_max;

            end

            table = cell2table( cell_arr );

            table.Properties.VariableNames = col_names;

        end

        % Removes any sampleInfo entries that are not in the sampleID list.
        function [obj] = removeMissingEntries( obj, sample_ids )

            all_sample_ids = keys( obj.entries );

            % Nothing to do, they should match.
            if length( all_sample_ids ) == length (sample_ids)

                return;

            end

            index = ismember( all_sample_ids, sample_ids );

            for i = 1 : length( index )

                if index( i ) == 0

                    % It wasnt imported....

                    remove( obj.entries, all_sample_ids{ i } );

                end

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

