function handles = gui_frame_init(ui)
%the framework is divided into 3 big blocks from the left to the right
%the LEFT block consists 'general setup' on the top, 'trading stats' in the
%middle and 'instruments' on the bottom;
%
%the MIDDLE block is market data oriented, i.e. 'market data' table on the
%top, 'market data operations' in the middle and 'market data plot' on the
%bottom. 
%
%the RIGHT block is trading oriented, i.e. 'positions' table on the top,
%'manual operations' in the middle and 'entrusts' on the bottom.
%
%in the end, we have status bar on the southeast side of the gui
%
%parameters
%gui framework

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
ui_leftBlockW = ui.leftBlockW;          %left block width
ui_middleBlockW = ui.middleBlockW;        %middle block width
%%
%given the above parameters, we can work out the x point of each block as
%follows:
leftBlockX = ui_panel2LeftFrame;
middleBlockX = leftBlockX + ui_leftBlockW + ui_panel2panelH;
rightBlockX = middleBlockX + ui_middleBlockW + ui_panel2panelH;
%
%also the width of the right block can be computed as follows:
rightBlockW = 1 - ui_panel2RightFrame - rightBlockX;
%%
frame = handles.frame;
%%
%the LEFT block
%3 panels, which are 'generalsetup','tradingstatus' and 'instruments' from
%the top to bottom on the LEFT block
ui_leftPanel1H = ui.leftPanel1H;
ui_leftPanel2H = ui.leftPanel2H;
%given the heights and 1st and 2nd pannel the 3rd pannel height is thus:
leftPanel3H = 1-ui_leftPanel1H-ui_leftPanel2H-ui_panel2TopFrame-ui_panel2BottomFrame-...
    2*ui_panel2panelH;
%the general setup
generalsetupPanelH = ui_leftPanel1H;
generalsetupPanelW = ui_leftBlockW;
generalsetupPanelX = leftBlockX;
generalsetupPanelY = 1 - ui_panel2TopFrame - generalsetupPanelH;
generalsetupPosition = [generalsetupPanelX generalsetupPanelY generalsetupPanelW generalsetupPanelH];
handles.generalsetup.panelbox = uipanel('Parent', frame, ...
    'Title', 'General Setup', ...
    'Units', 'Normalized',...
    'Position', generalsetupPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');
%
%the trading status
tradingstatsPanelH = ui_leftPanel2H;   %userinput
tradingstatsPanelX = leftBlockX;
tradingstatsPanelW = ui_leftBlockW;
tradingstatsPanelY = generalsetupPanelY - ui_panel2panelV - tradingstatsPanelH;
tradingstatsPanelPosition = [tradingstatsPanelX tradingstatsPanelY tradingstatsPanelW tradingstatsPanelH];
handles.tradingstats.panelbox = uipanel('Parent', frame, 'Title', 'TradingStats', ...
    'Units', 'Normalized', ...
    'Position', tradingstatsPanelPosition,...
    'FontSize', ui_panelFontSize,... 
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');
%
instrumentPanelX = leftBlockX;
instrumentPanelW = ui_leftBlockW;
instrumentPanelY = ui_panel2BottomFrame;
instrumentPanelH = leftPanel3H;
instrumentPanelPosition = [instrumentPanelX instrumentPanelY instrumentPanelW instrumentPanelH];
handles.instruments.panelbox = uipanel('Parent', frame, 'Title', 'Instruments', ...
    'Units', 'Normalized', ...
    'Position', instrumentPanelPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold', ...
    'TitlePosition', 'lefttop');
%%
%the MIDDLE block
%3 panels, which are 'mktdatatbl','mktdata operations' and 'mktdata plot' from
%the top to bottom on the MIDDLE block
ui_middlePanel1H = ui.middlePanel1H;
ui_middlePanel2H = ui.middlePanel2H;
%given the heights and 1st and 2nd pannel the 3rd pannel height is thus:
middlePanel3H = 1-ui_middlePanel1H-ui_middlePanel2H-ui_panel2TopFrame-ui_panel2BottomFrame-...
    2*ui_panel2panelH;
%market data table
mktdataTblPanelH = ui_middlePanel1H;
mktdataTblPanelW = ui_middleBlockW;
mktdataTblPanelX = middleBlockX;
mktdataTblPanelY = 1-ui_panel2TopFrame-mktdataTblPanelH;
mktdataTblPanelPosition = [mktdataTblPanelX mktdataTblPanelY mktdataTblPanelW mktdataTblPanelH];
handles.mktdatatbl.panelbox = uipanel('Parent', frame, 'Title', 'Market Data', ...
    'Units', 'Normalized', ...
    'Position', mktdataTblPanelPosition,...
    'FontSize', 10, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%market data operations
mktdataOpsPanelX = middleBlockX;
mktdataOpsPanelW = ui_middleBlockW;
mktdataOpsPanelH = ui_middlePanel2H;
mktdataOpsPanelY = mktdataTblPanelY - mktdataOpsPanelH-ui_panel2panelV;
mktdataOpsPanelPosition = [mktdataOpsPanelX mktdataOpsPanelY mktdataOpsPanelW mktdataOpsPanelH];
handles.mktdataops.panelbox = uipanel('Parent', frame, 'Title', 'Market Data Operations', ...
    'Units', 'Normalized', ...
    'Position', mktdataOpsPanelPosition,...
    'FontSize', ui_panelFontSize, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%mktdataPlot
mktdataPlotPanelX = middleBlockX;
mktdataPlotPanelW = ui_middleBlockW;
mktdataPlotPanelY = ui_panel2BottomFrame;
mktdataPlotPanelH = middlePanel3H;
mktdataPlotPanelPosition = [mktdataPlotPanelX mktdataPlotPanelY mktdataPlotPanelW mktdataPlotPanelH];
handles.mktdataplot.panelbox = uipanel('Parent', frame, 'Title', 'Market Data Plot', ...
    'Units', 'Normalized', ...
    'Position', mktdataPlotPanelPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%%
%the RIGHT block
%4 panels, which are 'positions','manualops','entrusts' and 'status from
%the top to bottom on the MIDDLE block
ui_statusbarPanelH = ui.statusbarPanelH;
ui_rightPanel1H = ui_middlePanel1H;
ui_rightPanel2H = ui_middlePanel2H;
rightPanel3H = 1-ui_rightPanel1H-ui_rightPanel2H-ui_panel2TopFrame-ui_panel2BottomFrame-...
    3*ui_panel2panelH-ui_statusbarPanelH;
%
%position
positionPanelX = rightBlockX;
positionPanelH = ui_rightPanel1H;
positionPanelY = 1 - positionPanelH- ui_panel2TopFrame;
positionPanelW = rightBlockW;
positionPanelPosition = [positionPanelX positionPanelY positionPanelW positionPanelH];
handles.positions.panelbox = uipanel('Parent', frame, 'Title', 'Positions', ...
    'Units', 'Normalized', ...
    'Position',positionPanelPosition , ...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%manualops
manualOpsPanelX = rightBlockX;
manualOpsPanelW = rightBlockW;
manualOpsPanelH = ui_middlePanel2H;
manualOpsPanelY = mktdataOpsPanelY;
manualOpsPanelPosition = [manualOpsPanelX manualOpsPanelY manualOpsPanelW manualOpsPanelH];
handles.manualops.panelbox = uipanel('Parent', frame, 'Title', 'Manual Operations', ...
    'Units', 'Normalized', ...
    'Position', manualOpsPanelPosition, ...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%entrusts
entrustsPanelX = rightBlockX;
entrustsPanelW = rightBlockW;
entrustsPanelY = mktdataPlotPanelY+ui_statusbarPanelH+ui_panel2panelV;
entrustsPanelH = rightPanel3H;
entrustsPanelPosition = [entrustsPanelX entrustsPanelY entrustsPanelW entrustsPanelH];
handles.entrusts.panelbox = uipanel('Parent', frame, 'Title', 'Entrusts', ...
    'Units', 'Normalized', ...
    'Position',entrustsPanelPosition,...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%status bar
statusbarPanelY = mktdataPlotPanelY;
statusbarPanelX = rightBlockX;
statusbarPanelWidth = rightBlockW;
statusbarPanelPosition = [statusbarPanelX statusbarPanelY statusbarPanelWidth ui_statusbarPanelH];
handles.statusbar.panelbox = uipanel('Parent', frame, 'Title', 'status', ...
    'Units', 'Normalized', ...
    'Position', statusbarPanelPosition, ...
    'FontSize', ui_panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
end
