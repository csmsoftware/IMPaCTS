function [dummy, labels_sorted]=getDummy(class);
%---------------------------------------
%args: class=vector with classlbl's (int)
%return: dummy= matrix (for PLS-DA), class labels(kolumns) in ascending order i.e. smallest class label will be as column one in dummy, etc.
%           labels_sorted=the class labels that are found in class in sorted order...
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------
%---------------------------------------

labels=unique(class);%the set of classlabels in class
labels_sorted=sort(labels); %sort labels in ascending order

len_class=length(class);%number of samples
len_labels=length(labels);%number of classes

dummy=zeros(len_class,len_labels); %dummy matrix initialized as a zero matrix

for i=1:len_labels %for each class label
   ind=find(class==labels_sorted(i)); %find the rows (samples) that belongs to the current class, labels_sorted(i
   dummy(ind,i)=1; %write ones in the positions where we have the current class....
end


