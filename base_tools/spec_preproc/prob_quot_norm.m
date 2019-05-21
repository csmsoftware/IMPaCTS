function normd=prob_quot_norm(reference_spectra, normd)
%This funciton takes a reference spectra and an array of spectra to be
%normalised and produces a normalised version of the spectras according to
%probabilistic quotient normalisation (It assumes data is pre-mormalised to
%an intergral value).

[n,m]=size(normd);
quotients=repmat(reference_spectra,n,1)./normd;
nans=isnan(normd);
if sum(nans)==0
    medians=median(quotients,2);
else
    %Do some fancy stuff to ignore NANs when taking the medians
    medians=zeros(n,1);
    nans=reshape(nans,n,m);
    for i=1:n
        medians(i,:)=median(quotients(i,logical(~nans(i,:))),2);
    end
end   
normd=normd./repmat(medians,1,m);

