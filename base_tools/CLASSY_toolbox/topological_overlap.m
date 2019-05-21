function W=topological_overlap(A);
% calculation of topological overlap
% Input: A is a matrix of pair-wise correlation coefficients

%Author: K.Veselkov Imperial College London


if size(A,1)~=size(A,2)
    error('input matrix A has to be symmetrical');
end
dim=size(A,1);
W=repmat(NaN,[dim, dim]);
%assume that there is no topological overlap of the node with itself
%diag_indexes=1:dim+1:dim.*dim;
%A(diag_indexes)=0;
%W(diag_indexes)=0;
connectivity=sum(abs(A));
for i=1:dim
    for j=1:dim
        if ~isnan(W(i,j))
            continue;
        end
        suml=0;
        for k=1:dim
           l=A(i,k)*A(k,j);
           suml=suml+l;
        end
        W(i,j)=(suml+A(i,j))./(min(connectivity([i,j]))+1-A(i,j));
    end
end
return;