% [ model ] = JTPscale( X, direction, scaleType )
%
% Scale matrix X according to method kind.
%
%
% Arguments:
% X             The data matrix.
% direction     'r' to scale along rows, otherwise, 'c' for columns.
% kind          The type of scaling, currently only 'uv', 'mc' or 'none'
%               suported.
%
% Return Values:
% X             The normalised data matrix.
% means         Mean of each data vector
% sDeviations   Standard deviation of each data vector.
% 
% Last Revision 13/11/2006
% (c) 2006 Jake Thomas Midwinter Pearce

function [X, means, sDeviations] = JTPscale(X, direction, kind)

% Simple stub function to rearrage matrices.
if(direction == 'r')
    [X, means, sDeviations] = JTPscaleSub(X, kind);
elseif(direction == 'c')
    [X, means, sDeviations] = JTPscaleSub(X', kind);
    X = X';
    means = means';
    sDeviations = sDeviations';
end
end

% Subroutine to do the work of scaling.
function [X, means, sDeviations] = JTPscaleSub(X, kind)

% Create variables
[noSamples, dummy] = size(X);

% Parse the scaling kind.
if(strcmp(kind, 'uv'))
    [X, means, sDeviations] = JTPunitVariance(X);
    
elseif(strcmp(kind, 'mc'))
    means = mean(X);
    X = detrend(X, 'constant');
    
    sDeviations = ones(noSamples, 1);
    
elseif(strcmp(kind,'none'))
    % Don't do anything.
    means = ones(noSamples, 1);
    sDeviations = ones(noSamples, 1);
else
    error('%s is an unknown scaling type!\n    See JTPscale.m for acceptable options.', ...
        kind);
end

end

% UV scaleing
function [X, means, sDeviations] = JTPunitVariance(X)

means = mean(X);
X = detrend(X, 'constant');


    [m, n] = size(X);
    
    if(m == 1)
        n = m;
    end
    
    sDeviations = std(X);
    
    for i = 1:n
        if(sDeviations(i) ~= 0)
            X(:,i) = X(:,i) * (1 / sDeviations(i));
        end
    end

end
