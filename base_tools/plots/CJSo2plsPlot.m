function CJSo2plsPlot(model,X,Y,ppm,varargin)
%function [tmp] = CJSo2plsPlot(model,X,Y,ppm,varargin)
% function to generate required plots from MJR o2pls code (modified from Mattias' 'mjrO2plsSummaryPlot.m' and 'mjrCloarecPlot.m'
%
% Arguments:
% model (struct) = model generated from mjrMainO2pls.m
% X (nxv) = X (feature) matrix (n samples x v variables)
% Y (nx1) = Y (predictor) matrix (n samples)
% scaling (string) = 'mc' for meancentered data; 'uv' for uv scaled data
% ppm (1xv) = ppm scale
%
% Optional arguments (in pairs):
%   'savedir', (char) = fullfile path and name to save figure to
%                      (default = not saved)
%   'name', {1,1} = char name/s to annotate figure with
%                             (default = OrthPLS)
%   'plotthis', (str) = plots required; options 'all','scores','loadings',
%                     'stats','perm'
%                     (default: 'all')
%   'sample_labels', {ns,1} = cell array of strings; sample labels for plotting
%                        (default: none)
%
% example run to plot loadings and stats only:
% >> OrthPLSplotCS_d4(model,X,Y,'mc',ppm,'test','loadings','stats')
%
% CJS 150713 caroline.sands01@imperial.ac.uk


% 1. Extract variables/set up defaults

% Extract any optional input parameters
args = struct;
for i=1:2:length(varargin); 
    args.(varargin{i}) = varargin{i+1};
end

% Set up defaults

if(isfield(args,'savedir')&&~isdir(args.savedir)); mkdir(args.savedir); end
if(~isfield(args,'plotthis')); args.plotthis = 'all'; end
if(isfield(args,'sample_labels')&&isnumeric(args.sample_labels)); 
    args.sample_labels = num2str(args.sample_labels); 
end
if(~isfield(args,'name')); args.name = 'OrthPLS' ; end
args.name = strrep(args.name,'_',' ');

% remove samples for which Y == NaN (not modeled)
if(isfield(model,'samplesRemoved'))
    X(model.samplesRemoved,:) = [];
    Y(model.samplesRemoved,:) = [];
end
[ns, nc] = size(Y);

% 2. Plot

% Scores: Tosc vs Tcv (if no Tosc, Tcv plotted against sample number)

if(strcmp('scores',args.plotthis)||strcmp('all',args.plotthis))
            
    if(isempty(model.o2plsModel.To))
        orth = (1:ns)';
        ylab = 'Sample number';
    else
        orth = model.o2plsModel.To;
        ylab = 'Tosc';
    end
        
    for c = 1:nc
         
        Ytemp = Y(:,c);
        Ytemp(Ytemp==0) = []; Ytemp(Ytemp==1) = [];
        
        figure; set(gcf,'color',[1 1 1],'name',sprintf('%s scores Tcv %g',args.name,c),'NumberTitle','off');
        hold on
        
        if(isempty(Ytemp)) % Y == dummy matrix
            
            plot(model.cv.Tcv(Y(:,c)==0),orth(Y(:,c)==0,end),'ob','MarkerFaceColor','b');
            plot(model.cv.Tcv(Y(:,c)==1),orth(Y(:,c)==1,end),'or','MarkerFaceColor','r');
            if(isfield(model.args,'Y0')&&isfield(model.args,'Y0'))
                legY = [model.args.Y0;model.args.Y1];
                if(isnumeric(legY)); legY = num2str(legY); end
            else
                legY = ['Y==0';'Y==1'];
            end
            
        else % Y == continuous
            
            % bin Y into 10 classes for colour plotting
            [groups,groupBounds] = CJSbinContin(Y(:,c));
            colorY = CJScolormaps(10,'continuous'); % colors
            legY = num2str(cat(2,groupBounds(1:end-1),groupBounds(2:end)));
            legY = legY(sort(unique(groups)),:);
            
            % plot Tcv vs To
            for i = 1:10
                plot(model.cv.Tcv(groups==i,c),orth(groups==i,end),'ob',...
                    'MarkerFaceColor',colorY(i,:),...
                    'MarkerEdgeColor','k');
            end
            
%             % plot corresponding spectral data
%             figure; set(gcf,'Color',[1 1 1]); hold on
%             for i=1:10
%                 if(sum(groups==i)~=0)
%                     plot(ppm,X(groups==i,:),'color',colorY(i,:));
%                 end
%             end
            
        end
        
        if(isfield(args,'sample_labels'))
            paperSize = get(gcf,'PaperSize');
            addval = ((abs(max(model.cv.Tcv(:,c)))+abs(min(model.cv.Tcv(:,c))))/paperSize(1))/5;
            text(model.cv.Tcv(:,c)+addval,orth(:,end),args.sample_labels);
        end
        
        xlabel(sprintf('Tcv component %g',c)); ylabel(ylab); legend(legY);
        title(sprintf('%s scores Tcv %g',args.name,c))
        
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s scores Tcv %g.fig',args.name,c)))
            snapnow; close
        end
    end
    
end

% Loadings
if(strcmp('loadings',args.plotthis)||strcmp('all',args.plotthis))
    
    
% Loadings for predictive component

%     Xmc = mjrScale(X,'mc','no'); Xmc = Xmc.X;
%     corY = NaN(nc,length(ppm));
%     pvalcorY = NaN(nc,length(ppm));
%     covY = NaN(nc,length(ppm));
    
    for c = 1:nc
%         Ymc = mjrScale(Y(:,c),'mc','no'); Ymc = Ymc.X;
%         
%         [corY(c,:),pvalcorY(c,:),covY(c,:)] = corCovCalc(Xmc,Ymc,'Pearson');
%         CJSqueryPlot(ppm,covY(c,:),abs(corY(c,:)),'ppm',ppm,'r',corY(c,:))

        CJSqueryPlot(ppm, model.association_XY.cov(c,:), abs(model.association_XY.cor(c,:)), 'ppm', ppm, 'r', model.association_XY.cor(c,:))
        hcbar = colorbar;
        set(get(hcbar,'Title'),'string','correlation');
        title(sprintf('%s loadings (correlation to Y) predictive component %g',args.name,c))
        ylabel('Covariance (mean centred data) (a.u.)')
        set(gcf,'name',sprintf('%s loadings predictive component %g',args.name,c),'NumberTitle','off')
        
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s loadings predictive component %g.fig',args.name,c)))
            snapnow; close
        end
        
%         CJSqueryPlot(ppm,covY(c,:),abs(model.o2plsModel.W(:,c))','ppm',ppm,'W',model.o2plsModel.W(:,c)')
%         hcbar = colorbar;
%         set(get(hcbar,'Title'),'string','W');
%         title(sprintf('%s loadings (from model) component %g',args.name,c))
%         set(gcf,'name',sprintf('%s loadings%g from model',args.name,c))
%         
%          if(isfield(args,'savedir'))
%             saveas(gcf,fullfile(args.savedir,sprintf('%s loadings%g from model.fig',args.name,c)))
%             snapnow;
%         end
        
    end
    
%     % Loadings for osc component if calculated
%     if(~isempty(model.o2plsModel.Wo))
%         
%         if(nc>1)
%             covYtemp = median(covY);
%         else
%             covYtemp = covY;
%         end
%         
%         for oc = 1:size(model.o2plsModel.Wo,2)
%             CJSqueryPlot(ppm,covYtemp,abs(model.o2plsModel.Wo(:,oc)'),'ppm',ppm,'r',model.o2plsModel.Wo(:,oc)')
%             hcbar = colorbar;
%             set(get(hcbar,'Title'),'string','Wo');
%             title(sprintf('%s loadings osc%g',args.name,oc))
%             set(gcf,'name',sprintf('%s loadings osc%g',args.name,oc))
%         
%             if(isfield(args,'savedir'))
%                 saveas(gcf,fullfile(args.savedir,sprintf('%s loadingsOSC%g',args.name,oc)))
%                 snapnow; close
%             end
%         end
%    end
end

% S-plot
if(strcmp('Splot', args.plotthis)||strcmp('all', args.plotthis)||strcmp('loadings', args.plotthis))
    
    % Prep data
    
    if ~(isfield(model.args, 'centreType'))
        model.args.centreType = model.args.centre_type;
        model.args.scaleType = model.args.scale_type;
    end
    
    Xscale = mjrScale(X, model.args.centreType, model.args.scaleType); Xscale = Xscale.X;
     
    % Loadings for predictive component/s
    for c = 1:nc
        Tscale = mjrScale(model.cv.Tcv(:,c), model.args.centreType, model.args.scaleType); Tscale = Tscale.X;
        [corrVect,~] = corCovCalc(Xscale, Tscale);   
        CJSquerySplot(model.o2plsModel.W(:,c), corrVect, ppm)
        set(gcf,'name',sprintf('%s S-plot predictive component %g',args.name,c),'NumberTitle','off')
        xlabel(sprintf('Loadings predictive component %g', c))
        ylabel('Correlation')
        title(sprintf('%s S-plot predictive component %g',args.name,c)) 
    
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir, sprintf('%s S-plot predictive component %g.fig', args.name, c)))
            snapnow; close
        end
    end
    
    % Loadings for orthogonal component
  %  for oc = 1:size(model.o2plsModel.Wo,2)
  %      Tscale = mjrScale(model.o2plsModel.To(:,oc), model.args.centreType, model.args.scaleType); Tscale = Tscale.X;
  %      [corrVectO,~] = corCovCalc(Xscale, Tscale);
  %      CJSquerySplot(model.o2plsModel.Wo(:,oc), corrVectO, ppm)
  %      set(gcf,'name',sprintf('%s S-plot orthogonal component %g',args.name, oc),'NumberTitle','off')
  %      xlabel(sprintf('Loadings osc component %g', oc))
  %      ylabel('Correlation')
  %      title(sprintf('%s S-plot orthogonalcomponent %g',args.name,oc)) 
        
  %      if(isfield(args,'savedir'))
  %          saveas(gcf,fullfile(args.savedir, sprintf('%s S-plot orthogonal component.fig', args.name, oc)))
  %          snapnow;
  %      end
  %  end
end


% Stats
if(strcmp('stats',args.plotthis)||strcmp('all',args.plotthis))
    %below is code adopted from Olivier Cloarecs disporth_pls(), plot model stats and F-test vals for residuals-------------
    figure; set(gcf,'Color','white','name',sprintf('%s stats',args.name),'NumberTitle','off');
    
    if isempty(model.o2plsModel.Pyo)
        Residual=sum((X-model.o2plsModel.T*model.o2plsModel.W')'.*(X-model.o2plsModel.T*model.o2plsModel.W')');
    else
        Residual=sum((X-model.o2plsModel.T*model.o2plsModel.W'-model.o2plsModel.To*model.o2plsModel.Pyo')'.*(X-model.o2plsModel.T*model.o2plsModel.W'-model.o2plsModel.To*model.o2plsModel.Pyo')');
    end
    TotalResidual=sum(Residual);
    
    Fcalc=Residual*ns/TotalResidual;
    Fcrit=mean(Fcalc)+1*std(Fcalc);
    
    %which Q2 do we want to display? model.cv.Q2Yhat(:,1) -
    %for no osc in Y....
    B=[model.cv.Q2Yhat(:,1) model.o2plsModel.R2Yhat' model.o2plsModel.R2X' model.o2plsModel.R2Xcorr'];
    
    subplot(2,1,1)
    if ~isempty(model.o2plsModel.To)
        nosc=length(model.o2plsModel.To(1,:));
    else
        nosc = 0;
    end
    
    SB=size(B);
    if SB(1)==1
        bar([B;0,0,0,0])
        legend('Q^2Yhat','R^2Yhat','R^2X','R^2Xcorr');
        set(gca,'XTickLabel',{'no Y-orth comp',''});
        set(gca,'Xlim',[0.5, 1.5]);
    else
        bar(B)
        legend('Q^2Yhat','R^2Yhat','R^2X','R^2Xcorr')
        xticklabels=cell(1);
        xticklabels{1}='no Y-orth comp';
        for i=2:nosc+1
            xticklabels{i}=[num2str(i-1),' Y-orth comp'];
        end
        set(gca,'XTickLabel',xticklabels);
    end
    title(sprintf('%s stats',args.name))
    
    subplot(2,1,2) 
    plot(1:ns,Fcalc,'-ob'); hold on; plot(1:ns,ones(1,ns)*Fcrit,'--r')
    ylabel('F_{calc}'); xlabel('Sample Number');
    legend('F','F_{crit}')
    if (isfield(args, 'sample_labels'))
        set(gca, 'XTick', 1:length(args.sample_labels), 'XTickLabel', args.sample_labels, 'XTickLabelRotation', 90)
        xlabel('Sample ID');
    end
    if(isfield(args,'savedir'))
        saveas(gcf,fullfile(args.savedir,sprintf('%s stats.fig',args.name)))
        snapnow; close
    end
end


% permutation test results
% from JTPpermutate

if(strcmp('perm',args.plotthis)||strcmp('all',args.plotthis)&&isfield(model,'perm')&&isfield(model.perm,'r')) 
    
    % Display the results in a SIMCA-like way
    figure; set(gcf,'color','white','name',sprintf('%s perm',args.name),'NumberTitle','off'); hold on
    
    if(all(size(model.perm.r)>1))
        r = mean(model.perm.r);
        xlab = 'Correlation with design (line fitted to average correlation across all predictive components for each permutation)';
    else
        r = model.perm.r;
        xlab = 'Correlation with design';
    end
    
    %lines of best fit.
    % Fit regression line (Q2).
    [slope, intercept] = JTPregressThroughPoint(r, model.perm.Q2p, 1, model.cv.Q2Yhat(end));
    
    linFit = [min(r) 1];
    plot(linFit, linFit.*slope+intercept, '-b');
    
    % Fit regression line (R2).
    [slope, intercept] = JTPregressThroughPoint(r, model.perm.R2p, 1, model.o2plsModel.R2Yhat(end));
    
    linFit = [min(r) 1];
    plot(linFit, linFit.*slope+intercept, '-g');
    
    plot(model.perm.r,repmat(model.perm.Q2p,nc,1),'.b')
    plot(model.perm.r,repmat(model.perm.R2p,nc,1),'.g')
    
    plot(model.cv.Q2Yhat(end),'*b')
    plot(model.o2plsModel.R2Yhat(end),'*g')
    xlabel(xlab)
    ylabel('Q^2 and R^2')
    legend({'Q^2Y','R^2Y'})
    title(sprintf('%s permutation test results',args.name))

    if(isfield(args,'savedir'))
        saveas(gcf,fullfile(args.savedir,sprintf('%s perm.fig',args.name)))
        snapnow; close
    end
    
end


if isfield(model,'da')
    
      nclasses=length(Y(1,:));
    %plot sens and spec
        figure;
        [res]=sens_spec_plot(model.da.trueClass, model.da.predClass);
        hold on;
        set(gca,'XTickLabel',{'Sensitivity';'Specificity';'Mean (sens, spec)'});
        set(gcf,'Color','white');
        plot([0.5,1.5]',[100/nclasses,100/nclasses]','--');
        hold off;
        title('Sensitivity and Specificity for the final model (max Y-orth comps)');
        for(i =1:model.da.nclasses)
            tmpLegend{i}=['Class ',num2str(i)];
        end
        legend(tmpLegend);
        
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s sensitivity_and_specificity.fig',args.name)))
            snapnow; close
        end
        
        
        %plot sens  for each Y-orth component...
        tmp=[];
        tmpLegend=cell(1);
        %unfold the cell matrix
        for(i=1:length(model.da.sensAllOsc))
            tmp=[tmp;model.da.sensAllOsc{i}];
            tmpLegend{i}=['Y-orth. comp. ',num2str(i-1)];
        end
        figure;
        bar(tmp');
        legend(tmpLegend);
        title('Sensitivity for each class and number of Y-orthogonal components');
        set(gcf,'Color','white');
        xlabel('Class');
        ylabel('Sensitivity');
        
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s sensitivity.fig',args.name)))
            snapnow; close
        end
        
        %plot spec for each Y-orth component...
        tmp=[];
        tmpLegend=cell(1);
        %unfold the cell matrix
        for(i=1:length(model.da.specAllOsc))
            tmp=[tmp;model.da.specAllOsc{i}];
            tmpLegend{i}=['Y-orth. comp. ',num2str(i-1)];
        end
        figure;
        bar(tmp');
        legend(tmpLegend);
        title('Specificity for each class and number of Y-orthogonal components');
        set(gcf,'Color','white');
        xlabel('Class');
        ylabel('Specificity');
        
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s specificity.fig',args.name)))
            snapnow; close
        end
        
        %plot confusion matrix
        figure;
        colormap(gray)
        imagesc(model.da.confusionMatrix)
        colorbar;
        set(gcf,'Color','white');
        xlabel('predicted');
        ylabel('true');
        title('Confusion Matrix');
         
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s confusion_matrix.fig',args.name)))
            snapnow; close
        end
end
    

% permutation of variables result

if(strcmp('permVars',args.plotthis)||strcmp('all',args.plotthis)&&isfield(model,'perm')&&isfield(model.perm,'pvalVarW')) 
  
    for c = 1:nc
        Xmed = median(X);
        CJSqueryPlot(ppm,Xmed,model.o2plsModel.W(:,c)','ppm',ppm,'W',model.o2plsModel.W(:,c)'); hold on
        Xmed(model.perm.pvalVarW(:,c)<=0.05) = NaN;
        plot(ppm,Xmed,'Color',[0.8 0.8 0.8]);
        
        hcbar = colorbar;
        set(get(hcbar,'Title'),'string','W');
        title(sprintf('%s significant loadings (from variable permutation test)',args.name))
        set(gcf,'name',sprintf('%s significant loadings',args.name))
    
        if(isfield(args,'savedir'))
            saveas(gcf,fullfile(args.savedir,sprintf('%s significant loadings.fig',args.name)))
            snapnow;
        end
    end
    
%     figure; set(gcf,'color','white','name',sprintf('%s significant loadings',args.name));
%     plot(ppm,Xmed,'Color',[0.8 0.8 0.8]); hold on
%     tempPos = Xmed; tempPos(model.o2plsModel.W<=0) = NaN; tempPos([1457,1458,9372,9373]) = NaN; tempPos(model.perm.pvalVarW>0.05) = NaN;
%     plot(ppm,tempPos,'r')
%     tempNeg = Xmed; tempNeg(model.o2plsModel.W>=0) = NaN; tempNeg([1457,1458,9372,9373]) = NaN; tempNeg(model.perm.pvalVarW>0.05) = NaN;
%     plot(ppm,tempNeg,'b')
%     legend({'not significant','correlated','anticorrelated'})
    
end

% % Return output arguments if required:
% if(nargout)
%     if (strcmp(args.plotthis,'all') || strcmp(args.plotthis,'loadings'))
%         tmp.corY = corY;
%         tmp.pvalcorY = pvalcorY;
%         tmp.covY = covY;
% 
%         if(exist('corrVect', 'var'))
%             tmp.corrVect = corrVect;
%         end
%     end    
% end

fprintf('PLS model statistics:')
fprintf('\n\tR2Yhat = %.4g', model.o2plsModel.R2Yhat(:)')
fprintf('\n\tQ2Yhat = %.4g', model.cv.Q2Yhat(:)')
fprintf('\n\tR2X = %.4g\n', model.o2plsModel.R2X(:)')
if isfield(model, 'perm')
    
    fprintf('\tPermutation p-value = %.4g (%g permutations)\n',...
        model.perm.pval,model.perm.ntests)
end    

function [slope, intercept] = JTPregressThroughPoint(x, y, x0,y0)

slope = (x'-x0)\(y'-y0);

intercept = y0-slope*x0;


function[corrVect,pval,covVect] = corCovCalc(X,Y,method)

% calculate correlation and covariance
    
if(nargin<3); method = 'pearson'; end

[~,n]=size(X);
remainder=mod(n,1000);

[corrVect,pval] = corr(X,Y,'type',method);
corrVect = corrVect'; pval = pval';
cov(X,repmat(Y,1,size(X,2)));

i=0;
if(floor(n/1000)>0)
    for i = 1:floor(n/1000)
        start=(1+(i-1)*1000);
        stop=(i*1000);
        covVect( start:stop)=(1/(length(Y)-1))*Y'*X(:,start:stop);
    end
end

start=(1+(i)*1000);
stop=(i*1000+remainder);
covVect( start:stop)=(1/(length(Y)-1))*Y'*X(:,start:stop);

