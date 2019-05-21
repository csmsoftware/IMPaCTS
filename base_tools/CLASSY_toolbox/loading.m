function spect=loading(X,ppm);
a=cd;
X(find(isnan(X)==1))=0;
model=mypca(X,'mc',2);
spect=max([abs(model.P(:,1)),abs(model.P(:,2))]');
cd(a)