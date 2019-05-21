function [mch] = mstrmatch(str,strs,flag)
% mstrmatch - match multiple strings
% [I] = mstrmatch(str,strs,flag)
%
% str, strs, flag - same as for strmatch, except that str may be more
% than one string.
% 
% Written 140600 TMDE  
% Revised 260600 to use cell arrays instead of char arrays 
%    - avoid blank padding
% Revised 300101 to go back to char arrays and deleted use of unique since
%    sorts output
% Revised 180402 TMDE to convert cellstrs to char arrays on input.
% (c) 2000 Dr. Timothy M D Ebbels, Imperial College, London

if iscell(str) str = char(str); end
if iscell(strs) strs = char(strs); end

mch = [];
if (nargin==3)
  for i=1:size(str,1),
% $$$   mch = [mch; strmatch(str(i),strs,flag)];
    mch = [mch; strmatch(str(i,:),strs,flag)];
  end  
else
  for i=1:size(str,1),
% $$$   mch = [mch; strmatch(str(i),strs)];
  mch = [mch; strmatch(str(i,:),strs)];
  end  
end

%mch = unique(mch);
