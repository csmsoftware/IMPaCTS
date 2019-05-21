function spinsystem=find_sets(corrmat,picked_peaks,minthresh)

%identify correlation networks.  Move from low correlation to high
%correlation threshold, and use the square root of the overlap factor to
%determine if there are false correlations in the correlation network.
%This allows robust thresholding to avoid false positives/negatives

threshvect=[minthresh:.01:.89,.90:.005:.935,.94:.002:.968,.97:.001:1];
index=1;
index2=1;
loopcount=1;
while loopcount<=size(threshvect,2);
    
    thresh=threshvect(loopcount);
    corrmat2=zeros(size(corrmat));
    corrmat2(find(corrmat>=thresh))=1;

    %This is essentially a measure of false correlations.  If the
    %correlation network share all correlations, the value will be an
    %integer corresponding to the number of members of the correlation
    %network.  If there is a correlation that is not shared by all other
    %members of the network, the value will be a non-integer
    p=corrmat2*corrmat2';
    c=sqrt(sum(p));

    k=1;
    while k<=size(c,2)
        if rem(c(k),1)==0 && c(k)>1 && size(unique(p(k,find(corrmat2(k,:)>0))),2)==1 && unique(p(k,find(corrmat2(k,:)>0)))==c(k)
            corrpeaks=find(corrmat2(:,k)>0);
            spinsystem{1,index}=corrpeaks;
            spinsystem{2,index}=picked_peaks(corrpeaks);
            spinsystem{3,index}=loopcount;
            c(corrpeaks)=.5;
            for zz=1:size(corrpeaks,1)
                corrmat(:,corrpeaks(zz))=0;
                corrmat(corrpeaks(zz),:)=0;
            end
            index=index+1;
            loopcount=1;
            corrmat2=zeros(size(corrmat));
            thresh=min(corrmat(find(corrmat>minthresh)))-.0001;
            if max(max(corrmat))>0
            corrmat2(find(corrmat>=thresh))=1;
            p=corrmat2*corrmat2';
            c=sqrt(sum(p));
            k=1;
            end
        elseif c(k)==1 && max(c)<=1
            corrpeaks=find(corrmat2(:,k)>0);
            spinsystem{1,index}=corrpeaks;
            spinsystem{2,index}=picked_peaks(corrpeaks);
            spinsystem{3,index}=loopcount;
            c(corrpeaks)=.5;
            for zz=1:size(corrpeaks,1)
                corrmat(:,corrpeaks(zz))=0;
                corrmat(corrpeaks(zz),:)=0;
            end
            index=index+1;
            loopcount=1;
            corrmat2=zeros(size(corrmat));
            thresh=min(corrmat(find(corrmat>minthresh)))-.0001;
            if max(max(corrmat))>0
                corrmat2(find(corrmat>=thresh))=1;
                p=corrmat2*corrmat2';
                c=sqrt(sum(p));
                k=1;
            end
        end
        k=k+1;
    end
    nestloop=0;


    if nestloop>0;
        corrmat2=zeros(size(corrmat));
        corrmat2(find(corrmat>=threshvect(loopcount)))=1;
        p=corrmat2*corrmat2';
        c=sqrt(sum(p));
        %use as index for killit the number of dissenting nodes to be ignored
        for killit=1:nestloop
            corrmat2=zeros(size(corrmat));
            corrmat2(find(corrmat>threshvect(loopcount)))=1;
            p(find(p==killit))=0;
            c=sqrt(sum(p));

            for k=1:size(c,2)
                if rem(c(k),1)==0 && c(k)>0 && size(unique(p(k,find(corrmat2(k,:)>0))),2)==1 && size(p(k,find(corrmat2(k,:)>0)),2)==c(k) && unique(p(k,find(corrmat2(k,:)>0)))==c(k)
                    corrpeaks=find(corrmat2(:,k)>0);
                    spinsystem{1,index}=corrpeaks;
                    spinsystem{2,index}=picked_peaks(corrpeaks);
                    c(corrpeaks)=.5;
                    for zz=1:size(corrpeaks,1)
                        corrmat(:,corrpeaks(zz))=0;
                        corrmat(corrpeaks(zz),:)=0;
                    end
                    index=index+1;
                end
            end
        end
	end
	
    if max(max(corrmat))==0
        break
    end
    loopcount=loopcount+1;
end