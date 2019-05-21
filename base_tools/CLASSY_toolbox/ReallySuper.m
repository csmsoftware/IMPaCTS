function ReallySuper(dataset2,dataset1,ppm,cluster,corr_metric)

%[R,newcluser_mat,order_spinsystem]=ReallySuper(dataset2,dataset1,ppm,corr_metric,cluster)

%Input: dataset2: Experimental variable- set of 1D spectra
%       dataset1: Control variable- set of 1D spectra from control animals
%       ppm: Chemical shift vector same length as dataset2 and dataset1
%       corr_metric: either 'pearson' or 'spearman'- default pearson
%       cluster: 1 for hierarchical clustering of R matrix sample dimension

%Output: R: log change matrix Rij=log(Cij/Cijo) where Cij is the intensity of peak
%           j in spectrum i and o is the median control spectrum
%       newcluster_mat: independent sets of statistical correlations
%           between peaks ordered by R potential
%       order_spinsystem: independent sets in order with peak indices and
%           corresponding chemical shifts.  
%       targets: indices in ppm vector of detected peaks


%ReallySuper finds independent sets in the correlation matrix of the peaks
%in the median spectrum of the set of experimental spectra and calculates
%the log change vs. median control peaks.  The independent sets with more
%than one chemical shift are ordered by their R potential, and the spectra
%dimension of the R matrix can be clusted hierarchically to investigate
%variable responses

%Author: Steven L Robinette, University of Florida & Imperial College
%London

if nargin<5
    corr_metric='pearson';
end
if nargin<4
    cluster=0;
end

if size(ppm,1)>size(ppm,2)
    ppm=ppm';
end
if size(dataset1,2)~=size(ppm,2)
    dataset1=dataset1';
end
if size(dataset1,2)~=size(ppm,2)
    dataset2=dataset2';
end

% Pick Peaks using Kirill's RSPA peak picking script
targets=PeakPicking(median(dataset2),ppm);
picked_peaks=ppm(targets);

%Here using dataset2 means only intra-experiment correlations are used
corrmat=pearson(dataset2(:,targets)');

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

%Rearrange corrmat to demonstrate biclustering
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

spinsystem2=spinsystem;
kill=zeros(1,size(spinsystem2,2));
for k=1:size(spinsystem2,2)
    if size(spinsystem2{2,k})==1;
        kill(k)=1;
    end
end

spinsystem2(:,find(kill>0))=[];
order2=[spinsystem2{1,:}];
bicluster_mat2=zeros(size(order2,2),size(order2,2));
for z=1:size(order2,2)
    for k=1:size(order2,2)
        bicluster_mat2(z,k)=old_corrmat(order2(z),order2(k));
    end
end

for k=1:size(dataset2,1)
    diff(k,:)=dataset2(k,targets)./median(dataset1(:,targets));
end
R=log(abs(diff(:,order2)));

index=1;
for k=1:size(spinsystem2,2);
    order_import(k)=sum(mean(R(:,index:index+size(spinsystem2{1,k},2)-1)));
    index=index+size(spinsystem2{1,k},2);
end

[h,me]=sort(abs(order_import),'descend');

for k=1:size(me,2)
    order_spinsystem{1,k}=spinsystem2{1,me(k)};
    order_spinsystem{2,k}=spinsystem2{2,me(k)};
end

neworder=[order_spinsystem{1,:}];
newcluster_mat=zeros(size(neworder,2),size(neworder,2));
for z=1:size(neworder,2)
    for k=1:size(neworder,2)
        newcluster_mat(z,k)=old_corrmat(neworder(z),neworder(k));
    end
end

figure, imagesc(newcluster_mat)
hold on
index=1;
for k=1:size(order_spinsystem,2)
    rectangle('Position',[index-.5,index-.5,size(order_spinsystem{1,k},2),size(order_spinsystem{1,k},2)], 'EdgeColor', [0 1 0])
    text(index+(size(order_spinsystem{1,k},2)/2)-.5,index+(size(order_spinsystem{1,k},2)/2)-.5,num2str(order_spinsystem{2,k}),'horizontalAlignment', 'center','color','green')
index=index+size(order_spinsystem{1,k},2);
end
caxis([-1 1])

R=log(abs(diff(:,neworder)));

if cluster==1;

    for k=1:size(R,1)
        for z=1:size(R,1)
            distmat(k,z)=sum(sum(([R(k,:)-R(z,:)].^2)));
        end
    end

    index=1;
    for k=2:size(R,1)+1
        distance(index:index+size(R,1)-k)=distmat(k-1,k:size(R,1));
        index=index+size(R,1)-k+1;
    end

    figure, dendrogram(linkage(distance),0,'colorthreshold',6.3);
    sample_order=str2num(get(gca,'XTickLabel'));
    figure, imagesc(R(sample_order,:)')
    caxis([-3 3])
else
    figure, imagesc(R)
    caxis([-3 3])
end

assignin('caller','R',R);
assignin('caller','newcluster_mat',newcluster_mat);
assignin('caller','order_spinsystem',order_spinsystem);
assignin('caller','targets',targets);