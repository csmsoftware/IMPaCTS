function [peakinds peaks] = findPeaksKV(X,ppm,method,val) % added stdnoise 090610
% function XPeaks = findPeaksKV(X,ppm,thresh)
% A fast method for identification of peaks in NMR spectra of complex
% biological mixtures.
% Algorithm: 1. Calculate smoothed first derivative of a spectrocsopic signal
%               by means of the Savitzky-Golay smoothing filter
%            2. Identify peak maximima when the first derivative crosses
%               zero
%            3. Calculate local base-line values for each peak and estimate
%               peak width by the difference between the base-line
%               positions
%            4. Threshold peaks which peak-width parameter values is smaller than the
%               pre-defined threshol, by default being very liberal - 0.005ppm
%            5. Calculate the peak amplitude values as the peak maximum
%               value corrected for the local baseline!!!
% Author: Kirill, Veselkov. Imperial College London 2010. 
%
% modified 170610 CJS - different options for validation thresholds AND
% output peak apex indices (peakinds) and vector with all indices 
% corresponding to peak (start:stop) given corresponding apex index

[nSmpls,nVrbls] = size(X);

if(nargin<4); val=[]; end

setupPeakPrmtrs(ppm);
maxPeakWindow   = floor(peakParam.iMaxPeakWindow/2);
if maxPeakWindow < 5
    error('Error: the window for idenifying the peak width and the peak baseline is too narrow');
end
%% Calculate the smoothed derivative of a spectroscopic signal
XALLDerivs         = sgolayDerX(X,peakParam.iOrder,peakParam.iFrameLen,2);  % caclulate the first smoothed spectral derivative using the Savitzky-Golay filter
maxPeakPstns    = (XALLDerivs>=0&XALLDerivs(:,[2:nVrbls,1])<0);                % identify peak max positions when the first derivative crosses zero
XPeaks          = zeros(nSmpls,nVrbls);

truepeaksall    = zeros(size(XPeaks)); % CAZ 060610

for iSmpl = 1:nSmpls
    maxPeakIndcs    = find(maxPeakPstns(iSmpl,:));                                    % find peak maximum indices
    maxPeakIndcs    = maxPeakIndcs((nVrbls-maxPeakWindow - 2 > maxPeakIndcs)...
        & (maxPeakIndcs> maxPeakWindow + 2));                                %
    
    nPeaks          = length(maxPeakIndcs);                                  % the overall number of identified peaks
    localIndcs      = 0:maxPeakWindow*2;                                     % the segment width for identifying peak related parameters
    segLength       = length(localIndcs);
    segmentStartIndcs = maxPeakIndcs' - maxPeakWindow;                       % the segment start indices
    segsIndcs       = repmat(localIndcs,nPeaks,1) + ...
        segmentStartIndcs(:,ones(1,length(localIndcs)));
    XDerivs   =  XALLDerivs(iSmpl,:);
    XDerivs   =  XDerivs(segsIndcs);
    
    peakLocalStartIndcs            = maxPeakWindow-2:-1:1;
    [truePeakStart,peakStart]      = max(XDerivs(:,peakLocalStartIndcs)'<=0);
    peakStart                      = peakLocalStartIndcs(peakStart);
    peakStart(truePeakStart==0)    = 1;
    peakLocalEndIndcs              = maxPeakWindow+4:length(localIndcs);
    [truePeakEnd,peakEnd]          = max(XDerivs(:,peakLocalEndIndcs)'>=0);
    peakEnd                        = peakLocalEndIndcs(peakEnd);
    peakEnd(truePeakEnd==0)        = length(localIndcs);
    Xstart                         = X(iSmpl,segmentStartIndcs'+peakStart-1);
    Xend                           = X(iSmpl,segmentStartIndcs'+peakEnd-1);
    peakBasl                       = Xstart(ones(1,segLength),:)+(((repmat(localIndcs+1,nPeaks,1)'-peakStart(ones(1,segLength),:)).*...
        (Xend(ones(1,segLength),:) - Xstart(ones(1,segLength),:)))./(peakEnd(ones(1,segLength),:)...
        - peakStart(ones(1,segLength),:)));            % calculate the local base-line values for the peaks
    
    % different methods for validating peaks
    switch method
        
        case {'none'}
            truePeaks              = true(size(maxPeakIndcs));
            
        case {'widthOnly','topNum'}
            truePeaks              = (peakEnd-peakStart+1)>peakParam.minPeakWidth;
            
            if(strcmp('topNum',method))
                intensities            = X(maxPeakIndcs(truePeaks));
                [chuck IX]             = sort(intensities,'descend');
                replace                = zeros(size(IX));
                replace(IX(1:val)) = 1;
                truePeaks(truePeaks)   = replace;
            end
            
        case {'real'}
            truePeaks              = ((X(iSmpl,maxPeakIndcs) - peakBasl(1+maxPeakWindow,:))>val )&((peakEnd-peakStart+1)>peakParam.minPeakWidth);
            
        case {'topPercent','LOD','mean'}
            ampThr                 = getAmpThr(peakBasl(1+maxPeakWindow,:),X(:,maxPeakIndcs),method,val);
            truePeaks              = ((X(iSmpl,maxPeakIndcs) - peakBasl(1+maxPeakWindow,:))>ampThr )&((peakEnd-peakStart+1)>peakParam.minPeakWidth); % true peaks are those which peak maximum value exceed the local threshold value
    end
    
    %truePeaks                      = ((peakEnd-peakStart+1)>peakParam.minPeakWidth); % true peaks are those which peak maximum value exceed the local threshold value
    peakStart                      = segmentStartIndcs(truePeaks)' + peakStart(truePeaks) -1 + round((maxPeakWindow + 1 - peakStart(truePeaks))/2);
    peakEnd                        = segmentStartIndcs(truePeaks)' + peakEnd(truePeaks)   -1 - round((peakEnd(truePeaks) - (maxPeakWindow+1))/2);
    segsIndcs                      = segsIndcs(truePeaks,:);
    peakOutputIndcs                = segsIndcs>=peakStart(ones(1,segLength),:)'&segsIndcs<=peakEnd(ones(1,segLength),:)';
    segsIndcs                      = segsIndcs(peakOutputIndcs);
    peakBasl                       = peakBasl(:,truePeaks)';
    peakBasl                       = peakBasl(peakOutputIndcs);
%    plotPeaksOrSegments(X,maxPeakIndcs,...
%        peakStart,peakEnd,0)
    
    XPeaks(iSmpl,segsIndcs) = X(iSmpl,segsIndcs) - peakBasl';
    truepeaksall(iSmpl,maxPeakIndcs(truePeaks))=1; % CAZ 060610
end

% CAZ
% XPeaks(XPeaks<0)=0; % original for if multiple samples

peakinds=find((sum(truepeaksall,1)~=0)==1);

if(nargout>1) % return vector containing peak start and stop information
    peaks=zeros(size(ppm));
    for i=1:length(peakinds)
        peaks(peakStart(i):peakEnd(i))=repmat(peakinds(i),1,peakEnd(i)-peakStart(i)+1);
    end
end

%     % added rest
%     peakinds=maxPeakIndcs(truePeaks);
%     if(nargout>1)
%         for i=1:length(peakinds)
%             peaks(peakStart(i):peakEnd(i))=peakinds(i);
%         end
%     end


return;

function setupPeakPrmtrs(ppm)
peakParam.iFrameLen      = 0.005; %the frame length of of the Savitzky-Golay smoothing filter (ppm scale)
peakParam.iMaxPeakWindow = 0.03;
peakParam.iOrder         = 3;     %the polynomial order of the Savitzky-Golay smoothing filter
%peakParam.ampThr         = thresh.val;
peakParam.minPeakWidth   = 0.005; %the minimum peak width (ppm scale)

if ~isempty(ppm)
    peakParam.iFrameLen=ppmToPt(peakParam.iFrameLen,0,abs(ppm(2)-ppm(1)));
    peakParam.iMaxPeakWindow=ppmToPt(peakParam.iMaxPeakWindow,0,abs(ppm(2)-ppm(1)));
    peakParam.minPeakWidth=ppmToPt(peakParam.minPeakWidth,0,abs(ppm(2)-ppm(1)));
end
assignin('caller', 'peakParam',   peakParam);
return

function pt = ppmToPt(ppmValues, firstPtPpm, resolution)

if(nargin < 2 || isempty(firstPtPpm))
    error('nargin < 2 || isempty(firstPtPpm)');
end;
if(nargin < 3 || isempty(resolution))
    resolution = ppmValues(2) - ppmValues(1);
end;

if(~isscalar(firstPtPpm))
    error('First ppm should be a number, got non-scalar value: %d', firstPtPpm);
end;
if(~isscalar(resolution))
    error('Resolution ppm should be a number, got non-scalar value: %d', resolution);
end;

ppmShift = ppmValues - firstPtPpm;

pt = round(ppmShift ./ resolution) + 1;

return

function  ampThr=getAmpThr(baslX,maxX,method,val) % added this CAZ 060610
% Automatic determination of amplitude threshold for peak peaking
% based on the 5% of the most intensive peaks 
% Author, K.Veselkov, Imperial College London, 2007

switch method
    
    case{'topPercent'}
            
        if(size(maxX,2)>1)
            maxX=max(maxX);
        end
    
        baslX=maxX-baslX;
        
        % SELECT THRESHOLD BASED ON (1-thesh)% OF THE MOST INTENSIVE PEAKS
        peakSortedValues=sort(baslX);
        index=floor(length(baslX)*val);
        ampThr=peakSortedValues(index);  
            
    case {'LOD'}
        
        if(isempty(val)); val=std(baslX); end % as in 100606_peakpick.m
    
        ampThr=baslX+3*val;
 
    case {'mean'}

        ampThr=mean(baslX);

end
return;


function derX = sgolayDerX(X, iOrder,iFrameLen,j)
% Calculate smoothed derivates using Savitzky - Golay filter
% iFrameLen- the length of frame window

if nargin<1
    error('Incorrect number of input arguments');
end

if nargin<2
    iOrder = 3;
end

if nargin<3
    iFrameLen=11;
end

if nargin<4
    j=2; %Derivative
end

iFrameLen=(floor(iFrameLen./2))*2+1; % iFramLen must be odd

[b,g] = sgolay(iOrder,iFrameLen);

[nSmpls,nVrbls] = size(X);
derX            = zeros(nSmpls,nVrbls);

for n = (iFrameLen+1)/2:nVrbls-(iFrameLen+1)/2
    %calculate first order derivate
    derX(:,n)=X(:,n - (iFrameLen+1)/2 + 1: n + (iFrameLen+1)/2 - 1)*g(:,j);
end

return;

function [B,G] = sgolay(k,F,varargin)
%SGOLAY Savitzky-Golay Filter Design.
%   B = SGOLAY(K,F) designs a Savitzky-Golay (polynomial) FIR smoothing
%   filter B.  The polynomial order, K, must be less than the frame size,
%   F, and F must be odd.
%
%   Note that if the polynomial order K equals F-1, no smoothing
%   will occur.
%
%   SGOLAY(K,F,W) specifies a weighting vector W with length F
%   containing real, positive valued weights employed during the
%   least-squares minimization.
%
%   [B,G] = SGOLAY(...) returns the matrix G of differentiation filters.
%   Each column of G is a differentiation filter for derivatives of order
%   P-1 where P is the column index.  Given a length F signal X, an
%   estimate of the P-th order derivative of its middle value can be found
%   from:
%
%                     ^(P)
%                     X((F+1)/2) = P!*G(:,P+1)'*X
%
%   See also SGOLAYFILT, FIR1, FIRLS, FILTER

%   References:
%     [1] Sophocles J. Orfanidis, INTRODUCTION TO SIGNAL PROCESSING,
%              Prentice-Hall, 1995, Chapter 8

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 01:17:19 $

%error(narginchk(2,3,nargin));
narginchk(2,3);

% Check if the input arguments are valid
if round(F) ~= F, error('Frame length must be an integer.'), end
if rem(F,2) ~= 1, error('Frame length must be odd.'), end
if round(k) ~= k, error('Polynomial degree must be an integer.'), end
if k > F-1, error('The degree must be less than the frame length.'), end
if nargin < 3,
    % No weighting matrix, make W an identity
    W = eye(F);
else
    W = varargin{1};
    % Check for right length of W
    if length(W) ~= F, error('The weight vector must be of the same length as the frame length.'),end
    % Check to see if all elements are positive
    if min(W) <= 0, error('All the elements of the weight vector must be greater than zero.'), end
    % Diagonalize the vector to form the weighting matrix
    W = diag(W);
end

% Compute the projection matrix B
s = fliplr(vander(-(F-1)./2:(F-1)./2));
S = s(:,1:k+1);   % Compute the Vandermonde matrix

[Q,R] = qr(sqrt(W)*S,0);

G = S*inv(R)*inv(R)'; % Find the matrix of differentiators

B = G*S'*W;

% [EOF] - sgolay.m
return;

function plotPeaksOrSegments(SpSmooth,peakMaxPositions,...
    peakStartPositions,peakEndPositions,debug,Marker)
% debugging purpose only

if nargin<6
    Marker=0.5;
end
segmentCount=length(peakStartPositions);
title(sprintf('%.d Segments Found ',segmentCount));
hold on
plot(SpSmooth,'b'); hold on;
ylim = get(gca,'YLim');
if ~isempty(peakMaxPositions)
    line([peakMaxPositions;peakMaxPositions],...
        [0.*ones([1 length(peakMaxPositions)]); ...
        SpSmooth(peakMaxPositions)],'Linewidth', Marker,'Color','b');
end
line([peakStartPositions;peakStartPositions],...
    [0.*ones([1 length(peakStartPositions)]);...
    SpSmooth(peakStartPositions)*5],'Linewidth', Marker,'Color','g');
line([peakEndPositions;peakEndPositions],...
    [0.*ones([1 length(peakEndPositions)]);...
    SpSmooth(peakEndPositions)*5],'Linewidth', Marker,'Color','k');
pause(debug);
hold off;

return