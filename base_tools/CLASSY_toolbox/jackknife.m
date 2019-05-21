function corr=jackknife(A)

%% function corr=jacknife(A) calculates jacknife correlation matrix of A.
%% See reference.  

%Reference- Heyer LJ, Kruglyak S, Yooseph S. Exploring expression data:
%identification and analysis of coexpressed genes. Genome Res 1999; 9: 1106-1115.

jack=zeros(size(A,1),size(A,1),size(A,2));
for k=1:size(A,2)
    jack(:,:,k)=pearson(A(:,[1:k-1,k+1:size(A,2)]),A(:,[1:k-1,k+1:size(A,2)]));
end
[h,m]=min(abs(jack),[],3);

corr=zeros(size(A,1),size(A,1));
for dim1=1:size(A,1)
    for dim2=1:size(A,1)
        corr(dim1,dim2)=jack(dim1,dim2,m(dim1,dim2));
    end
end