function [specp,popt,Fopt] = autophase(spec,p0,nrego,nregi,pbreg,step)
% autophase - autophase a 1d NMR spectrum
% [specp,popt,Fopt] = autophase(spec,p0[,nrego,nregi[,pbreg,step]])
%
% spec = (nX3) spectrum in format [ppm re im]
% p0 = (2X1) Initial guess for search algorithms ([] if grid)
% ng = (1X1) if >0 then does grid search with ng grid points
% nrego = (mX2) outer regions for detection of negative spectrum
% nregi = (mX2) inner regions for detection of negative spectrum
%
% specp = (nX3) autophased spectrum
% popt = (2X1) [P0;P1] phase parameters at optimum
% Fopt = (1X1) value of optimisation function at found minimum
%
% Written 150101 TMDE  
% Revised 070201 getting rid of plotting and grid search bits
% Revised 071101 removing functions unsupported in stand alone mode
%               Also using function handle for objphase in fminsearch call
% Revised 161202 TMDE to warn if can't find any data points in inversion
% detection regions
% (c) 2001 Dr. Timothy M D Ebbels, Imperial College, London

% Defaults

if (nargin<2 | isempty(p0)) p0 = [0 0]; end
if (nargin<3) nrego = [13.5 10; -0.5 -4]; end
if (nargin<4) nregi = [10 6; 4.5 -0.1]; end
if (nargin<5) pbreg = [13.5 10; -0.5 -4]; end
if (nargin<6) step = 4; end

%p0 = [p0(1) p0(2); p0(1)+180 p0(2)]; % Two restarts p0 +/- 180deg

ppm = spec(:,1);
re = spec(:,2);
im = spec(:,3);

% fminsearch optimisation
  
fmsopt = optimset('Display','off','TolX',1,'TolFun',1);
% more off
for i=1:size(p0,1) % Loop over restarts
  for j=1:2, % Two chances in case first returns inverted spectrum
    
%     fprintf('autophase(%d,%d): initial values are: PHC0=%0.1f, PHC1=%.1f\n',i,j,p0(i,:));
    [p(i,:),Fmin(i),eflag,output] = fminsearch(@objphase,p0(i,:),fmsopt,ppm,re,im,pbreg,step);
%     fprintf('fminsearch optimum phases: (%.1f,%.1f)\n',p(i,:));
    
% Detect inverted spectrum
    rep = phase(re,im,p(i,:),0);
    %nrego = [13.5 10;
	 %  -0.5 -4];
    kpind1 = find(ppm<nrego(1,1) & ppm>nrego(1,2));
    kpind2 = find(ppm<nrego(2,1) & ppm>nrego(2,2));
    if (isempty(kpind1) | isempty(kpind2))
        warning('autophase: no regions found for inversion detection - check baseline regions');
        specp = [];
        return
    end
    
    ym1 = mean(rep(kpind1(1:step:end)));
    ym2 = mean(rep(kpind2(1:step:end)));
    %nregi = [10 6;
    %      4.5 -0.1];
    midind = find((ppm<nregi(1,1) & ppm>nregi(1,2)) | (ppm<nregi(2,1) & ppm>nregi(2,2)));
    if isempty(midind)
        warning('autophase: no regions found for inversion detection - check baseline regions');
        specp = [];
        return
    end
    
    di = mean(rep(midind)) - 0.5*(ym1+ym2);
% $$$     fprintf('di = %.3e ',di);
    if (di>0) % Not inverted - accept this one
      break; 
    else      % Inverted - go back and try with (p0opt+180,p1opt)
      p0(i,1) = mod(p(i,1)+180,360);
      p0(i,2) = p(i,2);
      if (j==2) warning('Spectrum still inverted'); end
    end
  end
end

% Get best values over restarts
[Fbest,ibest] = min(Fmin);
pbest = p(ibest,:);
% more on

% fprintf('Best relative phase values: PHC0=%.1f, PHC1=%.1f\n',pbest);

[specp(:,2),specp(:,3)] = phase(re,im,pbest,0);
specp(:,1) = ppm;
popt = pbest;
Fopt = Fbest;

% End of main


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
