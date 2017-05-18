% [peakwidthHz, outliers, output] = CJSpeakwidth(X,ppm,args,SF)
%
% Function to calculate peak width of args.LWpeak at half height, and to 
% determine those samples for which peakwoidth exceeds the critical value
% (args.LWthreshold), and plot results
%
% Arguments:
%   X (ns,nv) = spectral data (ns samples, nv variables)
%   ppm (1,nv) = ppm scale
%   args (struct) = running parameters
%                   .LWpeak = peak to calculate LW from, set to either:
%                             'glucose','lactate' or 'TSP'
%                   .LWthreshold = cutoff value (in Hz)
%   SF = spectrometer frequency, set to either:
%        1. actual value of spectrometer frequency, either as single value 
%           or in a vector with one value per sample (ns,1)
%        2. file path to directory of spectral data in order that SF can be
%           determined
%
% Optional arguments (in pairs):
%   'savedir', char = path to directory in which to save figures
%   'plotBy', char = either 'ppm' or 'Hz'
%   'noPlots', char = if 'noPlots' then results will not be plotted
%   'hwPlots', char = if 'hwPlots' then hw example will be plotted for each
%                     sample
%
% Return Values:
%   peakwidthHz (ns,1) = peakwidth values
%   outliers (ns,1 dataset) = logical vector indicating outlying samples
%   output (struct) = variables generated during run
%
% caroline.sands01@imperial.ac.uk 2014

function [peakwidthHz, outliers, output] = CJSpeakwidth(X,ppm,args,SF,varargin)

% Set up running arguments
if(isempty(args)); args = struct; end

% Get varargin
if(nargin>4)
    if(any((strcmpi(varargin,'noPlots'))))
        noPlots = 1;
        varargin(strcmpi(varargin,'noPlots')) = [];
    end
    if(any((strcmpi(varargin,'hwPlots'))))
        hwPlots = 1;
        varargin(strcmpi(varargin,'hwPlots')) = [];
    end
    for i=1:2:length(varargin);
        args.(varargin{i}) = varargin{i+1};
    end
end

% Check if peak is user defined
if(isfield(args,'peak'))
    args.LWpeak = 'userDefined';
    if(length(args.peak)~=2)
        disp('Please ensure args.peak is 1*2 corresponding to start and stop ppm of peak')
        return
    end
end

% Get spectrometer frequency if SF is filepath
if(ischar(SF)); SF = getSpecFreq(SF); end
[ns,~] = size(X);
if(length(SF)==1); SF = repmat(SF,ns,1); end

% Flip data if necessary
if(ppm(1)>ppm(2)); X = fliplr(X); ppm = fliplr(ppm); end

% Define boundaries of peak on which linewidth determined
if(strcmpi(args.LWpeak,'TSP'))
    peak = find(ppm>=-0.1,1,'first'):find(ppm>=0.1,1,'first');
elseif(strcmpi(args.LWpeak,'glucose'))
    peak = find(ppm>=5.22,1,'first'):find(ppm>=5.25,1,'first');
elseif(strcmpi(args.LWpeak,'lactate'))
    peak = find(ppm>=1.31,1,'first'):find(ppm>=1.34,1,'first');
elseif(isfield(args,'peak'))
    peak = find(ppm>=args.peak(1),1,'first'):find(ppm>=args.peak(2),1,'first');
else
    disp('args.LWpeak or args.peak not recognised: please set to either TSP, glucose or lactate')
    return
end

% Check critical value for linewidth set
if(~isfield(args,'LWthreshold'))
    disp('args.LWthreshold not recognised/set: (i.e., outlier detection not set)')
    args.LWthreshold = inf;
end

% Check sample_labels is char array (if present)
if(isfield(args,'sample_labels')&&isnumeric(args.sample_labels))
    [sl,sv] = size(args.sample_labels);
    if(sv>sl); args.sample_labels = args.sample_labels'; end 
    args.sample_labels = cellstr(num2str(args.sample_labels));
end

% Plot by Hz unless ppm specified
if(~isfield(args,'plotBy')); 
    args.plotBy = 'Hz'; 
end


% Calculate linewidth at half peak height:
baseline = nan(size(X));
apex = nan(ns,1);
halfpoints = nan(ns,2);

peakwidth = nan(ns,1);

for i=1:ns
    
    [~,tmp] = max(X(i,peak)); apex(i) = peak(tmp); % peak apex
    
    [~,start] = min(X(i,peak(1):apex(i))); start = peak(start);
    [~,stop] = min(X(i,apex(i):peak(end))); stop = apex(i)+stop-1;
    
    if(X(i,stop) ~= X(i,start))
        baseline(i,start:stop) = X(i,start):(X(i,stop)-X(i,start))/(stop-start):X(i,stop);
    else
        baseline(i,start:stop) = repmat(X(i,start),1,stop - start + 1);
    end
    
    hps = intersections(ppm(start:stop),X(i,start:stop),ppm(start:stop),...
        repmat(X(i,apex(i))-(X(i,apex(i))-baseline(i,apex(i)))/2,1,stop-start+1)); % find intersection points
        
    if(length(hps)==4)
        if(ppm(apex(i))>hps(2)); 
            halfpoints(i,:) = hps(3:4); 
        else
            halfpoints(i,:) = hps(1:2); 
        end
    elseif(length(hps)==2)
        halfpoints(i,:) = hps(1:2);
    else
        halfpoints(i,:) = [nan, nan];
        continue
    end
    
    % peakwidth in ppm
    if(all(halfpoints(i,:)>0)||all(halfpoints(i,:)<0))
        peakwidth(i) = max(halfpoints(i,:))-min(halfpoints(i,:)); 
    else
        peakwidth(i) = sum(abs(halfpoints(i,:)));
    end
    
    % Can plot figs here to check
    if(exist('hwPlots','var'))
        figure; hold on
        plot(ppm,X(i,:))
        plot(ppm,baseline(i,:),'r')
        plot(ppm(apex(i)),X(i,apex(i)),'o')
        plot(ppm(apex(i)),baseline(i,apex(i)),'o')
        plot(halfpoints(i,:),repmat(X(i,apex(i))-(X(i,apex(i))-...
            baseline(i,(apex(i))))/2,1,2),'o')
    end
   
end

% linewidth in Hz
peakwidthHz = peakwidth .* SF;

% quantiles
quantiles = [0.25,0.5,0.75; quantile(peakwidth,[0.25,0.5,0.75]);...
    quantile(peakwidthHz,[0.25,0.5,0.75])];
quantiles = mat2dataset(quantiles','VarNames',{'Quantile','LWppm','LWhz'});

% outliers
outliers = zeros(size(peakwidthHz));
outliers(peakwidthHz>args.LWthreshold) = 1;


% Plot boxplot
if(~exist('noPlots','var'))
    figure; boxplot(peakwidthHz);
    if(isfield(args,'savedir'))
        saveas(gcf,fullfile(args.savedir,'LW boxplot.fig')); snapnow; close
    end
end


% Plot results: shaded quantiles, LW thresholds and outlying samples
Xn = X - baseline;
midpt = (halfpoints(:,2) - halfpoints(:,1))/2 + halfpoints(:,1); 
medmid = median(midpt(~isnan(midpt)));
halfpoints = halfpoints - repmat(midpt,1,size(halfpoints,2))+repmat(medmid,size(halfpoints));

if(strcmp(args.plotBy,'Hz'))
    % Change ppm scale to plot in Hz - with midpoint of peak at 0Hz
    ppm = (ppm-repmat(medmid,size(ppm)))*SF(1)*2;
end

% Plot spectral data (full range and median value)
if(~exist('noPlots','var'))
    JTPplotSpectralVarainceInGroups(ppm(peak), X(:,peak),...
        ones(1,size(X,1)),'Quantile',[0.00 1])
    set(gcf,'color','white'); hold on
    legprev{1} = 'full range of data'; legprev{2} = 'median spectrum';
    ylims = get(gca,'Ylim');
    
    % Add 25-75 quantiles
    if(strcmp(args.plotBy,'Hz')) % plot by Hz
        xdata = [-quantiles.LWhz(3), quantiles.LWhz(3);...
            -quantiles.LWhz(3), quantiles.LWhz(3);...
            -quantiles.LWhz(1), quantiles.LWhz(1);...
            -quantiles.LWhz(1), quantiles.LWhz(1)];
        xlabel('relative Hz - midpoint of peak set to zero')
    else % plot by ppm
        xdata = [medmid-quantiles.LWppm(3)/2, medmid+quantiles.LWppm(3)/2;...
            medmid-quantiles.LWppm(3)/2, medmid+quantiles.LWppm(3)/2;...
            medmid-quantiles.LWppm(1)/2, medmid+quantiles.LWppm(1)/2;...
            medmid-quantiles.LWppm(1)/2, medmid+quantiles.LWppm(1)/2];
        xlabel('/delta^1H')
    end
    ydata = [ylims(1), ylims(1); ylims(2), ylims(2);...
        ylims(2), ylims(2); ylims(1), ylims(1)];
    patch(xdata,ydata,'w','FaceColor','b','FaceAlpha',0.25,'EdgeColor','none')
    legprev{3} = 'LW 25-75% quantiles';
    
    % Add lines for LWthresholds (if set)
    if(~isinf(args.LWthreshold))
        if(strcmp(args.plotBy,'Hz')) % plot by Hz
            line([-args.LWthreshold,-args.LWthreshold],ylims,'color','r')
            line([+args.LWthreshold,+args.LWthreshold],ylims,'color','r')
        else % by ppm
            line([medmid-(args.LWthreshold/SF(1))/2,medmid-(args.LWthreshold/SF(1))/2],ylims,'color','r')
            line([medmid+(args.LWthreshold/SF(1))/2,medmid+(args.LWthreshold/SF(1))/2],ylims,'color','r')
        end
        legprev(4:5) = {'LW threshold','LW threshold'};
    end
    
    % Plot linewidths (within critical value blue; outliers red)
    leg = cell(1,ns);
    j=1;
    for i=1:ns
        if(outliers(i)==1)
            if(strcmp(args.plotBy,'Hz')) % plot by Hz
                ppmlocal = ppm - repmat(midpt(i)*SF(1)*2,size(ppm)) + repmat(medmid*SF(1)*2,size(ppm));
                plot(ppmlocal(peak(1):peak(end)),Xn(i,peak(1):peak(end)),'r')
                plot([-peakwidthHz(i),peakwidthHz(i)],repmat(Xn(i,apex(i))-Xn(i,apex(i))/2,2,1),'ro')
            else
                ppmlocal = ppm - repmat(midpt(i),size(ppm)) + repmat(medmid,size(ppm));
                plot(ppmlocal(peak),Xn(i,peak),'r');
                plot(halfpoints(i,:),repmat(Xn(i,apex(i))-Xn(i,apex(i))/2,2,1),'ro')
            end
            
            if(isfield(args,'sample_labels'))
                leg(j:j+1) = repmat(args.sample_labels(i),1,2); j=j+2;
            end
            
        elseif(any(isnan(halfpoints(i,:))))
            if(strcmp(args.plotBy,'Hz')) % plot by Hz
                plot(ppm(peak),X(i,peak),'r')
            else
                plot(ppm(peak),Xn(i,peak),'r');
            end
            
            if(isfield(args,'sample_labels'))
                leg(j) = args.sample_labels(i); j=j+1;
            end
            
        else
            if(strcmp(args.plotBy,'Hz')) % plot by Hz
                plot([-peakwidthHz(i),peakwidthHz(i)],repmat(Xn(i,apex(i))-Xn(i,apex(i))/2,2,1),'bo')
            else
                plot(halfpoints(i,:),repmat(Xn(i,apex(i))-Xn(i,apex(i))/2,2,1),'bo')
            end
            if(isfield(args,'sample_labels'))
                leg(j) = args.sample_labels(i); j=j+1;
            end
        end
    end
    leg(j:end) = [];
    
    % add legend
    legend([legprev,leg],'location','NorthEastOutside');
    
    % add title
    title(sprintf('Linewidth of %s peak at half height\n(25-75%% quantiles shaded and samples exceeding critical value/NaN for LW plotted in red)',...
        args.LWpeak))
    
    % save if required
    if(isfield(args,'savedir'))
        saveas(gcf,fullfile(args.savedir,'LW outliers.fig')); snapnow; close
    end
end

% Save output variables
if(nargout>2)
    output.peakwidthHz = peakwidthHz;
    output.peakwidth = peakwidth;
    output.quantiles = quantiles;
end

varNames = {'LWinHz',sprintf('failLWexceed%g',args.LWthreshold)};
varNames = strrep(varNames,'.','p');
outliers = array2table([peakwidthHz, outliers],'VariableNames',varNames);
 
if(~exist('noPlots','var'))
    fprintf('\n%g samples exceed linewidth threshold of %g Hz\n',sum(outliers.LWinHz>=args.LWthreshold),args.LWthreshold)
    fprintf('\nLinewidth stats\n\tMin = %g\n\t25%% = %g\n\tMedian = %g',...
        min(peakwidthHz),quantiles.LWhz(1),quantiles.LWhz(2))
    fprintf('\n\t75%% = %g\n\tMax = %g\n',...
        quantiles.LWhz(3),max(peakwidthHz))
end 

function[SF] = getSpecFreq(spec)

% list all experiments
files = dir(spec);

i=1;
while(~exist('SF','var'))
    if(files(i).isdir==1&&~isnan(str2double(files(i).name)))
        exptNo = files(i).name;
        fid = fopen(strcat(spec,'/',exptNo,'/uxnmr.info'));
        readvar = fscanf(fid,'%c');
        [matchstr,SF] = regexp(readvar,'1H-frequency\s*:\s*(\d*.\d*)\s*MHz','match','tokens');
        disp(matchstr)
        SF = str2double(SF{1});
        fclose('all');
    else
        i=i+1;
    end
end

