function [] = CJSplotPeaklist(flag,X,XTitles,peaks,peakList,ppm,name,from,header,stars)
% plots peak list data
%
% flag = (1x1) if flag==1 plots only sections of full spectrum containing
%        peaks, else if flag==0 plots full spectrum
% X = (mxn)  spectral data
% XTitles = (mx1 cell) X sample names
% peaks = (1xn) peak locations
% peakList = (1xv) list of peaks/clusters to plot number corresponds to
%            number in peaks
% ppm = (1xn) optional ppm scale (if not entered plots across indices 1:n)
% name = (vx1 cell) optional name of each peak/cluster
% from = (1xv) optional indices of peak (for each cluster) correlation 
%        driven from
% header = (1xc char) optional title for plot
% stars = (1x1) flag - if stars==1 will plot star at peak node index in 
%         full spectrum (i.e. if flag==0)
%
% 271009 caroline.sands01@imperial.ac.uk

figure;set(gcf,'Color',[1 1 1]);
nvars=size(X,2); Xm=max(X); 
if(nargin<10);stars=0; end
if(nargin<9); header=[]; end
if(nargin<8); from=[]; end
if(nargin<7||isempty(name)); name=cell(1,length(peakList)); end
if(nargin<6||isempty(ppm)); ppm=1:nvars; end

if(flag==1) % plot subset

    peakstemp=zeros(1,nvars);
    for j=1:length(peakList)
        peakstemp(peaks==peakList(j))=j;
    end
    
    temp=[find(peakstemp~=0) nvars]; temp2=[1 temp(1:end-1)]; temp3=temp-temp2;
    inds=find(temp3>1500); if(temp3(length(temp3))<=1500); inds(length(inds)+1)=length(temp); end
    len=length(inds)-1; if(isempty(inds)); len=1; inds=[1 length(temp)]; end
    plotInds=zeros(len,4);
    
    % get plot indices
    
    for i=1:len
        if(temp(inds(i))-50<1); start=1; else start=temp(inds(i))-50; end
        if(temp2(inds(i+1))+50>nvars); stop=nvars; else stop=temp2(inds(i+1))+50; end
        plotInds(i,1:2)=[start stop];
        plotInds(i,plotInds(i,1:2)<1)=1; plotInds(i,plotInds(i,1:2)>size(X,2))=size(X,2);
        plotInds(i,3)=plotInds(i,2)-plotInds(i,1);
        temp4=Xm; temp4(peakstemp==0)=0;
        plotInds(i,4)=max(temp4(plotInds(i,1):plotInds(i,2)));
    end

    % generate factors
    factor=(1-(len+1)*0.1)/sum(plotInds(:,3));
    
    % generate position vectors
    for i=1:len
        if i==1; position(i,:)=[0.1 0.05 plotInds(i,3)*factor 0.9];
        else position(i,:)=[0.1*i+sum(plotInds(1:i-1,3))*factor 0.05 plotInds(i,3)*factor 0.9];
        end
        subplot('position',position(i,:));
        plot(ppm(plotInds(i,1):plotInds(i,2)),X(:,(plotInds(i,1):plotInds(i,2))),'Color',[0.7 0.7 0.7]); hold all; set(gca,'Xdir','reverse');
        xlim([ppm(plotInds(i,1)) ppm(plotInds(i,2))]);
        ylim([0 max(plotInds(:,4))+1/10*max(plotInds(:,4))]);
        if(~isempty(from)&&(plotInds(i,1)<peakList(from)&&plotInds(i,2)>peakList(from)))
            plot(ppm(peakList(from)),Xm(peakList(from)),'v','Color',[0 0 0]);
        end
    end
    
    
    % plot clusters
    
    for i=1:length(peakList)
        plot_at=peaks==peakList(i);
        col=[];
        for k=1:len
            plot_here=plot_at;plot_here(1:plotInds(k,1))=0;plot_here(plotInds(k,2):end)=0;
            if(all(plot_here==0)); continue; end
            
            subplot('position',position(k,:));

            if(isempty(col))
                p1=plot(ppm(plot_here),Xm(plot_here));
                col=get(p1,'Color');
            else
                plot(ppm(plot_here),Xm(plot_here),'Color',col);
            end
            
            if(plotInds(k,1)<peakList(i)&&plotInds(k,2)>peakList(i))
                plot(ppm(peakList(i)),Xm(peakList(i)),'*','Color',col);
                if(~isempty(name{i}))
                    tempTitle=cell2mat(name(i));
                    if(ischar(tempTitle))
                        text(ppm(peakList(i)),Xm(peakList(i)),sprintf('%s',tempTitle),'Color',col);
                    else
                        text(ppm(peakList(i)),Xm(peakList(i)),sprintf('%g',tempTitle),'Color',col);
                    end
                end
            end
        end
    end
    
else % plot all
    
   plot(ppm,X,'Color',[0.7 0.7 0.7]); hold all;
   if(ppm(length(ppm))==length(ppm))
       set(gca,'YColor',[1 1 1],'Box','off','Xdir','reverse'); 
   else
       set(gca,'YColor',[1 1 1],'Box','off','Xdir','reverse'); 
       xlabel('\delta^1H');
   end
   
   % plot peaks
   legV=0;
   for i=1:length(peakList)
       plot_at=peaks==peakList(i);
       p1=plot(ppm(plot_at),Xm(plot_at)); legV=legV+1;
       if(stars==1); col=get(p1,'Color'); plot(ppm(peakList(i)),Xm(peakList(i)),'*','Color',col); legV=legV+1; end
       if(~isempty(name{i}))
           col=get(p1,'Color');
           tempTitle=cell2mat(name(i));
           if(ischar(tempTitle))
               text(ppm(peakList(i)),Xm(peakList(i)),sprintf('%s',tempTitle),'Color',col);
           else
               text(ppm(peakList(i)),Xm(peakList(i)),sprintf('%g',tempTitle),'Color',col);
           end
       end
   end
end

if(~isempty(header))
    title(sprintf('%s',header));
end

if(length(name)==legV/2) % if plot stars double name vector to plot correctly!
    name2=cell(2*length(name),1); na2=1;
    for na=1:2:length(name2)-1
        name2(na:na+1)=[name(na2);name(na2)]; na2=na2+1;
    end
    name=name2;
end

if(~isempty(XTitles)&&~isempty(name))
    legend([XTitles;name]);
elseif(~isempty(XTitles))
    legend(XTitles)
end
       