classdef csm_import_spectra_hdf < csm_import_spectra_base
% CSM_IMPORT_SPECTRA_HDF - Import a spectra object into a HDF file
%
% Usage:
%
% 	csm_import_spectra_hdf( 'filename', filename )
%
% Arguments:
%
%	filename : (str) Full Path to filename. Default will prompt.
%
% Returns:
%
%   csm_import_spectra_hdf.spectra : (csm_spectra) The imported spectra.
%
% Description:
%
%	Import a HDF file containing information describing a csm_spectra
%	object.
%   Format: 
%           /spectra/X
%           /spectra/is_continuous
%           /spectra/name
%           /spectra/sample_ids
%           /spectra/sample_metadata
%           /spectra/sample_type
%           /spectra/x_scale
%           /spectra/x_scale_name
%           /spectra/nmr_experiment_info
%           /spectra/nmr_calibration_info
%           /spectra/ms_features
%           /spectra/ms_type
%           /hdf_metadata/matlab/spectra_class
%           /hdf_metadata/matlab/audit_info
%           /hdf_metadata/matlab/<extra metadata>
%           /hdf_metadata/hdf_version
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties
       
        tmp = struct;
        datasets_in_spectra;
        
    end    

    methods

        % Constructor for csm_rspa
        function [obj] = csm_import_spectra_hdf( varargin )
            
            % Allows creation of empty objects for cloning
            
            obj = obj@csm_import_spectra_base( varargin );
            
            obj.datasets_in_spectra = {};
            
            obj = importHDFMetadata( obj );

            % Create the empty spectra class
            if strcmp( obj.spectra_class, 'csm_nmr_spectra')
                obj.tmp.spectra = csm_nmr_spectra();
            elseif strcmp( obj.spectra_class, 'csm_jres_spectra')
                obj.tmp.spectra = csm_jres_spectra();
            elseif strcmp( obj.spectra_class, 'csm_ms_spectra')
                obj.tmp.spectra = csm_ms_spectra();
            end            
            
            obj = importGeneralSpectra( obj );
            
            if strcmp( obj.spectra_class, 'csm_nmr_spectra')
               
                obj = importNMRspectraData( obj );
                
            elseif strcmp( obj.spectra_class, 'csm_jres_spectra')
               
                obj = importNMRspectraData( obj );
            
                obj = importJRESspectraData( obj );
                
            elseif strcmp( obj.spectra_class, 'csm_ms_spectra')
                
                obj = importMSspectraData( obj );
                
            end           
            
            obj = createSpectra( obj );
            
            obj.tmp = struct;
                        
        end
        
        function [obj] = importHDFMetadata( obj )
            
            % Read in the existing datasets
            info = h5info(obj.filename,'/hdf_metadata/matlab');

            % Build the dataset lookups
            datasets_in_matlab = cell(1,size(info.Datasets,1));
            for i = 1 : size(info.Datasets,1)
                datasets_in_matlab{ 1, i } = info.Datasets(i).Name;
            end
            
            groups_in_matlab = cell(1,size(info.Groups,1));
            for i = 1 : size(info.Groups,1)
                groups_in_matlab{ 1, i } = info.Groups(i).Name;
            end
           
            % Read in the spectra class
            if any(strcmp(datasets_in_matlab,'spectra_class'))
                obj.tmp.matlab.spectra_class = h5read(obj.filename,'/hdf_metadata/matlab/spectra_class');
                obj.spectra_class = obj.tmp.matlab.spectra_class;
            else
                obj.spectra_class = 'unknown';                
            end    
               
            % Import audit info
            if any(strcmp(groups_in_matlab,'/hdf_metadata/matlab/audit_info'))
                obj = importAuditInfo( obj );
            end
            
        end    
        
        % Imports information relevant to all spectra.
        function [obj] = importGeneralSpectra( obj )

            % Read in the existing datasets
            info = h5info(obj.filename,'/spectra/');
            for i = 1 : size(info.Datasets,1)
                obj.datasets_in_spectra{ end + 1 } = info.Datasets(i).Name;
            end 
        
            % Import the X Dataset
            if any(strcmp(obj.datasets_in_spectra,'X')) && ~isa( obj.tmp.matlab.spectra_class, 'csm_jres_spectra' )
                obj = importXDataset( obj );
            end    
            
            % Import Sample Metadata            
            if any(strcmp(obj.datasets_in_spectra,'sample_metadata'))
                obj = importSampleMetadata( obj );
            end    
            
            % Import the object name
            if any(strcmp(obj.datasets_in_spectra,'name'))
                obj.tmp.spectra.name = h5read(obj.filename,'/spectra/name');
            end
               
            % Import the is_continuous flag
            if any(strcmp(obj.datasets_in_spectra,'is_continuous'))
                obj.tmp.spectra.is_continuous = h5read(obj.filename,'/spectra/is_continuous');
            end
           
            % Import the x_scale_name
            if any(strcmp(obj.datasets_in_spectra,'x_scale_name'))
                obj.tmp.spectra.x_scale_name = h5read(obj.filename,'/spectra/x_scale_name');
            end
                
            % Import the x_scale
            if any(strcmp(obj.datasets_in_spectra,'x_scale'))
                obj.tmp.spectra.x_scale = h5read(obj.filename,'/spectra/x_scale')';
            end
                
            % Import the sample_ids
            if any(strcmp(obj.datasets_in_spectra,'sample_ids'))
                obj.tmp.spectra.sample_ids = h5read(obj.filename,'/spectra/sample_ids')';
            end
           
            % import the sample type
            if any(strcmp(obj.datasets_in_spectra,'sample_type'))
                obj.tmp.spectra.sample_type = h5read(obj.filename,'/spectra/sample_type');
            end    
         
        end
        
        % Import the NMR specific Data
        function [obj] = importNMRspectraData( obj )
            
            % Import the NMR Experiment Info
            if any(strcmp(obj.datasets_in_spectra,'nmr_experiment_info'))
                obj = importNMRExperimentInfo( obj );
            end
            
            % Import the NMR Experiment Info
            if any(strcmp(obj.datasets_in_spectra,'nmr_calibration_info'))
                obj = importNMRCalibrationInfo( obj );
            end
            
            % Import the pulse_program
            if any(strcmp(obj.datasets_in_spectra,'pulse_program'))
                % / pulse_program / <spectra.pulse_program>
                obj.tmp.spectra.pulse_program = h5read(obj.filename,'/spectra/pulse_program');
            end
            
        end
        
        % Import the JRES specific Data
        function [obj] = importJRESspectraData( obj )
            
            % Import the JRES spectra
            if any(strcmp(obj.datasets_in_spectra,'X'))
                obj = import2DXDataset( obj );
            end
            
            % Import the JRES PPM
            if any(strcmp(obj.datasets_in_spectra,'ppm2D'))
                obj.tmp.spectra.ppm2D = h5read(obj.filename,'/spectra/ppm2D');
            end
            
        end
        
        % Import the JRES specific Data
        function [obj] = importMSspectraData( obj )
            
            % Import the JRES spectra
            if any(strcmp(obj.datasets_in_spectra,'ms_features'))
                obj = importMSFeatures( obj );
            end
            
            % Import the JRES PPM
            if any(strcmp(obj.datasets_in_spectra,'ms_type'))
                obj.tmp.spectra.ms_type = h5read(obj.filename,'/spectra/ms_type');
            end
            
        end
        
        % Import the audit info
        function [obj] = importAuditInfo( obj )
            
            % Read in the existing datasets
            info = h5info(obj.filename,'/hdf_metadata/matlab/audit_info/');

            datasets_in_audit_info = cell(1,size(info.Datasets,1));
            for i = 1 : size(info.Datasets,1)
                datasets_in_audit_info{ 1, i } = info.Datasets(i).Name;
            end
           
            obj.tmp.audit_info = csm_audit_info('is_empty',true);
            
            % Import the csm_toolbox_version
            if any(strcmp(datasets_in_audit_info,'csm_toolbox_version'))
                obj.tmp.audit_info.csm_toolbox_version = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/csm_toolbox_version');
            end
            
            % Import the datetime_created
            if any(strcmp(datasets_in_audit_info,'datetime_created'))
                obj.tmp.audit_info.datetime_created = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/datetime_created');
            end
            
            % Import the java_version
            if any(strcmp(datasets_in_audit_info,'java_version'))
                obj.tmp.audit_info.java_version = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/java_version');
            end
            
            % Import the licence_number
            if any(strcmp(datasets_in_audit_info,'licence_number'))
                obj.tmp.audit_info.licence_number = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/licence_number');
            end
            
            % Import the csm_toolbox_version
            if any(strcmp(datasets_in_audit_info,'csm_toolbox_version'))
                obj.tmp.audit_info.csm_toolbox_version = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/csm_toolbox_version');
            end
            
            % Import the matlab_version
            if any(strcmp(datasets_in_audit_info,'matlab_version'))
                obj.tmp.audit_info.matlab_version = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/matlab_version');
            end
            
            % Import the operating_system
            if any(strcmp(datasets_in_audit_info,'operating_system'))
                obj.tmp.audit_info.operating_system = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/operating_system');
            end
            
            % Import the registered_email
            %if any(strcmp(datasets_in_audit_info,'registered_email'))
            %    obj.tmp.audit_info.registered_email = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/registered_email');
            %end
            
            % Import the username
            if any(strcmp(datasets_in_audit_info,'username'))
                obj.tmp.audit_info.username = h5read(obj.filename,'/hdf_metadata/matlab/audit_info/username');
            end
            
        end
        
        % Clone the created spectra for returning
        function [obj] = createSpectra( obj )
            
            obj.spectra = obj.tmp.spectra;
            
            obj.spectra.audit_info = obj.tmp.audit_info;
            
        end
        
        % Import the sample Metadata
        function [obj] = importSampleMetadata( obj )
           
            % Read the data into a struct
            metadata_struct = h5read(obj.filename,'/spectra/sample_metadata/');
            
            % Instantiate the model
            obj.tmp.spectra.sample_metadata = csm_sample_metadata();
            obj.tmp.spectra.sample_metadata.dynamic_field_names = h5read(obj.filename,'/hdf_metadata/matlab/sample_metadata/dynamic_field_names')';
            obj.tmp.spectra.sample_metadata.filename = h5read(obj.filename,'/hdf_metadata/matlab/sample_metadata/filename');
            
            
            fields = fieldnames(metadata_struct);
            
            entries = containers.Map;
            
            for i = 1:numel(metadata_struct.Sample_ID)
            
                sample_metadata_entry = csm_sample_metadata_entry();
                
                sample_id = metadata_struct.Sample_ID{i,1};
                
                for p = 1 : numel( fields )
                    
                    % Determine if cell or array
                    if iscell(metadata_struct.(fields{p}))
                        sample_metadata_entry.addDynamicField( fields{p}, metadata_struct.(fields{p}){i,1} ); 
                    else
                        sample_metadata_entry.addDynamicField( fields{p}, metadata_struct.(fields{p})(i,1) ); 
                    end    
                     
                end
                
                entries( sample_id ) = sample_metadata_entry;
            end    
            
            % Assign the container.
            obj.tmp.spectra.sample_metadata.entries = entries;
            
        end    
        
        function [obj] = importNMRExperimentInfo( obj )
            
            % Read the data into a struct
            metadata_struct = h5read(obj.filename,'/spectra/nmr_experiment_info/');
            
            % Instantiate the model
            obj.tmp.spectra.nmr_experiment_info = csm_nmr_experiment_info();
            
            fields = fieldnames(metadata_struct);
            
            entries = containers.Map;
            
            for i = 1:numel(metadata_struct.Sample_ID)
            
                experiment_info_entry = csm_nmr_experiment_info_entry();
                
                sample_id = metadata_struct.Sample_ID{i,1};
                
                experiment_info_entry.setSampleID(sample_id);
                
                if any(strcmp(fields,'Experiment_Number'))
                    experiment_info_entry.setExperimentNumber( metadata_struct.Experiment_Number{i,1});
                end
                
                if any(strcmp(fields,'Experiment_Folder'))
                    experiment_info_entry.setExperimentFolder( metadata_struct.Experiment_Folder{i,1});
                end
                
                if any(strcmp(fields,'Rack'))
                    experiment_info_entry.setRack( metadata_struct.Rack{i,1});
                end
                
                if any(strcmp(fields,'Rack_Position'))
                    experiment_info_entry.setRackPosition( metadata_struct.Rack_Position{i,1} );
                end
                
                if any(strcmp(fields,'Instrument'))
                    experiment_info_entry.setInstrument( metadata_struct.Instrument{i,1} );
                end
                
                if any(strcmp(fields,'Acquisition_Batch'))
                    experiment_info_entry.setAcquisitionBatch( metadata_struct.Acquisition_Batch{i,1} );
                end
                
                if any(strcmp(fields,'Peak_Width'))
                    experiment_info_entry.setPeakWidth( metadata_struct.Peak_Width{i,1} );
                end
                
                if any(strcmp(fields,'Instrument'))
                    experiment_info_entry.setInstrument( metadata_struct.Instrument{i,1} );
                end
                
                if any(strcmp(fields,'spectratrometer_Frequency'))
                   experiment_info_entry.setspectratrometerFrequency( metadata_struct.spectratrometer_Frequency{i,1} );
                end
                
                if any(strcmp(fields,'Unique_ID'))
                    experiment_info_entry.setUniqueID( metadata_struct.Unique_ID{i,1} );
                end
                
                entries( sample_id ) = experiment_info_entry;
            
            end 
            
            % Assign the container.
            obj.tmp.spectra.nmr_experiment_info.entries = entries;
            
        end
        
        function [obj] = importNMRCalibrationInfo( obj )
            
            % Read the data into a struct
            metadata_struct = h5read(obj.filename,'/spectra/nmr_calibration_info/');
            
            % Instantiate the model
            obj.tmp.spectra.nmr_calibration_info = csm_nmr_calibration_info();
            
            fields = fieldnames(metadata_struct);
            
            entries = containers.Map;

            for i = 1:numel(metadata_struct.Sample_ID)
            
                experiment_info_entry = csm_nmr_calibration_info_entry();
                
                sample_id = metadata_struct.Sample_ID{i,1};
                
                experiment_info_entry.setSampleID(sample_id);
                
                if any(strcmp(fields,'Sample_Type'))
                    experiment_info_entry.setSampleType( metadata_struct.Sample_Type{i,1});
                end
                
                if any(strcmp(fields,'Calibration_Type'))
                    experiment_info_entry.setCalibrationType( metadata_struct.Calibration_Type{i,1});
                end
                
                if any(strcmp(fields,'Calibration_Ref_Point'))
                    experiment_info_entry.setCalibrationRefPoint( metadata_struct.Calibration_Ref_Point(i,1));
                end
                
                if any(strcmp(fields,'Calibration_Search_Min'))
                    experiment_info_entry.setCalibrationSearchMin( metadata_struct.Calibration_Search_Min(i,1) );
                end
                
                if any(strcmp(fields,'Calibration_Search_Max'))
                    experiment_info_entry.setCalibrationSearchMax( metadata_struct.Calibration_Search_Max(i,1) );
                end

                entries( sample_id ) = experiment_info_entry;
            
            end
            
            % Assign the container.
            obj.tmp.spectra.nmr_calibration_info.entries = entries;
            
        end
        
        function [obj] = importMSFeatures( obj )
            
            % Read the data into a struct
            metadata_struct = h5read(obj.filename,'/spectra/ms_features/');
            
            % Instantiate the model
            obj.tmp.spectra.ms_features = csm_ms_features();
            
            fields = fieldnames(metadata_struct);
            
            features = containers.Map;
            
            for i = 1:numel(fields)
            
                features(fields{i}) = metadata_struct.(fields{i});
                
            end
            
            % Assign the container.
            obj.tmp.spectra.ms_features.features = features;
            
            obj.tmp.spectra.ms_features.feature_identifiers = h5read(obj.filename,'/hdf_metadata/matlab/ms_features/feature_identifiers')';
            
        end
        

        % Write the spectra to the HDF file
        function [obj] = importXDataset( obj )
            
            obj.tmp.spectra.X = h5read(obj.filename,'/spectra/X')';

        end
        
               
        % Write the pulse program to the file
        function [obj] = importPulseProgram( obj )
           
            % / pulse_program / <spectra.pulse_program>
            obj.tmp.pulse_program = h5read(obj.filename,'/spec/pulse_program');
            
        end
        
        
    end

end

        
