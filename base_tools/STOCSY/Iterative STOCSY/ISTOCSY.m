function[out]=ISTOCSY(X,ppm,driver,in)
% Fully automated iterative STOCSY. Iterates  multiple rounds of STOCSY
% initially from a given driver peak of interest, but in subsequent rounds
% from all peaks correlating above a certain threshold to driver/s in the
% previous round. Highly correlating (putatively structural) peaks are
% grouped together and the results automatically plotted in the
% ISTOCSY_plot interactive plot (showing node-to-node associations
% alongside the corresponding spectral data)
%
% Required input arguments:
% X (mxn) = spectral data matrix (m samples, n variables)
% ppm (1xn) = ppm scale
% driver (1x1) = ppm of driver peak
%
% Optional input arguments:
% in (struct) = optional running parameters, including fields:
%      .peakInds (1*n) = indices of peak apexes
%                        (default = generated using findPeaksKV.m)
%      .allpeaks (1*n) = ppm regions corresponding to each peak in peakInds
%                        (default = generated using findPeaksKV.m)
%      .LOD (1*1) = for findPeaksKV; limit of detection below which peaks
%                   will not be picked (assumed noise)
%                   (default = mean(baseline_noise) + 3*std(baseline_noise))
%      .noise (1*2) = for findPeaksKV; if LOD not specified explicitly, LOD
%                     calculated as above, noise defines region to use in 
%                     LOD calculation
%                     (default = 9.5:10 ppm)
%      .ISTOCSY_cutoff (1*1) = minimum correlation to detect inter-peak 
%                              connections 
%                             (default = 0.8)
%      .struct_cutoff (1*1) = minimum threshold for grouping structurally 
%                             correlated peaks 
%                             (default = 0.95)
%      .Nrounds (1*1) = number of rounds of iteration to run 
%                       (default = 10)
%      .name (str) = name to save plots as
%                    (default = none)
%      .corrColScale (str) = colour scale by which to colour peaks in the
%                            interactive plot, 'full' colours on scale 
%                            from -1 to 1, 'min2max' colours on scale from 
%                            min to max correlation
%                            (default = 'full')
%
% Output arguments:
% out = (struc) output results with fields
%       .in (struct) = running parameters (fields as above)
%       .results (m*2) = matrix of peaks detected in each round; columns 
%                        correspond to: 
%                        round | indices of representative peaks
%       .sets (m*n) = 'structural' or highly related sets, each row 
%                     containing indices of peaks which correlate > 
%                     struct_cutoff (represented by one node in final plot)
%       .connections (m*n) = node connectivities; for each row, the first 
%                            number corresponds to the driver node, and 
%                            subsequent values to those connected nodes 
%                            (where numbers relate to row indices in the 
%                            results matrix)
%       .correlates (m*n) = corresponding correlations for each connection
%       .peaksplot (m*n) = for plotting (each row corresponds to a row in 
%                          connections, and all peaks from the same 
%                          structural set have the same index
%       .allpeaksplot (1*n) = for plotting (all peaks identified)
%       .roundpeaksplot (m*n) = for plotting (peaks identified in each
%                               round)
%       .allInRound = for plotting (peaks in each round)
%       .plot_xy (m*2) = for plotting (x and y locations for each node)
%
% 110510 caroline.sands01@imperial.ac.uk


% 1. checks and set up defaults
fprintf('ISTOCSY driven from peak at %g\n', driver)

% data is in ASCENDING ppm order
if(ppm(1)>ppm(end))
    ppm = fliplr(ppm);
    X = fliplr(X);
    in.fliplrData = 1;
end

in.driver = find(ppm >= driver, 1);

% '.name' name to save plots as (default = current date-time)
% if(~isfield(in,'name')); 
%     in.name = strcat(date,'-',strrep(num2str(rem(now,1)),'0.',''));
% end
% fprintf('Plots saved as %s\n',in.name)

% '.STOCSYI_cutoff' minimum correlation to detect inter-peak connectins 
% (default = 0.8)
if(~isfield(in,'ISTOCSY_cutoff')); 
    in.ISTOCSY_cutoff = 0.8; 
end
fprintf('ISTOCSY_cutoff = %g\n',in.ISTOCSY_cutoff)

% '.struct_cutoff' minimum threshold for grouping structurally correlated 
% peaks (default = 0.95)
if(~isfield(in,'struct_cutoff'))
    in.struct_cutoff = 0.95;
end
fprintf('struct_cutoff = %g\n',in.struct_cutoff)

% '.Nrounds' number of rounds of iteration to run (default = 10)
if(~isfield(in,'Nrounds')); 
    in.Nrounds = 10; 
end
fprintf('Nrounds = %g\n',in.Nrounds)

% pick peak apex's if peakinds and allpeaks not included 
% (peaks defined as those with signal > LOD)
if(~isfield(in,'peakInds')||~isfield(in,'allpeaks')); 
    
    disp('Peaks picked using findPeaksKV')
    
    % if LOD not given, LOD = mean(baseline_noise) + 3*std(baseline_noise)
    if(~isfield(in,'LOD'))
        fprintf('\tLOD set using mean(noise)+3*std(noise)\n')
        
        % if noise not given, noise set to 9.5:10 ppm
        if(~isfield(in,'noise'));
            noise = [9.5 10];
            fprintf('\tnoise region set to default 9.5:10ppm\n')
        end
        [~,noise(1)] = min(abs(ppm - repmat(noise(1),size(ppm))));
        [~,noise(2)] = min(abs(ppm - repmat(noise(2),size(ppm))));
        in.noise = [ppm(noise);noise];
        LOD = nanmean(nanmean(X(:,noise(1):noise(2)))) + 3*nanmean(nanstd(X(:,noise(1):noise(2))));
        in.LOD = LOD;
        fprintf('\tLOD = %g\n',LOD)
    end
    
    % run peak-picking algorithm
    [in.peakInds,in.allpeaks] = findPeaksKV(mean(X),ppm,'real',LOD);
    
    % plot picked peaks
    CJSplotPeaklist(0,X,[],in.allpeaks,in.peakInds,ppm,[],[],[],1)
    set(gcf,'name','ISTOCSY_pickedPeaks','NumberTitle','off')
    if(~isempty(in.name));
        saveas(gcf,sprintf('%s_ISTOCSY_pickedPeaks.fig',in.name));
    end
end

% ensure that driver peak is included in peaklist
if(in.allpeaks(in.driver) ~= in.driver) % add driver to peaks if not present already
    in.allpeaks(in.driver) = in.driver;
    in.peakInds = [in.peakInds in.driver];
end
peaks=zeros(size(ppm)); peaks(in.peakInds) = in.peakInds;

fprintf('Number of peaks picked = %g\n',length(in.peakInds))

% '.corrColScale' colour scale by which to colour peaks in the interactive 
% plot (default = 'full')
if(~isfield(in,'corrColScale')); 
    in.corrColScale = 'full'; 
end


% 2. initialise variables
results = zeros(length(in.peakInds),2);
results(1,:) = [0 in.driver];
sets = zeros(length(in.peakInds)); sets(1,1) = in.driver; 
inds.S = 2;
connects = zeros(length(in.peakInds));
correlates = zeros(length(in.peakInds));
round = 1;
inds.start = 1; inds.stop = 1; indS = inds.S;
addAll = zeros(length(in.peakInds),3);

% 3. run iterative STOCSY until Nrounds reached or no new peaks identified
while(round<=in.Nrounds)
    
    addAll(round,:)=[inds.stop+1 inds.start inds.stop];
    
    [results,connects,correlates,inds,sets] = eachRound(X,sets,...
        in.ISTOCSY_cutoff,peaks,connects,correlates,results,...
        in.struct_cutoff,inds,round);
    
    if(indS==inds.S-1); 
        break; 
    end
    
    indS=inds.S;
    round=round+1;
end

if(all(results(inds.start,:)==0)) % if ended because no new peaks
    inds.stop=inds.start-2;
    
else % if round exceeded Nrounds tidy last round so connections link back to preceding peak
    for i=inds.start:inds.stop
        [row,~]=find(connects==i);
        connects(i,1:length(row))=row;
        correlates(i,1:length(row))=correlates(connects==i);
    end
    addAll(max(results(:,1))+1,:)=[inds.stop+1 inds.start inds.stop];
end

% add row to connects and correlates - connect to all peaks
results(inds.stop+1,1)=round-1;
for i=1:max(results(:,1))+1
    connects(addAll(i,1),1:addAll(i,3)-addAll(i,2)+1)=addAll(i,2):addAll(i,3);
    temp=unique(sets(addAll(i,2):addAll(i,3),:));
    sets(addAll(i,1),1:length(temp))=temp;
end

results=results(1:inds.stop+1,:);
connects=connects(1:inds.stop+1,:);
correlates=correlates(1:inds.stop+1,:);
sets=sets(1:inds.stop+1,:);

% 4. determine the y axis values
round=results(:,1)+1;
n=zeros(1,max(round));
k=zeros(size(round));
b=1;
for p=1:1:max(round)
    n(p)=length(round(round==p));
    k(b:n(p)+b-1)=n(p);
    l(b:n(p)+b-1)=1:1:n(p);
    b=b+n(p);
end
plot_at=(max(n)-1)./(k+1);
plot_at=plot_at.*l'+1;
plot_at(addAll(1:max(round),1))=max(plot_at(addAll(1:max(round),1)));

plot_xy =[results(:,1) plot_at];

% adapt peaks and define peaksplot and allpeaksplot
peaksplot=zeros(inds.stop+1,length(ppm)); allpeaksplot=zeros(1,length(ppm));
for i=1:inds.stop+1
    temp=sets(i,:);temp(temp==0)=[];
    peaksplot(i,ismember(in.allpeaks, temp))=1; 
    allpeaksplot(ismember(in.allpeaks, temp))=sets(i,1);
end

% all peaks found in each round
nrounds=max(results(:,1));
roundpeaksplot=zeros(nrounds,length(ppm));
for i=1:nrounds
    temp=results(results(:,1)==i,2);
    roundpeaksplot(i,ismember(allpeaksplot,temp))=allpeaksplot(ismember(allpeaksplot,temp));
end

out.in = in;
out.results = results;
out.sets = sets;
out.connections = connects;
out.correlations=correlates;
out.peaksplot = peaksplot;
out.allpeaksplot = allpeaksplot;
out.roundpeaksplot = roundpeaksplot;
out.allInRound = addAll(1:nrounds+1,1);
out.plot_xy = plot_xy;

% 5. plot results

% interactive plot
ISTOCSY_plot(out,X,ppm,in.corrColScale);
set(gcf,'name','ISTOCSY_plot','NumberTitle','off')
if(~isempty(in.name));
    saveas(gcf,sprintf('%s_ISTOCSY_plot.fig',in.name));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[results, connects, correlates, inds, sets]=eachRound(X,sets,...
    cutoff,peaks,connects,correlates,results,strThr,inds,round)
% function generates connectivities from incoming peaks (identified at
% previous round) with |r|>cutoff
%
% peajs with correlations |r|>0.95 are grouped as structural and represented 
% by a single peak from the group - but STOCSY is run from each member then 
% all unique peaks identified connect to single representative peak

inds.S=inds.S+1;

for k=inds.start:inds.stop % all new peaks IDd in previous round
    
    peakout=[]; peakcors=[];

    run=sets(k,:); run(run==0)=[]; % each row == set of peaks r^2>0.9

    % now for each set of structural peaks identify correlations>cutoff
    for i=1:length(run)

        % correlations to all peak apexes EXCEPT those in group
        if (i==1)
            peakstemp=peaks; peakstemp(run)=[];
            peaksIDd=unique(peakstemp(peakstemp~=0));
        end

        % calculate correlation (STOCSY)
        cor = corr(X(:,peaksIDd),X(:,run(i)))';

        % select peaks r2>cutoff (pos and neg)
        peaksIDd2=peaksIDd(abs(cor)>=cutoff);

        % continue to next peak if empty
        if(isempty(peaksIDd2)); continue; end

        corrs=cor(abs(cor)>=cutoff);
        
        % want unique list from ALL peaks in highly connected group
        tf=ismember(peaksIDd2,peakout);
        peakout=[peakout peaksIDd2(tf==0)];
        peakcors=[peakcors corrs(tf==0)];
        cor=[];

    end

    % if have already run peak - find in sets then save connectivities and
    % maximum correlation value
    tf=ismember(peakout,sets);

    old=peakout(tf==1); oldcor=peakcors(tf==1); tcon=zeros(size(old));
    for j=1:length(old)
        tcon(j) = find(sets==old(j));
    end
    [tcon, m]=unique(tcon);
    tcor=oldcor(m);

    % add new peak indices to sets output
    peakout(tf==1)=[]; peakcors(tf==1)=[];
    
    con1=[]; con2=[];
    if(~isempty(peakout))
        con1=inds.S;
        [sets, inds, results, cor] = addSets(X,peakout,peakcors,sets,strThr,inds,results,round);
        con2=inds.S-1;
    end
    
    % save connectivities and correlations
    tcon=[tcon con1:con2]; tcor=[tcor cor];
    connects(k,1:length(tcon))=tcon;
    correlates(k,1:length(tcor))=tcor;
    
end

results(inds.stop+1,1)=round-1;
inds.start=inds.stop+2;
inds.stop=inds.S-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[sets, inds, results, cor] = addSets(X,peakout,peakcors,sets,strThr,inds,results,round)
% for each set of newly identified peaks, identify those peaks which
% correlate with r^2>0.9 and save into 'sets' variable and into results

i=1;
while(~isempty(peakout))
    
    % identify structural correlations within driver peak list
    structCor = corr(X(:,peakout),X(:,peakout(1)))';
    sInds=find(structCor>=strThr);
    cor(i)=mean(peakcors(sInds));
    run=peakout(sInds);
    
    % save in sets matrix
    sets(inds.S,1:length(run))=run; 
    
    % save in results for previous round
    results(inds.S,:)=[round run(1)]; inds.S=inds.S+1;
    
    % delete structural correlations from driver peak list
    peakout(sInds)=[]; peakcors(sInds)=[];
    i=i+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y] = nanmean(X)
% Function to calculate the mean of all values in X, after excluding NaN 
% values. For matrices X, nanmean(X) is a row vector of column means, once
% NaN values are removed. Equivalent of nanmean in MATLAB stats toolbox.

if(size(X, 1) == 1 || size(X, 2) == 1)
    y = mean(X(~isnan(X)));

else
    y = NaN(1, size(X, 2));
    for i = 1:length(y)
        temp = X(:, i);
        y(i) = mean(temp(~isnan(temp)));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y] = nanstd(X)
% Function to calculate the std of all values in X, after excluding NaN 
% values. For matrices X, nanstd(X) is a row vector of column std, once
% NaN values are removed. Equivalent of nanstd in MATLAB stats toolbox.

if(size(X, 1) == 1 || size(X, 2) == 1)
    y = std(X(~isnan(X)));

else
    y = NaN(1, size(X, 2));
    for i = 1:length(y)
        temp = X(:, i);
        y(i) = std(temp(~isnan(temp)));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [corY] = corr(X, Y)
% Function to calculate the correlation between a value (Y) and every
% element in a vector (X). Equivalent of corr in MATLAB stats toolbox.

corY = zeros(size(X,2), 1);
for i = 1:1:size(X, 2)
    r = corrcoef(X(:,i), Y);
    corY(i) = r(1, 2);
end