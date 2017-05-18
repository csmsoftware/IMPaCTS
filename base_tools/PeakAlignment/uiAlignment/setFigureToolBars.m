function metadata = setFigureToolBars(metadata)
%% The function configures user interfaced push and toggle
%% buttons for the main and peak alginment toolbar
%  Input:  metadata - the variable data of peak picking parameters, figure
%                    plots, alignment algorithms etc.
%  Output: metadata.hMainTB     - a handle associateed with the modified main
%                                toolbar
%          metadata.PeakAlignTB - a handle associateed with the peak
%                                alignmenttoolbar
%% Author: Kirill Veselkov, Imperial College 2010.
metadata = customizeMainTB(metadata);
metadata = setPeakAlignTB(metadata);
setSTOCSYmenus()


function metadata = customizeMainTB(metadata)
%% The function customizes the main figure toolbar 

metadata.h.MainTB = findall(metadata.h.Main,'tag','FigureToolBar');
hMainTBButtons    = findall(metadata.h.MainTB);
delete(hMainTBButtons([14:end 9 6 4]));
hMainTBButtons    = findall(metadata.h.MainTB);
set(hMainTBButtons(end-3),'Separator','on'); 

hPAbuttons(2)  = uipushtool(metadata.h.MainTB);     %set peak picking parameters
set(hPAbuttons(2),'Enable','off');
hPAbuttons  = uipushtool(metadata.h.MainTB,'CData',...
    metadata.icons.getStats,'ClickedCallback',{@definePeakPickingPrmtrs},'TooltipString','Define peak picking parameters');
hPAbuttons  = uipushtool(metadata.h.MainTB,'CData',...
    metadata.icons.adjustColorMap,'ClickedCallback',{@adjustColorMap},'TooltipString','Adjust colormap');
 hPAbuttons  = uipushtool(metadata.h.MainTB,'CData',...
    metadata.icons.stocsy,'ClickedCallback',...
    {@doStocsyUIAlignment},'TooltipString','STOCSY it');


function metadata = setPeakAlignTB(metadata)
%% The function installs peak alignment toolbar

metadata.h.PeakAlignTB  = uitoolbar(metadata.h.Main); % Handle for the the peak alignment toolbar
icons                   = metadata.icons;

%% Peak position boundaries...
hPAbuttons(1)  = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.defineSegs,'ClickedCallback',{@definePeakBndrs},'TooltipString','Define peak position variation boundaries');
hPAbuttons(2)  = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.removePeakBndrs,'ClickedCallback',{@removePeakBndrs},'TooltipString','Remove previously defined peak boundaries');

hPAbuttons(3)  = uipushtool(metadata.h.PeakAlignTB);
set(hPAbuttons(3),'Enable','off')

%% Selection of a reference sample...
hPAbuttons(4)  = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.targetOn,'ClickedCallback',{@uiSelectReference},'TooltipString','Choose reference');
hPAbuttons(5)  = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.showtargeton,'ClickedCallback',{@uiShowReference},'TooltipString','Show reference');
hPAbuttons(6)  = uipushtool(metadata.h.PeakAlignTB);
set(hPAbuttons(6),'Enable','off')

%% RSPA alignment
hPAbuttons(7)  = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.RSPASettings,'ClickedCallback',{@defineRSPAPrmtrs},'TooltipString','Set RSPA parameters','Separator','on');
hPAbuttons(8)  = uipushtool(metadata.h.PeakAlignTB,...
    'CData',icons.doRSPA,'ClickedCallback',{@uiRSPA},'TooltipString','Do RSPA');

%% COW alignment
hPAbuttons(9)  = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.COWSettings,'ClickedCallback',{@defineCCOWPrmtrs},'TooltipString','Set CCOW parameters','Separator','on');
hPAbuttons(10) = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.doCCOW,'ClickedCallback',{@uiCCOW},'TooltipString','Do CCOW');
hPAbuttons(11)  = uipushtool(metadata.h.PeakAlignTB);
set(hPAbuttons(11),'Enable','off')

%% Show non-aligned/aligned data
hPAbuttons(12) = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.SwitchIcon,'ClickedCallback',{@switchData},'TooltipString','Show aligned data');

%% Export data to workspace
hPAbuttons(13) = uipushtool(metadata.h.PeakAlignTB,'CData',...
    icons.saveas,'ClickedCallback',{@exportProcData},'TooltipString','Export processed data into workspace','Separator','on');

metadata.h.hPeakAlignTBbuttons = hPAbuttons; 