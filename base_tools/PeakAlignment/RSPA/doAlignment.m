function Sp=doAlignment(Sp,ppm,refSp,donormalise,debug)
% Recursive Segment-Wise Peak Alignment (RSPA) for accounting peak position
% variation across multiple 1H NMR biological spectra

% Input: X - 1H-NMR biological spectra [observations dimensions]
%        ppm - NMR chemical shift scale
%        refSp - the reference spectrum to which all others are to be aligned
%        ([], for automatic selection)
%        donormalise - accounting for differential dilution across biological spectra 
%        (true or false) 
%        debug - visualise alignment using interval ("debug" seconds)
% Output: Aligned spectra
% Author, K. Veselkov, Imperial College London, 2007

currentFolder = pwd;
cd(currentFolder);

if ppm(2)<ppm(1)
    ppm=sort(ppm);
end
setup(ppm);

[obs dim]=size(Sp);
if nargin<5
    debug=[];
end
if nargin<4
    donormalise=1;
end

%Quotient probabilistic normalisation
[Sp,factors,NormSp] = normalise(Sp,'prob');
minSp               = min(Sp(:));
Sp                  = Sp - minSp;

if isempty(refSp)
    disp('...Automatic selection of a reference spectrum...');
    index=selectRefSp(Sp,recursion.step);
    refSp=Sp(index,:);
else
    [refSp]=normalise(refSp,'prob',NormSp);
end


% segmentate a reference spectrum
[refSegments,peakParam] = segmentateSp(refSp, peakParam, debug);
for index=1:obs;
    % segmentate a test spectrum 
    clear iSegments
    testSegments=segmentateSp(Sp(index,:), peakParam, debug);
    % match test and reference segments
    [testSegments,refSegments]=attachSegments(refSegments,testSegments);
    [testSegs,refSegs]=matchSegments(refSp,Sp(index,:),...
        testSegments,refSegments,MAX_DIST_FACTOR, MIN_RC,debug);
    % align a test spectrum 
    Sp(index,:) = alignSp(refSp,refSegs,Sp(index,:),...
        testSegs,recursion,MAX_DIST_FACTOR, MIN_RC,debug) + minSp;
    % undo normalisation
    if 0==donormalise
        Sp(index,:)=Sp(index,:)*factors(index);
    end
end
Sp(isnan(Sp)) = 0;

if 1==donormalise
    disp('...');
    disp('...returning normalised and aligned spectra...');
else
    disp('...');
    disp('...returning aligned spectra...');
end
return;