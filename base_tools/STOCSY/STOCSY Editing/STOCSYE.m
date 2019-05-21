function[dataN,cor,out]=STOCSYE(X,ppm,driver,cutoff,all,noise,extra,mode)
%
% Runs STOCSY editing algorithm
%
% Required input arguments:
% X = (mxn) original spectral data matrix (m samples, n variables)
% ppm = (1xn) ppm scale in -1:10 orientation (see note)
% driver = (1xnp) a single or vector of peak ppm values from which STOCSYE is
%          driven
%
% Optional input arguments:
% cutoff = (1x1 OR 1xp) correlation threshold if scalar will use across all 
%          peaks, otherwise can input vector if a different cutoff for each 
%          peak is required (optional, default = 0.9)
% all = (string) if 'all' will include pos and neg correlations else if
%       'pos' will use positive correlations only (optional, default =
%       'pos')
% noise = (1x2) start and stop ppm values of noise region (optional, 
%         default = between 9.5:10ppm)
% extra : defines region around each drug peak to find local baseline 
%         (optional, default is 0.02ppm either side of each region to scale)
% mode = (string) if 'by_sample' calculates region to scale and replace
%        separately for each sample, if 'by_mean' calculates region from
%        mean spectrum and uses for all samples (optional, default =
%        'by_sample')
%
% Output arguments:
% dataN = (mxn) scaled and background corrected stocsy edited data
% cor = (p+1,n) squared correlation vectors for each peak, and
%       cor(p+1,:) = max of all.^2
% out = (struct) saved running parameters (optional)
%       .peak .cutoff .all .noise .extra .mode
% 
% Example run (driven from multiple peaks):
% [dataN] = STOCSYE(X, ppm, [3.7135, 2.6014, 4.2723]);
%
% NOTE: if ppm scale runs from ppm(1) = 10 to ppm(end) = -1, then data
% matrices will be flipped to run in ppm numerically ascending order. dataN
% and cor (if required) will be returned to the original orientation before
% output BUT variables in 'out' (if required) will remain in the
% orientation as ppm numerically increasing, so remember to check and
% change these (by reversing using fliplr or subtracting from the length of
% ppm) before analysis!
%
% CJS 070409
% 140210 adapted from STOCSYE_v17 optimised and tidied up 

% initial set up define global variables and undefined input arguments

if(nargin<8); mode=[]; end
if(nargin<7); extra=[]; end
if(nargin<6); noise=[]; end
if(nargin<5); all=[]; end
if(nargin<4); cutoff=[]; end

% Check that ppm scale runs from -1:10 and reverse if not
reversedppm = 0;
if(ppm(1)>ppm(end))
    reversedppm = 1;
    X = fliplr(X);
    ppm = fliplr(ppm);
end

% Extract indices of peak ppms
for i = 1:length(driver)
    driver(i) = find(ppm >= driver(i), 1);
end

if(isempty(mode))
    mode='by_sample';
end

ppmInc=median(diff(ppm)); % find increments of ppm scale
if(isempty(extra))
    extra=round(0.02/ppmInc); % extra default (0.02 ppm each side)
    disp('extra set to default 0.02ppm each side of region')
else
    extra=round(extra/ppmInc);
end

if(isempty(noise))
    noise=[9.5 10];
    disp('noise region set to default 9.5:10ppm')
end
[~,ppmmin]=min(abs(ppm-noise(1))); [~,ppmmax]=min(abs(ppm-noise(2)));
noise=ppmmin:ppmmax;

if(isempty(all))
    all='pos';
    disp('all set to pos i.e. only returns positive correlations')
end

if(isempty(cutoff))
    cutoff=0.9;
    disp('cutoff set to default 0.9')
end

ppmcut=find(diff(ppm)>ppmInc*1.5)'; % identify regions where data cut (i.e. water removed)
if(isstruct(driver)); driver=driver.DataIndex; end % converts peak from struct to index
[~,var]=size(X);
dataN=X; dataD=zeros(size(X));
if(strcmp('by_mean',mode)); Xm=mean(X); end

% 1. generate correlation
cor=zeros(length(driver),var);
for p=1:1:length(driver)
    cor(p,:)=stocsyCS(X,driver(p));
end

if(strcmp('pos',all)); cor(cor<0)=0; end % delete negs if only interested in pos
cor2=max(abs(cor),[],1).^2; % find max correlation squared (for data scaling)
    
% finds indices to scale (indices with correlation>cutoff)
if(length(cutoff)==1); cutoff=repmat(cutoff,length(driver),1); end
cutoff=repmat(cutoff,1,var);
[~,remove]=find(cor.^2>cutoff);

% generate matrix of start and stop indices for each region (each region=row)
ax=1; ay=1; rem_list(ay,ax)=remove(1);
for j=2:1:length(remove)
    if(remove(j)-remove(j-1)>10); % emalgamates if less than 10 between two peaks
        rem_list(ay,2)=remove(j-1);
        ay=ay+1;
        rem_list(ay,1)=remove(j);
    end
end
rem_list(ay,2)=remove(end);


% for every drug region (defined by a pair in rem_list)
for p=1:size(rem_list,1)
    
    % define region +/-extra each side of peak for background estimation
    start=rem_list(p,1)-extra;
    stop=rem_list(p,2)+extra;
    if(start<1); start=1; end
    if(stop>length(ppm)); stop=length(ppm); end
   
    % check doesn't span a cut region
    cutmatstart=repmat(ppmcut,1,rem_list(p,1)-start+1);
    cutmatstop=repmat(ppmcut,1,stop-rem_list(p,2)+1);
    checkstart=cutmatstart-repmat(start:1:rem_list(p,1),length(ppmcut),1);
    if(any(checkstart==0,2)==1); start=ppmcut(any(checkstart==0,2)+1); end
    checkstop=cutmatstop-repmat(rem_list(p,2):1:stop,length(ppmcut),1);
    if(any(checkstop==0,2)==1); start=ppmcut(any(checkstop==0,2)); end    
    
    % LOD=mean(local baseline)+3*std(noise)
    min_baseline=min(X(:,start:stop),[],2);
    std_noise=mean(std(X(:,noise),[],1));
    LOD=mean(min_baseline)+3*std_noise;
    
    if(strcmp('by_mean',mode));
        differ=diff(Xm);
        from=rem_list(p,1)-find(fliplr(differ(1:rem_list(p,1)-1))<0,1,'first')+1;
        to=rem_list(p,2)+find(differ(rem_list(p,2)+1:end)>0,1,'first');
    end

    % do scaling and background correction
    for t=1:1:size(dataN,1) % for each sample
        
        if(strcmp('by_sample',mode))
            % find local minima either side of region
            differ=diff(X(t,:));
            from=rem_list(p,1)-find(fliplr(differ(1:rem_list(p,1)-1))<0,1,'first')+1;
            to=rem_list(p,2)+find(differ(rem_list(p,2)+1:end)>0,1,'first');
        end
        
        % scale data
        tempdata=X(t,from:to).*(1-cor2(from:to));
        
        dataD(t,from:to)=X(t,from:to)-tempdata;
        
        % background correct if signal<LOD
        inds=find(tempdata<LOD);
        tempdata(inds)=repmat(abs(min_baseline(t)),...
            1,length(inds))+std_noise*randn(1,length(inds));
        
        dataN(t,from:to)=tempdata;
    end
end

% reverse ppm if flipped
if(reversedppm == 1);
    dataN = fliplr(dataN);
end


if(nargout>1)
    if(reversedppm == 1); cor = fliplr(cor); cor2 = fliplr(cor2); end
    cor=[cor.^2;cor2];
end

if(nargout>2)
    out.reversedppm = reversedppm;
    out.peak=driver;
    out.cutoff=cutoff;
    out.all=all;
    out.noise=[ppmmin ppmmax];
    out.extra=extra;
    out.mode=mode;
    out.dataD=dataD;
    out.dataS=X-dataD;
end

