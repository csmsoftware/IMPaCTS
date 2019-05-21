function spec_preproc_v5
%This function reads in the options in options.txt of the current
%directory.  It then performs the preprocessing specified in this file,
%with the spectra read in.
%Written Rachel Cavill 2007, utilising much code already written by others
%in the Biomolecular medicine department, Imperial College London.

% Added v4 - Median Fold Change normalisation (21st April 2008)
%          - Getting current directory from matlab, rather than having to type
%            in correctly in options file (21st April 2008)
%          - Logfile name specification, including option to not write
%            logfile by omitting name. (21st April 2008)
%          - Probabilitic Quotient Normalisation, with all rows

% Added v5 - Glucose Calibration (10th August)


%TO DO
% * Check options which work/don't work when reading in matlab files.
% * Doesn't trim data when reading in Matlab files - unless it does it in
% reducespec
% * Trumpets!


fid=fopen('options.txt');
lines=textscan(fid,'%s','Delimiter','\n');

[s,t]=size(lines{1});

for i=3:s
    opts(:,i-2)=textscan(char(lines{1}(i)),'%s','Delimiter',':\n')
end

fclose(fid);
%Fiddle the format to get things in one cell array, rather than an array of
%cell arrays!
for i=1:(s-2)
    opts_new{1,i}=char(opts{i}(1,1));
    if size(opts{i},1)==1
        opts_new{2,i}=char('');
    else
        opts_new{2,i}=char(opts{i}(2,1));
    end
end
%To add a new option, add it in here, then add the corresponding
%instructions in the right point lower down.
Ordered_steps={char('Input File Format'),  char('Matlab input file name'), char('Matlab output file name'),...
    char('Phase Correction'), char('Baseline Correction'),char('Referencing to TSP'),char('Referencing to glucose'),...
    char('Standardise ppm scales'),char('Normalise'), char('Normalisation type'),char('Reference Spectra type'), char('Reference Spectra rows'),...
    char('Bucket size'), char('Start range'),...
    char('End range'), char('.rgn files directory'), char('List of rgn files for exclusion'), char('List of rgn files for merger'),...
    char('Fix 6ppm bucket'), char('Renormalise'), char('Output Bruker Format'), char('Output Matlab Format'),...
    char('Log filename')};
used=zeros(size(opts_new,1),1);
order=zeros(size(opts_new,1),1);
steps_to_do=zeros(size(Ordered_steps,2),1);
%Work out which steps to do, and check for missing/extra instructions in
%the file.
for i=1:size(Ordered_steps,2)
    row=(strmatch(Ordered_steps{i}, char(opts_new))+1)/2;
    if isempty(row)
        warning('No instructions for %s - Will skip this step',Ordered_steps{i});
        steps_to_do(i)=0;
    else
        if strcmpi(char(opts_new(2,row)),char('y'));
            steps_to_do(i)=1;
        else
            steps_to_do(i)=0;
        end
        order(i)=row;
    end
    used(row,1)=1;
end
if sum(used)~=size(used,1)
    warning('Some options were not used');
end

%Set defaults of everything off
options.matlab_filename='';
options.matlab_output_filename='';
options.dophase=0;
options.dobase=0;
options.doref=0;
options.glucose=0;
options.standardise=0;
options.normalise=0;
options.norm_type='unitarea';
options.refspec_type='median';
options.refspec_rows='all';
options.bucket=0.04;
options.start_ppm=9.98;
options.end_ppm=0.22;
options.rgn_dir='';
options.exclude_files='';
options.merge_files='';
options.fix6ppm=0;
options.renormalise=0;
options.dowrite=0;
options.matlab_output=0;


%Turn the steps to do into a single options structure.
for i=1:size(Ordered_steps,2)
   if strmatch(Ordered_steps{i},'Matlab input file name')
       options.matlab_filename=char(opts_new(2,order(i)));
   elseif strmatch(Ordered_steps{i}, 'Matlab output file name')
       options.matlab_output_filename=char(opts_new(2,i));
   elseif strmatch(Ordered_steps{i},'Phase Correction')
       options.dophase=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Baseline Correction')
       options.dobase=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Referencing to TSP')
       options.doref=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Referencing to glucose')
       options.glucose=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Standardise ppm scales')
       options.standardise=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Normalise')
       options.normalise=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Normalisation type')
       options.norm_type=char(opts_new(2,order(i)));
   elseif strmatch(Ordered_steps{i},'Reference Spectra type')
       options.refspec_type=char(opts_new(2,order(i)));
   elseif strmatch(Ordered_steps{i},'Reference Spectra rows')
       options.refspec_rows=char(opts_new(2,order(i)));    
   elseif strmatch(Ordered_steps{i}, 'Bucket size')
       options.bucket=str2double(char(opts_new(2,order(i))));
   elseif strmatch(Ordered_steps{i}, 'Start range')
       options.start_ppm=str2double(char(opts_new(2,order(i))));
   elseif strmatch(Ordered_steps{i}, 'End range')
       options.end_ppm=str2double(char(opts_new(2,order(i))));
   elseif strmatch(Ordered_steps{i},'.rgn files directory')
       options.rgn_dir=char(opts_new(2,order(i)));
   elseif strmatch(Ordered_steps{i},'List of rgn files for exclusion')
       options.exclude_files=char(opts_new(2,order(i)));
   elseif strmatch(Ordered_steps{i},'List of rgn files for merger')
       options.merge_files=char(opts_new(2,order(i)));
   elseif strmatch(Ordered_steps{i},'Fix 6ppm bucket')
       options.fix6ppm=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Renormalise')
       options.renormalise=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Output Bruker Format')
       options.dowrite=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Output Matlab Format')
       options.matlab_output=steps_to_do(i);
   elseif strmatch(Ordered_steps{i},'Logfile name')
       options.logfile=steps_to_do(i);
   end   
end

options.bruker_directory=cd;
options
options.matlab_filename
%Other options which nmrproc has (and needs)
if isfield(options,'logfile')
    options.logfile = strcat(options.bruker_directory,'/',options.logfile); %string
else
    options.logfile='';
end
options.datasource='dir'; %file or dir
options.expno = 10; %string

%Get lists of files into an array type thingy!
r=options.exclude_files;
i=1;
list_files=[];
while ~isempty(r)
    [t,r]=strtok(r,', ');
    list_files{i}=t;
    i=i+1;
end
options.exclude_files=list_files;

r=options.merge_files;
i=1;
list_files=[];
while ~isempty(r)
    [t,r]=strtok(r,', ');
    list_files{i}=t;
    i=i+1;
end
options.merge_files=list_files;

if options.doref==1 & options.glucose==1
    warning('Referencing should only be done to TSP *OR* glucose, not both. - referencing to TSP only');
    options.glucose=0;
end
%Input file from correct format
if strcmpi(char(opts_new(2,1)),char('Bruker'))
    %Check whether the directory or file names have spaces in them and add
    %a backslash so that the output procedures in nmrpoc will work.
    options.bruker_directory=strrep(options.bruker_directory,' ','\ ');
   
    
    %Use nmrproc to do processing
   % try

   specs=do_nmrproc_rc(options);
   % catch
        %error('** Error occured whilst running NMRproc - see above messages; try moving the offending spectrum into a different directory and rerunning **');
   % end
        
elseif strcmpi(char(opts_new(2,1)),char('Matlab'))
    if options.dophase==1 | options.dobase==1 | options.doref==1 | options.dowrite
        warning('Phasing, Baselining and Referencing and outputing Bruker files can only be done to Bruker input files at present');
    end
    options.matlab_filename
    load(options.matlab_filename);
else error('Unrecognised file format %s',char(opts_new(2,1)))    
end

if options.standardise==1
    %Standardise ppm scales (Interpolation)
    if strmatch(opts_new(2,1),char('Matlab'))
        warning('Matlab files are already on a common ppm scale, so no need to standardise');
    else
        %These settings for x are only temporary - check out what
        %metaspectra does and change accordingly!
        [s,num_spec]=size(specs);
        %plot(specs{1}(:,1),specs{1}(:,2))
        x=linspace(options.start_ppm,options.end_ppm,32697);
        
        for loop1=1:num_spec
            %sum(isnan(specs{loop1}))
            data.Spectra.Sp(loop1,:)=interp1(specs{loop1}(:,1)',specs{loop1}(:,2)',x,'spline');
        end
        %figure
        %plot(x,data.Spectra.Sp(1,:))
        data.Spectra.ppm=x;
   
    end
end

%Glucose callibration
%[ppm, spectra] = JTPcalibrateNMR('glucose', Oldppm, OldSpectra);
if options.glucose==1
    fprintf('Glucose calibration');
    %Flip the ppm and spectra before using Jake's code, then flip them back
    %afterwards.  
    [data.Spectra.ppm,data.Spectra.Sp]=JTPcalibrateNMR('glucose',fliplr(data.Spectra.ppm), fliplr(data.Spectra.Sp));
    data.Spectra.ppm=fliplr(data.Spectra.ppm);
    data.Spectra.Sp=fliplr(data.Spectra.Sp);
end

if strmatch(opts_new(2,1),char('Bruker')) & (options.normalise==1 ...
        |  options.renormalise==1 | options.matlab_output==1) & options.standardise==0
        warning('Later operations (including outputting in matlab format) cannot be performed on bruker files unless standardisation of ppm scales has occured');   
else
    if options.normalise==1
        %Normalise
        if strmatch(options.norm_type,char('unitarea'))
            fprintf('Normalising to unit area...\n');
            data.Spectra.Sp=normalise_to_100unit_area(data.Spectra.Sp);
        elseif strmatch(options.norm_type,char('pqn'))
            fprintf('Probabilistic Quotient Normalisation....\n');
            if strmatch(options.refspec_rows,'all')
                first=1;
                last=num_spec;
            else
                rows=textscan(options.refspec_rows,'%s','Delimiter','-');
                rows=rows{1,1};
                first=str2num(rows{1,1});
                last=str2num(rows{2,1});
            end
            if strmatch(options.refspec_type,'median')
                    ref_spec=median(data.Spectra.Sp(first:last,:));
            elseif strmatch(options.refspec_type,'mean')
                    ref_spec=mean(data.Spectra.Sp(first:last,:));
            else
                    fprintf('Unknown reference spectra type - check options file\n');
            end
            data.Spectra.Sp=prob_quot_norm(ref_spec,data.Spectra.Sp);
        elseif strmatch(options.norm_type,char('tsp'))
            fprintf('Normalising to TSP... \n');
            data.Spectra.Sp=normalise(data.Spectra.Sp, signal(-0.01,0.01,data.Spectra.Sp,data.Spectra.ppm)');
        elseif strmatch(options.norm_type,char('mfc'))
            fprintf('Normalising to Median Fold Change... \n');
            data.Spectra.Sp=normalise(data.Spectra.Sp, 0);
        end
    end
    data=reducespec_rc_no_popups(data,options);
    
    if (~strmatch(options.norm_type,char('unitarea'))) & (options.renormalise==1)
        fprintf('Doing renormalisation since reducespec does not do this type of normalisation (not implemented yet)\n');
    end
    if options.matlab_output==1
        %Output matlab
        save(options.matlab_output_filename,'data');        
    end
end



