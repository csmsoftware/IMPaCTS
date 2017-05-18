% [p, t] = JTPpca(X, numberOfComponents)
% 
% Perform Priciple Component Analysis (PCA) by the NIPALS algorythm.
% Generaly you should use JTPcrossValidatedPCA rather than this function.
%
% Arguments:
% X                     The data matrix to extract components from.
% numberOfComponents    Number of componets to extract.
%
% Return Values:
% p                     Matrix of Loadings.
% t                     Matric of Scores. (This is the only vector i ever
%                       return as a transpose! Should have thought of 
%                       that before.)
%
% Last revision 17/06/2007
% (c) 2005 Jake Thomas Midwinter Pearce.

% Optimised to remove JTPpcaComponent to avoid needing to dupilcate X. I
% think this is now about as efficient as I can get it.
function [p, t] = JTPpca(X, numberOfComponents)

% Defaults
convergenceConstant = 1e-6;
maxIterations = 10000;

% Determine matrix sizes.
[Xsamples, Xvars] = size(X);
p = zeros(numberOfComponents, Xvars);
t = zeros(Xsamples, numberOfComponents);

% calc components
for component = 1:numberOfComponents
    
    % Set score vector (t) to the column in X with the greatest variance.
    [dummy, tIndex] = max(var(X)); % Although X must be passed by copy
    % here, it might be better to roll my own inline var() to eliminate
    % this.
    t(:,component) = X(:,tIndex);

    % Loop start
    convergenceValue = 10;
    iterations = 0;
    while convergenceValue > convergenceConstant
    
        % Calculate the loadings vector (p'). p' = t'X/t't
        p(component,:) = (t(:,component)' * X / (t(:,component)' * t(:,component)));

        % Normalise p to length one by multiplying by c = 1/sq(p'p)
        p(component,:) = p(component,:)' * (1/sqrt(p(component,:) * p(component,:)'));
        
        % Calculate an new score vector (t2) by, t2=Xp/p'p
        t2 = X * p(component,:)'/ (p(component,:) * p(component,:)');
        
        % Check for convgeance via sum of squares of diference beteween 
        % old and new score vectors BREAK
        DIFF = t(:,component) - t2;
        convergenceValue = sum(DIFF .^2);
    
        % Set t = t2
        t(:,component) = t2;
        iterations = iterations + 1;
        if iterations > maxIterations
            break;
        end
    end
    
    % Remove modeled variance, ready to compute next pc E = X - tp'
    X = X - (t(:,component) * p(component,:));
end

end
