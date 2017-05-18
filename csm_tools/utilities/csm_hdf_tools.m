classdef csm_hdf_tools < handle
%CSM_HDF_TOOLS - Pain killer class for Matlab low level tools.
%
% Usage:
%
%	csm_hdf( ).method( )
%
% Static Methods:
%
%	csm_hdf_tools.createGroup( file_id, group_name ) : Create a group.
%	csm_hdf_tools.writeString( file_id, dataset_name, string ) : Write a string to the dataset.
%   csm_hdf_tools.writeCompoundTable( file_id, dataset_name, save_table ) : Write a table to the dataset
%
% Description:
%
%	Matlab has high level and low level functions for HDF5. The high level
%	functions are great, see h5create and h5write. However Strings are NOT
%	supported by these functions. Therefore I have provided the following
%	functions for adding strings to HDF files.
%
%	Unlike h5create, if group does not exist, you need to createGroup()	before writeString().
%
%	Use Statically.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2014

% Author - Gordon Haggart 2014


    methods( Static )

        % Create a new group group_name, in the file filePath.
        function createGroup( file_id, group_name )
            
            groupID = H5G.create( file_id, group_name, 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT' );

            H5G.close( groupID );

        end

        % Write a string to the dataset in filePath.
        function writeString( file_id, dataset_name, string )
            
            % Get the String datatype
            stringType = H5T.copy( 'H5T_C_S1' );

            % Set the datatype size.
            H5T.set_size( stringType, numel( string ) );

            % Create a default data space
            spaceID = H5S.create( 'H5S_SCALAR' );

            % Create the dataset
            datasetID = H5D.create( file_id, dataset_name, stringType, spaceID, 'H5P_DEFAULT' );

            % Write the dataset to the the file.
            H5D.write( datasetID, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', string );

            % Close everything
            H5S.close( spaceID );
            H5T.close( stringType );
            H5D.close( datasetID );

        end
        
        % This will write a mixed type table to the open file.
        function [spaceID,datasetID] = writeCompoundTable( file_id, dataset_name, save_table )
            
            % If the table is empty, you can't write it.
            if isempty(save_table)
                spaceID = [];
                datasetID = [];
                return;
            end    
                
           
            save_struct = struct;
            for i = 1 : numel(save_table.Properties.VariableNames)
               
                variable_name = save_table.Properties.VariableNames{i};
                
                save_struct.(variable_name) = save_table.(variable_name)';
                                
            end
            
            variable_data_types = containers.Map;
            
            % Work out the data types for each column
            for i = 1 : numel(save_table.Properties.VariableNames)
               
                variable_name = save_table.Properties.VariableNames{i};
                
                if iscell(save_struct.(variable_name))
                    
                    for p = 1 : size(save_struct.(variable_name),2)
                        
                        if isnan(save_struct.(variable_name){p})
                            save_struct.(variable_name){p} = '';
                        end    
                        
                        if isempty(save_struct.(variable_name){p})
                            save_struct.(variable_name){p} = '';
                        end
                        
                        if ~ischar(save_struct.(variable_name){p})
                            warning(variable_name); 
                        end    
                        
                    end
                    
                    variable_datatype = H5T.copy('H5T_C_S1');
                    H5T.set_size (variable_datatype, 'H5T_VARIABLE'); 
                    variable_data_types(variable_name) = variable_datatype;
                
                elseif isnumeric(save_struct.(variable_name))
                    
                    variable_datatype = H5T.copy('H5T_NATIVE_DOUBLE');
                    variable_data_types(variable_name) = variable_datatype;
                    
                elseif islogical(save_struct.(variable_name))
                    
                    % Convert to double
                    save_struct.(variable_name) = double(save_struct.(variable_name));

                    variable_datatype = H5T.copy('H5T_NATIVE_DOUBLE');
                    variable_data_types(variable_name) = variable_datatype;
                    
                end    
    
            end
            
            mem_size = [];

            % Calculate the memory requirements
            for i = 1 : numel(save_table.Properties.VariableNames)
               
                variable_name = save_table.Properties.VariableNames{i};
                mem_size(i) = H5T.get_size(variable_data_types(variable_name));
                
            end    
            
            % mem_length = 5
            mem_length = numel(mem_size);
            
            % Set the memory offsets
            % mem_size = [8,8,8,8,8]
            % offset = [0,8,16,24,32]
            offset(1) = 0;
            offset(2:mem_length) = cumsum(mem_size(1:(mem_length-1)));
            
            % Create the compound datatype for the file
            % filetype = H5T.create ('H5T_COMPOUND', 40);
            
            filetype = H5T.create ('H5T_COMPOUND', sum(mem_size));
            
            for i = 1 : numel(save_table.Properties.VariableNames)
               
                variable_name = save_table.Properties.VariableNames{i};
                H5T.insert (filetype,variable_name,offset(i),variable_data_types(variable_name));
                                
            end
            
            
            % Create the dataspace
            % dim_size = [48,5]
            
            dim_size = size(save_struct.(save_table.Properties.VariableNames{1}),2);
            
            % space = H5S.create_simple(2,[5, 48], [5, 48]);
            spaceID = H5S.create_simple(1,dim_size, []);
                    
            datasetID = H5D.create (file_id, dataset_name, filetype, spaceID, 'H5P_DEFAULT');
          
            H5D.write (datasetID,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT', save_struct);
            
        end
        
        function [space_id,dataset_id] = writeArray(file_id,dataset_name,data_set)
            
           if iscell(data_set)
               
                 main_datatype_id = H5T.copy('H5T_C_S1');
                 H5T.set_size(main_datatype_id,'H5T_VARIABLE');
            else
                
                main_datatype_id = H5T.copy('H5T_NATIVE_DOUBLE');
                
            end
            
            % Create a suitable space
            h5_dims = size(data_set);
            space_id = H5S.create_simple(2,h5_dims,h5_dims);
            
            % Create the dataset
            dataset_id = H5D.create(file_id,dataset_name,main_datatype_id,space_id,'H5P_DEFAULT');
            
            % Write the dataset
            H5D.write(dataset_id,main_datatype_id,'H5S_ALL','H5S_ALL','H5P_DEFAULT',data_set);
            
            H5S.close(space_id);
            H5D.close(dataset_id);
            H5T.close(main_datatype_id);
            
        end
    end

end

