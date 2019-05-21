function specs = do_nmrproc_rc(options)
% do_nmrproc - Process multiple Bruker 1d spectra 
% [options] = do_nmrproc([options])
%
% options = (1X1 struc) OPTIONAL Options structure:
%    .options.namefile = (1Xk char) File containing spectra to be processed
%       Format is: [dataset_name exp_no proc_no]
%    .logfile = (1Xk char) name of log file (default matproc.log)
%    .p0 = (1X2 int) Initial guess of phase params
%    .datasource = (1Xk char) where to get list of spectra to process:
%           datasource = 'dir' (default) process all spectra in one directory
%           datasource = 'file' process spectra named in a given file
%
% options = (1X1 struc) Output options structure
%
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

% Written 240101 TMDE version 0.1  
% Revised ??0501 HK to include automatic baseline & referencing 
% Revised 250601 TMDE to use uigetfile for names file
% Revised 190901 TMDE to use uigetfile for log file
% Revised 270901 TMDE to process all spectra found in one directory (default)
% Revised 241001 TMDE Copy of old multiproc_v04 but uses GUI for parameters
% Revised 071101 TMDE removing commands not supported in stand alone mode
%                       eg. exist('variable','var'), more, unix etc.
% Revised 04-080402 TMDE to update to nmrproc v0.3:
%       - Use BYTORDP parameter to adjust to little or big-endian data
%       - Does not require top level of Bruker data structure (/disk/data/user/nmr)
%       - Writes parameters used to the log file
%       - Allows user to specify a different default procno from 1
%       - Allows user to select spectra to process from directory listing of expnos
% Revised 161202 TMDE to set inversion detection regions to phase baseline
% regions by default. Also gives warnings if doesn't find any spectrum in
% the specified regions (ie regions specified wrongly).
%
% Revised 240907 RC - calls the changed version of get_spectra_list, so the interactive options are removed, 
%         and passes out the spectra to the calling program, so more stuff can be done.
%         100708 RC - Moved the reading of the offset from the bruker file
%         out of the if statement for the referencing, so that the ppm
%         scale can still be ascertained to some degree of accuracy even if
%         the referencing isn't being used. 
% Revised 220210 RC - calls a revised version of specwrite which takes into
%         account the nc_proc parameter.

% Defaults

warn_state = warning('on'); % Warnings on but no backtrace
if (nargin==0) options = []; end
[options,lfid] = setdefault_options(options);

% Get list of spectra to process

[ns,dname,expno,procno,disk,user] = getnames(options,lfid);

% Loop over spectra to be processed
offset=0;
p0=options.p0;
p = [0 0];
specs={};
count_spec_readin=1;
for i=1:ns,
    %     fprintf('paused...\n'); 
    pause(0.01)  % Pause to allow interrupts
    logprint(lfid,'\nProcessing %s %d %d\n',dname{i},expno(i),procno(i));
    
    % Read spectrum & check for strangeness
    
    [spec,dmy,dmy,bytordp] = specread_rc(dname{i},expno(i),procno(i),disk{i},user{i});
    if isempty(spec)
        logprint(lfid,'Couldn''t read spectrum file - skipping (Could be a 2d - this program does not handle 2d spectra - yet!)\n');
        continue
    end
    if length(find(spec(:,2)==spec(:,3)))>0.5*length(spec)
        warning('Identical real and imaginary parts detected - skip this spectrum');
        continue
    end   
    %if (length(find(spec==0))>0.1*length(spec))
    %    warning('Large number of zero values detected - skip this spectrum')
    %    continue
    %end
    
    % Apply processing as needed
    
    %
    % NC PROC CORRECTION for intensity scaling factor - added by Daniel
    % Homola dh711@imperial.ac.uk, on 1st of April 2014
    %
    % This feature is missing from the lates .m files, but it was 
    % incorporated in the lates .p file when they discovered it in the TOPSPIN
    % documentation: http://www.as.miami.edu/chemistry/pdf/NMRmanuals/proc_commands_parameters.pdf    
    [ncproc, mpar] = getbrukpar('procs','NC_proc',dname{i},expno(i),procno(i),disk{i},user{i});
    ncproc = str2num(ncproc);
  
    spec(:,2) = spec(:,2).*2^ncproc;
    spec(:,3) = spec(:,3).*2^ncproc;
    
    %
    % Phase correction
    %
    
    if (options.dophase==1)
        fprintf('Autophasing...');
        fprintf(lfid,'Autophasing...\n');
        [spec,popt] = autophase(spec,p0,options.nrego,options.nregi,options.pbreg,options.step);
        
        if isempty(spec) continue; end
        fprintf(lfid,'Optimum parameters found: PHC0=%.1f, PHC1=%.1f\n',popt);
        popt(1) = mod(popt(1),360);
        %         fprintf(lfid,'Taking mod(360), params are: PHC0=%.1f, PHC1=%.1f\n',popt);
        p(i,:) = popt; % save relative phase pars
    end
    
    %
    % Baseline correction
    %
    
    if (options.dobase==1)
        fprintf('Baseline correction...');
        %fprintf(lfid,'Baseline correction...\n');
        reb = baseline(spec(:,1),spec(:,2),options.breg);
        if isempty(reb) continue; end
        spec(:,2) = reb;
    end
    
     
    
    %
    % Referencing 
    %
    %Get the offset from Bruker even if referencing isn't going to be done.
    [offset, mpar] = getbrukpar('procs','OFFSET',dname{i},expno(i),procno(i),disk{i},user{i});
    offset = str2num(offset);
    if (options.doref==1)
        fprintf('Referencing...');
        %fprintf(lfid,'Referencing...\n');
        %fprintf(lfid,'Old offset: (%.3f)\n',offset);
        off1 = reference(spec(:,1),spec(:,2),options.rreg,options.refppm);
        %fprintf('%.3f',off1);
        if isempty(off1) continue; end
        offset = offset - off1;
        %fprintf(lfid,'New offset: (%.3f)\n',offset);
    end
    
    %
    % Write spectrum (Bruker format)
    %
    
    if (options.dowrite==1) 
        fprintf('Writing spectrum...');
        fprintf(lfid,'Writing spectrum...\n');
        [cr,ci] = specwrite_rc(spec,dname{i},expno(i),procno(i),disk{i},user{i},bytordp);
        if (cr==size(spec,1) & ci==size(spec,1))
            fname = fullfile(dname{i},num2str(expno(i)),'pdata',num2str(procno(i)),'1r');
            fprintf(lfid,'Processed spectrum saved to %s & 1r at %s\n',fname,datestr(now));
            % If successful spectrum write then write parameters
            if (options.dophase==1)
                putbrukpar_rc('procs',['PHC0';'PHC1'],num2str(popt),dname{i},expno(i),procno(i),disk{i},user{i});
                putbrukpar_rc('proc',['PHC0';'PHC1'],num2str(popt),dname{i},expno(i),procno(i),disk{i},user{i});
            end
            if (options.doref==1)
                putbrukpar_rc('procs','OFFSET',num2str(offset),dname{i},expno(i),procno(i),disk{i},user{i});
                putbrukpar_rc('proc','OFFSET',num2str(offset),dname{i},expno(i),procno(i),disk{i},user{i});
            end
        else
            fprintf(lfid,'Error: specwrite failed - %d & %d integers written\n',cr,ci);
            logprint(lfid,'No parameter files written either\n');
        end 
    end
    %Correct the spectra for the offset found, by recalculating the ppm
    %column
    if ~isempty(spec)
        current_max_ppm=max(spec(:,1));
        current_min_ppm=min(spec(:,1));
        number_points=size(spec,1);
        new_max_ppm=offset;
        new_min_ppm=current_min_ppm-(current_max_ppm-offset);
        spec(:,1)=linspace(new_max_ppm,new_min_ppm,number_points);
        specs(count_spec_readin)={spec};
        count_spec_readin=count_spec_readin+1;
    end
        
    fprintf('Done\n');
end

options.p0 = p0;
logprint(lfid,'\nNMRproc finished %s\n\n',datestr(now));
if not(strmatch(lfid,''))
    fclose(lfid);
end
warning(warn_state)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%
% FUNCTIONS
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ns,dname,expno,procno,disk,user] = getnames(options,lfid);
% Get list of spectra to process

% Get list of spectra from file...
if strcmp(options.datasource,'file')
    % Read names file
    [dname,expno,procno,disk,user] = textread_nowhich(options.namefile,'%s %d %d %s %s');
    ns = length(dname);
    logprint(lfid,'Read %d dataset names from %s\n',ns,options.namefile);
    % Convert 'central' to \\bc-jkn-20\nmrdata
    cind = find(strcmp(disk,'central'));
    disk(cind) = {'\\bc-jkn-20\nmrdata'};
    % Add / to disk unit if not there already
    sind = strmatch(filesep,disk);
    nsind = setdiff([1:ns],sind);
    for i=nsind,
        disk{i} = strcat(filesep,disk{i});
    end
else
    % ...or get list from directory - get directory name and read it
    dpath = cd;
    [dname,expno,disk,user] = get_spectra_list_rc(dpath);
   
    % Assign Bruker data structure parameters, sort expnos & print to log file
    ns = size(dname,1);
    procno = repmat(options.procno,ns,1);
    if isempty(expno) expno = repmat(options.expno,ns,1); end

    logprint(lfid,'\nWill process %d spectra from %s\n',ns,dpath);
    fprintf(lfid,'List of spectra to process:\n');
    for i=1:ns,
        fprintf(lfid,'%s %d %d %s %s\n',dname{i},expno(i),procno(i),disk{i},user{i});
        %         fprintf('%s %d %d %s %s\n',dname{i},expno(i),procno(i),disk{i},user{i});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [options,lfid] = setdefault_options(options);
% Set the default options

if ~isfield(options,'logfile')
    [lfile,lpath] = uiputfile('\\bc-jkn-20\nmrdata\data\comet\nmr\*.log','Select log file');
    if (lfile==0) return; end
    options.logfile = fullfile(lpath,lfile); 
end
if (~isfield(options,'datasource')) 
    options.datasource = 'dir';
end
if (strcmp(options.datasource,'file') & ~isfield(options,'namefile'))
    [nfile,npath] = uigetfile('\\bc-jkn-20\nmrdata\data\comet\nmr\*.names','Select names file');
    if (nfile==0) return; end
    options.namefile = fullfile(npath,nfile);
end
if ~isfield(options,'p0') options.p0 = [0 0]; end
%Defaults are commented, changed for INTERMAP
%if ~isfield(options,'pbreg') options.pbreg = [13.5 10; -0.5 -4]; end
if ~isfield(options,'pbreg') options.pbreg = [13.5 9.5; -0.19 -4]; end
% if ~isfield(options,'nrego') options.nrego = [13.5 10; -0.5 -4]; end
if ~isfield(options,'nrego') options.nrego = options.pbreg; end
if ~isfield(options,'nregi') options.nregi = [options.nrego(1,2) 6; 4.5 options.nrego(2,2)]; end
if ~isfield(options,'step') options.step = 4; end
if ~isfield(options,'dophase') options.dophase = 1; end
if ~isfield(options,'dobase') options.dobase = 1; end
if ~isfield(options,'doref') options.doref = 1; end
% commented default, changed for INTERMAP
%if ~isfield(options,'breg') options.breg = [13.5 10; -0.5 -4]; end
if ~isfield(options,'breg') options.breg = [13.5 9.5; -0.19 -4]; end
if ~isfield(options,'rreg') options.rreg = [0.2 -0.2]; end
if ~isfield(options,'dowrite') options.dowrite = 1; end
if ~isfield(options,'refppm') options.refppm = 0; end
if ~isfield(options,'procno') options.procno = 1; end
if ~isfield(options,'expno') options.procno = 10; end

% Open log file and write options used
if strmatch(options.logfile,'')
    lfid='';
else
    lfid = fopen(options.logfile,'at');
    if (lfid==-1) error(sprintf('Cannot open file %s for writing - check permissions',options.logfile)); end
end
logprint(lfid,'\n*********************************************\n');
logprint(lfid,'NMRproc version 0.3 starting %s\n\n',datestr(now));
if (options.dophase) logprint(lfid,'WILL do autophasing,\n'); 
else logprint(lfid,'WILL NOT do autophasing\n'); end
if (options.dobase) logprint(lfid,'WILL do baseline correction,\n'); 
else logprint(lfid,'WILL NOT do baseline correction\n'); end
if (options.doref) logprint(lfid,'WILL do referencing\n'); 
else logprint(lfid,'WILL NOT do referencing\n'); end
if (options.dowrite) logprint(lfid,'WILL write the spectra\n');
else logprint(lfid,'WILL NOT write the spectra\n'); end

% Output other options to logfile

fprintf(lfid,'\nlogfile = %s\n',options.logfile);
fprintf(lfid,'datasource = %s',options.datasource);
if isfield(options,'namefile') fprintf(lfid,'namefile = %s\n',options.namefile); end
fprintf(lfid,'p0 = %.2f %.2f\n',options.p0');
fprintf(lfid,'nrego = %.2f %.2f\n',options.nrego');
fprintf(lfid,'nregi = %.2f %.2f\n',options.nregi');
fprintf(lfid,'pbreg = %.2f %.2f\n',options.pbreg'); 
fprintf(lfid,'step = %d\n',options.step); 
fprintf(lfid,'breg = %.2f %.2f\n',options.breg'); 
fprintf(lfid,'rreg = %.2f %.2f\n',options.rreg'); 
fprintf(lfid,'refppm = %.2f\n',options.refppm); 
fprintf(lfid,'procno = %d\n',options.procno); 
fprintf(lfid,'expno = %d\n',options.expno); 
