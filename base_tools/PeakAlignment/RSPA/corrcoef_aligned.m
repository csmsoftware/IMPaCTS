function CC=corrcoef_aligned(sp,ref,step)
% Calculation of correlation coefficient:
% Filter scales the spectral regions through specified step to unit variance 
% so as the high intensive and low intensive peaks would contribute 
% equally in the similarity


ilength=length(sp);
if ilength<20
    CC=0;
end

if step>=ilength
    CC=corrcoef(sp,ref);
    CC=CC(1,2);
    return;
end

bin_count=ceil(ilength/step);
bin_width=ceil(ilength/bin_count);
bins=[1:bin_width:ilength];

if bins(end)~=ilength
    bins=[bins ilength];
    bin_count=bin_count+1;
end

for i=1:bin_count-1
    istart=bins(i);
    iend=bins(i+1)-1;
    sp(istart:iend)=sp(istart:iend)-mean(sp(istart:iend));
    ref(istart:iend)=ref(istart:iend)-mean(ref(istart:iend));
    if var(sp(istart:iend))~=0
        sp(istart:iend)=sp(istart:iend)./std(sp(istart:iend));
    end
    if var(ref(istart:iend))~=0
        ref(istart:iend)=ref(istart:iend)./std(ref(istart:iend));
    end
end
%CC=sp(1:end-1)*ref(1:end-1)'./(ilength-1);
CC=corrcoef(sp(1:end-1),ref(1:end-1));
CC=CC(1,2);
return;