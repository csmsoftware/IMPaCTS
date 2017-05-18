function setSTOCSYmenus()
% setSTOCSYmenus: set up of STOCSY menus

mainmenu = uimenu('Label','STOCSY');
submenu1 = uimenu(mainmenu,'Label','Choose Correlation Coefficient');
stocsy.submenu2 = uimenu(mainmenu,'Label','Set Stat. Significance Threshold','Callback',{@pThr});
uimenu(submenu1,'Label','Spearman','Callback',{@spearman});
uimenu(submenu1,'Label','Pearson','Callback',{@pearson});

function spearman(hObject,ignore)
metadata             = guidata(hObject);
metadata.stocsy.cc   = 'spearman';
guidata(hObject,metadata);

function pearson(hObject,ignore)
metadata             = guidata(hObject);
metadata.stocsy.cc   = 'pearson';
guidata(hObject,metadata);

function pThr(hObject,ignore)
metadata              = guidata(hObject);
options.Resize        = 'on';
options.WindowStyle   = 'normal';
options.Interpreter   = 'tex';
pValue                = inputdlg('p value <','statistical significance',1,{num2str(metadata.stocsy.pThr)},options);
metadata.stocsy.pThr  = str2num(pValue{1});
guidata(hObject,metadata);