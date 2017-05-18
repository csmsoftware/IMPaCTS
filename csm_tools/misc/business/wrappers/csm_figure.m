classdef csm_figure < csm_wrapper
% CSM_FIGURE - Base class for CSM Figures. ie. csm_plot_pca, csm_gui_alignment, etc.
%
% Usage:
%
%	model = csm_figure( );
%
% Returns:
%
%	csm_figure.handles : (cell) The figure handles.
%	csm_figure.linkprop : (struct) The linkprop should it exist.
%
% Methods:
%
%	csm_figure.init( obj ) : Run the initialisation methods.
%	csm_figure.runAuditInfoMethods() : Run the csm_audit_info methods.
%	csm_figure.setCsmDataHash() : Set the data hashes.
%	csm_figure.callBaseTool() : Call the underlying tool (ie mypca)
%	csm_figure.parseOutput() : Parse the output from tmp into output.
%
% Description:
%
%	The base class for the CSM figures. These wrappers are the standardised access points to the underlying CSM functions.
%
%	Have a look at the code for any of the existing wrappers for examples
%	of building your own, eg csm_plot_pca()
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    properties

        handles;
        linkprop;

    end
    
    methods 
        
        function [obj] = csm_figure( varargin )
        
            obj = obj @ csm_wrapper( varargin{:} );
            obj.handles = {};

        end
    end    

end

