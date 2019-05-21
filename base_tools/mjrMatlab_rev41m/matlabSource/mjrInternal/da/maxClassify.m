function [predClass]=maxClassify(data)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------

    predClass = [];

    for(i=1:length(data(:,1)))
        tmp=find(data(i,:)==max(data(i,:)));
        if(length(tmp)==1)
            predClass(i)=find(data(i,:)==max(data(i,:)));
        else
            predClass(i)=NaN;
            
        end
            
    end
    predClass=predClass';
end
