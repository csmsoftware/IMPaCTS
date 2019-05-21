function [sample_order,m]=hier_cluster(X,cluster_metric,algorithm)
%
%sample_order=hier_cluster(X,cluster_metric,algorithm)
%
%Input: singletmatrix- matrix to cluster, where 2nd dim is observations
%       cluster_metric: either 'euclidean' for euclidean distance,
%           'pearson' for pearson correlation, or 'spearman' for spearman
%           correlation
%       algorithm: determines how hierarchical clustering is done- takes
%       inputs 'single', 'average', 'complete', or 'weighted'
%
%Output: sample_order: clustered order of indices in singletmatris
%
% hier_cluster does hierarchical clustering on the input matrix using one
% of several distance metrics
%
%Author: Steven L Robinette, University of Florida & Imperial College
%London

if nargin<3
    algorithm='complete';
end
if nargin<2
    cluster_metric='euclid_dist';
end

if cluster_metric(1)=='e'
    distmat=euclid_dist(X);
elseif cluster_metric(1)=='p'
    %transform corrmat to 0-1, 0 being perfect correlation
    distmat=((-1*pearson(X))+1)/2;
elseif cluster_metric(1)=='s'
    distmat=((-1*spearman(X))+1)/2;
else
    error('clustr_metric must have values euclidean, pearson, or spearman')
end

index=1;
for k=2:size(X,1)+1
    distance(index:index+size(X,1)-k)=distmat(k-1,k:size(X,1));
    index=index+size(X,1)-k+1;
end
m=linkage(distance,algorithm);

figure, h=dendrogram(m,0,'ORIENTATION','left');
set(h,'LineWidth',1,'Color','k')
sample_order=str2num(get(gca,'YTickLabel'));
sample_order=sample_order(length(sample_order):-1:1)';
assignin('caller','sample_order',sample_order);
figure, imagesc(X(sample_order,:))
set(gca,'YTick',1:size(X,1))
set(gca,'YTickLabel',sample_order);
