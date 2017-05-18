function [ spectra ] = csm_import_spectra( spec_type, varargin )
%CSM_IMPORT_SPECTRA - Dynamic spectra import tool.
%
% Usage:
%
% 	spectra = csm_import_spectra( spec_type );
%
% 	spectra = csm_import_spectra( spec_type, 'filename', filename );
%
% Arguments:
%
%	*spec_type : (str) 'MS' or 'NMR'.
%   
%   filename : (str) Full path to the file to be imported.
%
% Returns:
%
%   spectra : (csm_spectra) NMR or MS spectra object.
%
% Description:
%
%	Dynamic spectra import tool. Identifies file types by extension and
%	provides options for importing. 
%
%   Intended for use by end users. If you are importing as part of a
%   workflow please use the workers themselves.
%
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016


    % Which extensions do we have importers for?
    allowed_extensions = {'*.csv;*.hdf;*.nmrML;*.mzML;*.xml;*.xls*'};

    % Check the inputs
    inputparser = inputParser;
    expected_spec_type = { 'ms', 'MS', 'nmr', 'NMR' };
    addRequired( inputparser , 'spec_type' , @( x ) any( validatestring( x, expected_spec_type ) ) );
    parse( inputparser, spec_type );
    
    % Set which spectra type it is
    switch spec_type
        case {'ms','MS'}
            is_ms = true;
        case {'nmr','NMR'}
            is_nmr = true;
    end
   
    
    found = false;
    
    if ~isempty( varargin )
        k = 1;
        while k <= numel( varargin{1} )

            % If it exists, set it and break
            if strcmp( varargin{1}{k}, 'filename')

                filename = varargin{1}{k+1} ;
                found = true;
                break;

            end     

        end    
        
    end    
    
    % If it doesn't exist, use a dialog box to set the options.
    if ~found

        [FileName,PathName] = uigetfile(allowed_extensions,'Please select the file to be imported');
        filename = strcat(PathName,FileName);
                
    end
    
    [~,~,ext] = fileparts(filename);

    % Get the worker name
    choice = csm_import_spectra_static.importChoiceDialog(ext);
    
    % Run the worker
    eval(strcat('imported = csm_import_worker_',lower(strrep(choice,' ','_')),'(''spec_type'',spec_type,''filename'',filename);'));
   
    spectra = imported.spectra;

end

