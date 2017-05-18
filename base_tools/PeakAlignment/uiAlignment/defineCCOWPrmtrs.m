function defineCCOWPrmtrs(hObject,ignore)
%% defineRSPAPrmtrs - passing user-defined parameters for CCOW

metadata            = guidata(hObject);
options.Resize      = 'on';
options.WindowStyle = 'normal';
options.Interpreter = 'tex';

prompt = {'Average peak width (in ppm):','Peak maximum shift (in ppm):',...
    'Slack (in ppm):'};
dlg_title = 'Change parameters for constrained correlation optimized warping alignment';
num_lines = 1;
def = {num2str(metadata.COW.averagePeakWidth),num2str(metadata.COW.maxPeakShift),num2str(metadata.COW.slack)};
answer = inputdlg(prompt,dlg_title,num_lines,def,options);

metadata.COW.averagePeakWidth = str2num(answer{1});
metadata.COW.maxPeakShift     = str2num(answer{2});
metadata.COW.slack            = str2num(answer{3});
guidata(hObject,metadata);