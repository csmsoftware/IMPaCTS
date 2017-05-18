classdef csm_nmr_experiment_info
% CSM_NMR_SPECTRA_INFO Container for NMR spectra info
%
% Usage:
%
% 	csm_nmr_experiment_info( );
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
%	Container for the NMR experiment info.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        entries;

        sample_ids;
        
        filename;
        
        unique_id_order;

    end

    methods

        function [obj] = csm_nmr_experiment_info()

            obj.entries = containers.Map;

            obj.sample_ids = {};
            obj.unique_id_order = {};
            
        end

        % Gets a tabular version of the spectra info rows.
        function table = getTable( obj )

            cell_arr = {};
            col_names = {};

            % Loop through all the unique IDs

            for i = 1 : length( obj.unique_id_order )

                if i == 1

                    col_names{ end + 1 } = 'Unique_ID';
                    col_names{ end + 1 } = 'Sample_ID';
                    col_names{ end + 1 } = 'Experiment_Number';
                    col_names{ end + 1 } = 'Experiment_Folder';
                    col_names{ end + 1 } = 'Rack';
                    col_names{ end + 1 } = 'Rack_Position';
                    col_names{ end + 1 } = 'Instrument';
                    col_names{ end + 1 } = 'Acquisition_Batch';

                end

                entry = obj.entries( obj.unique_id_order{ i } );

                cell_arr{ i, 1 } = entry.unique_id;

                cell_arr{ i, 2 } = entry.sample_id;

                cell_arr{ i, 3 } = entry.experiment_number;

                cell_arr{ i, 4 } = entry.experiment_folder;

                cell_arr{ i, 5 } = entry.rack;

                cell_arr{ i, 6 } = entry.rack_position;

                cell_arr{ i, 7 } = entry.instrument;

                cell_arr{ i, 8 } = entry.acquisition_batch;
                
            end

            table = cell2table( cell_arr );

            table.Properties.VariableNames = col_names;

        end

        % Removes any sampleInfo entries that are not in the sample_id list.
        function [obj] = removeMissingEntries( obj, sample_ids )

            unique_ids = keys( obj.entries );

            X = [];

            uniqueIDsToKeep = {};

            for i = 1 : length( unique_ids )

                nmr_experiment_info_entry = obj.entries( unique_ids{ i } );

                if isempty(find(ismember(sample_ids,nmr_experiment_info_entry.sample_id),1))

                    remove(obj.entries,unique_ids{i});

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

