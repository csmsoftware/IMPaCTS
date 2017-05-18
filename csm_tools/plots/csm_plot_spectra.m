classdef csm_plot_spectra < csm_figure
%CSM_PLOT_SPECTRA - Plot spectral data.
%
% Usage:
%
% 	figure = csm_plot_spectra( spectra );
%    
% 	figure = csm_plot_spectra( spectra, 'sample_ids', sample_ids, 'classes', classes, 'title', title );
%
% Arguments:
%
%	*spectra : (csm_spectra) csm_spectra object containing spectral matrix.
%
%	sample_ids : (cell) Sample IDs for legend, default taken from spectra.
%	classes : (m*1) Sample classes for colours. Default none.
%   title : (str) Title of plot. Default simple.
%
% Returns:
%
%	figure : (csm_figure) csm_figure with some stored inputs, the handle and auditInfo.
%
% Description:
%
%	Basic spectra plotter functionality.
%
%   Utilises the CJSplotspectra method written by Caroline Sands.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    methods

        % Constructor for csm_plot_spectra
        function [obj] =  csm_plot_spectra( spectra, varargin )
           
            obj = obj @ csm_figure( varargin{:} );

            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
           
            obj = assignDefaults( obj, spectra, varargin );

            obj = parseInput ( obj );

            obj = callBaseTool( obj );

            obj = runAuditInfoMethods( obj );

            obj = parseOutput( obj );

        end

        % Assign the inputs and default options
        function [obj] = assignDefaults( obj,  spectra, varargin )

            obj.input.spectra = spectra;

            obj.optional_defaults = containers.Map;
            
            % Optional arguments with S
            obj.optional_defaults( 'sample_ids' ) = (1:length( spectra.X (:,1) ));
            obj.optional_defaults( 'classes' ) = [];
            obj.optional_defaults( 'title' ) = 'Plot of spectra';
            
            obj = overwriteSpecifiedOptions( obj , varargin{:} );
            
            % If the sample_ids have been left to default but the spectra has sample_ids, set the sample_ids.
            if ~ismember( 'sample_ids', obj.set_options ) && ~isempty( spectra.sample_ids )
                
                obj.input.sample_ids = spectra.sample_ids;

            end
            
            if ismember( 'classes', obj.set_options) 
                
                if ~iscell( obj.input.classes )
                    obj.input.classes = cellstr(num2str(obj.input.classes(:)));
                end
            end    

        end
        
        % Check the input
        function [obj] = parseInput( obj )
            
            obj.inputparser = inputParser;
                 
            addRequired( obj.inputparser , 'spectra' , @( x ) isa( x, 'csm_spectra') )
            
            parse( obj.inputparser, obj.input.spectra );
     
        end

        % Call the plotspectraCS function
        function [obj] = callBaseTool( obj )
            
            % If the classes have been left to default but the spectra has sample info, set the sample info to be a table.
            if ismember( 'classes', obj.set_options )
                
                obj.handles{ 1 } = CJSplotSpectra( obj.input.spectra.x_scale, obj.input.spectra.X, 'sample_labels', obj.input.sample_ids, 'class', obj.input.classes, 'newfigure', 'true'  );
                                
            else 
                
                obj.handles{ 1 } = CJSplotSpectra( obj.input.spectra.x_scale, obj.input.spectra.X, 'sample_labels', obj.input.sample_ids, 'newfigure', 'true'  );

            end
            
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



