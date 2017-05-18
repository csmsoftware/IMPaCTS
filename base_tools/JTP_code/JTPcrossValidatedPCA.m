% model = JTPcrossValidatedPCA(X, prep, components)
%
% Generate and cross-validate an O2 - PLS model for the provided dataset.
%
% Note that during cross validation the dataset is divided up randomly, 
% therefore small varations in the cross validated statistics (Q2) can 
% be expected between two runs on the same dataset.
%
% In order to change the times cross validation edit the global parameter:
% nTimesValidation, by default this is set to 7.
%
% Arguments:
% X             Data matrix
% prep          'mc' for meancenter; 'uv' for univariate scaling; 'pa' for
%               pareto
% components    Number of priciple components to calculate.
% 
% 
%
% Return Values:
% In the form of model.*
% p             Matrix of Loadings
% t             Matrix of scores
% Tcv           Matrix of cross validated scores.
% R2            Modeled variation.
% Q2            Cross-validated modeled variation.
% Xr            Model residuals
%
% Last revision 5/01/2007
% C 2005 Jake Thomas Midwinter Pearce.

function model = JTPcrossValidatedPCA(X, prep, components, varargin)

% Defaults
def.nTimesValidation = 7;

args = MWparseargs(def, varargin{:});

% Set any X variables == 0 to min(X)/10
if(sum(sum(X==0))~=0)
    model.args.nXzeros = sum(sum(X==0));
    model.args.XzerosSetTo = min(min(X(X~=0)))/10;
    fprintf('X contains %g variables == 0; 0 replaced with min/10 (%g)\n',...
        model.args.nXzeros,model.args.XzerosSetTo);
    X(X==0) = model.args.XzerosSetTo;
end

% Prep data
if(strcmp(prep,'mc')) % mean centre data
    centerType = 'mc';
    scaleType = 'no';
elseif(strcmp(prep,'uv'))
    centerType = 'mc';
    scaleType = 'uv';
elseif(strcmp(prep,'pa'))
    centerType = 'mc';
    scaleType = 'pa';
else
    centerType = 'no';
    scaleType = 'no';
end

X = mjrScale(X,centerType,scaleType); X = X.X;

% Determine matrix sizes.
[Xsamples, ~] = size(X);

% Global parameters
Tpredicted = zeros(Xsamples, components);

randKeys = randperm(Xsamples);

% Generate n random matrices (use randperm to rehash the matrices).
% One loop fort each cross-validation set.
for i = 1:args.nTimesValidation
    
    % Reset counters
    iSamples = 1;
    notIsamples = 1;
    
    % Split the data matrix.
    Xi = X(randKeys(i:args.nTimesValidation:Xsamples),:);
    Xnoti = X;
    Xnoti(randKeys(i:args.nTimesValidation:Xsamples),:) = [];
    
    backIndex = randKeys(i:args.nTimesValidation:Xsamples);

    % Model the bulk and predict the fraction
    [P, T] = JTPpca(Xnoti, components);
    
    % Calculate CV scores
    Ttmp = Xi * P';

    [iSamples, dummy] = size(Xi);
    for j = 1:iSamples
        Tpredicted(backIndex(j),:) = Ttmp(j,:);     
    end
end

% Generate overal model of whole dataset.
[P, T] = JTPpca(X, components);

model.scaling = prep;
model.P = P;
model.T = T';

% Loop to calculate goodnes of fit for each component.
% And cross validated goodness of fit.
R2 = ones(components, 1);
Q2 = ones(components, 1);
Xr = X; % model residuals

for i = 1:components
    % Goodness of fit (cumalative)
    E = (model.T(1:i,:)' * model.P(1:i,:));
    R2(i) = sum(sum(E .* E)) / sum(sum(X .* X));
    
    % Cross validated goodness of fit.
    % Calculate Statistics.
    Xmodeled = Tpredicted(:,1:i) * P(1:i,:);
    
    Q2(i) = sum(sum(Xmodeled .* Xmodeled)) / sum(sum(X .* X));
    
    % Calculate resuiduals
    Xr = Xr - model.T(i,:)'*model.P(i,:);
end

model.Tcv = Tpredicted;
model.T = model.T';

% report stats
model.R2 = R2;
model.Q2 = Q2;
model.Xr = Xr;

% output:
fprintf('\nCross validated PCA run with the following parameters:')
fprintf('\n\tscaling = %s\n\tnumber of components = %g\n',...
    prep,components)

end