% [outliers, output] = CJSbaseline(X, ppm, region, varargin)
%
% Function to determine baseline differences from either end of the 
% (removed) presaturated water peak for a set of spectra, and plot results
%
% Samples are defined as outliers if either:
%   1. 'threshold' percent of the area (0.1 ppm) either side of the removed
%      water region exceeds the critical value 'alpha'
%   2. 'threshold' percent of the signal (0.1 ppm) either side of the 
%      removed water region is negative
%
% Arguments:
%   X (ns,nv) = spectral data (ns samples, nv variables)
%   ppm (1,nv) = ppm scale 
%
% Optional arguments (in pairs):
%   'alpha', value = critical value for defining the rejection
%                    region (comprises alpha*100% of the sampling 
%                    distribution) (default: alpha = 0.05)
%   'threshold', value = percentage of samples in region allowed to exceed 
%                        the 'alpha' value before sample is defined as an
%                        outlier (default: threshold = 90)
%   'savedir', char = path to directory in which to save figures
%   'savename', char = name to which to save figure
%
% Return values:
%   outliers (ns,1 dataset) = logical vector indicating outlying samples
%   output (struct) = variables generated during run
%
% caroline.sands01@imperial.ac.uk 2014

function [outliers, output] = CJSbaseline(X, ppm, region, varargin)

% Get optional inputs
if(nargin>2)
    for i=1:2:length(varargin)
        if(strcmp(varargin{i},'alpha'))
            alpha = varargin{i+1};
        elseif(strcmp(varargin{i},'threshold'))
            threshold = varargin{i+1}; 
        elseif(strcmp(varargin{i},'savedir'))
            savedir = varargin{i+1};
        elseif(strcmp(varargin{i},'savename'))
            savename = varargin{i+1};
        end
    end
end

% Reverse data if necessary
if(ppm(1)>ppm(2))
    X = fliplr(X);
    ppm = fliplr(ppm);
end
ns = size(X,1); % number of samples

% Define alpha and threshold values if necessary
if(~exist('alpha','var')); alpha = 0.05; end
if(~exist('threshold','var')); threshold = 90; end

% Define savename
if(~exist('savename','var'))
    savename = 'BL';
end
savename2 = sprintf('%.2f to %.2f', min(region), max(region));
savename2 = strrep(savename2, '.', 'p');
savename2 = strrep(savename2, '-', 'neg');

% Define region to investigate
minR = find(ppm >= min(region), 1, 'first');
maxR = find(ppm >= max(region), 1, 'first');

% Integrate area under peaks for each sample
area = areaTrap(X, ppm, ppm(minR), ppm(maxR));
areaAbs = abs(area);

% Proportion of points which exceed critical value for each sample

% Critical value? 
areaCrit = quantile(areaAbs, 1 - alpha);

% Proportion of points exceeding critical value
failArea = sum(areaAbs > repmat(areaCrit, ns, 1), 2) / size(area, 2) * 100;

% Proportion of points failing negativity test
failNeg = sum(area < 0,2) / size(area, 2) * 100;

% Plot
figure; set(gcf,'color','white')
plot(1:ns,failArea,'b'); hold on;
plot(1:ns,failNeg,'r');
plot(1:ns,threshold*ones(size(failArea)),'--b')
legend('fail on area','fail on negativity',sprintf('critical value (%g%%)',threshold),'location','NorthEastOutside');
xlim([0 ns+1]);
xlabel('sample number');
ylabel('proportion of points in region failing test')
title(sprintf('ppm %s', savename2))

if(exist('savedir','var'))
    saveas(gcf,fullfile(savedir, sprintf('%s stats %s.fig',savename,savename2))); snapnow; close
end

% Outliers?
outliers = [failArea > threshold, failNeg > threshold];
varNames = {sprintf('failArea %s',savename2), sprintf('failNeg %s',savename2)};
varNames = strrep(varNames,' ','');
outliers = array2table(outliers, 'VariableNames', varNames);

% Plot spectral data of outliers?
JTPplotSpectralVarainceInGroups(ppm(minR:maxR), X(:, minR:maxR), ones(1,size(X,1)),'Quantile',[0.05 0.95])

% overlay outliers
hold on;
leg = cell(1,sum(sum(outliers{:,:}))); j=1;

temp = find(outliers{:,1});
for i = 1:length(temp)
    plot(ppm(minR:maxR), X(temp(i), minR:maxR),'r')
    leg{j} = sprintf('outlier on area, sample %g',temp(i)); j=j+1;
end

temp = find(outliers{:,2});
for i = 1:length(temp)
    plot(ppm(minR:maxR), X(temp(i), minR:maxR),'b')
    leg{j} = sprintf('outlier on negativity, sample %g',temp(i)); j=j+1;
end

% update legend
leg_h = gcf;
legPrev = leg_h.Children(1);
leg{1} = legPrev.String{1};
leg{2} = 'median';
legend(leg,'location','NorthEast');
xlim([ppm(minR), ppm(maxR)]);
set(gcf,'color','white')
xlabel('\delta^1H');
ylabel('Intensity')
title(sprintf('ppm %s', savename2))

if(exist('savedir','var'))
    saveas(gcf,fullfile(savedir, sprintf('%s outliers %s.fig',savename,savename2))); snapnow; close
end

% Save variables
if(nargout>1)
    output.region = region;
    output.regionIX = minR:maxR;
    output.area = area;
    output.alpha = alpha;
    output.threshold = threshold;
    output.areaCrit = areaCrit;
    output.failArea = failArea;
    output.failNeg = failNeg;
end

fprintf('%g samples exceed baseline threshold %s\n', sum(any(outliers{:,:},2)), savename2)


% areaHighTot = sum(abs(areaHigh),2);
% areaHighCrit = mean(areaHighTot)+1*std(areaHighTot); % critical value?
% areaHighQuants = quantile(areaHighTot,[0.25 0.5 0.75 0.95 0.99]);


function[area] = areaTrap(X,ppm,start,stop)
% Calculate area under curve (trapeze method)

start=find(ppm>=start,1,'first'); stop=find(ppm<=stop,1,'last');
step=ppm(2)-ppm(1);

area = zeros(size(X,1),stop-start-1);

for i=1:size(X,1)
    for j=start:stop-1
        area(i,j-start+1) = (X(i,j)+X(i,j+1))/2*step;
    end
end