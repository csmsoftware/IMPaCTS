function [ output_struct ] = CLASSY(dataset1,ppm,varargin)


%Basic: CLASSY(dataset1,ppm)
%Advanced: CLASSY(dataset1,ppm,dataset2,...,datasetN,'peak_picking','Complex','corr_metric','pearson','cluster_metric','correlation','hier_method','single','pearthresh',.8,'spearthresh',.75,'represent','median','peakthresh',.8)
%
%Input: dataset1: Control variable- set of 1D spectra from control animals
%       ppm: Chemical shift vector same length as dataset2 and dataset1
%       varargin: Comma delimited experimental variables- sets of 1D
%           spectra followed by any parameter changes
%
%Output: R: log change matrix Rij=log(Cij/Cjo) where Cij is the intensity of peak
%           j in spectrum i and o is the median control spectrum
%       hier_sets: hierarchically clustered independent sets of
%           statistical correlations between peaks
%       cluster_sets: independent sets in hierarchical order with peak
%           incices and corresponding chemical shifts.
%       cluster_biocorrelations: biological correlation matrices-
%           independent sets collapse to single point
%       targets: indices in ppm vector of detected peaks
%       shifts: all chemical shifts, ordered by appearance in plots
%
% CLASSY identifies independent sets in the correlation matrix of the
% full set of experimental spectra and then calculates individual
% correlation matrices with the structural correlations (independent sets)
% collapsed to the first point to produce matrices of biological
% correlations for each subset of spectra with the experiment,
% hierarchically clusters the biological correlations, then re-expands them
% within the clusters and calculates the log-change matrix based on the
% cluster order.  It then plots the individual indepdendent set clustered
% correlation matrices with independent sets boxed and chemical shift
% values superimposed and the R matrices with non-peak dimension in the
% input spectra order.
%
%Additional parameters:
%       peak_picking: 'simple' (multiple of noise), or 'complex' (RSPA)
%       corr_metric: either 'pearson', 'spearman', or 'jackknife' - default pearson
%       cluster_metric: either 'euclidean' for euclidean distance,
%           'topological' for topological overlap, or 'correlation'
%       hier_method: linkage algorith-'single','complete','average','weighted'
%       pearthresh: minimum considered pearson structural correlation
%       spearthresh: minimum considered spearman structural correlation
%       represent: representative spectrum of spectral set- can be
%           'mean','median','max', 'min', 'var' an interger for the index of
%           the spectrum in the full stack, or 'dataset1' for median control
%       peakthresh: values between 0 and 1, controls peak picking threshold
%       edit_peaks: 1 to manually edit peaks, 0 to not.
%       output: 1 to save variables, 0 to discard
%
%
%Author: Steven L Robinette, University of Florida & Imperial College
%London

%Default parameters
peak_picking='complex';
corr_metric='pearson';
cluster_metric='correlation';
hier_method='average';
pearthresh=.8;
spearthresh=.75;
represent='median';
peakthresh=.8;
edit_peaks=0;
output=1;

% Assemble cell of spectra stacks
dataset{1}=dataset1;
if size(dataset{1},1)>size(dataset{1},2)
    dataset{1}=dataset{1}';
end

m=2;
while m-1<=length(varargin) && isstr(varargin{m-1})==0;
    dataset{m}=varargin{m-1};
    if size(dataset{m},1)>size(dataset{m},2)
        dataset{m}=dataset{m}';
    end
    m=m+1;
end

for params=m-1:2:length(varargin)
    v = genvarname([varargin{params}]);
eval([v '= varargin{params+1};']);
end

assignin('caller','parameters',varargin(m-1:length(varargin)));
clear varargin

if size(ppm,1)>size(ppm,2)
    ppm=ppm';
end

% Do alignment if specified

fulldataset=cell2mat(dataset');


% Pick Peaks using Simple or Complex peak picking
switch peak_picking
    case 'simple'
        if ischar(represent)==0
            spect=fulldataset(represent,:);
            pretargets=simplepick(spect,ppm,peakthresh);
        else
            represent=str2func(represent);
            spect=represent(fulldataset);
            pretargets=simplepick(spect,ppm,peakthresh);
        end
    case 'complex'
        if ischar(represent)==0
            spect=fulldataset(represent,:);
            pretargets=PeakPicking(spect,ppm,peakthresh);
        else
            represent=str2func(represent);
            spect=represent(fulldataset);
            pretargets=PeakPicking(spect,ppm,peakthresh);
        end
end
clear dataset1

%Plot peaks and get user to remove false positives and add missed peaks
fighandle=figure; plot(ppm,fulldataset)
set(gca,'XDir','reverse')
hold on
for k=1:length(pretargets)
    n(k)=scatter(ppm(pretargets(k)),max(fulldataset(:,pretargets(k))),'b');
end

if edit_peaks==1
    input('To remove false positive peaks edit "current object properties" in the figure window, click peak circle and hit delete.  When finished, input 1 to continue');
end

doublepeak=findobj(fighandle,'Marker','o');
picked_peaks=get(doublepeak(1:length(doublepeak)/2),'Xdata');
picked_peaks=cell2mat(picked_peaks');
targets=zeros(1,size(picked_peaks,2));
for k=1:size(picked_peaks,2)
    [a,targets(k)]=min(abs(ppm-picked_peaks(k)));
end

if edit_peaks==1
    dcm_obj = datacursormode(fighandle);
    set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on')
    input('To add a peak, click on peak apex with datatip.  To add next peak, right click and select "Create new datatip".  When finished, input 1 to continue');
    c_info = getCursorInfo(dcm_obj);
    for k=1:size(c_info,2)
        picked_peaks(size(picked_peaks,2)+1)=c_info(k).Position(1);
        targets(size(targets,2)+1)=c_info(k).DataIndex;
    end
end

%Identify independent sets in all-spectra correlation matrix
corr_metric=str2func(corr_metric);
corrmat=corr_metric(fulldataset(:,targets)');
old_corrmat=corrmat;
spinsystem=find_sets(corrmat,picked_peaks,pearthresh);

old_corrmat=corrmat;

%cluster chemical shifts with .03 ppm resolution
for index=1:size(spinsystem,2)
    x=spinsystem{2,index};
    spinsystem{2,index}=[];
    a=[];
    for k=1:size(x,2)-1;
        if (abs((x(k)-x(k+1))) < .03) %%.03 is ppm threshold to seperate compounds%%
            a(k)=0;
        else
            a(k)=1;
        end
    end
    a=find(a);
    a=cat(2, 0, a, size(x,2));
    for k=1:size(a,2)-1
        spinsystem{2,index}(k)=mean(x(a(k)+1:a(k+1)));
    end
end


%Calculate individual correlation matrices for each stack
for k=1:max(size(dataset))
correlation_matrix{k}=corr_metric(dataset{k}(:,targets)');
end

for k=1:size(spinsystem,2)
    spinsystem{1,k}=spinsystem{1,k}';
end
order=[spinsystem{1,:}];
bicluster_mat=zeros(size(order,2),size(order,2));
for z=1:size(order,2)
    for k=1:size(order,2)
        bicluster_mat(z,k)=old_corrmat(order(z),order(k));
    end
end

index=1;
for k=1:size(spinsystem,2)
    if size(spinsystem{1,k},2)>1
        [n,v]=max(sum(old_corrmat(spinsystem{1,k},spinsystem{1,k})));
        kill{index}=setdiff(spinsystem{1,k},spinsystem{1,k}(v));
        index=index+1;
    end
end

kill2=cell2mat(kill);

order2=order;
for k=1:size(kill2,2)
    order2(find(order2==kill2(k)))=[];
end

%Collapse independent sets
full_singletmatrix=zeros(size(order2,2),size(order2,2));
for z=1:size(order2,2)
    for k=1:size(order2,2)
        full_singletmatrix(z,k)=old_corrmat(order2(z),order2(k));
    end
end

for m=1:size(dataset,2);
    clear diff
    for k=1:size(dataset{m},1)
        diff(k,:)=dataset{m}(k,targets(order2))./median(dataset{1}(:,targets(order2)));
    end
    Rfirst{m}=log(abs(diff));
end
    
%Hierarchically cluster biological correlations
if cluster_metric(1)=='t'
    distmat=topological_overlap(abs(full_singletmatrix.^3));
    distmat=-1*((distmat+max(max(distmat)))./2)+max(max(distmat));
%     for k=1:size(distmat,1)
%         distmat(k,k)=0;
%     end
elseif cluster_metric(1)=='e'
    distmat=euclid_dist(Rfirst{size(Rfirst,2)}');
else
    distmat=-1*((full_singletmatrix+1)./2)+1;
end

index=1;
for k=2:size(full_singletmatrix,1)+1
    distance(index:index+size(full_singletmatrix,1)-k)=distmat(k-1,k:size(full_singletmatrix,1));
    index=index+size(full_singletmatrix,1)-k+1;
end

figure, dendrogram(linkage(distance,hier_method),0,'colorthreshold',6.3);
sample_order=str2num(get(gca,'XTickLabel'));

%calculate individual biological correlation matrices
for m=1:size(dataset,2)
    bio_correlations{m}=zeros(size(order2,2),size(order2,2));
    for z=1:size(order2,2)
        for k=1:size(order2,2)
            bio_correlations{m}(z,k)=correlation_matrix{m}(order2(z),order2(k));
        end
    end
end

%cluster individual correlation matrices using same previous indices
for m=1:size(bio_correlations,2);
    for z=1:size(sample_order,1)
        for k=1:size(sample_order,1)
            clusterbio_correlations{m}(z,k)=bio_correlations{1,m}(sample_order(z),sample_order(k));
        end
    end
    %     figure, imagesc(clusterbio_correlations{m});caxis([-1 1])
end

%Re-expand structural correlations to assemble biological correlation
%clustered full correlation matrices, plot, and superimpose independent set
%bounding boxes and chemical shifts.  
cluster_sets=spinsystem(:,sample_order);
order3=[cluster_sets{1,:}];
for m=1:size(bio_correlations,2);
    hier_sets{m}=zeros(size(order3,2),size(order3,2));
    for z=1:size(order3,2)
        for k=1:size(order3,2)
            hier_sets{m}(z,k)=correlation_matrix{m}(order3(z),order3(k));
        end
    end
    figure, imagesc(hier_sets{m})
    hold on
    index=1;
    number=1;
    for k=1:size(cluster_sets,2)
        if size(cluster_sets{1,k},2)>1
            rectangle('Position',[index-.5,index-.5,size(cluster_sets{1,k},2),size(cluster_sets{1,k},2)], 'EdgeColor', [0 1 0])
            text(index+(size(cluster_sets{1,k},2)/2)-.5,index+(size(cluster_sets{1,k},2)/2)-.5,num2str(cluster_sets{2,k}),'horizontalAlignment', 'center','color','green')
            remember{number}=index:index+size(cluster_sets{1,k},2)-1;
            index=index+size(cluster_sets{1,k},2);
            number=number+1;
        else
            index=index+size(cluster_sets{1,k},2);
        end
    end
    caxis([-1 1])
end

% Calculate log-change R matrices

for m=1:size(bio_correlations,2);
    clear diff
    for k=1:size(dataset{m},1)
        diff(k,:)=dataset{m}(k,targets(order3))./median(dataset{1}(:,targets(order3)));
    end
    R{m}=log(abs(diff));
    figure, imagesc(R{m})
    caxis([-3 3])
end


shifts=ppm(targets([cluster_sets{1,:}]));

output_struct = struct;
output_struct.remember = remember;
output_struct.R = R;
output_struct.hier_sets = hier_sets;
output_struct.cluster_sets = cluster_sets;
output_struct.cluster_biocorrelations = clusterbio_correlations;
output_struct.targets = targets;
output_struct.shifts = shifts;
output_struct.peakmatrix = dataset{m}(:,targets(order3));

%if output==1;
% Export important variables to workspace
%assignin('caller','remember',remember);
%assignin('caller','R',R);
%assignin('caller','hier_sets',hier_sets);
%assignin('caller','cluster_sets',cluster_sets);
%assignin('caller','cluster_biocorrelations',clusterbio_correlations);
%assignin('caller','targets',targets);
%assignin('caller','shifts',shifts);
%assignin('caller','peakmatrix',dataset{m}(:,targets(order3)));
%end