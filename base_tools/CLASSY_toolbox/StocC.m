function values=StocC(ppm,dataset,target,Cutoff)

%values=StocC(ppm,dataset,target,Cutoff)

%Input: dataset: Control variable- set of 1D spectra from control animals
%       ppm: Chemical shift vector same length as dataset2 and dataset1
%       target: driver peak chemical shift
%       Cutoff: correlation coefficient to define connectivity

%Output: values: peaks with correlation to target higher than Cutoff,
%           clustered with .03 ppm resolution

%StocC identifies all peaks in experimental array 'dataset' with
%correlations to driver peak 'target' higher than correlation coefficient
%'Cutoff'

%Author: Steven L Robinette, University of Florida & Imperial College
%London


if size(dataset,1)>size(dataset,2)
    dataset2=dataset2';
end
if size(ppm,1)>size(ppm,2)
    ppm=ppm';
end


targets=PeakPicking(mean(dataset),ppm);
picked_peaks=ppm(targets);


%find indexes of picked chemical shifts
[h,target_ind]=min(abs(picked_peaks-target));

%Here using dataset2 means only intra-experiment correlations are used
corrmat=pearson(dataset(:,targets)');

values=picked_peaks(find(corrmat(target_ind,:)>Cutoff));

x=values;
clear values
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
    values(k)=mean(x(a(k)+1:a(k+1)));
end



