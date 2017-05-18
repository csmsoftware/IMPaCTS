function [ output_string ] = fix_filesep( inputString )
%FIX_FILESEP Fix your path seperators depending on your OS
%
%   This function replaces /'s and \'s with filesep, the OS independent
%   file seperator.

    if ispc
        
        filesep_to_fix = '/';
                
    else    
        
        filesep_to_fix = '\';
        
    end    
    
    % explode inputString

    input_explode = strsplit(inputString, filesep_to_fix);

    output_string = input_explode{ 1 };

    % loop over them, concat with filesep
    for i = 2 : length( input_explode )

        if ~ strcmp( input_explode{ i }, '' )
                        
            output_string = strcat( output_string, filesep, input_explode{ i } );
            
        end

    end

    % if the last element is empty string, add a trailing filesep.
    if strcmp( input_explode{ end }, '')

        output_string = strcat( output_string, filesep );

    end

end

