function plotTwoWithPeaks(spectrum1, segments1, spectrum2, segments2, xValues)
%
%
%

if(length(spectrum1) ~= length(spectrum1))
    error('length(spectrum1) ~= length(spectrum1)');
end;


if nargin<5
    xValues = 1:length(spectrum1);
end
if isempty(xValues)
    xValues = 1:length(spectrum1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Normal function execution:
drawnow;
plot(xValues, spectrum1, 'r');
hold on;
plot(xValues, spectrum2,'b');
grid on;
legend('reference','current');
ylim = get(gca,'YLim');
ymax=max([spectrum1 spectrum2]);
ymin=min([spectrum1 spectrum2]);
if ~isempty(segments1)
    for index = 1:length(segments1.start)
        lineHS = line([xValues(segments1.start(index)) xValues(segments1.start(index))], [ymin ymin+(ymax-ymin)./3]);
        lineHE = line([xValues(segments1.end(index)) xValues(segments1.end(index))], [ymin ymin+(ymax-ymin)./2]);

        set(lineHS,'Color','r');
        set(lineHE,'Color','r');
        set(lineHE,'LineWidth',3);
        set(lineHS,'LineWidth',3);
    end
end
if ~isempty(segments2)
    for index = 1:length(segments2.start)
        lineHS = line([xValues(segments2.start(index)) xValues(segments2.start(index))], [ymin ymin+(ymax-ymin)./3]);
        lineHE = line([xValues(segments2.end(index)) xValues(segments2.end(index))], [ymin ymin+(ymax-ymin)./2]);


        set(lineHS,'Color','b');% yellow
        set(lineHE,'Color','b');
        set(lineHS,'LineStyle','--');
        set(lineHE,'LineStyle','--');
        set(lineHE,'LineWidth',3);
        set(lineHS,'LineWidth',3);
    end
end
hold off;

return;