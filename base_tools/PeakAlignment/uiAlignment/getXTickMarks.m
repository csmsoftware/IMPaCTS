function [xTickIndcs,ppmTickMarkOut] = getXTickMarks(hAxes,ppm,xAxis)
%% Get ppm tick marks or spacings of a power of 10 for visualization of
%% pair-wise comparative analysis
%   Input:  hAxes            - axis handle 
%           ppm [1xnVrbls]   - vector of ppm values
%           xAxis            - True or False (if false the y tick marks are to be identified)

%   Output: xTickIndcs       - x tick marks
%           ppmTickMarkOut   - ppm tick marks
%% Author: Kirill Veselkov, Imperial college London, 2010

if nargin <3 
    xAxis = 1; 
end

if xAxis == 1
    xlims      = get(hAxes,'xlim');                 % Get the limits of the x-axis
else
    xlims      = get(hAxes,'ylim');                 % Get the limits of the x-axis
end

xlims      = [floor(xlims(1)) ceil(xlims(2))];
range      = ppm(xlims(2)) - ppm(xlims(1));   
delta      = 10.^(ceil(log10(range)-1));      % Make the tick mark spacing to be power 
                                              % of 10, which results between 1 and 10 tick marks
nSpacings  = floor(range./delta);             % Calculate the actual number of x tick marks

%% A few cases to increase a number of spacings which results between 5 and
%% 10 tick marks
if nSpacings <= 2
    delta    = delta./5;
elseif nSpacings < 5
    delta    = delta./2;                       
end

%% Round off the first value
residual      = ppm(xlims(1))-delta*floor(ppm(xlims(1))./delta);
if (residual~=0)
    ppm(xlims(1))   = ppm(xlims(1)) - residual;
    ppmTickMarks    = ppm(xlims(1)):delta:ppm(xlims(2));
    ppmTickMarks(1) = [];
else
    ppmTickMarks    = ppm(xlims(1)):delta:ppm(xlims(2));
end

%% Get the x tick indices 
nTickMarks     = length(ppmTickMarks);
ppmTickMarkOut = ppmTickMarks;
xTickIndcs     = [];
prevTickIndex  = 0;
for iTick = 1:nTickMarks
    XTickIndex = find(ppm>=ppmTickMarks(iTick),1,'first');
    if XTickIndex > prevTickIndex
        prevTickIndex = XTickIndex;
        xTickIndcs    = [xTickIndcs XTickIndex];
    else
        ppmTickMarkOut(iTick) = NaN;
    end
end
ppmTickMarkOut(isnan(ppmTickMarkOut))  = [];
return; 