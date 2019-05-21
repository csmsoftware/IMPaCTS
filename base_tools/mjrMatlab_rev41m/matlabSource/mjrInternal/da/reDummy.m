function classVect=reDummy(Y)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------

[n,m]=size(Y);
classVect=zeros(n,1);
for(i=1:m)
    ind=find(Y(:,i)==1);
    classVect(ind)=i;
end
