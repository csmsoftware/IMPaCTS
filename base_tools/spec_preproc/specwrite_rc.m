function [countr,counti] = specwrite_rc(spec,expname,expno,procno,disk,user,bytordp)
% specwrite - write 1d binary Bruker spectrum
% [countr,counti] = specwrite(spec,expname,expno,procno[,disk,user]) 
% Note - assumes that correct parameter files already exist!
%
% spec = (nX3) spectrum to write, format is: [ppm real imag]
% expname = (1X1 string) Experiment name
% expno = (1X1 string) Experiment number
% procno = (1X1 string) Processed data number
%
% written 070201 TMDE
% revised 240901 to use absolute path if required
% Revised 260302 TMDE to use BYTORDP parameter if required
% Revised 240505 TMDE to round data before writing integers

% Revised 220210 RC to take into account the NC_PROC parameter

% (c) 2001-2002 Dr. Timothy M D Ebbels, Imperial College, London

% Byte order

if (nargin<7) bytordp = 1; end
if (bytordp==0) machine_format = 'l'; else machine_format = 'b'; end


% construct output file names

if (~ischar(expno)) expno = num2str(expno); end
if (~ischar(procno)) procno = num2str(procno); end
if (nargin>=6 & ~isempty(disk) & ~isempty(user))
    expname = fullfile(disk,'data',user,'nmr',expname);
end
np = size(spec,1);

% Open files

rfile = fullfile(expname,expno,'pdata',procno,'1r');
ifile = fullfile(expname,expno,'pdata',procno,'1i');

pfile = fullfile(expname,expno,'pdata',procno,'procs');

if ~(exist(pfile)==2) warning(sprintf('File %s does not exist',pfile)); end

%Get the NC_Proc parameter from the 'procs' file.

fid = fopen(pfile,'rt');
nc_proc=[];
while 1
    line = fgetl(fid);
    if (~isempty(findstr('##$NC_proc=',line)))
           ind = findstr(' ',line);
           nc_proc = str2num(line(ind+1:length(line)));
    end
    if (~isempty(nc_proc)) break; end
end
fclose(fid);
   
   
% Write the binary data

fidr = fopen(rfile,'w',machine_format);
if (fidr==-1) 
    warning(sprintf('Cannot open file %s for writing - check permissions',rfile));
    countr = 0; counti=0;
    return
end
fidi = fopen(ifile,'w',machine_format);
if (fidi==-1) 
    warning(sprintf('Cannot open file %s for writing - check permissions',ifile)); 
    countr = 0; counti=0;
    return
end

spec(:,2:3) = spec(:,2:3)/realpow(2, nc_proc); %Rescale the values back using NC_PROC

spec(:,2:3) = round(spec(:,2:3)); % Round real & imaginary values to integers (prevents warning)
countr = fwrite(fidr,spec(:,2),'integer*4');
if (countr ~= np) 
  warning(sprintf('Only %d integers written to file %s',countr,rfile));
else
% $$$   fprintf('%d integers written to file %s\n',countr,rfile);
end
fclose(fidr);
   
counti = fwrite(fidi,spec(:,3),'integer*4');
if (counti ~= np) 
  warning(sprintf('Only %d integers written to file %s',counti,ifile));
else
% $$$   fprintf('%d integers written to file %s\n',counti,ifile);
end
fclose(fidi);

