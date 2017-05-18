function [handle] = CJSplotSpectra(ppm,X,varargin)
% Plot NMR spectral data
%
% INPUT: required
% ppm (1,nv) = ppm scale for nv variables
% X (ns,nv)  = NMR spectral data for ns samples
%
% INPUT: optional pairs of values
% name                   value options
% sample_labels {ns,1} = cell array of strings; sample labels for plotting
%                        (default: none)
% class (ns,1)         = class membership for each of ns samples - if
%                        included samples in same class will be plotted in 
%                        the same colour
%                        (default: samples coloured per MATLAB ColorOrder)
% newfigure (flag)     = if newfigure == 'true' then new figure will be
%                        generated, elseif newfigure == 'false' then 
%                        spectra will be plotted onto already open figure
%                        (default: 'true')
% savename (str)       = name to save figure to
%                        (default: figure not automatically saved)
%
% example run >> plotSpectraCS(ppm,X,'sample_labels',titles);
%
% CJS 121112 email caroline.sands01@imperial.ac.uk

% Extract any optional input parameters
if(nargin>2)
    for i=1:2:length(varargin)
        if(strcmp('sample_labels',varargin{i}));
            sample_labels = varargin{i+1}; 
        elseif(strcmp('class',varargin{i}))
            class = varargin{i+1};
        elseif(strcmp('QC',varargin{i}))
            QC = varargin{i+1};
        elseif(strcmp('newfigure',varargin{i}))
            newfigure = varargin{i+1};
        elseif(strcmp('savename',varargin{i}))
            savename = varargin{i+1};
        end
    end
end


% Conduct basic checks

% Check all required inputs present
if(~exist('X','var')||~exist('ppm','var'))
    disp('Please ensure ppm and X inputs included')
    return
end

% Check ppm not transposed
[temp,nv] = size(ppm);
if(temp>nv); ppm = ppm'; end

% Check number of variables consistant
[ns,nv] = size(X);
if(nv~=length(ppm));
    disp('Please ensure number of variables is consisitant in X and ppm')
    return
end

% Check orientation of ppm scale
if(ppm(1)<ppm(end))
    ppm = fliplr(ppm);
    X = fliplr(X);
end

% Check class variable
if(exist('class','var')) & ~ istable(class)
    
    % Check class not transposed
    [nc,temp] = size(class);
    if(temp>nc); class = class'; [nc,temp] = size(class); end
    
    % Check dimensions consistent
    
    if(nc~=ns||temp~=1)
        disp('Please check dimensions of class (should be ns,1)/nData will be plotted without this information')
        clear class
    end
end

% Check QC
if(exist('QC','var'))
    
    % Check class not transposed
    [nc,temp] = size(QC);
    if(temp>nc); QC = QC'; [nc,temp] = size(QC); end
    
    % Check dimensions consistent
    
    if(nc~=ns||temp~=1)
        disp('Please check dimensions of QC (should be ns,1)/nData will be plotted without this information')
        clear class
    end
end

% Check sample titles
if(exist('sample_labels','var'))
    
    % check dimensions 
    [nc,temp] = size(sample_labels);
    if(temp>nc); sample_labels = sample_labels'; end
    
    % if numeric convert to str
    if(isnumeric(sample_labels));
        sample_labels = num2str(sample_labels);
    end
end


% Plot data

% Generate new figure if required
if(~exist('newfigure','var')||strcmp('true',newfigure));
    figure; set(gcf,'color','white'); hold on
end

if(exist('class','var'))
    if(isnumeric(class))
        class = cellstr(num2str(class));
    end
    uniqClass = unique(class);
    color = CJScolormaps(length(uniqClass),'discrete'); % colors
    for i=1:ns
        col = color(strcmp(class(i), uniqClass), :);
        plot(ppm, X(i, :), 'color', col);
    end
    
    % add class legend (on left so as not to interfere with sample legend)
    hleg = legend(['Class Legend'; uniqClass], 'location', 'northwestoutside');
    boxpos = repmat(get(hleg, 'Position'), length(uniqClass)+1, 1);
    boxpos(:,2) = boxpos(1,2) : -0.025 : boxpos(1,2)-(length(uniqClass))*0.025;
    delete(hleg);
    annotation('textbox', boxpos(1,:), 'String', 'Class Legend', 'Edgecolor', 'none')
    uniqClass = strrep(uniqClass, '_', ' ');
    for i = 2:length(uniqClass)+1
        annotation('textbox', boxpos(i,:), 'String', uniqClass(i-1), 'Color', color(i-1,:), 'Edgecolor', 'none')
    end

elseif(exist('QC','var')&&length(unique(QC))~=1)
    for i=1:ns
        if(QC(i)==1)
            plot(ppm,X(i,:),'color','c');
        else
            plot(ppm,X(i,:),'color','b');
        end
    end
else
    plot(ppm,X)
end

% Annotate
set(gca,'Xdir','Reverse');
xlabel('\delta^1H');
ylabel('Intensity');

% Add legend if sample_labels provided
if(exist('sample_labels','var'))
    sample_labels = strrep(sample_labels, '_', ' ');
    legend(sample_labels,'location','NorthEastOutside');
end

% Save if savename provided
if(exist('savename','var'))
    title(savename);
    set(gcf,'name',savename,'NumberTitle','off')
    saveas(gcf,savename);
    snapnow;
    close
end

if(nargout)
    handle = gcf;
end
