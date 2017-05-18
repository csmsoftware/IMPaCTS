function [ output_args ] = csm_publish_qc_basic( spectra,csm_peak_width_model,save_dir )

%publish_qc_publish Summary of this function goes here
%   Detailed explanation goes here

assignin('base', 'spectra', spectra);
assignin('base', 'csm_peak_width_model', csm_peak_width_model);
assignin('base', 'save_dir', save_dir);

codeToEvaluate = 'csm_qc_basic(spectra,csm_peak_width_model,save_dir)';

pub_options = struct('format','html','outputDir',strcat(save_dir,filesep, 'publishedOutput'),'codeToEvaluate',codeToEvaluate);
close all % close all existing figures
% Analyse and publish data: CS working on this now!
publish('csm_qc_basic.m',pub_options);

end

