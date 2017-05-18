function defineRSPAPrmtrs(hObject,ignore)
%% defineRSPAPrmtrs - passing user-defined parameters for RSPA
% Input: 

%% Author: Kirill Veselkov, Imperial College 2010

metadata            = guidata(hObject);
options.Resize      = 'on';
options.WindowStyle = 'normal';
options.Interpreter = 'tex';

prompt = {'Average peak width to stop recursion (in ppm):','Peak maximum shift (in ppm):',...
    'Peak alignment acceptance (any value from 0 to 1):','Peak alignment resemblance to stop recursion(any value from 0 to 1):',...
    'Enter the value of a do recursion parameter (TRUE (1) or FALSE (0))'};
dlg_title = 'Change default parameters for local recursive segment wise peak alignment';
num_lines = 1;
def = {num2str(metadata.RSPA.minSegWidth),num2str(metadata.RSPA.maxPeakShift),num2str(metadata.RSPA.acceptance),num2str(metadata.RSPA.resemblance),num2str(metadata.RSPA.recursion)};
answer = inputdlg(prompt,dlg_title,num_lines,def,options);

metadata.RSPA.minSegWidth     = str2num(answer{1});
metadata.RSPA.maxPeakShift    = str2num(answer{2});
metadata.RSPA.acceptance      = str2num(answer{3});
metadata.RSPA.resemblance     = str2num(answer{4});
metadata.RSPA.recursion       = str2num(answer{5});
guidata(hObject,metadata);