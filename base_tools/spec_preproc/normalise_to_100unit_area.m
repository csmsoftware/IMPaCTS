function normalised_matrix = normalise_to_100unit_area(mat)
% This small function normalises each row of a spectrum matrix to an area of 100.

totals=sum(mat,2);
[m,n]=size(mat);
for x=1:n
    mat(:,x)=(mat(:,x)./totals)*100;
end
normalised_matrix=mat;
