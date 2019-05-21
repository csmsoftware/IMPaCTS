function out = ISTOCSY_plot(in,X,ppm,corrColScale)
% interactive STOCSYI plotting plots results of ISTOCSY.m
% 
% in = (struct) results from ISTOCSY.m, with required fields:
%      .plot_xy (kx2) x and y location of each node
%      .connections = (kxu) node connectivities; for each row, the first 
%                     number corresponds to the driver node, and subsequent
%                     values to those connected nodes (where all numbers 
%                     relate to row indices in the results matrix)
%      .correlates = (kxu) corresponding correlations for each connection
%      .peaksplot = (kxn) plotting peaks information, each row corresponds
%                   to a row in connections, and all peaks from the same 
%                   structural set have the same index
%      .sets = (kxu) 'structural' or highly related sets, each row 
%              contains the indices of highly related peaks (represented 
%              by one node in the interactive plot)
% X = (mxn) spectral data
% ppm = (1xn) ppm scale
% corrColScale = (str) colour scale by which to colour peaks in the
%                interactive plot, 'full' colours on scale from -1 to 1,
%                'min2max' colours on scale from min to max correlation
%                (default = 'full')
%
% out = (struct) imputed and generated arguments (output if required)
% 280410 CJS

% Check for call-back invocation
if (nargin == 1 && ~isempty(gcbo))
   [~,f] = gcbo;
   doclickCS(f, in);
   return
end

if(nargin<4); corrColScale='full'; end

gx=in.plot_xy(:,1);
gy=in.plot_xy(:,2);
gconnect=in.connections;
peaks=in.peaksplot;
correlates=in.correlations;
maxR=find(all(gconnect==0)==1,1,'first'); % max number of connections at any one level

% determine colours for correlations
corcolour=correlates;

figure; 
colormap(gcf, 'jet');
Color=get(gcf,'Colormap'); 
close

if(strcmp('full',corrColScale))
    mincol=-1;
    maxcol=1;
else
    mincol=min(correlates(correlates~=0));
    maxcol=max(correlates(correlates~=0));
end
caxisval=[mincol maxcol];

inc=(maxcol-mincol)/size(Color,1);
inc=mincol:inc:maxcol;

for i=1:size(Color,1)
    corcolour(correlates>=inc(i)&correlates<=inc(i+1))=i;
end
corcolour(correlates==0)=0;

in.corcolour=corcolour;
in.color=Color;
in.caxisval=caxisval;

corr.col=Color;
corr.cor=corcolour;
corr.all=in.allInRound;

% set up colour matrices
n=length(gx); 
if(size(X,1)>1);
    maxX=max(X);
else
    maxX=X;
end
maxmaxX=zeros(size(maxX));
gpeaks=repmat(maxX,n,1);
gpeaks(peaks==0)=NaN;

% set colormap to jet minus yellow for rest of plotting....
figure
colormap(hsv(min([maxR 50])));
col=get(gcf,'Colormap'); 
close
data.gconnect=gconnect; data.col=col(randperm(size(col,1)),:);

% Create initial plot with all groups - if click within each plotted area
% calls back to doclickCS function....
figure; set(gcf,'Color',[1 1 1],'Userdata',data);
subplot(2,1,1); hold on
for j=1:n
   ftxt = sprintf('ISTOCSY_plot(%d)', j);
   plot(gx(j),gy(j),'ko','UserData',j,  'ButtonDownFcn',ftxt);
end
set(gca,'Box','off','YColor',[1 1 1],'XColor',[1 1 1],'UserData',n);
title('Interactive Iterative STOCSY Plot', 'fontweight','bold');

subplot(2,1,2); 
colormap(gca,'jet');
hold on
plot(ppm,X,'Color',[0.8 0.8 0.8]); hold all;
for k=1:n
    plot(ppm,gpeaks(k,:),'k-','UserData',k)
    
    ftxt2 = sprintf('ISTOCSY_plot(%d)', k);
    sets=in.sets(k,:); sets(sets==0)=[];
    plot(ppm(sets),maxmaxX(sets),'k*','Userdata',k,'ButtonDownFcn',ftxt2);
end
set(gca,'YColor',[1 1 1],'Box','off','Xdir','reverse','UserData',corr);
caxis(caxisval);
colorbar


% Color peaks corresponding to initial driver
doclickCS(gcf,1);
hold off

if(nargout==1)
    out=in;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doclickCS(hfig,grp)

%DOCLICK Processes a click on group grp

% Get info from graph
data = get(hfig,'UserData');
gconnect=data.gconnect;
gcol=data.col;
%ax = get(hfig, 'CurrentAxes');
ax=get(hfig,'Children'); topax=ax(3); botax=ax(2);
ngroups = get(topax, 'UserData');
corr = get(botax,'UserData');
corcol=corr.col;
corcor=corr.cor;
corall=corr.all;

% Loop over all points, adjusting colors 
connect=gconnect(grp,:); connect(connect==0)=[];
if(~isempty(connect));
    Col=repmat(gcol,ceil(length(connect)/size(gcol,1)),1);
    a=1;
end

for j=1:ngroups     
   h = findobj(topax, 'UserData',j, 'Marker','o');
   h1= findobj(botax,'UserData',j,'Type','Line');
   
   if (isempty(h)), continue; end
   if (j == grp)
      clr = 'k';
      clr2=clr;
   elseif(ismember(j,gconnect(grp,:)))
      clr = Col(a,:); a=a+1; 
      if(all(corcor(grp,:)==0))
          clr2=clr;
      else
          clr2=corcol(corcor(grp,gconnect(grp,:)==j),:);  
      end
          
   else
      clr = repmat(0.8,1,3);
      clr2 = clr;
      
   end
   set(h, 'Color', clr,'MarkerFaceColor',clr);
   set(h1(1),'Color',clr);  
   set(h1(2),'Color',clr2); 
   
end

h=zeros(length(corall),2);
for i=1:length(corall)
    h(i,:) = findobj(botax,'UserData',corall(i),'Type','Line');
end
h=h(:);
set(h,'Visible','off')
