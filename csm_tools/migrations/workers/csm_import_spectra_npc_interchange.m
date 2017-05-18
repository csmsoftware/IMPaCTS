classdef csm_import_spectra_npc_interchange < csm_import_spectra_base
% CSM_IMPORT_SPECTRA_NPC_INTERCHANGE - Import worker for NPC Interchange format
%
% Usage:
%
% 	imported = csm_import_spectra_npc_interchange( 'spec_type', spec_type, 'intensity_file', intensity_file, 'feature_file', feature_file, 'sample_metadata_file', sample_metadata_file );
%
% Arguments:
%
%	spec_type : (str) spectra type. 'MS' or 'NMR'.
%	intensity_file : (str) The intensity file to import.
%	feature_file : (str) The feature file to import.
%	sample_metadata_file : (str) The sample metadata file to import.
%
% Returns:
%
%	imported : (csm_import_spectra_npc_interchange) Import worker with imported spectra.
%   imported.spectra : (csm_spectra) Imported spectra object
%
% Description:
%
%	Import worker for importing from NPC LIMS formats.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties
        
        sample_metadata_file;
        intensity_file;
        feature_file;
        path;
        sample_metadata;
        X;
        sample_ids;
        x_scale;
        x_scale_name;
        ms_features;
         
    end    
    
    methods
        
        function [obj] = csm_import_spectra_npc_interchange(varargin)
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
         
            % Set the output filename
            sample_metadata_file_found = false;
            intensity_file_found = false;
            feature_file_found = false;
            file_found = false;
            k = 1;
            
            while k < numel( varargin )
                
                % If it exists, set it and break
                if strcmp( varargin{k}, 'sample_metadata_file')
                    
                    obj.sample_metadata_file = varargin{k+1};
                    
                    sample_metadata_file_found = true;
                    
                % If it exists, set it and break
                elseif strcmp( varargin{k}, 'intensity_file')
                    
                    obj.intensity_file = varargin{k+1};
                    
                    intensity_file_found = true;
                    
                % If it exists, set it and break
                elseif strcmp( varargin{k}, 'feature_file')
                    
                    obj.feature_file = varargin{k+1};
                    
                    feature_file_found = true;
                
                elseif strcmpi( varargin{k}, 'filename')
                    
                    obj.filename = varargin{k+1};    
                    file_found = true;
                    
                elseif strcmpi( varargin{k}, 'spec_type')
                    
                    obj.spec_type = varargin{k+1};    
                    
                end
                                
                k = k + 2;
                
            end
            
            if file_found
                [obj.path,~,~] = fileparts(obj.filename);
            else
                obj.path = csm_settings.getValue('workspace_path');
            end    
                        
            if ~intensity_file_found
                uiwait(msgbox('Please select the Intensity Data file'));
                [obj.intensity_file,obj.path,~] = uigetfile({strcat(obj.path,'/*_intensityData.csv')},'Please select the Intensity Data file');
            end
            
            if ~sample_metadata_file_found
                uiwait(msgbox('Please select the Sample Metadata file'));
                [obj.sample_metadata_file,~,~] = uigetfile({strcat(obj.path,'/*_sampleMetadata.csv')},'Please select the Sample Metadata file');
            end
            
            if ~feature_file_found
                uiwait(msgbox('Please select the Feature Metadata file'));
                [obj.feature_file,~,~] = uigetfile({strcat(obj.path,'/*_featureMetadata.csv')},'Please select the Feature Metadata file');
            end
            
            if strcmpi( obj.spec_type , 'MS')

                obj = importMS( obj );
               
            elseif strcmpi( obj.spec_type, 'NMR' )
                
                obj = importNMR( obj);
                
            end    
            
        end
        
        function [obj] = importNMR(obj)
            
            obj = importSampleMetadata( obj );
            
            [pathstr,~,~] = fileparts(obj.feature_file);
            
            if strcmp(pathstr,'')
                obj.feature_file = strcat(obj.path,filesep,obj.feature_file);
            end
            
            % ppm
            obj.x_scale = importdata( obj.feature_file );
            
            % X matrix
            
            [pathstr,~,~] = fileparts(obj.intensity_file);
            
            if strcmp(pathstr,'')
                obj.intensity_file = strcat(obj.path,filesep,obj.intensity_file);
            end
      
            obj.X = csvread( obj.intensity_file );
            
            obj.spectra = csm_nmr_spectra( obj.X, obj.x_scale, 'sample_ids',obj.sample_ids, 'sample_metadata', obj.sample_metadata );
            
        end    
        
        function [obj] = importMS(obj)
            
            obj = importSampleMetadata( obj );
            
            % X matrix
            
            [pathstr,~,~] = fileparts(obj.intensity_file);
            
            if strcmp(pathstr,'')
                obj.intensity_file = strcat(obj.path,filesep,obj.intensity_file);
            end
      
            obj.X = csvread( obj.intensity_file );
      
            obj = importMSFeatures( obj );
            
            % Build the spec
            
            obj.spectra = csm_ms_spectra( obj.X, obj.x_scale, 'm/z','sample_ids',obj.sample_ids, 'sample_metadata', obj.sample_metadata, 'ms_features', obj.ms_features );
            
            
        end
        
        function [obj] = importSampleMetadata( obj )
                      
            obj.sample_metadata = csm_sample_metadata();
            
            [pathstr,filename,~] = fileparts(obj.sample_metadata_file);
            
            if strcmp(pathstr,'')
                obj.sample_metadata_file = strcat(obj.path,filesep,obj.sample_metadata_file);
            end
            
            warning ('off','all');
            
            sample_table = readtable(obj.sample_metadata_file);
            
            warning ('on','all');
            
            if strcmpi(obj.spec_type,'ms')
                obj.sample_ids = sample_table.SampleFileName;
            elseif strcmpi(obj.spec_type,'nmr')
                obj.sample_ids = sample_table.SampleID;
            end
            
            obj.sample_metadata = obj.sample_metadata.setFilename(filename);
            
            obj.sample_metadata.dynamic_field_names = sample_table.Properties.VariableNames;
            
            sample_cell = table2cell(sample_table);
            
            for r = 1 : size(sample_cell,1)
                
                sample_metadata_entry = csm_sample_metadata_entry( );
                
                if strcmpi(obj.spec_type,'ms')
                    sample_metadata_entry.sample_id = strrep(sample_cell{ r, 2 },'''','');
                elseif strcmpi(obj.spec_type,'nmr')
                    sample_metadata_entry.sample_id = strrep(sample_cell{ r, 19 },'''','');
                end
                
                % Set the optional extras in the dynamic field map
                for c = 1 : size(sample_cell,2)
                    if ischar(sample_cell{ r, c })
                        sample_metadata_entry.addDynamicField( obj.sample_metadata.dynamic_field_names{ c }, strrep(sample_cell{ r, c },'''','') );
                    else
                        sample_metadata_entry.addDynamicField( obj.sample_metadata.dynamic_field_names{ c }, sample_cell{ r, c } );
                    end    
                end
                
                obj.sample_metadata.entries( sample_metadata_entry.sample_id ) = sample_metadata_entry;
                
            end   
            
        end 
        
        function [obj] = importMSFeatures( obj )
            
            % Features
            columnsWanted = { 'm/z', 'Peak Width','Adducts','Feature Name', 'Isotope Distribution', 'Retention Time' };
          
            [pathstr,~,~] = fileparts(obj.feature_file);
            
            if strcmp(pathstr,'')
                obj.feature_file = strcat(obj.path,filesep,obj.feature_file);
            end
            
            imported = importdata(obj.feature_file);
            
            obj.x_scale_name = 'm/z';
            
            number_of_rows = length( imported.data );
            
            obj.x_scale = cell(number_of_rows,1);
            peak_width_cell_array = cell(number_of_rows,1);
            adducts_cell_array = cell(number_of_rows,1);
            feature_name_cell_array = cell(number_of_rows,1);
            isotope_distribution_cell_array = cell(number_of_rows,1);
                        
            for i = 1 : number_of_rows
                
                k = i + 1;
                
                obj.x_scale{ i } = imported.textdata{ k , 2 };
                
                peak_width_cell_array{ i } = imported.textdata{ k , 3 };
                adducts_cell_array{ i } = imported.textdata{ k , 4 };
                feature_name_cell_array{ i } = imported.textdata{ k , 5 };
                isotope_distribution_cell_array{ i } = imported.textdata{ k , 6 };
                                                                
            end
            
            retention_time_cell_array = num2cell(imported.data);
           
            features = containers.Map;
            features('m/z') = obj.x_scale;
            features('Peak Width') = peak_width_cell_array;
            features('Adducts') = adducts_cell_array;
            features('Feature Name') = feature_name_cell_array;
            features('Isotope Distribution') = isotope_distribution_cell_array;
            features('Retention Time') = retention_time_cell_array;
            
            obj.ms_features = csm_ms_features();
            obj.ms_features.features = features;
            obj.ms_features.feature_identifiers = obj.x_scale;
            
        end
                
    end
    
end

