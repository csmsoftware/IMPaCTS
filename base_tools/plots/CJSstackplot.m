function[handle]=CJSstackplot(ppm,X,options)
% creates a stackplot of data in X; either to simply plot spectral data OR
% to plot stacked colorplots
% 
% Arguments required
% ppm (1*n) = ppm scale
% X (m*n) = data
%
% Optional input, options (struct) with fields:
%   .multi (m*1) = ('normal' only) definitition of which rows in X 
%                  should be plotted together e.g., .multi = [1 1 1 2 2 2] 
%                  would group the first 3 together and the last 3 together
%                  (default = ones(m,1) - plots all together)
%   .C (m*n) = ('colorplot' only) color to plot X data; each row will be
%              plotted separately
%   .titles {m*1 (str)} = titles for each grouping of X/each colorplot 
%   .legend {m*1 str or double)} = ('normal' only, use titles for 
%                                  colorplot) legend for each row in X
%   .scale (1x1 flag) = ('normal' only) set .scale==1 if the scales for the 
%                       different plots are very different, then data will
%                       be scaled as to better compare
%
% if plot generated using stackplotCS, but then saved and reopened, zoom
% action will have been disabled, to re-enable once figure opened run
% stackplot('zoom') 

% Check for call-back invocation
if (~isempty(gcbo))
   doclickCS(gcbo);
   return
end

% some basic checks and set up
if(nargin<3); options=[]; end
[X,options] = setupCheck(ppm,X,options);

% save data into options for saving to figure
options.X = X; options.ppm = ppm;

figure; %set(gcf,'Color',[1 1 1],'Userdata',options)
set(gcf,'color','white','name', 'stack plot', 'NumberTitle', 'off' );
set(gcf,'Userdata',options);
set(gca,'XLim',[min(ppm) max(ppm)])
% plot(ppm,X);
handle = gcf;

doclickCS(gcf);

h = zoom(gcf);
set(h,'ActionPostCallback',@CJSstackplot);
set(h,'Enable','on');

h = pan(gcf);
set(h,'ActionPostCallback',@CJSstackplot);
set(h,'Enable','on');


function[X,options]=setupCheck(ppm,X,options)

% ppm and size(data,2) must be equal
if(length(ppm)~=size(X,2)); 
    disp('ERROR: number of variables in data matrix must equal length of ppm')
    return
end

% options.multi must equal size(data,1)
if(~isfield(options,'multi'))
    options.multi=ones(size(X,1),1);
elseif(length(options.multi)~=size(X,1))
    disp('ERROR: number of samples in data matrix must equal length of options.multi')
    return
end

% if data in different matrices is of significantly different scale, want
% to scale so intensities are comparable
if(~isfield(options,'scale'))
    options.scale=0;
end

if(options.scale==1)
    range=zeros(1,max(options.multi));
    for i=1:max(options.multi)
        range(i)=abs(max(max(X(options.multi==i,:))))+abs(min(min(X(options.multi==i,:))));
    end
    factor=max(range)./range;
    for i=1:max(options.multi)
        X(options.multi==i,:)=X(options.multi==i,:).*factor(i);
    end
    disp('NOTE: scales between plots not comparable!')
end

if(isfield(options,'C'))
    X = repmat(X,size(options.C,1),1);
    options.multi = (1:size(options.C,1))';
end 
    
        


function[] = doclickCS(f)

data = get(f,'Userdata');

Xlims = get(gca,'XLim');

for i = 1:length(Xlims)
    [~, Xlims(i)] = min(abs(data.ppm-Xlims(i)));
end

Xlims = sort(Xlims);

maxIs = zeros(max(data.multi),1); minIs = maxIs;
for i = 1:max(data.multi)
    maxIs(i) = max(max(data.X(data.multi==i,Xlims(1):Xlims(2)),[],2));
    minIs(i) = abs(min(min(data.X(data.multi==i,Xlims(1):Xlims(2)),[],2)));
end
inc = maxIs/10; inc = inc+minIs; inc(1) = 0;

addmat = zeros(size(data.X));
for i = 1:max(data.multi)
    if(i==1)
        addmat(data.multi==i,:) = zeros(sum(data.multi==i),size(data.X,2));
    else
        addmat(data.multi==i,:) = repmat(sum(maxIs(1:i-1))+sum(inc(1:i)),sum(data.multi==i),size(data.X,2));
    end
end 
leg = sort(unique(addmat));
plotthis = data.X+addmat;

cla
for i = 1:max(data.multi)
    if(~isfield(data,'C'))
        plot(data.ppm(Xlims(1):Xlims(2)),plotthis(data.multi==i,Xlims(1):Xlims(2)));
    else
        patch([data.ppm(Xlims(1):Xlims(2)) NaN],...
            [plotthis(data.multi==i,Xlims(1):Xlims(2)) NaN],...
            [data.C(data.multi==i,Xlims(1):Xlims(2)) NaN],...
            'edgecolor','interp');
    end
    if(isfield(data,'titles'))
        text(data.ppm(1)+1,leg(i),strrep(data.titles(i),'_',' '),'FontSize',12);
    end
    
    hold on
    ax = gca;
    ax.ColorOrderIndex = 1;
end

set(gca,'XDir','reverse','YLimMode','auto');
xlabel('\delta^1H');

if(isfield(data,'legend'))
    legend(data.legend,'location','westoutside');
end

set(gca,'Box','off','YColor',[1 1 1])
    
    