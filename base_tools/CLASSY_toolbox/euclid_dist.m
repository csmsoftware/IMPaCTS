function distmat=euclid_dist(A)

distmat=zeros(size(A,1),size(A,1));
for k=1:size(A,1)
    for z=1:size(A,1)
        distmat(k,z)=sqrt(sum([A(k,:)-A(z,:)].^2));
    end
end