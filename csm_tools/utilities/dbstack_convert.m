function [ stack_struct ] = dbstack_convert( stack )
%DBSTACK_CONVERT Converts dbstack into struct.
%   

    % create cell array

    for i = 1 : length( stack )

        stack_functions{ i } = stack( i );

        stack_level{ i } = strcat( 'Level ', num2str( i ) );

    end

    stack_struct = cell2struct( stack_functions, stack_level, 2 );

end

