classdef csm_import_spectra_static
%CSM_IMPORT_SPECTRA_STATIC - Static methods for spectra import
%
% Methods:
%
%   csm_import_spectra_static.importChoiceDialog(extension) : Show the dialog options.
%
% Description:
%
%	Static methods for import.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016e
    
    properties (Constant)
        
        choice_options = {...
                            {'.hdf'},...
                            {'.nmrML'},...
                            {'.mzML'},...
                            {'.xml',{ 'Target Lynx', 'Test' }},...
                            {'.xls',{ 'XCMS', 'Progenesis QI' }},...
                            {'.xlsx',{ 'XCMS' }},...
                            {'.csv',{ 'NPC Interchange' }},...    
                            };
               
    end
    
    methods (Static)
        
        function [choice] = importChoiceDialog(extension)
            
            k = 1;
            while k <= numel( csm_import_spectra_static.choice_options )
                
                if strcmp( csm_import_spectra_static.choice_options{k}{1}, extension)
                   
                    if numel(csm_import_spectra_static.choice_options{k}) > 1

                        choices = csm_import_spectra_static.choice_options{k}{2};
                        
                        selected = menu('What is the data source?',choices{:});
                        
                        choice = choices{selected};

                    else

                        choice = extension(2:numel(extension));

                    end
                    
                    break;
                                        
                end
                
                k = k + 1;
                
            end    
            
        end
                  
        % schema_definition = {'Column 1','Column 2','Column 3','Column 4'}
        function [importedData] = importFromXLS( filename, schema_definition )
            
            [a,b,content] = xlsread( filename );
            
            for i = 2 : size(content,1)
                
                for k = 1 : numel(schema_definition)
                    
                    rowi_col1 = content{ i , 1 };
                
                    rowi_col2 = content{ i , 2 };
                    
                end     

            end    
                        cel
        end
        
        % schema_definition = {'Column 1','Column 2','Column 3','Column 4'}
        function [importedData] = importFromCSV( filename, schema_definition )
            
            % No schema_definition means just read it into a matrix - ie the
            % spectral X matrix
            if ~schema_definition
                
               importedData = csvread( filename );
               return;
                
            end
            
            % Build the format spec string
            k = 1;
            formatspectraCell = cell(1,numel(schema_definition));
            while k <= numel(schema_definition)
                
                formatspectraCell{ k } = '%s';
                k = k + 1;
                
            end
            formatspectra = strjoin(formatspectraCell,' ');
            
            fid = fopen( filename );

            content = textscan( fid, formatspectra, 'delimiter', ',' );

            fclose( fid );
            
            for i = 2 : length( content{ 1 } )
                
                
                
            end

        end
      
        function [importedData] = importFromXML( schema_definition )
           
            
            
        end
        
        function [importedData] = importFromHDF( schema_definition )
           
            
            
        end
     
        
    end
    
end

