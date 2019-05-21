function[res]=sens_spec_plot(v, m)

% Plots sensitivity (true positive rate) and specificity (true negative rate)
% v = row vector of true class assignments (template)
% m = matrix (or row vector) of class assignments to be compared.
%
% Max Bylesjö
% Research Group for Chemometrics
% Department of Organic Chemistry
% Umeå University
% Sweden


[sensvec, specvec, classvec, tot_sens]=sens_spec(v, m);

h=bar([100.*sensvec; 100.*specvec; 100.*[mean(sensvec),mean(specvec),zeros(1,length(specvec)-2)] ]);
h=gca;
%set(h, 'XTickLabel', ['Sensitivity'; 'Specificity'; 'Total_sens_spec'])
ylabel('TP/TN rate (%)')

res.sens=sensvec;
res.spec=specvec;
res.tot_sens=tot_sens;
res.meanSens=mean(sensvec);
res.meanSpec=mean(specvec);