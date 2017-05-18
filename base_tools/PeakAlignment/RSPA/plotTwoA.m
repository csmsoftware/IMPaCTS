function plotTwoA(signal1, signal2, xValues,step,debug)

if isempty(xValues)
     xValues = 1:length(signal1);
end

if isempty(debug)
    return;
end

if isempty(xValues)
     xValues = 1:length(signal1);
end
    
CorrCoef=corrcoef_aligned(signal1,signal2,step);

if debug<0
    plot(xValues, signal1, 'r');
    hold on;
    plot(xValues, signal2, 'b');
    title(sprintf('resemblance %.2f',CorrCoef),'FontSize',16);
    legend('reference','current');
    hold off;
    pause();
else
    plot(xValues, signal1, 'r');
    hold on;
    plot(xValues, signal2, 'b');
    title(sprintf('resemblance %.2f',CorrCoef),'FontSize',16);
    legend('reference','current');
    hold off;
    pause(debug);
end

return;