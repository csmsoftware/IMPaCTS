classdef csm_export_spectra_hdf < csm_export_spectra_base
% CSM_EXPORT_SPECTRA_HDF - Export a spectra object into a HDF file
%
% Usage:
%
% 	csm_export_spectra_hdf( spectra, 'filename', filename, 'overwrite', overwrite )
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%
%	filename : (str) Full Path to filename. Default will prompt.
%	overwrite : (bool) Set to true to overwrite files. Default is false.
%
% Returns:
%
%   file_id : (1x1) File identifier to the file.
%   file_overwite : (bool) Overwrite an existing file.
%   spectra : (str) Full path to NMR experiment file.
%   imported_data : (str) Full path to NMR calibration file.
%   spectra : (csm_spectra) Exported spectra file.
%   spectra_class : (str) Class of the spectra.
%
% Description:
%
%	Export a csm_spectra object to a HDF file.
%   Format: 
%           /spectra/X
%           /spectra/is_continuous
%           /spectra/name
%           /spectra/sample_ids
%           /spectra/sample_metadata
%           /spectra/sample_type
%           /spectra/x_scale
%           /spectra/x_scale_name
%           /hdf_metadata/matlab/spectra_class
%           /hdf_metadata/matlab/audit_info
%           /hdf_metadata/hdf_version
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties
       
        file_id;
        file_overwrite;
        hdf_format_version;
    
    end    

    methods

        % Constructor for csm_rspa
        function [obj] = csm_export_spectra_hdf( spectra, varargin )
            
            obj = obj@csm_export_spectra_base( spectra, varargin );
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.hdf_format_version = '0.1';
            
            obj.file_overwrite = false;
            k = 1;
            while k < numel( varargin )
                
                % If it exists, set it and break
                if strcmp( varargin{k}, 'overwrite')
                    
                    obj.file_overwrite = true;
                    break;                    
                end
                
                k = k + 2;
                
            end    
            
            obj = createFile( obj );
            
            obj = exportHDFMetadata( obj );
            
            obj = exportGeneralSpectraData( obj );
            
            if isa( obj.spectra, 'csm_nmr_spectra')
               
                 obj = exportNMRspectraData( obj );
                
            elseif isa( obj.spectra, 'csm_jres_spectra')
               
                obj = exportNMRspectraData( obj );
            
                obj = exportJRESspectraData( obj );
                
            elseif isa( obj.spectra, 'csm_ms_spectra')
                
                obj = exportMSspectraData( obj );
                
            end
       
            H5F.close(obj.file_id);
           
        end
        
        % Writes the spec data shared by all types
        function [obj] = exportGeneralSpectraData( obj )
           
            csm_hdf_tools.createGroup( obj.file_id, '/spectra/' );
            
             % Write out the X Dataset
            if ~isempty( obj.spectra.X) && ~isa( obj.spectra_class, 'csm_jres_spectra' )
                obj = exportXDataset( obj );
            end
            
            % Write out the X Scale
            if ~isempty( obj.spectra.x_scale)
                obj = exportXScale( obj );
            end
            
            % Write out the Sample IDs
            if ~isempty( obj.spectra.sample_ids)
                obj = exportSampleIDs( obj );
            end
            
            % Write out the sample metadata
            if ~isempty( obj.spectra.sample_metadata)
                csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/sample_metadata',obj.spectra.sample_metadata.getTable());
                
                % Write the matlab specific metadata
                csm_hdf_tools.createGroup(obj.file_id, '/hdf_metadata/matlab/sample_metadata');
                csm_hdf_tools.writeString( obj.file_id,  '/hdf_metadata/matlab/sample_metadata/filename', obj.spectra.sample_metadata.filename )
                csm_hdf_tools.writeArray(obj.file_id,'/hdf_metadata/matlab/sample_metadata/dynamic_field_names',obj.spectra.sample_metadata.dynamic_field_names);

            end
            
            % Write out the sample type (Serum/Plasma etc)
            if ~isempty( obj.spectra.sample_type)
                obj = exportSampleType( obj );
            end
            
            % Write out the spec name
            if ~isempty( obj.spectra.name)
                obj = exportName( obj );
            end
            
            % export out is_continuous
            if ~isempty( obj.spectra.is_continuous)
                obj = export_is_continuous( obj );
            end
            
        end 
        
        % Write the NMR specific Data
        function [obj] = exportNMRspectraData( obj )
            
            % Write the NMR Experiment Info
            if ~isempty( obj.spectra.nmr_calibration_info)
                csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/nmr_calibration_info',obj.spectra.nmr_calibration_info.getTable());
                
                % Write the matlab specific metadata
                csm_hdf_tools.createGroup(obj.file_id, '/hdf_metadata/matlab/nmr_calibration_info');
                csm_hdf_tools.writeString( obj.file_id,  '/hdf_metadata/matlab/nmr_calibration_info/filename', obj.spectra.nmr_calibration_info.filename )
            end
            
            % Write the NMR Experiment Info
            if ~isempty( obj.spectra.nmr_experiment_info)
                csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/nmr_experiment_info',obj.spectra.nmr_experiment_info.getTable());
                
                % Write the matlab specific metadata
                csm_hdf_tools.createGroup(obj.file_id, '/hdf_metadata/matlab/nmr_experiment_info');
                csm_hdf_tools.writeString( obj.file_id,  '/hdf_metadata/matlab/nmr_experiment_info/filename', obj.spectra.nmr_experiment_info.filename )
            end
            
            % Write the pulse_program
            if ~isempty( obj.spectra.pulse_program)
                % / pulse_program / <spectra.pulse_program>
                csm_hdf_tools.writeString( obj.file_id, '/spectra/pulse_program/', obj.spectra.pulse_program );
            end
            
        end
        
        function [obj] = exportJRESspectraData( obj )
           
            % Write out the 2D X Dataset
            if ~isempty( obj.spectra.X)
                obj = export2DXDataset( obj );
            end
            
             % Write out the 2D X Dataset
            if ~isempty( obj.spectra.X)
                obj = exportPPM2D( obj );
            end
            
        end
        
        % Exports the MS specific data
        function [obj] = exportMSspectraData( obj )
           
            % MS TYPE & MS FEATURES
            
            if ~isempty( obj.spectra.ms_features )
                csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/ms_features',obj.spectra.ms_features.getTable());
                
                csm_hdf_tools.createGroup(obj.file_id, '/hdf_metadata/matlab/ms_features');
                csm_hdf_tools.writeArray(obj.file_id,'/hdf_metadata/matlab/ms_features/feature_identifiers',obj.spectra.ms_features.feature_identifiers);
            end
                        
            if ~isempty( obj.spectra.ms_type )
                csm_hdf_tools.writeString( obj.file_id, '/spectra/ms_type/', obj.spectra.ms_type );
            end 
            
        end
        
        % Creates the h5 file
        function [obj] = createFile( obj )
           
            if exist(obj.filename, 'file') & false(obj.file_overwrite)
                
                button = questdlg('File exists, do you want to overwrite?');
              
                if strcmp(button,'Yes')
                    
                    fcpl = H5P.create('H5P_FILE_CREATE');
                    fapl = H5P.create('H5P_FILE_ACCESS');
                
                    % create the file first
                    obj.file_id = H5F.create( fix_filesep(obj.filename), 'H5F_ACC_TRUNC', fcpl, fapl );
                    
                else
                    
                    error('File creation terminated');
                    
                end
                
            else
                
                fcpl = H5P.create('H5P_FILE_CREATE');
                fapl = H5P.create('H5P_FILE_ACCESS');
                
                % create the file first
                obj.file_id = H5F.create( fix_filesep(obj.filename), 'H5F_ACC_TRUNC', fcpl, fapl );
                
            end
            
        end    
        
        % Writes the sample metadata
        function [obj] = exportSampleMetadata( obj )
            
            csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/sample_metadata',obj.spectra.sample_metadata.getTable());
            
        end
        
        % Writes the nmr experiment info
        function [obj] = exportNmrExperimentInfo( obj )
            
            csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/nmr_experiment_info',obj.spectra.nmr_experiment_info.getTable());
            
        end
        
        % Writes the nmr calibration info
        function [obj] = exportNmrCalbrationInfo( obj )
            
            csm_hdf_tools.writeCompoundTable(obj.file_id,'/spectra/nmr_calibration_info',obj.spectra.nmr_calibration_info.getTable());
            
        end
        
        % Write out the PPM2D
        function [obj] = exportPPM2D( obj )
            
           % Create a suitable space
            h5_dims = size(obj.spectra.ppm_2D);
            space_id = H5S.create_simple(2,h5_dims,h5_dims);
            
            % Create the dataset
            dataset_id = H5D.create(obj.file_id,'/spectra/ppm_2D/',main_datatype_id,space_id,'H5P_DEFAULT');
            
            % Write the dataset
            H5D.write(dataset_id,main_datatype_id,'H5S_ALL','H5S_ALL','H5P_DEFAULT',obj.spectra.ppm_2D);
            
            H5S.close(space_id);
            H5D.close(dataset_id);
            H5T.close(main_datatype_id); 
            
        end
        
        % Export a 2D dataset
        function [obj] = export2DXDataset( obj )
           
            % not implemented
            
        end    

        % Write the spectra to the HDF file
        function [obj] = exportXDataset( obj )
            
            % The datatype
            datatype_id = H5T.copy('H5T_NATIVE_DOUBLE');
            
            % Create a suitable space
            h5_dims = size(obj.spectra.X);
            space_id = H5S.create_simple(2,h5_dims,h5_dims);
            
            % Create the dataset
            dataset_id = H5D.create(obj.file_id,'/spectra/X/',datatype_id,space_id,'H5P_DEFAULT');
            
            % Write the dataset
            H5D.write(dataset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',obj.spectra.X');
            
            H5T.close(datatype_id);
            H5S.close(space_id);
            H5D.close(dataset_id);

        end
        
        % Write the x_scale to the file
        function [obj] = exportXScale( obj )
            
            if iscell(obj.spectra.x_scale)
               
                 main_datatype_id = H5T.copy('H5T_C_S1');
                 H5T.set_size(main_datatype_id,'H5T_VARIABLE');
            else
                
                main_datatype_id = H5T.copy('H5T_NATIVE_DOUBLE');
                
            end
            
            % Create a suitable space
            h5_dims = size(obj.spectra.x_scale);
            space_id = H5S.create_simple(2,h5_dims,h5_dims);
            
            % Create the dataset
            dataset_id = H5D.create(obj.file_id,'/spectra/x_scale/',main_datatype_id,space_id,'H5P_DEFAULT');
            
            % Write the dataset
            H5D.write(dataset_id,main_datatype_id,'H5S_ALL','H5S_ALL','H5P_DEFAULT',obj.spectra.x_scale);
            
            H5S.close(space_id);
            H5D.close(dataset_id);
            H5T.close(main_datatype_id);
            
            % Write the X Scale Name
            stringType = H5T.copy( 'H5T_C_S1' );

            % Set the datatype size.
            H5T.set_size( stringType, numel( obj.spectra.x_scale_name ) );

            % Create a default data space
            space_id = H5S.create( 'H5S_SCALAR' );

            % Create the dataset
            dataset_id = H5D.create( obj.file_id, '/spectra/x_scale_name/', stringType, space_id, 'H5P_DEFAULT' );

            % Write the dataset to the the file.
            H5D.write( dataset_id, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', obj.spectra.x_scale_name );
            
            H5T.close(stringType);
            H5S.close(space_id);
            H5D.close(dataset_id);
            
        end    
            
        % Write the spectra to the HDF file
        function [obj] = exportSampleIDs( obj )
            
            datatype_id = H5T.copy('H5T_C_S1');
            H5T.set_size(datatype_id,'H5T_VARIABLE');

            h5_dims = size(obj.spectra.sample_ids);
            h5_maxdims = h5_dims;
            
            % Create a dataspace for cellstr
            space_id = H5S.create_simple(2,h5_dims,h5_maxdims);

            % Create dataset
            dataset_id = H5D.create(obj.file_id,'/spectra/sample_ids/',datatype_id,space_id,'H5P_DEFAULT');

            % Write data
            H5D.write(dataset_id,datatype_id,'H5S_ALL','H5S_ALL','H5P_DEFAULT',obj.spectra.sample_ids);
            
            H5T.close(datatype_id);
            H5S.close(space_id);
            H5D.close(dataset_id);

        end
        
        % Writes the is continuous flag
        function [obj] = export_is_continuous( obj )
           
            if true(obj.spectra.is_continuous)
               
                % / is_continuous / 'yes'
                csm_hdf_tools.writeString( obj.file_id, '/spectra/is_continuous/', 'yes' );
                
            else
                
                % / is_continuous / 'no'
                csm_hdf_tools.writeString( obj.file_id, '/spectra/is_continuous/', 'no' );                
                
            end    
            
        end
        
        % Write the class type to the file
        function [obj] = exportHDFMetadata( obj )
           
            % /hdf_metadata/
            csm_hdf_tools.createGroup( obj.file_id, '/hdf_metadata/' );
            
            % /hdf_metadata/hdf_format_version/
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/hdf_format_version/', obj.hdf_format_version );
            
            % /hdf_metadata/matlab/
            csm_hdf_tools.createGroup( obj.file_id, '/hdf_metadata/matlab/' );
             
            % /hdf_metadata/matlab/spectra_class/ (csm_nmr_spectra | csm_ms_spectra)            
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/spectra_class/', obj.spectra_class );
            
            % Write out the audit info
            if ~isempty( obj.spectra.audit_info)
                obj = exportAuditInfo( obj );
            end
            
        end
        
        % Write the relevant audit info data to the file
        function [obj] = exportAuditInfo( obj )
            
            csm_hdf_tools.createGroup( obj.file_id, '/hdf_metadata/matlab/audit_info/' );
                        
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/datetime_created/', obj.spectra.audit_info.datetime_created );
            
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/csm_toolbox_version/', obj.spectra.audit_info.csm_toolbox_version );
           
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/matlab_version/', obj.spectra.audit_info.matlab_version );
            
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/operating_system/', obj.spectra.audit_info.operating_system );
            
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/username/', obj.spectra.audit_info.username );
            
            %csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/registered_email/', obj.spectra.audit_info.registered_email );
            
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/licence_number/', obj.spectra.audit_info.licence_number );
            
            csm_hdf_tools.writeString( obj.file_id, '/hdf_metadata/matlab/audit_info/java_version/', obj.spectra.audit_info.java_version );
                        
        end
        
        % Write the sample type to the file
        function [obj] = exportName( obj )
           
            % / name / <spectra.name>
            csm_hdf_tools.writeString( obj.file_id, '/spectra/name/', obj.spectra.sample_type );
            
        end
        
        % Write the sample type to the file
        function [obj] = exportSampleType( obj )
           
            % / sample_type / <spectra.sample_type>
            csm_hdf_tools.writeString( obj.file_id, '/spectra/sample_type/', obj.spectra.sample_type );
            
        end
        
        % Write the pulse program to the file
        function [obj] = exportPulseProgram( obj )
           
            % / pulse_program / <spectra.pulse_program>
            csm_hdf_tools.writeString( obj.file_id, '/spectra/pulse_program/', obj.spectra.pulse_program );
            
        end
                
    end

end
