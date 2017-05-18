function varargout = uiSelectReference(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiSelectReference_OpeningFcn, ...
                   'gui_OutputFcn',  @uiSelectReference_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function uiSelectReference_OpeningFcn(hObject, eventdata, handles, varargin)
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
handles.MainFigure = varargin;
guidata(hObject, handles); % Update handles structure

function varargout = uiSelectReference_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% Executes on button press in ref_mean.
function ref_mean_Callback(hObject, eventdata, handles)
close(handles.figure1);
selectTarget(handles.MainFigure{1},'mean');

%% Executes on button press in ref_median.
function ref_median_Callback(hObject, eventdata, handles)
close(handles.figure1)
selectTarget(handles.MainFigure{1},'median');

%% Executes on button press in ref_closestToMean.
function ref_closestToMean_Callback(hObject, eventdata, handles)
close(handles.figure1)
selectTarget(handles.MainFigure{1},'simtomean');

%% Executes on button press in ref_closestToMedian.
function ref_closestToMedian_Callback(hObject, eventdata, handles)
close(handles.figure1)
selectTarget(handles.MainFigure{1},'simtomedian');

%% Executes on button press in sample number table
function sampleNumber_Callback(hObject, eventdata, handles)
refSamId       = str2double(get(handles.sampleNumber,'String'));
close(handles.figure1);
metadata       = guidata(handles.MainFigure{1});
metadata.T     = metadata.Sp(refSamId,:);
guidata(handles.MainFigure{1},metadata);

%% Executes on button press in ref_ClosestToOthers.
function ref_ClosestToOthers_Callback(hObject, eventdata, handles)
selectTarget(handles.MainFigure{1},'simtoallsamples');
close(handles.figure1);