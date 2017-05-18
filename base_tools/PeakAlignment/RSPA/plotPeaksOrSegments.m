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