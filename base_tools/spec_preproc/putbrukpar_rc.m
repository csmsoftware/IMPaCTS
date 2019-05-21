function [] = putbrukpar_rc(pfname,pars,vals,expname,expno,procno,disk,user)
% putbrukpar - Update Bruker parameters
% [] = putbrukpar(pfname,pars,vals,expname,expno,procno[,disk,user])
%
% pfname = (1Xt char) name of parameter file to search eg 'procs'
% pars = (nXk char) list of parameter names whos values to return
% vals = (nXk char) new values of parameters
% expname,expno,procno = (char,int,int) Experiment name, Experiment no. 
%    & Proccessed data no. (Supply [] as procno if not needed).
% disk,user = (char,char) disk and user name for absolute data path
%
% mpar = (nXk char) matching parameter names (in case of no match)
%
% Written 300101 TMDE  
% Revised 250901 to use disk and user name for absolute data paths if required.
% Revised 161202 to cope with spaces in file paths on DOS
% Revised 151107 to cope with spaces in file paths in UNIX (Mac)
% (c) 2001-2003 Dr. Timothy M D Ebbels, Imperial College, London

% Get file path and check existance

%if (nargin==8 & ~isempty(disk) & ~isempty(user))
%    expname = fullfile(disk,'data',user,'nmr',expname);
%end
fname = fullfile(expname,num2str(expno),'pdata',num2str(procno),pfname);
if ~(exist(fname)==2)
    warning(sprintf('Parameter file: %s does not exist',fname));
    return
end

fidr = fopen(fname,'rt');
fwname = strcat(fname,'.temp');
% $$$ if exist(fwname)==2 
% $$$   warning(sprintf('Temporary parameter file: %s already exists',fwname)); 
% $$$   return
% $$$ end
fidw = fopen(fwname,'wt');

% Loop over lines of file until find one of parameters we're looking for

pars = cellstr(pars);
while 1
    % Read line
    line = fgetl(fidr);
    if isempty(line) 
        % warning(sprintf('Empty line in putbrukpar in file %s',fname)); 
        continue; 
    end
    if (line==-1) break; end
    
    % Check if matches one of the parameters 
    ind1 = findstr('$',line);
    if ~isempty(ind1) ind1 = ind1(end); end
    ind2 = findstr(' ',line);
    if ~isempty(ind2) ind2 = ind2(1); end
%     if (isempty(ind1) | isempty(ind2)) continue; end
    if (~isempty(ind1) & ~isempty(ind2))
        match = find(strcmp(line(ind1+1:ind2-2),pars));
    else
        match = [];
    end
    
    % If match then construct new line
    if ~isempty(match)
        match = match(end); % Use last matching par val pair
        newline = [line(1:ind2),vals(match,:)];
    else
        newline = line;
    end
    
    % Write line to output file
    % $$$    fprintf('%s\n',newline);
    fprintf(fidw,'%s\n',newline);
    
end

fclose(fidr);
fclose(fidw);
%Fix spaces in unix directory/file names
fname=strrep(fname,' ','\ ');
fwname=strrep(fwname,' ','\ ');
unixcmd1 = ['rm ' fname];
unixcmd2 = ['mv -f ' fwname ' ' fname];
% pccmd1 = ['del ' fname];
% pccmd2 = ['rename ' fwname ' ' pfname];
pccmd1 = ['del "' fname '"'];
pccmd2 = ['rename "' fwname '" "' pfname '"'];
err=0;
if isunix
    %     [err,result]=unix(unixcmd2);
    [err]=unix(unixcmd2);
elseif ispc
    %     [err,result]=dos(pccmd1);
    %     [err,result]=dos(pccmd2);
    [err]=dos(pccmd1);
    [err]=dos(pccmd2);
else
    warning('Unknown operating system type');
end 
if err
    warning('mv of temp Bruker parameter file on to original failed:')
    %   fprintf('%s',result);
end
