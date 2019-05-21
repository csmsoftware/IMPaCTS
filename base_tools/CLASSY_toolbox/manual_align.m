function aligned=manual_align(alignit,ppmreg)

%aligned=manual_align(alignit,ppmreg)
%
%Input: alignit: mis-aligned region from stack of 1D spectra
%       ppmreg: chemical shift vector for mis-aligned region
%
%Output: aligned: alignment corrected region
%
% manual_align aligns a problem multiplet by maximizing the inner product.
% You must identify the region corresponding to the multiplet manually.  

%Author: Steven L Robinette, University of Florida & Imperial College
%London

[h,ref_ind]=max(max(alignit'));
reference=alignit(ref_ind,:);

for ind=1:size(alignit,1);
for k=1:size(alignit,2)
    aligntry(:,k)=circshift(alignit(ind,:),[0 k]);
    shift_ind(k)=reference*aligntry(:,k);
end
[h,shiftit]=max(shift_ind);
aligned(ind,:)=aligntry(:,shiftit);
end

figure, plot(ppmreg,aligned)

