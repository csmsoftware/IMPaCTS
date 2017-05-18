function csm_qc_basic(spectra,peak_width_model,save_dir)
% CSM_QC_BASIC - Run the basic QC.
%
% Usage:
%
% 	model = csm_qc_basic( spectra, peak_width_model, save_dir );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%	*peak_width_model : (csm_peak_width) CSM Peak Width model.
%	*save_dir : (str) Location to save the data.
%
% Description:
%
%	Runs the basic QC. Used for generating reports post-import.
%

    %% NMR BASIC QC STATS
    % Report on basic QC stats

    %% Check referencing

    % Plot data
    csm_plot_spectra(spectra);
    
    % Zoom in on peak data referenced to:
    if(strcmpi(spectra.sample_type, 'Plasma') || strcmpi(spectra.sample_type, 'Serum'))
        set(gca,'XLim',[5.2 5.26])
        title('Zoom on glucose peak')
    else
        set(gca,'XLim',[-0.2 0.2])
        title('Zoom on TSP peak')
    end

    saveas(gcf,fullfile(save_dir,'X.fig')); snapnow; close

   
    %% Cut TSP resonance

    % Remove TSP peak
    spectra = spectra.cutRegion(-0.2,0.2);
   

    %% Baseline (spectral extremes) outliers
    % Outliers in baseline are defined as any samples for which the mean or
    % std difference in signal between spectral ends (>9,5x_scale and <-0.5)
    % exceed that number which would be expected with a 95% threshold

    % Baseline fluctuations between min(x_scale) and -0.5 (Low)
    baseline_low = csm_baseline_diff(spectra,[min(spectra.x_scale),-0.5],'save_dir',save_dir);
    
    % Baseline fluctuations between 9.5 and max(x_scale) (High)
    baseline_high = csm_baseline_diff(spectra,[9.5,max(spectra.x_scale)],'save_dir',save_dir);
    
    % Fluctuations in baseline across all samples
    figure;
    errorbar(mean(spectra.X(:,baseline_high.output.regionIX),2),std(spectra.X(:,baseline_high.output.regionIX),[],2),'b'); hold on;
    errorbar(mean(spectra.X(:,baseline_low.output.regionIX),2),std(spectra.X(:,baseline_low.output.regionIX),[],2),'r');
    legend('high x_scale','low x_scale','location','NorthEastOutside');
    title('Mean+/-std for each sample signal distribution')
    xlabel('sample number')
    saveas(gcf,fullfile(save_dir,'BL across sample fluctuations.fig')); snapnow; close



    %% Cut water resonance

    % Remove presaturated water resonance
    WPcutRegion = [4.55, 4.9];

    spectra = spectra.cutRegion(WPcutRegion(1),WPcutRegion(2));

    %% Water pre-saturation outliers
    % Outlier in the baseline around the (removed) presaturated water peak are 
    % defined as those where either:
    %
    % # 'threshold' percent of the area (0.1 x_scale) either side of the removed
    % water region exceeds the critical value 'alpha'
    % # 'threshold' percent of the signal (0.1 x_scale) either side of the 
    % removed water region is negative

    % Baseline fluctuations for region below removed water peak
    wp_baseline_low = csm_baseline_diff(spectra,[WPcutRegion(1)-0.1,WPcutRegion(1)],'save_dir',save_dir,'saveName','WP');
    
    % Baseline fluctuations between 9.5 and max(x_scale) (High)
    wp_baseline_high = csm_baseline_diff(spectra,[WPcutRegion(2)-0.1,WPcutRegion(2)+0.1],'save_dir',save_dir,'saveName','WP');
    
    %% Output table for samples to investigate as potential outliers
    
    nmr_experiment_table = spectra.nmr_experiment_info.getTable();

    temp = regexp(nmr_experiment_table.Properties.VariableNames, {'Unique_ID|Sample_ID'});
    temp = cellfun(@(x) ~isempty(x), temp);
    outliersALL = cat(2, nmr_experiment_table(:,temp), peak_width_model.output.outliers, baseline_low.output.outliers, baseline_high.output.outliers, wp_baseline_low.output.outliers, wp_baseline_high.output.outliers);
    writetable(outliersALL,fullfile(save_dir,'outliersALL.csv'))

    fprintf('Outlier information exported to %s\n',fullfile(save_dir,'outliersALL.xls'));
    fprintf('%g samples exceed outlier criteria across all tests\n', sum(any(outliersALL{:,sum(temp)+2:end},2)))

    %% Save data

    X = spectra.X;
    ppm = spectra.x_scale;
    LW = peak_width_model.output;
    
    save(fullfile(save_dir,'preproc.mat'),'X','ppm',...
        'LW','outliersALL');

    fprintf('Data saved as %s\n',fullfile(save_dir,'preproc.mat'));

end