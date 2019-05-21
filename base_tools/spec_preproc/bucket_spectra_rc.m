function data = bucket_spectra_rc(data,binsize,range)
% bucket_spectra - Read and bucket Bruker 1-d spectra
% [data] = bucket_spectra()
%
% Written 210102 TMDE  
% Revised 280203 TMDE to use uigetdir instead of uigetfile
% Revised 050803 TMDE to cope if title file exists but is blank (uses
% expname_expno_procno as if there is no title file)
% Revised 120405 TMDE so doesn't crash if there is no spectrum in some bins
% Revised 020608 RC problem if no points wholey inside a bucket, gave 0's
% for this situation -  fixed.
% (c) Copyright 2001-2003 Dr. T.M.D. Ebbels, Imperial College, London

% Default parameters

minlookaheadfac = 10; % minimum number of bucket widths to look ahead for next bucket


% Compute bin centers etc.
b = binsize / 2;
binedges = range(1) : -binsize : range(2);
nb  = length(binedges)-1;
data.vnames = num2str(binedges(1:nb)' - b);
% Lookahead factor is 
binsizes = -diff(binedges(:));
lookaheadfac = max([minlookaheadfac; round(max(binsizes)/min(binsizes))]);
% fprintf('Look ahead factor is %.3f\n',lookaheadfac);

% Read the list of spectra

% fprintf('Reading spectra directory...\n');
% [dname,expno,disk,user] = get_spectra_list(dpath);
% procno = repmat(procno,size(dname,1),1);
% if isempty(dname)  error('No spectra selected'); end
% if any(diff(expno)) 
%     fprintf('List of spectra (ranges separated by 10s):\n');
%     s = ind2range(expno,10);
%     fprintf('%s\n\n',s);
% end

%ns = size(dname,1);
ns=size(data.Spectra.Sp,1);
data.X = zeros(ns,nb);

% Loop over spectra

%hwb  = waitbar(0,'Bucketing spectra...');
xi=1; % count spectra actually reduced (misses out any spectra not read properly).
for i=1:ns,
    spec=[data.Spectra.ppm' data.Spectra.Sp(i,:)'];
     dppm = abs(mean(diff(spec(:,1))));
     dppm2 = dppm/2;
    
    % Find start and finish of bit of spectrum to be bucketed
    ls = length(spec);
    binedges(1);
    binedges(2);
    start = find(spec(:,1)<binedges(1) & spec(:,1)>binedges(2));
        % start = max([start(1)-1 1]');
    if isempty(start) start = 1; else start = start(1)-1; end
    finish = find(spec(:,1)<binedges(nb) & spec(:,1)>binedges(nb+1));
         %finish = min([finish(end)+1,ls]');
    if isempty(finish) finish = ls; else finish = finish(end)+1; end
    
    start;
    finish;
    
    % Loop over buckets

    for j=1:nb,

        j1 = j+1;
        size(spec);
        size(binedges);
        % Find data points which are wholely in current bucket and edge data points
        %RC - changed boundaries to look for half a bucket out from each
        %then below have changed the way it deals with the edges of the
        %buckets
        ind =  start-1 + find(spec(start:finish,1)<binedges(j)+dppm2 & spec(start:finish,1)>binedges(j1)-dppm2);
%         ind =  find(spec(:,1)<binedges(j)-dppm2 & spec(:,1)>binedges(j1)+dppm2); %Old slow algorithm
% Just find data point centres in bucket - as AMIX does (Peter Neidig's email)
%         ind = start-1 + find(spec(start:finish,1)<binedges(j) & spec(start:finish,1)>binedges(j1)); 
        if isempty(ind)
            s = 0; 
            s1 = 0;
            s2 = 0;
            warning('empty bucket')
        else
            % Sum internal points and proportional bit of edge points
            if (ind(1)==1) % spectrum starts part way through the bin
                s1 = 0;
            else
                %RC changed from ind1=ind(1)-1;
                ind1 = ind(1);
                dx1 = binedges(j)-spec(ind1,1)+dppm2;
                s1 = spec(ind1,2) * dx1/dppm;
            end
            if (ind(end)==ls) % spectrum ends halfway through the bin
                s2 = 0;
            else
                %RC changed from ind2=ind(end)+1;
                ind2 = ind(end);
                dx2 = spec(ind2,1)-binedges(j1)+dppm2;
                s2 = spec(ind2,2) * dx2/dppm;
            end
            %Take the first and last points out cos these have already been
            %dealt with
            ind=ind(2:end-1);
            s = sum(spec(ind,2));
            start = ind2; % Update starting index to last data point used - RC changed from ind(end) to ind2 cos now last point is put there.
            %end
            finish = min([ls start+lookaheadfac*(length(ind)+2)]'); % Only look through spec for fac bucket lengths ahead, RC - changed to add 2 to ind length, cos now first and last are out of bucket.
        end
        
        data.X(xi,j) = s + s1 + s2;
        %          data.X(i,j) = s; % If using AMIX algorithm
    end
    %     close(hwb2)
    xi=xi+1;
end
data.Spectra.Sp=data.X;
data.Spectra.ppm=binedges(1:(end-1))-(binsize/2);
