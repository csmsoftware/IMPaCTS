% figurehandle = JTPplotSpectralVarainceInGroups(scale, spectra, classes)
%
% Plot average spectra of the groups in 'classes', with the selected range
% indicated. Possible plots include:
% 'stdev'                   Plot bounds at one standard deviation above and
%                           below the average.
% 'iqr'                     Colour all the spectra in a dataset according 
%                           to the class identifiers you provide.
% 'quantile'                Plot bounds at the quantiles specified in
%                           'Quantiles'. Default is [0.1 0.9].
% 'stderr'                  Plot bounds at the standard error above and
%                           below the average.
%
% Arguments:
% scale                     Scale vector to label the X axis (the ppm).
% spectra                   Array of spectra to plot.
% classes                   Vector (numeric or cell array od strings)
%                           determining the class of each spectrum in
%                           'spectra'.
%
% Optional arguments in the form of <'argument', value> can further
% customise the plot.
%
% Optional Arguments:
% 'Plot'                    Type of plot to generate (see above).
% 'Average'                 Type of aveage spectrum to generate, may be:
%                           'median' (default), 'mean', or 'mode'
% 'Colourmap                Name of the matlab colourmap to shade with.
%                           Defaults to 'jet'
% 'Alpha'                   Use transparency in Matlab figures, defaults
%                           to 'Yes', use 'No' to enble saving figures with
%                           vector data for editing in Illustrator.
%
% Last Revision 11/09/2013
% (c) 2013 Jake Thomas Midwinter Pearce
%

% 'Title'                   Title for the plot.
% 'Xlabel', 'Xlabel'        Label for the relevent axis.
% 'ReverseX'                Reverse the X axis, 'yes' (default) or 'no'.

function varargout = JTPplotSpectralVarainceInGroups(scale, spectra, classes, varargin)

args.LegendText = [];
% args.Scale = 1:size(X, 2);
% args.PlotType = {'Spectrum' 'Bar'};
% args.Scaling = {'mc' 'uv'};
args.SortValues = {'' 'Yes' 'No'};
args.Plot = {'quantile', 'stdev', 'stderr', 'minmax', 'iqr'};
args.Average = {'median', 'mean', 'mode'};
% args.CrossValidation = 7;
args.Bins = [];
args.pValues = [];
args.Colourmap = [];
args.Bounds = 1;
args.Quantile = [0.05 0.95];
args.Alpha = {'Yes', 'No'};



% Defaults
args = MWparseargs(args, varargin{:});

[noSpectra,noPoints] = size(spectra);

figureHandle = figure;

% Get classes
uClasses = unique(classes);

groupAverage = zeros(length(uClasses), noPoints);
upperbound = zeros(length(uClasses), noPoints);
lowerbound = zeros(length(uClasses), noPoints);

% Get the colourmap
if(isempty(args.Colourmap))
    Color = colormap(lines(length(uClasses)));
else
    Color = colormap(lines(length(classes)));
    colormap(args.Colourmap);
    Color = colormap;
end

Color = colormap();
hold all
for i = 1:length(uClasses)
    
    if isnumeric(classes)
        mask = classes == uClasses(i);
    else
        mask = strcmp(classes, uClasses(i));
    end    
    
    % Create average spectrum of group.
    if strcmpi(args.Average, 'median')
        groupAverage(i,:) = median(spectra(mask,:));
    elseif strcmpi(args.Average, 'mean')
        groupAverage(i,:) = mean(spectra(mask,:));
    elseif strcmpi(args.Average, 'mode')
        groupAverage(i,:) = mode(spectra(mask,:));
    end
    
    
    if strcmpi(args.Plot, 'stderr')
        
        upperbound(i, :) = std(spectra(mask,:))/sqrt(sum(mask));
        lowerbound(i, :) = upperbound(i, :);
        
    elseif strcmpi(args.Plot, 'stdev')
                
        upperbound(i, :) = std(spectra(mask,:));
        lowerbound(i, :) = upperbound(i, :);
        
        
    elseif strcmpi(args.Plot, 'quantile')
                
        upperbound(i, :) = quantile(spectra(mask,:), args.Quantile(2)) - median(spectra(mask,:));
        lowerbound(i, :) = median(spectra(mask,:)) - quantile(spectra(mask,:), args.Quantile(1));
        
    elseif strcmpi(args.Plot, 'minmax')
        
        upperbound(i, :) = max(spectra(mask,:)) - groupAverage(i,:);
        lowerbound(i, :) = groupAverage(i,:) - min(spectra(mask,:));
        
    end
    
    if strcmpi(args.Alpha, 'Yes')
        boundedline(scale, groupAverage(i, :),  [lowerbound(i, :) .*args.Bounds; upperbound(i, :) .*args.Bounds]',...
            'alpha', 'cmap', Color(i,:));
    else
        boundedline(scale, groupAverage(i, :),  [lowerbound(i, :) .*args.Bounds; upperbound(i, :) .*args.Bounds]',...
            'cmap', Color(i,:));
    end
end
set(gca,'Xdir','Reverse');

legendT = {};

labelText = [args.Plot ' '];

if strcmpi(args.Plot, 'quantile');
    labelText = [labelText ' ' num2str(args.Quantile(1)) '-' num2str(args.Quantile(2))];
end

for i = 1:length(uClasses)
    if isnumeric(uClasses(i))
        legendT{length(legendT) + 1} = labelText;
        legendT{length(legendT) + 1} = [num2str(uClasses(i)) ', ' num2str(sum(classes == uClasses(i))) ' samples'];
    else
        legendT{length(legendT) + 1} = labelText;
        legendT{length(legendT) + 1} = [uClasses{i} ', ' num2str(sum(strcmp(classes, uClasses(i)))) ' samples'];

    end
end
legend(legendT);

end