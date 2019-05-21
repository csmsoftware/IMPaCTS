function [spec,ppm1,ppm2,bytordp] = specread_rc(expname,expno,procno,disk,user)
% specread - read binary Bruker spectrum
% [spec[,ppm1,ppm2,byteordp]] = specread(expname,expno,procno[,disk,user]) 
%
% expname = (1X1 string) Experiment name
% expno = (1X1 string) Experiment number
% procno = (1X1 string) Processed data number
%
% spec = (mXn) matrix of the data read in. 1d: [ppm real imag], 2d: [realreal]
% ppm1, ppm2 = (m or n X1) vectors of ppm values on f1 and f2
% byteordp = BYTEORDP parameter: 0=little endian, 1=big endian
%
% written 091199 TMDE
% revised 220200 to read 2-d spectra
% revised 310101 to return with empty spectrum if data does not exist
%    (instead of crashing).
% revised 040401 to open binary files in big-endian format - corresponds to data stored on 
% RAID system (native UNIX format?)
% revised 240901 to construct absolute path name if given disk unit and user name
% Revised 260302 to read BYTORDP parameter. Changed to read parameter file before data.
% (c) 1999-2001 Dr. Timothy M D Ebbels, Imperial College, London

% revised 161107 Rachel Cavill - added blank initialisation of ppms and
% bytordp so that it doens't crash when returning without a spectra.

% construct input file names

if (~ischar(expno)) expno = num2str(expno); end
if (~ischar(procno)) procno = num2str(procno); end
if (nargin==5)
    if (~isempty(disk) & ~isempty(user))
        expname = fullfile(disk,'data',user,'nmr',expname);
    end
end
spec = [];
ppm1 = [];
ppm2 = [];
bytordp = [];

% Decide whether it's 1d or 2d

rfile = fullfile(expname,expno,'pdata',procno,'1r');
ifile = fullfile(expname,expno,'pdata',procno,'1i');
dim=[];
if (exist(rfile)==2) 
    dim = 1;
    if ~(exist(ifile)==2) warning(sprintf('Imaginary file %s does not exist',ifile)); end
else
    rrfile = fullfile(expname,expno,'pdata',procno,'2rr');
    if (exist(rrfile)==2) 
        dim = 2;
    else
        warning(sprintf('Cannot find %s or 2rr files',rfile)); 
        return; end
end
if (isempty(dim)) dim = 1; end

% read the acquisition and processing parameters,
% extracting the offset and spectral width

pfile = fullfile(expname,expno,'pdata',procno,'procs');
fid = fopen(pfile,'rt');
offset=[]; sw=[]; sf=[]; si=[];
while 1
    line = fgetl(fid);
    if (~isempty(findstr('##$OFFSET=',line)))
        ind = findstr(' ',line);
        offset = str2num(line(ind+1:length(line)));
    end
    if (~isempty(findstr('##$SW_p=',line)))
        ind = findstr(' ',line);
        sw = str2num(line(ind+1:length(line)));
    end
    if (~isempty(findstr('##$SF=',line)))
        ind = findstr(' ',line);
        sf = str2num(line(ind+1:length(line)));
    end
    if (~isempty(findstr('##$SI=',line)))
        ind = findstr(' ',line);
        si = str2num(line(ind+1:length(line)));
    end
    if (~isempty(findstr('##$BYTORDP=',line)))
        ind = findstr(' ',line);
        bytordp = str2num(line(ind+1:length(line)));
    end
    if (~isempty(offset) & ~isempty(sw) & ~isempty(sf) & ~isempty(si) & ~isempty(bytordp)) break; end
end
fclose(fid);

% Read 2d processing parameters

if (dim==2)
    p2file = fullfile(expname,expno,'pdata',procno,'proc2s');
    fid = fopen(p2file,'rt');
    offset2=[]; sw2=[]; si2=[];
    while 1
        line = fgetl(fid);
        if (~isempty(findstr('##$OFFSET=',line)))
            ind = findstr(' ',line);
            offset2 = str2num(line(ind+1:length(line)));
        end
        if (~isempty(findstr('##$SW_p=',line)))
            ind = findstr(' ',line);
            sw2 = str2num(line(ind+1:length(line)));
        end
        if (~isempty(findstr('##$SI=',line)))
            ind = findstr(' ',line);
            si2 = str2num(line(ind+1:length(line)));
        end
        if (~isempty(offset2) & ~isempty(sw2) & ~isempty(si2)) break; end
    end
    fclose(fid);
end

% Read the binary data - switch on whether it's 1d or 2d data - first 1d data
% Check byte order

if (bytordp==0) machine_format = 'l'; else machine_format = 'b'; end

if (dim==1)
    
    if ~(exist(pfile)==2) warning(sprintf('File %s does not exist',pfile)); return; end
    
    % read the binary data
    
    if (exist(rfile)==2)
        fid = fopen(rfile,'r',machine_format);
        %       spec(:,2) = fread(fid,inf,'int');
        spec(:,2) = fread(fid,'integer*4');
        fclose(fid);
    end
    
    if (exist(ifile)==2)
        fid = fopen(ifile,'r',machine_format);
        %       spec(:,3) = fread(fid,'int');
        spec(:,3) = fread(fid,inf,'integer*4');
        fclose(fid);
    end
    
    n = size(spec,1);
    
else
    
    % Second - If 2d data
    
    if ~(exist(pfile)==2) warning(sprintf('File %s does not exist',pfile)); return; end
    if ~(exist(p2file)==2) warning(sprintf('File %s does not exist',p2file)); return; end
    
    % read the binary data
    
    if (exist(rrfile)==2)
        fid = fopen(rrfile,'r',machine_format);
        spec = fread(fid,'integer*4');
        fclose(fid);
    end
    
    l = length(spec);
    if (si*si2 ~= l)
        warning(sprintf('Read dimensions %dX%d do not match spectrum size %d',si,si2,l)); 
        return
    end
end   

% Generate ppm values for 1d

if (dim==1)
    swp = sw/sf;
    dppm = swp/(n-1);
    spec(:,1) = [offset : -dppm : offset-swp]';
    ppm1 = [];
    ppm2 = [];
    return
end

% Fpr 2d, reshape into a 2d matrix and generate ppm values

if (dim==2)
    swp1 = sw/sf;
    swp2 = sw2/sf;
    dppm1 = swp1/(si-1);
    dppm2 = swp2/(si2-1);
    %ppm1 = [offset : -dppm1 : offset-swp1]';
    %ppm2 = [offset2 : -dppm2 : offset2-swp2]';
    %spec = reshape(spec,si,si2);
    %spec = spec';
    %Return empty structures for 2d for now!
    spec=[];
    ppm1=[];
    ppm2=[];
end

