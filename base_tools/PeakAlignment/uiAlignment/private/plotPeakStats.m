function [hlink,metadata] = plotPeakStats(metadata)
%% The function performs visualization of peak positions across NMR spectra
%% of complex biological mixtures

%% Author: Kirill Veselkov, Imperial College London

%% Identify all the peaks in a data set
if (metadata.plotNonAlignedData)
    Sp = metadata.Sp;
else
    Sp = metadata.SpAL;
end
[XPeaks,stats] = findPeaks(Sp,metadata.ppm,metadata.peakPickingParams);

XPeaks          = log(abs(XPeaks)+metadata.peakPickingParams.offset);
permInd         = 1:size(Sp,1);
nVrbls          = size(Sp,2);

%% Subplot 1: Spectral profiles
metadata.h.SubPlot(1) = subplot(10,1,1:2);
if ishold(metadata.h.SubPlot(1))
    hold(metadata.h.SubPlot(1));
end
metadata.SubPlot(1).ylim = [min(min(Sp)),max(max(Sp))];
plot(1:nVrbls,Sp);
ylim([min(min(Sp)),max(max(Sp))])
xlim([1,nVrbls]);
[xTickIndcs,xTicksLbls]   = getXTickMarks(metadata.h.SubPlot(1),metadata.ppm);
set(gca,'XTick',xTickIndcs);
set(gca,'XTickLabel',[]);
set(gca,'FontSize',14);
ylabel('Intensity (a.u.)','FontSize',18);
set(gca,'Xdir','reverse');

%% Subplot 2: 2D - Visualization of spectral peak positions
metadata.h.SubPlot(2) = subplot(10,1,3:8);
imagesc(XPeaks(permInd,:));
xlim([1,nVrbls]);
set(gca,'XTick',xTickIndcs);
set(gca,'XTickLabel',[]);
set(gca,'FontSize',14);
ylabel('Samples','FontSize',18);
set(gca,'Xdir','reverse');
metadata.SubPlot(2).ylim = [0 metadata.nSmpls];

%% Subplot 3: Summary of peak position statistics
metadata.h.SubPlot(3) = subplot(10,1,9:10);
plot(1:nVrbls,stats);
xlim([1,nVrbls]);
set(gca,'XTick',xTickIndcs);
set(gca,'XTickLabel',xTicksLbls);
set(gca,'FontSize',14);
set(gca,'Xdir','reverse');
ylabel('Peak position distribution','FontSize',14);
xlabel('{\delta}^{ 1}H ppm','FontSize',18)
metadata.SubPlot(3).ylim = get(metadata.h.SubPlot(3),'YLim');

hlink          = linkprop(metadata.h.SubPlot,'xlim');
metadata.hlink = hlink;
colormap(metadata.peakPickingParams.colorMap);

if ~(metadata.showtarget)
    nVrbls   = length(metadata.T);
    if ~ishold(metadata.h.SubPlot(1))
        hold(metadata.h.SubPlot(1));
    end
    metadata.h.Target = plot(1:nVrbls,metadata.T,'parent',metadata.h.SubPlot(1),'LineWidth',...
        metadata.Tlinewidth,'Color',metadata.TColor);
    legend(metadata.h.Target,'reference');
    hold off;
end
guidata(metadata.h.Main,metadata);
return;