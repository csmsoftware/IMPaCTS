function CJSqueryPlot(X,Y,C,varargin)
% function to plot data coloured by C and with option to user specify
% datatip values
%
% REQUIRED INPUT ARGUMENTS
% X (1,nv)  = X data e.g. ppm scale
% Y (1,nv)  = Y data e.g. covariance
% C (1,nv) = Color scale e.g. correlation.^2
% 
% OPTIONAL INPUT ARGUMENTS
% reverse (flag) = reverse colouring e.g. in case of plottting p-values
% varargin       = pairs of arguments to annotate data points, for example
%                  'ppm',ppm,'r2',corrVect.^2
%                  NOTE the first pair MUST be ppm
%
% example run (to plot the covariance of X with Y coloured by the absolute
% correlation of X with Y, and annotated with the datatip at each point to 
% give ppm and correlation value):
% >> CJSqueryPlot(ppm,covXY,abs(corXY),'ppm',ppm,'r',corXY);
%
% NOTE: if you close generated figures without first selecting datatip in
% the plot browser, for some reason the datatip functionality will fail,
% therefore for full functionality datatip must be selected THEN figure
% saved and closed
%
% CJS 050613 caroline.sands01@imperial.ac.uk


% 1. Extract/set up input variables

if(nargin>3)
    del = zeros(1,length(varargin));
    for i=1:length(varargin)
        if(strcmp('reverse',varargin{i}));
            reverse = 1;
            del(i) = 1;
        elseif(length(varargin{i})==2&&isnumeric(varargin{i}))
            collims = varargin{i}; 
            del(i) = 1;
        end
    end
    varargin(del==1) = [];
else
    varargin = [];
end

% 2. Plot
figure; set(gcf,'Color',[1 1 1]);
colormap('jet')
h1 = plot(X,Y,'Color',[0.8 0.8 0.8]); hold on;
if(exist('reverse','var')); cmap = colormap; colormap(flipud(cmap)); end
if(exist('collims','var')); C(C<collims(1)) = collims(1); C(C>collims(2)) = collims(2); end
h2 = patch([X NaN], [Y NaN], [C NaN], 'edgecolor','interp');
set([h1 h2],'UserData',varargin);
hcbar = colorbar;
set(get(hcbar,'Title'),'string','corr^2');
set(gca,'Xdir','reverse')
xlabel('\delta^1H');
ylabel('OPLS coefficients (a.u.)')

% 3. Add required datatips
if(~isempty(varargin))
    dcm = datacursormode(gcf);
    datacursormode on
    set(dcm, 'updatefcn',@datatipCS) 
end


function output_txt = datatipCS(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');

data = get(event_obj.Target,'UserData');

IX = data{2} == pos(1);

out = cell(1,length(data)/2); outi = 1;
for i = 1:2:length(data)
    tmp = data{i+1};
    tmp = tmp(IX);
    out{outi} = sprintf('%s: %.4g',data{i},tmp);
    outi=outi+1;
end
  
output_txt = out;  