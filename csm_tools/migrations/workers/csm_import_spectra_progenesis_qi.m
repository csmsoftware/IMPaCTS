classdef csm_import_spectra_progenesis_qi < csm_import_spectra_base
% CSM_IMPORT_SPECTRA_PROGENESIS_QI - Import worker for Progenesis QI format
%
% Usage:
%
% 	imported = csm_import_spectra_progenesis_qi( 'filename', filename );
%
% Arguments:
%
%	filename : (str) The file to import.
%
% Returns:
%
%	imported : (csm_import_spectra_progenesis_qi) Import worker with imported spectra.
%   imported.spectra : (csm_spectra) Imported spectra object
%
% Description:
%
%	Import worker for importing from Progenesis QI.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016,2016

% Author - Gordon Haggart 2016,2016

    properties
        
        path;
        ms_features;
        
    end    
    
    methods
        
        function [obj] = csm_import_spectra_progenesis_qi(varargin)
                     
            obj = obj@csm_import_spectra_base( varargin );
            
            
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.spec_type = 'MS';
            
            obj = importXLS(obj);
            
        end
        
        function [obj] = importXLS(obj)
           
            [a,b,content] = xlsread(obj.filename );
            
            [number_of_rows,number_of_cols] = size(content);
            
            
            % FILE CALIBRATION - EACH ONE IS SLIGHTLY DIFFERENT!
            
            ms_feature_section_one_start = 1;
            
            rows_doubled = false;
            
            for i = 1 : number_of_cols
                
               if strcmpi(content{1,i},'Normalised Abundance')
                   
                   ms_feature_section_one_end = i - 1;
                   normalised_X_start = i;
                   
                   if strcmpi(content{2,i},'SRD')
                      
                      header_row = 3;
                      
                   elseif strcmpi(content{3,i},'SRD')
                       
                       header_row = 5;
                       rows_doubled = true;
                    
                   else
                        error('Header row of file is not 3 or 5');    
                       
                   end    
                   
               elseif strcmpi(content{1,i},'Raw Abundance')
                   
                   normalised_X_stop = i;
                   break;
                   
               end
                               
            end    
            
            lengthOfX = normalised_X_stop - normalised_X_start;

            raw_X_start = normalised_X_stop;
            ms_feature_section_two_start = (raw_X_start + lengthOfX);
            
            raw_X_stop = ms_feature_section_two_start - 1;
            ms_feature_section_two_end = number_of_cols;
            
            number_of_active_rows = number_of_rows - header_row;
            
            size_of_ms_features_section_one = ms_feature_section_one_end - ms_feature_section_one_start;
            
            size_of_ms_features_section_two = ms_feature_section_two_end - ms_feature_section_two_start;
            
            % IMPORT MS FEATURES
            
            obj.ms_features = csm_ms_features();
            
            for i = 1 : ms_feature_section_one_end
                
                feature_name = content{header_row,i};
                
                cell_array = {};
                
                for p = 1 : number_of_active_rows

                    k = p + header_row;

                    if isnan(content{ k , i })
                        continue;
                    end
                    
                    if rows_doubled == true
                        t = p / 2;
                    else
                        t = p;
                    end 

                    cell_array{ t } = content{ k , i };

                end

                obj.ms_features.features(feature_name) = cell_array;
               
            end
            
            for i = ms_feature_section_two_start : ms_feature_section_two_end
                
                feature_name = content{header_row,i};
                
                cell_array = {};
                
                for p = 1 : number_of_active_rows

                    k = p + header_row;

                    if isnan(content{ k , i })
                        continue;
                    end
                    
                    if rows_doubled == true
                        t = p / 2;
                    else
                        t = p;
                    end 

                    cell_array{ t } = content{ k , i };

                end

                obj.ms_features.features(feature_name) = cell_array;
               
            end
            
            
            % REMAINING!! IMPORT X & sample IDs
            
            sample_ids = {};
            X_matrix = [];
            
            counter = 1;
                        
            for i = raw_X_start : raw_X_stop
                
                sample_id = content{header_row,i};
                
                sample_ids{end+1} = sample_id;
                
                for p = 1 : number_of_active_rows

                    k = p + header_row;

                    if isnan(content{ k , i })
                        continue;
                    end
                    
                    if rows_doubled == true
                        t = p / 2;
                    else
                        t = p;
                    end 

                    X_matrix( t , counter ) = content{ k, i };
                    
                end
                
                counter = counter + 1;
               
            end
            
            X = X_matrix';
            
            obj.spectra = csm_ms_spectra(X,obj.ms_features.features('Compound'),'retentionTime_mz','sample_ids',sample_ids,'is_continuous',false,'ms_features',obj.ms_features);
            
        end    
        
        function [obj] = importCSV(obj)
            
            imported = importdata(obj.filename);
            
            [number_of_rows,number_of_cols] = size(imported.textdata);
            
            
            % FILE CALIBRATION - EACH ONE IS SLIGHTLY DIFFERENT!
            
            ms_feature_section_one_start = 1;
            
            first_row = strfind(imported.textdata{1,1},',');
            
            previous_value = 0;
            
            ms_feature_section_one_found = false;
            
            for i = 1 : length(first_row)
               
                current_value = first_row(i);
                
                if (current_value - previous_value) > 1
                   
                    %there is a jump
                    
                    if ms_feature_section_one_found == false
                       
                        ms_feature_section_one_end = i - 1;
                        ms_feature_section_one_found = true;
                        normalised_X_start = i;
                        
                    else
                        normalised_X_stop = i;
                        break;
                    end    
                    
                end
                
                previous_value = current_value;
                
            end
            
            lengthOfX = normalised_X_stop - normalised_X_start;

            % find which row is the header row - its going to be 3 or 5
            if ~isempty(imported.textdata{2,1})
                header_row = 3;
            elseif ~isempty(imported.textdata{3,1})
                header_row = 5;
            else
                error('Header row of file is not 3 or 5');
            end 
            
            raw_X_start = normalised_X_stop;
            raw_X_stop = raw_X_start + lengthOfX;
            
            ms_feature_section_two_start = raw_X_stop;
            ms_feature_section_two_end = number_of_cols;
            
            number_of_active_rows = number_of_rows - header_row;
            
            size_of_ms_features_section_one = ms_feature_section_one_end - ms_feature_section_one_start;
            
            size_of_ms_features_section_two = ms_feature_section_two_end - ms_feature_section_two_start;
            
            % IMPORT MS FEATURES
            
            features = containers.Map;
            
            matrix_counter = 0;
            
            for i = 1 : size_of_ms_features_section_one
                
                feature_name = imported.textdata{header_row,i};
                
                if ~isempty(imported.textdata{(header_row+1), i })
                    
                    % ITS A STRING VECTOR! (Cell array)
                    
                    cell_array = cell(number_of_active_rows,1);
                
                    for p = 1 : number_of_active_rows

                        k = p + header_row;

                        cell_array{ p } = imported.textdata{ k , i };

                    end

                    features(feature_name) = cell_array;
                
                else 
                                       
                    % ITS A NUMERICAL VECTOR (matrix)
                    
                    matrix_counter = matrix_counter + 1;
                    
                    matrix = zeros(number_of_active_rows,1);
                    
                    for p = 1 : number_of_active_rows

                        matrix( p , 1 ) = imported.data( p , matrix_counter );

                    end
                    
                    features(feature_name) = matrix;
                    
                end    
                
                
            end
            
            obj.ms_features = csm_ms_features();
            obj.ms_features.features = features;
            obj.ms_features.feature_identifiers = features('Compound');
            
        
        end
                
    end
    
end

