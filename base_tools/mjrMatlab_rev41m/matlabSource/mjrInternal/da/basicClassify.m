function [predClass]=basicClassify(data,k)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------


%   k is boundary, data is y_hat
    predClass=NaN*ones(length(data(:,1)),length(data(1,:)));
     for(i=1:length(data(:,1)))        
        tmp=find(data(i,:)>k);
        predClass(i,1:length(tmp))=tmp;
     end     
end
