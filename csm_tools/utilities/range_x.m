function [ range ] = range_x ( x )
% Utility function the replace the stats toolbox range function.

    range = max(x(:))-min(x(:));

end