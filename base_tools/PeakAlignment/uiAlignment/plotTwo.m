function plotTwo(signal1, signal2, xValues,RSPA,debug)

if isempty(xValues)
    xValues = 1:length(signal1);
end

if isempty(debug)
    return;
end

if isempty(xValues)
    xValues = 1:length(signal1);
end

[CorrCoef,testSeg,refSeg]     = VarScCorrCoef(signal1,signal2,RSPA);

if debug<0
    subplot(1,2,1);
    plot(xValues, signal1, 'r');
    hold on;
    plot(xValues, signal2, 'b');
    title(sprintf('resemblance %.2f',CorrCoef),'FontSize',16);
    legend('reference','current');
    hold off;
    subplot(1,2,2);
    plot(xValues, refSeg, 'r');
    hold on;
    plot(xValues, testSeg, 'b');
    hold off;
    pause();
else
    subplot(1,2,1)
    plot(xValues, signal1, 'r');
    hold on;
    plot(xValues, signal2, 'b');
    title(sprintf('resemblance %.2f',CorrCoef),'FontSize',16);
    legend('reference','current');
    hold off;
    subplot(1,2,2);
    plot(xValues, refSeg, 'r');
    hold on;
    plot(xValues, testSeg, 'b');
    hold off;
    pause(debug);
end

return;