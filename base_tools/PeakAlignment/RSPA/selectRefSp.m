function index=selectRefSp(X,step)
% Automated selection of a reference spectrum based on the highest similarity to
% all other spectra
% Input: X - spectra
%        step - used to scale spectral regions down to specific bin_size

[obs,splength]=size(X);

if step>=splength
    CC=corrcoef(X);
    index=find(prod(CC)==max(prod(CC)));
    return;
end

bin_count=ceil(splength/step);
bin_width=ceil(splength/bin_count);
bins=[1:bin_width:splength];

if bins(end)~=splength
    bins=[bins splength];
    bin_count=bin_count+1;
end

for i=1:bin_count-1
    istart=bins(i);
    iend=bins(i+1)-1;
    seglength=iend-istart+1;
    X(:,istart:iend)=X(:,istart:iend)-mean(X(:,istart:iend)')'*ones(1,seglength);
    stdX=std(X(:,istart:iend)')';
    stdX(stdX==0)=1;
    X(:,istart:iend)=X(:,istart:iend)./(stdX*ones(1,seglength));
end

CC=abs(corrcoef(X'));
index=find(prod(CC)==max(prod(CC)));
end