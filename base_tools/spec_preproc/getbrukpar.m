function [vals,mpar] = getbrukpar(pfname,pars,expname,expno,procno,disk,user)
% getbrukpar - Get Bruker parameters
% [vals,mpar] = getbrukpar(pfname,pars,expname,expno,procno[,disk,user])
%
% pfname = (1Xt char) name of parameter file to search
% pars = (nXk char) list of parameter names whos values to return
% expname,expno,procno = (char,int,int) Experiment name, Experiment no. 
%    & Processed data no. (Supply [] as procno if not needed).
% disk,user = (char,char) Disk and user for absolute data path
%
% vals = (nXk char) values of require parameters
% mpar = (nXk char) matching parameter names (in case of no match)
%
% Written 300101 TMDE  
% Revised 250901 to use disk and user name for absolute data paths if required.
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

% Get file path and check existance

if (nargin==7 & ~isempty(disk) & ~isempty(user))
    expname = fullfile(disk,'data',user,'nmr',expname);
end
fname = fullfile(expname,num2str(expno),'pdata',num2str(procno),pfname);
if ~(exist(fname)==2) 
  warning(sprintf('Parameter file: %s does not exist',fname)); 
  return
end

% Read pars & find required matches

[par,val] = brukpread(fname);
% $$$ [par,val]
ind = mstrmatch(pars,par,'exact');
vals = val(ind,:);
mpar = par(ind,:);