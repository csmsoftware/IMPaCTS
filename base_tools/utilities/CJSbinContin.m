function[OUT_groups,OUT_groupBounds]=CJSbinContin(IN,varargin)
% bins continuous data into specified bins
% 
% INPUT: required
% IN (mxn) = continuous data, m=measure for each sample, n=number of
%            different continuous data set variables to be binned
%
% INPUT: optional
% varargin (1x1) EITHER varargin = number of groups into which to divide data
%                (default = 10) 
% OR varargin (1xe) = vector of group edges (bins) which must contain
%                   monotonically increasing values and end with inf
%                   e.g. varargin = [-6,-4,-2,0,2,4,inf];
%
% OUTPUT
% OUT_groups (mxn) = group memberships for each sample and each continuous
%                    measure
% OUT_groupBounds (exn) = bin edges
%
% basic run >> [groups, groupBounds]=binContinCS(rand(100,1),10);
%
% CJS 181212 email caroline.sands01@imperial.ac.uk 

% set up input parameters and output variables
[m,n]=size(IN);
OUT_groups=zeros(m,n);

if(nargin>1)
    if(length(varargin{1})==1)
        ngroup=varargin{1};
        binedges=[];
        OUT_groupBounds=zeros(ngroup+1,n);
    else
        binedges=varargin{1};
        ngroup=length(binedges);
        OUT_groupBounds=zeros(ngroup,n);
    end
else
    ngroup=10;
    binedges=[];
    OUT_groupBounds=zeros(ngroup+1,n);
end
    
% define groups
for i=1:n
    if(isempty(binedges))
        t_min=min(IN(:,i));
        t_max=max(IN(:,i));
        t_inc=(t_max-t_min)/ngroup;
        binedges=[(t_min:t_inc:t_max-t_inc) inf];
        OUT_groupBounds(:,i)=binedges';
        binedges=[];
    else
        OUT_groupBounds(:,i)=binedges';
    end
    [~,OUT_groups(:,i)]=histc(IN(:,i),OUT_groupBounds(:,i)');
    OUT_groups(isnan(IN(:,i)),i)=NaN;
    % figure; scatter(IN(:,i),OUT_groups(:,i))  % check ok!
end