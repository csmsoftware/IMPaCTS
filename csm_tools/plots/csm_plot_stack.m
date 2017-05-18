classdef csm_plot_stack < csm_figure
%CSM_PLOT_STACK - Stack plot for comparing spectra.
%
% Usage:
%
% 	figure = csm_plot_stack( {csm_spectra1, csm_spectra2} );
%
% 	figure = csm_plot_stack( {csm_spectra1, csm_spectra2}, 'multi', multi, 'titles', titles, 'legend', legend, 'scale', scale, 'no_labels', no_labels, 'title', title );
%
% Arguments:
%
%   {csm_spectra1, csm_spectra2} : (cell) Cell array of csm_spectra objects containing spectral matrix X.
%
%	multi : (m*1) matrix with classes for which spectra in the X matrix  should be plotted together e.g. for a set of 6 spectra plotting the first and last three together multi = [1; 1; 1; 2; 2; 2]. Default all.
%	titles : (cell) titles for the different stackplots e.g. .titles = {'set 1','set 2'}. Default spectra name.
%	legend : (cell) legend for each sample. Default sample_id or spectra_num*Pos.
%	scale : (bool) set true if the scales for the different plots are very different, then data will be scaled to better compare. Default false.
%   title : (str) Title of plot. Default simple.
%
% Returns:
%
%	figure : (csm_figure) csm_figure with some stored inputs, the handle and auditInfo.
%
% Description:
%
%   Plot multiple spectra together.
%
%	Utilises the CJSstackplot method written by Caroline Sands.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author: Gordon Haggart, 2015


    methods

        % Constructor for csm_plot_spectra
        function [obj] =  csm_plot_stack( spec_array, varargin )
            
            obj = obj @ csm_figure( varargin{:} );

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj = assignDefaults( obj, spec_array, varargin );

            obj = parseInput ( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs and default options
        function [obj] = assignDefaults( obj,  spec_array, varargin )
            
            obj.input.spec_array = spec_array;
            spectra1 = spec_array{1};
            obj.input.x_scale = spectra1.x_scale;

            obj.input.X = [];
            multi = [];
            titles = {};
            labels = {};
           
            for i = 1 : length( obj.input.spec_array )

                spectra = spec_array{i};
                obj.input.X = [obj.input.X; spectra.X];
                multi = [multi; (ones(size(spectra.X,1),1)*i)];
               
                if ~isempty(spectra.name)
                    titles{i} = spectra.name;
                else
                    titles{i} = strcat('Spectra ',num2str(i));
                end 
                    
                labels = buildLabelsForLegend( obj, labels, i,  spectra, varargin{:} );
                    
            end	        

            obj.optional_defaults = containers.Map;
            
            % Optional arguments with defaults
            obj.optional_defaults( 'multi' ) = multi;
            obj.optional_defaults( 'titles' ) = titles;
            obj.optional_defaults( 'legend' ) = labels;
            obj.optional_defaults( 'scale' ) = 0;
            obj.optional_defaults( 'title' ) = 'Stack plot of spectra';
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
            obj.input.options = struct;
            obj.input.options.multi = obj.input.multi;
            obj.input.options.titles = obj.input.titles;
            obj.input.options.legend = obj.input.legend;
            obj.input.options.scale = obj.input.scale;
            
        end
        
        % Build the labels for the legend
        function new_labels = buildLabelsForLegend( obj, labels, i, spectra,varargin )
            
            k = 1;
            while k < numel( varargin{1} )

                % Check its in the options map
                if strcmp( 'no_labels' , varargin{ 1 }{ k } ) && true( varargin{ 1 }{ k + 1 } )
                    
                    new_labels = {};
                    
                    return;
                end
                
                k = k + 2;
                
            end
            
            
            if isempty( spectra.sample_ids)
               
                % create cell array of ((spectra Number * 100) + 1) : Length
                
                new_labels = arrayfun(@num2str, ((i*100)+1):(size(spectra.X,1)+(i*100)), 'unif', 0);
                   
            else 
                
                new_labels = spectra.sample_ids;
                
            end    
                
            if i > 1
                
                new_labels = [labels, new_labels];
                
            end    
            
        end    
        
            % Assign the inputs and default options
        function [obj] = parseInput( obj )

            obj.inputparser = inputParser;
            
            addRequired( obj.inputparser , 'spec_array' , @( x ) iscell( x ) );
            addRequired( obj.inputparser , 'multi' , @( x ) ismatrix( x ) );
            addRequired( obj.inputparser , 'titles' , @( x ) iscell( x ) );
            addRequired( obj.inputparser , 'legend' , @( x ) iscell( x ) );
            
            parse( obj.inputparser, obj.input.spec_array, obj.input.multi, obj.input.titles, obj.input.legend );

        end    


        % Call the stackplotCS function
        function [obj] = callBaseTool( obj )

            obj.handles{ end + 1 } = CJSstackplot( obj.input.x_scale, obj.input.X, obj.input.options );

            title(obj.optional_defaults('title'));
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

    end

end



