function handles = gui_frame_md_init(ui)
%the MD framework is divided into 2 big blocks from the top to the bottom
%the TOP block consists 'general setup' on the left, 'market data' on the
%right;
%
%the BOTTOM block is for dynamic figures market data plot 

%%
ui_guiW = ui.guiW;
ui_guiH = ui.guiH;
ui_guiX = ui.guiX;
ui_guiY = ui.guiY;
ui_guiColor = ui.guiColor;
ui_guiName = ui.guiName;
%
guiPosition = [ui_guiX ui_guiY ui_guiW ui_guiH];
handles.frame = figure(1);
set(handles.frame,'Name',ui_guiName,...
    'Position',guiPosition,...
    'Color',ui_guiColor,...
    'ToolBar','none',...
    'MenuBar','none',...
    'NumberTitle','off');
% movegui(handles.frame, 'north');
%%
ui_panel2LeftFrame = ui.panel2LeftFrame;     %distance between the very left panel and the left frame
ui_panel2RightFrame = ui.panel2RightFrame;    %distance between the very right panel and the right frame
ui_panel2TopFrame = ui.panel2TopFrame;      %distance between the very top panel and the top frame
ui_panel2BottomFrame = ui.panel2BottomFrame;   %distance between the very bottom panel and the bottome frame
ui_panel2panelH = ui.panel2panelH;        %horizontal distance between panels
ui_panel2panelV = ui.panel2panelV;        %vertical distance between panels
ui_panelFontSize = ui.panelFontSize;          %panel font size
ui_topLeftBlockW = ui.topLeftBlockW;          %left block width
% ui_middleBlockW = ui.middleBlockW;        %middle block width
%%
%given the above parameters, we can work out the x point of each block as
%follows:
upperLeftBlockX = ui_panel2LeftFrame;
upperRightBlockX = upperLeftBlockX + ui_topLeftBlockW + ui_panel2panelH;
% rightBlockX = upperRightBlockX + ui_middleBlockW + ui_panel2panelH;
%
%also the width of the right block can be computed as follows:
upperRightBlockW = 1 - ui_panel2RightFrame - upperRightBlockX;
%%
frame = handles.frame;
%%
%the TOP LEFT block
%'generalsetup'
ui_topPanelH1 = ui.topPanelH1;
% ui_leftPanel2H = ui.leftPanel2H;
%given the heights and 1st and 2nd pannel the 3rd pannel height is thus:
% leftPanel3H = 1-ui_topPanelH-ui_leftPanel2H-ui_panel2TopFrame-ui_panel2BottomFrame-...
%     2*ui_panel2panelH;
%the general setup
generalsetupPanelH = ui_topPanelH1;
generalsetupPanelW = ui_topLeftBlockW;
generalsetupPanelX = upperLeftBlockX;
generalsetupPanelY = 1 - ui_panel2TopFrame - generalsetupPanelH;
generalsetupPosition = [generalsetupPanelX generalsetupPanelY generalsetupPanelW generalsetupPanelH];
handles.generalsetup.panelbox = uipanel('Parent', frame, ...
    'Title', 'General Setup', ...
    'Units', 'Normalized',...
    'Position', generalsetupPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');
%'operations
mktdataopsH = ui.topPanelH2;
mktdataopsW = ui_topLeftBlockW;
mktdataopsX = upperLeftBlockX;
mktdataopsY = generalsetupPanelY-ui_panel2panelV-mktdataopsH;
mktdataopsPosition = [mktdataopsX mktdataopsY mktdataopsW mktdataopsH];
handles.mktdataops.panelbox = uipanel('Parent',frame,...
    'Title', 'Operations', ...
    'Units', 'Normalized',...
    'Position', mktdataopsPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');

%%
%the TOP RIGHT block
%'mktdatatbl'
ui_topRightPanelH = ui.topPanelH1 + ui.topPanelH2 + ui_panel2panelV;
%market data table
mktdataTblPanelH = ui_topRightPanelH;
mktdataTblPanelW = upperRightBlockW;
mktdataTblPanelX = upperRightBlockX;
mktdataTblPanelY = 1-ui_panel2TopFrame-mktdataTblPanelH;
mktdataTblPanelPosition = [mktdataTblPanelX mktdataTblPanelY mktdataTblPanelW mktdataTblPanelH];
handles.mktdatatbl.panelbox = uipanel('Parent', frame, 'Title', 'Market Data', ...
    'Units', 'Normalized', ...
    'Position', mktdataTblPanelPosition,...
    'FontSize', 10, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');

%%
%the BOTTOM block
%'mktdataplot'
ui_bottomPanelH = 1-ui.topPanelH1-ui.topPanelH2-2*ui_panel2panelV-ui_panel2TopFrame-ui_panel2BottomFrame;
%market data plot
mktdataPlotPanelH = ui_bottomPanelH;
mktdataPlotPanelW = 1-ui_panel2LeftFrame-ui_panel2RightFrame;
mktdataPlotPanelX = upperLeftBlockX;
mktdataPlotPanelY = ui_panel2BottomFrame;
mktdataPlotPosition = [mktdataPlotPanelX mktdataPlotPanelY mktdataPlotPanelW mktdataPlotPanelH];
handles.mktdataplot.panelbox = uipanel('Parent', frame, ...
    'Title', 'Market Plot', ...
    'Units', 'Normalized',...
    'Position', mktdataPlotPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');
%
end
