function Hierarch_sets(dataset1,dataset2,ppm,corr_metric,cluster_metric)

%[R,hier_sets,cluster_sets]=Hierarch_sets(dataset1,dataset2,ppm,corr_metric,cluster_metric)

%Input: dataset1: Control variable- set of 1D spectra from control animals
%       dataset2: Experimental variable- set of 1D spectra
%       ppm: Chemical shift vector same length as dataset2 and dataset1
%       corr_metric: either 'pearson' or 'spearman'- default pearson
%       cluster_metric: either 'euclidean' for euclidean distance,
%       'topological' for topological overlap, or 'correlation' 

%Output: R: log change matrix Rij=log(Cij/Cijo) where Cij is the intensity of peak
%           j in spectrum i and o is the median control spectrum
%       hier_sets: hierarchically clustered independent sets of
%           statistical correlations between peaks
%       cluster_sets: independent sets in hierarchical order with peak
%           incices and corresponding chemical shifts.  
%       targets: indices in ppm vector of detected peaks

% Hierarchical sets identifies independent sets, then collapses them and
% hierarchically clusters the biological correlations, then re-expands them
% within the clusters and calculates the log-change matrix based on the
% cluster order.

%Author: Steven L Robinette, University of Florida & Imperial College London

if nargin<5
    cluster_metric='topological';
end
if nargin<4
    corr_metric='pearson';
end

cluster=1;


if size(dataset1,1)>size(dataset1,2)
    dataset1=dataset1';
end
if size(dataset2,1)>size(dataset2,2)
    dataset2=dataset2';
end
if size(ppm,1)>size(ppm,2)
    ppm=ppm';
end

% Pick Peaks using Kirill's RSPA peak picking script
targets=PeakPicking(median(dataset2),ppm);
picked_peaks=ppm(targets);

% Calculate correlation matrix of all peaks and identify independent sets
if corr_metric(1)=='p'
    corrmat=pearson(dataset2(:,targets)');
    old_corrmat=corrmat;
    spinsystem=find_sets(corrmat,picked_peaks,.8);
else
    corrmat=spearman(dataset2(:,targets)');
    old_corrmat=corrmat;
    spinsystem=find_sets(corrmat,picked_peaks,.75);
end


%cluster peaks based on .03 ppm
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
        kill{index}=spinsystem{1,k}(2:size(spinsystem{1,k},2));
        index=index+1;
    end
end

kill2=cell2mat(kill);

order2=order;
for k=1:size(kill2,2)
    order2(find(order2==kill2(k)))=[];
end

singletmatrix=zeros(size(order2,2),size(order2,2));
for z=1:size(order2,2)
    for k=1:size(order2,2)
        singletmatrix(z,k)=old_corrmat(order2(z),order2(k));
    end
end

% figure, imagesc(singletmatrix)
% caxis([-1 1])

%cluster biological correlations to identify metabolite ensembles
if cluster_metric(1)=='t'
    distmat=topological_overlap(abs(full_singletmatrix.^3));
    distmat=-1*((distmat+max(max(distmat)))./2)+max(max(distmat));
%     for k=1:size(distmat,1)
%         distmat(k,k)=0;
%     end
elseif cluster_metric(1)=='e'
    distmat=euclid_dist(singletmatrix.^3);
else
    distmat=-1*((full_singletmatrix+1)./2)+1;
end

index=1;
for k=2:size(singletmatrix,1)+1
    distance(index:index+size(singletmatrix,1)-k)=distmat(k-1,k:size(singletmatrix,1));
    index=index+size(singletmatrix,1)-k+1;
end

figure, dendrogram(linkage(distance),0,'colorthreshold',6.3);
sample_order=str2num(get(gca,'XTickLabel'));
sample_order=sample_order';

cluster_sets=spinsystem(:,sample_order);
order3=[cluster_sets{1,:}];
hier_sets=zeros(size(order3,2),size(order3,2));
for z=1:size(order3,2)
    for k=1:size(order3,2)
        hier_sets(z,k)=old_corrmat(order3(z),order3(k));
    end
end

%Create log change R matrix
for k=1:size(dataset2,1)
    diff(k,:)=dataset2(k,targets(order3))./median(dataset1(:,targets(order3)));
end
R=log(abs(diff));

figure, imagesc(R)
caxis([-3 3])

% Visualize clustered correlation matrix and plot independent set bounding
% boxes and chemical shifts
figure, imagesc(hier_sets)
hold on
index=1;
for k=1:size(cluster_sets,2)
    if size(cluster_sets{1,k},2)>1
        rectangle('Position',[index-.5,index-.5,size(cluster_sets{1,k},2),size(cluster_sets{1,k},2)], 'EdgeColor', [0 1 0])
        text(index+(size(cluster_sets{1,k},2)/2)-.5,index+(size(cluster_sets{1,k},2)/2)-.5,num2str(cluster_sets{2,k}),'horizontalAlignment', 'center','color','green')
        index=index+size(cluster_sets{1,k},2);
    else
        index=index+size(cluster_sets{1,k},2);
    end
end
caxis([-1 1])

assignin('caller','R',R);
assignin('caller','hier_sets',hier_sets);
assignin('caller','cluster_sets',cluster_sets);
assignin('caller','targets',targets);

