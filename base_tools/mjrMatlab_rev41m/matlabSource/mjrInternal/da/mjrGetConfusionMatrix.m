function [A] = mjrGetConfusionMatrix(true,pred)

    uniqueClass=unique(true);

    A=zeros(length(uniqueClass),length(uniqueClass));

    for i = 1 : length( uniqueClass )
        indTrue=find(true==uniqueClass(i));
            for(j = 1:length(indTrue))
                A(i,find(uniqueClass==pred(indTrue(j))))=A(i,find(uniqueClass==pred(indTrue(j))))+1;
            end
            A(i,:)=A(i,:)./length(indTrue);
    end

end