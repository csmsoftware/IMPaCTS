function data2 = reducespec_rc_no_popups(data,options)
% reducespec - Reduce a series of spectra, exclude/merge and normalise
% [] = reducespec()
%
%
% Written 280301 TMDE 
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

% Revised 240401 TMDE to read AMIX files and prompt for exclusion/merge regions
% Revised 260601 TMDE to cope with multiple merge regions properly
% Revised 060701 TMDE to read exclusion & merge regions from files
% Revised 100701 TMDE to check for overlap of exclusion & merge regions
% Revised 220102 TMDE to bucket spectra using bucket_spectra.m
% Revised 120803 TMDE to add acknowledgement splash window
% Revised 040209 RC to check that the passed options for start and end ppm
% aren't outside the current range of ppm in the data.

% Headline
fprintf('*********************\n');
fprintf('***reducespec v0.1***\n');
fprintf('*********************\n');
fprintf('(c) Copyright 2003 Dr. T.M.D. Ebbels, Imperial College, London\n');
fprintf('Starting %s...\n\n',datestr(now));

%checklicense_reducespec;

% Defaults

tol = 10*eps;   % Tolerence for bucket comparisons to avoid round off error.
normc = 100;
b = 0.02; % Half bin width
          % Hard code since calc from first two bins produces 
          % pathological roundoff error
    if options.bucket~=0
        %Make sure the the passed options aren't outside the range of the
        %current ppm
        options.start_ppm=min(options.start_ppm, max(data.Spectra.ppm));
        options.end_ppm=max(options.end_ppm, min(data.Spectra.ppm));
        data = bucket_spectra_rc(data,options.bucket,[options.start_ppm,options.end_ppm]); % Bucket a bunch of spectra
    end
        %data.Spectra.Sp=data.X;

vnam=data.Spectra.ppm;
 nreg = length(vnam);

b = (vnam(1)-vnam(2))/2; % Half bin width

% Get excluded regions
excl=[];
for i=1:size(options.exclude_files,2)
    exfile=options.exclude_files{i};
    if (exfile~=0) 
        [e1,e2] = textread_nowhich(fullfile(options.rgn_dir,exfile),'%f %f','commentstyle','matlab');
        excl1 = [e1 e2];
        excl1 = [sort(excl1')]';
        excl1 = excl1(:,end:-1:1);
        excl = [excl; excl1];
    end
end
if ~isempty(excl) fprintf('Excluding regions...\n'); end
exclind = cell(size(excl,1),1);

for i=1:length(exclind)
    exclind{i} = find((vnam-excl(i,1)-b<-tol) & (vnam-excl(i,2)+b>tol));
    if ~isempty(exclind{i})
        fprintf('Exclude centres %d: %.2f to %.2f\n',i,vnam(exclind{i}([1 end])));
    end
end
exi = unique(cat(2,exclind{:}));
ini = setdiff([1:nreg],exi);

% Exclude regions

vnam = vnam(ini);
data.Spectra.Sp = data.Spectra.Sp(:,ini);
data.Spectra.ppm = data.Spectra.ppm(:,ini);
nreg = length(vnam);

%find regions to merge from files.
merge=[];

for i=1:size(options.merge_files,2)
    merge_file=options.merge_files{i};
    if (merge_file~=0) 
        [e1,e2] = textread_nowhich(fullfile(options.rgn_dir,merge_file),'%f %f','commentstyle','matlab');
        merge1 = [e1 e2];
        merge1 = [sort(merge1')]';
        merge1 = merge1(:,end:-1:1);
        merge = [merge; merge1];
    end
end

% Check if any merge regions overlap with exclusion regions. 
% If so, then widen exclusion regions to include merge region.

for i=1:size(merge,1)
    for j=1:size(excl,1)
        if (merge(i,1)>excl(j,1) & merge(i,2)<excl(j,1)) 
            button = questdlg(sprintf('Merge region (%.3f to %.3f) overlaps with exclusion region (%.3f to %.3f). Extend exclusion region LHS to merge region LHS (%.3f) ?',merge(i,1),merge(i,2),excl(j,1),excl(j,2),merge(i,1)),'Region overlap');
            if strcmp(button,'Yes') excl(j,1)=merge(i,1); end
        end
        if (merge(i,1)>excl(j,2) & merge(i,2)<excl(j,2)) 
            button = questdlg(sprintf('Merge region (%.3f to %.3f) overlaps with exclusion region (%.3f to %.3f). Extend exclusion region RHS to merge region RHS (%.3f) ?',merge(i,1),merge(i,2),excl(j,1),excl(j,2),merge(i,2)),'Region overlap');
            if strcmp(button,'Yes') excl(j,2)=merge(i,2); end
        end
    end
end    


% Get regions to merge

if ~isempty(merge) fprintf('Merging regions...\n'); end
merge = sortrows(merge);
merge=merge([end:-1:1],:);      % Sort merge regions in reverse ppm order
mind = cell(size(merge,1),1);
for i=1:length(mind)
    mind{i} = find(vnam-merge(i,1)-b<-tol & vnam-merge(i,2)+b>tol);
   if ~isempty(mind{i})
        fprintf('Merge centres %d: %.2f to %.2f\n',i,vnam(mind{i}([1 end])));
    end
end

% Merge regions

lefti = 1;
vnamout = [];
Xout = [];
for i=1:length(mind)
    if ~isempty(mind{i})
        % Keep portion of data array from right of previous merge region to left of present one
        kpind = lefti:mind{i}(1)-1;
        vnamout = [vnamout vnam(kpind)];
        Xout = [Xout data.Spectra.Sp(:,kpind)];
        % Attach this merge region
        vnamout = [vnamout mean(vnam(mind{i}))];
        Xout = [Xout sum(data.Spectra.Sp(:,mind{i}),2)];
        lefti = mind{i}(end)+1;
    end
end
% Rightmost chunk
kpind = lefti:length(vnam);
data.Spectra.ppm = [vnamout vnam(kpind)];
data.Spectra.Sp = [Xout data.Spectra.Sp(:,kpind)];


% Correction for 6.0ppm bucket - AMIX includes half the bucket (6.02-6.00), while 
% reducespec with exclude region 5.98-4.50 includes the whole bucket.

if options.fix6ppm==1
     ind6 = find(str2num(data.vnames)==6.00);
     if ~isempty(ind6)
         fprintf('Correcting 6ppm bucket by multiplying by 0.5\n');
         data.Spectra.Sp(:,ind6) = data.Spectra.Sp(:,ind6) * 0.5;
     end
end


% Normalise

if options.renormalise==1 & options.norm_type=='unitarea'
    fprintf('Renormalising...\n');
    nani = find(isnan(data.Spectra.Sp));
    data.Spectra.Sp(nani) = 0; % Temporarily set NaN  elements to zero for normalisation
    integrals = repmat(sum(data.Spectra.Sp,2),1,size(data.Spectra.Sp,2));
    data.Spectra.Sp = normc * data.Spectra.Sp ./ integrals;
    data.Spectra.Sp(nani) = nan; % Reset NaN elements
end

%Empty data strcuture of strang stuff it's acquired on the way through;
data2.Spectra.ppm=data.Spectra.ppm;
data2.Spectra.Sp=data.Spectra.Sp;


fprintf('\n***reducespec v0.1 finished %s***\n',datestr(now));
