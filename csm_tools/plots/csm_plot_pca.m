classdef csm_plot_pca < csm_figure
%CSM_PLOT_PCA - Plot the scores and loadings from a PCA model
%
% Usage:
%
% 	figure = csm_plot_pca( csm_pca_model );
%
% 	figure = csm_plot_pca( csm_pca_model, 'plot_type', plot_type, 'classes', classes, 'sample_ids', sample_ids, 'components', components );
%
% Arguments:
%
%	*csm_pca_model : (csm_pca) csm_pca model.
%
%	plot_type : (str) 'all', 'scores', 'loadings', 'stats'. Default 'all'
% 	classes : (m*1) Classes for plotting. Default is table from csm_pca spectra input.
% 	sample_ids : (cell) Sample Labels for plotting. Default is sample_ids from csm_pca spectra input.
% 	components : (m*1) Vector of which components to plot. Default is all.
%
% Returns:
%
%	figure : (csm_figure) csm_figure with some stored inputs, the handle and auditInfo.
%
% Description:
%
%	Utilises the CJSpcaPlot function written by Caroline Sands.
%
%	If classes is specified, uses those classes. Otherwise uses the
%	classes specified in the csm_pca_model.input.spectra (csm_nmr_spectra).
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_plot_spectra
        function [obj] =  csm_plot_pca( csm_pca_model, varargin )
            
            obj = obj @ csm_figure( varargin{:} );

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj = assignDefaults( obj, csm_pca_model, varargin );

            obj = parseInput ( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end
        
        function [obj] = assignDefaults( obj, csm_pca_model, varargin )

            % Required arguments
            obj.input.csm_pca_model = csm_pca_model;

            obj.input.in = struct;
            obj.input.in.P = csm_pca_model.output.P;
            obj.input.in.T = csm_pca_model.output.T;
            obj.input.in.Tcv = csm_pca_model.output.Tcv;
            obj.input.in.Xr = csm_pca_model.output.Xr;
            obj.input.in.R2 = csm_pca_model.output.R2;
            obj.input.in.Q2 = csm_pca_model.output.Q2;
            
            obj.optional_defaults = containers.Map;
            
            % Optional arguments with defaults
            obj.optional_defaults( 'plot_type' ) = 'all';
            obj.optional_defaults( 'classes' ) = ones( length( csm_pca_model.output.T (:,1) ), 1 );
            obj.optional_defaults( 'sample_ids' ) = ones( length( csm_pca_model.output.T (:,1) ), 1 );
            obj.optional_defaults( 'components' ) = 1 : size( csm_pca_model.output.T, 2 );
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
            % Set dependant defaults
                        
            % plot_type
            if strcmp( obj.optional_defaults( 'plot_type' ), 'all')

                obj.input.base_plot_type = 'all';

            elseif strcmp( obj.optional_defaults( 'plot_type' ), 'stats' )

                obj.input.base_plot_type = 'all';

            else

                obj.input.base_plot_type = obj.optional_defaults( 'plot_type' );

            end

            % If the classes have been left to default but the spectra has sample info, set the sample info to be a table.
            if ~ismember( 'classes', obj.set_options ) && ~isempty( csm_pca_model.input.spectra.sample_metadata )
                
                obj.input.classes = csm_pca_model.input.spectra.sample_metadata.getTable();

            end
            
            % If the sample_ids have been left to default but the spectra has sample_ids, set the sample_ids.
            if ~ismember( 'sample_ids', obj.set_options ) && ~isempty( csm_pca_model.input.spectra.sample_ids )
                
                obj.input.sample_ids = csm_pca_model.input.spectra.sample_ids;

            end

        end
                
        % Check the input
        function [obj] = parseInput( obj )
            
            obj.inputparser = inputParser;
            
            expected_plot_type = { 'all', 'scores', 'loadings', 'stats' };
     
            addRequired( obj.inputparser , 'csm_pca_model' , @( x ) isa( x, 'csm_pca') )
            addRequired( obj.inputparser , 'plot_type' , @( x ) any( validatestring( x, expected_plot_type ) ) );
            addRequired( obj.inputparser , 'components' , @( x ) ismatrix( x ) );
            
            parse( obj.inputparser, obj.input.csm_pca_model, obj.input.plot_type, obj.input.components );
     
            
        end    

        % Call the CJSpcaPlot function
        function [obj] = callBaseTool( obj )

            % Anything but 'stats' run the base method
            if ~strcmp(obj.input.plot_type,'stats')
            
                obj.handles = CJSpcaPlot( obj.input.in, obj.input.csm_pca_model.input.spectra.x_scale(), obj.input.csm_pca_model.input.spectra.X, 'plottype', obj.input.plot_type, 'class', obj.input.classes, 'components', obj.input.components );
            
            end
            
            if strcmp(obj.input.plot_type,'stats') || strcmp(obj.input.plot_type,'all')
                
                obj = runExtraMethods( obj );
                
            end    

        end

        % Parse the model output
        function [obj] = parseOutput( obj )

            obj.tmp = '';

        end

        % Run the auditInfo methods (must be run)
        function [obj] = runAuditInfoMethods( obj )

            obj.class_name = class( obj );

            runAuditInfoMethods @ csm_figure( obj );

        end

        function [obj] = runExtraMethods( obj )

            if strcmp( obj.input.plot_type, 'all' ) || strcmp( obj.input.plot_type, 'stats' )

                % Scree plot

                figure; % open new figure
                obj.handles{ end + 1 } = gcf;
                set(gcf,'color','white','name', 'PCA scree', 'NumberTitle', 'off' );
                plot(1:size(obj.input.csm_pca_model.output.R2,1),obj.input.csm_pca_model.output.R2); % plot data
                xlabel('Component'); ylabel('Variance explained'); % add axis labels
                title('Plot of variance explained by each component') % add title
                fprintf('\nPCA scree plot\n')

                % DModX plot

                figure;
                obj.handles{ end + 1 } = gcf;
                set(gcf,'color','white','name', 'PCA DModX', 'NumberTitle', 'off' );
                plot( 1:obj.input.csm_pca_model.output.ns ,obj.input.csm_pca_model.output.DModX, '-ob'); hold on; % plot DModX
                plot(1:obj.input.csm_pca_model.output.ns, ones (1,obj.input.csm_pca_model.output.ns) * obj.input.csm_pca_model.output.Dcrit, '--r') % line at critical value
                set(gca, 'XTick', 1:obj.input.csm_pca_model.output.ns , 'XTickLabel', obj.input.sample_ids,'XTickLabelRotation', 90)
                ylabel( 'DModX' ); xlabel( 'Sample ID' );  
                legend( 'DModX', 'Dcrit' );
                title( 'PCA DModX plot (moderate outliers)' );
                fprintf('\nPCA DModX plot\n')

                %TODO: Make 1 plot

            end

        end

    end

end




