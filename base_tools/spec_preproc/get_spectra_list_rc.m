function [dname,expno,disk,user] = get_spectra_list(dpath)
% get_spectra_list - get a list of spectra from a directory
% [dname,expno,disk,user] = get_spectra_list(dpath)
%
% dpath = (1Xn char) path to search for spectra, eg /central/data/user/nmr/expname/
% 
% Written 210102 TMDE  
% Revised 080202 TMDE to use list box to select the expnos
% Revised 08-090402 TMDE to not require top level Bruker data structure (/disk/data/user/nmr)
%       as part of NMRproc version 0.3
% Revised 221102 TMDE to fix problem with str2num when compiled - changed
% to str2double and isnan at lines 36-40
% (c) Copyright 2001-2002 Dr. T.M.D. Ebbels, Imperial College, London
% Revised 240907 RC two lines commented out so to not call the interactive
%       file choosing bit (for use in spec_preproc).


% Defaults

default_expno = 10;
comet_study_prefix = {'D' 'F' 'L' 'N' 'R' 'S'};

% Read the directory
%[disk,user,expname] = brukdpath(dpath);
%if (~isempty(disk) & ~isempty(user)) % Standard Bruker data path
%    d = fullfile(disk,'data',user,'nmr',expname);
%else % If not, assume path given is a Bruker expname
    d = dpath;
    disk = ''; user = '';
    expname = dpath;
%end
dstr = dir(d); 
[fnames{1:length(dstr)}] = deal(dstr.name);

expno=[];
if ~isempty(expname)
    % Find out if any of the filenames from the directory are numeric - could be expnos   
    j=1;
    for i=1:length(fnames)
%         en = str2num(char(fnames{i})); % old code
        en = str2double(fnames{i}); % Fix for compiled code
%         if ~isempty(en) % Old code
        if ~isnan(en)  % Fix for compiled code
            expno(j,1) = en;
            j=j+1;
        end
    end
end

% If expnos then we are looking at a single dataset from which expnos are to be selected
% Work out which directories correspond to expnos (if any) and make a list of them
if ~isempty(expno)
    % Sort the expnos and let user select which ones to use
    [expno,si] = sort(expno);
    cellstrexpno = cellstr(num2str(expno));
    %RACHEL _ Changed from listdlgnorml to listdlg - since listdlgnormal
    %doesn't seem to exist in my matlab!
    
    %Taking out these two lines so that instead of selecting particular files from the directory with a GUI box,
    %it instead just selects all files automatically. 
    %[selection,ok] = listdlg('ListString',cellstrexpno,'Name','Select spectra','PromptString','Select spectra to process')
    %expno = expno(selection);
    ne = length(expno);
    dname = cellstr(repmat(expname,ne,1));
    
    % If no expnos then try to get list of expnames
else
    fprintf('No experiment numbers found in directory %s\n',d)
    fprintf('Now looking for data sets - will process using default expno\n');
    %RACHEL _ Changed from listdlgnorml to listdlg - since listdlgnormal
    %doesn't seem to exist in my matlab!
    [selection,ok] = listdlg('ListString',fnames,'Name','Select data sets','PromptString','Select data sets to process');
    dname = fnames(selection)';
    ne = length(dname);
    
    % If the selection looks like COMET sample names then sort the dnames by time point then ratnum
    ai = findstr('r',dname{1});
    if isempty(ai) ai = findstr('m',dname{1}); end 
    ti = findstr('h',dname{1});
    if (ismember(dname{1}(1),comet_study_prefix) & ~isempty(ai) & (ai==4|ai==5) & ~isempty(ti) & (ti==7|ti==8))
        snames = char(dname);
        animno = str2num(snames(:,ai+1:ai+2));
        timept = str2num(snames(:,ti+1:ti+4));
        [as,ia] = sort(animno);  % Sort on animal nos first
        [ts,it] = sort(timept(ia));  % Then on time points - 
        dname = dname(ia(it));
    end
end

% set constant outputs

if ~isempty(disk) disk = cellstr(repmat(disk,ne,1));
else disk = cell(ne,1); [disk{1:ne}] = deal(''); end
if ~isempty(user) user = cellstr(repmat(user,ne,1));
else user = cell(ne,1); [user{1:ne}] = deal(''); end

fprintf('%d spectra selected from %s\n',ne,d);


