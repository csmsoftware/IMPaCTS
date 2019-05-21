function [par,val] = brukpread(fname)
% brukpread - read  Bruker parameter file
% [par,val] = brukpread(fname) 
%
% par = (nXk char) parameter names
% val = (nX1 char) parameter values (as char array)
%
% written 290101 TMDE
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

% Initialise
par = '';
val = '';

% Open and read file

if ~(exist(fname)==2) warning(sprintf('File %s does not exist',fname)); return; end

fid = fopen(fname,'rt');
while 1
   line = fgetl(fid);
   if isempty(line) 
       % warning(sprintf('Empty line in brukpread in file %s',fname)); 
       continue; 
   end
   if (line==-1) break; end
   ind1 = findstr('$',line);
   if isempty(ind1) 
     ind1 = findstr('#',line); 
   end
   if isempty(ind1) continue; end
   ind1 = ind1(end);
   ind2 = findstr(' ',line);
   if isempty(ind2)
   else
     ind2 = ind2(1);
   end
   
   if (ind1+1<=ind2-2)
     p = line(ind1+1:ind2-2);
   else
     p = '';
   end
   if (ind2+1<=length(line))
     v = line(ind2+1:length(line));
   else
     v = '';
   end
   if (~isempty(p) & ~isempty(v))
     par = strvcat(par,p);
     val = strvcat(val,v);
   end   
end
fclose(fid);

