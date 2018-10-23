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
guiW = 1800;
guiH = 1000;
guiX = 0;
guiY = 0;
guiColor = [0.85 0.85 0.85];
guiToolBar = 'none';
guiMenuBar = 'none';
guiName = 'CTP Realtime Trading';
guiNumberTitle = 'off';
%
guiPosition = [guiX guiY guiW guiH];
frame = figure('Name',guiName,...
    'Position',guiPosition,...
    'Color',guiColor,...
    'ToolBar',guiToolBar,...
    'MenuBar',guiMenuBar,...
    'NumberTitle',guiNumberTitle);
movegui(frame, 'north');
%%
panel2LeftFrame = 0.01;     %userinput
panel2RightFrame = 0.01;    %userinput
panel2TopFrame = 0.02;      %userinput
panel2BottomFrame = 0.02;   %userinput
panel2panelH = 0.01;        %userinput
panel2panelV = 0.01;        %userinput
panelFontSize = 9;          %userinput
%%
%the LEFT block
leftBlockX = panel2LeftFrame;
leftBlockW = 0.11;          %userinput
%the general setup
generalsetupPanelH = 0.2;
generalsetupPanelW = leftBlockW;
generalsetupPanelX = leftBlockX;
generalsetupPanelY = 1 - panel2TopFrame - generalsetupPanelH;
generalsetupPosition = [generalsetupPanelX generalsetupPanelY generalsetupPanelW generalsetupPanelH];
generalsetup.panelbox = uipanel('Parent', frame, ...
    'Title', 'General Setup', ...
    'Units', 'Normalized',...
    'Position', generalsetupPosition,...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');
%
%the trading status
tradingstatsPanelH = 0.2;   %userinput
tradingstatsPanelX = leftBlockX;
tradingstatsPanelW = leftBlockW;
tradingstatsPanelY = generalsetupPanelY - panel2panelV - tradingstatsPanelH;
tradingstatsPanelPosition = [tradingstatsPanelX tradingstatsPanelY tradingstatsPanelW tradingstatsPanelH];
tradingstats.panelbox = uipanel('Parent', frame, 'Title', 'TradingStats', ...
    'Units', 'Normalized', ...
    'Position', tradingstatsPanelPosition,...
    'FontSize', panelFontSize,... 
    'FontWeight', 'bold',...
    'TitlePosition', 'lefttop');
%
instrumentPanelX = leftBlockX;
instrumentPanelW = leftBlockW;
instrumentPanelY = panel2BottomFrame;
instrumentPanelH = tradingstatsPanelY - instrumentPanelY - panel2panelV;
instrumentPanelPosition = [instrumentPanelX instrumentPanelY instrumentPanelW instrumentPanelH];
instruments.panelbox = uipanel('Parent', frame, 'Title', 'Instruments', ...
    'Units', 'Normalized', ...
    'Position', instrumentPanelPosition,...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', ...
    'TitlePosition', 'lefttop');
%%
%the MIDDLE block
middleBlockX = leftBlockX + leftBlockW + panel2panelH;
middleBlockW = 0.43;    %userinput
%market data table
mktdataTblPanelH = 0.4; %userinput
mktdataTblPanelW = middleBlockW;
mktdataTblPanelX = middleBlockX;
mktdataTblPanelY = 1-panel2TopFrame-mktdataTblPanelH;
mktdataTblPanelPosition = [mktdataTblPanelX mktdataTblPanelY mktdataTblPanelW mktdataTblPanelH];
mktdatatbl.panelbox = uipanel('Parent', frame, 'Title', 'Market Data', ...
    'Units', 'Normalized', ...
    'Position', mktdataTblPanelPosition,...
    'FontSize', 10, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%market data operations
mktdataOpsPanelX = middleBlockX;
mktdataOpsPanelW = middleBlockW;
mktdataOpsPanelH = 0.08;    %userinput
mktdataOpsPanelY = mktdataTblPanelY - mktdataOpsPanelH-panel2panelV;
mktdataOpsPanelPosition = [mktdataOpsPanelX mktdataOpsPanelY mktdataOpsPanelW mktdataOpsPanelH];
mktdataops.panelbox = uipanel('Parent', frame, 'Title', 'Market Data Operations', ...
    'Units', 'Normalized', ...
    'Position', mktdataOpsPanelPosition,...
    'FontSize', panelFontSize, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%mktdataPlot
mktdataPlotPanelX = middleBlockX;
mktdataPlotPanelW = middleBlockW;
mktdataPlotPanelY = panel2BottomFrame;
mktdataPlotPanelH = mktdataOpsPanelY - mktdataPlotPanelY-panel2panelV;
mktdataPlotPanelPosition = [mktdataPlotPanelX mktdataPlotPanelY mktdataPlotPanelW mktdataPlotPanelH];
mktdataplot.panelbox = uipanel('Parent', frame, 'Title', 'Market Data Plot', ...
    'Units', 'Normalized', ...
    'Position', mktdataPlotPanelPosition,...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%%
%the RIGHT block
statusbarPanelH = 0.04;
rightBlockX = middleBlockX + middleBlockW + panel2panelH;
rightBlockW = 1 - panel2RightFrame - rightBlockX;
%
%position
positionPanelX = rightBlockX;
positionPanelH = mktdataTblPanelH;
positionPanelY = 1 - positionPanelH- panel2TopFrame;
positionPanelW = rightBlockW;
positionPanelPosition = [positionPanelX positionPanelY positionPanelW positionPanelH];
positions.panelbox = uipanel('Parent', frame, 'Title', 'Positions', ...
    'Units', 'Normalized', ...
    'Position',positionPanelPosition , ...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%manualops
manualOpsPanelX = rightBlockX;
manualOpsPanelW = rightBlockW;
manualOpsPanelH = mktdataOpsPanelH;
manualOpsPanelY = mktdataOpsPanelY;
manualOpsPanelPosition = [manualOpsPanelX manualOpsPanelY manualOpsPanelW manualOpsPanelH];
manualops.panelbox = uipanel('Parent', frame, 'Title', 'Manual Operations', ...
    'Units', 'Normalized', ...
    'Position', manualOpsPanelPosition, ...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%entrusts
entrustsPanelX = rightBlockX;
entrustsPanelW = rightBlockW;
entrustsPanelY = mktdataPlotPanelY+statusbarPanelH+panel2panelV;
entrustsPanelH = manualOpsPanelY - entrustsPanelY-panel2panelV;
entrustsPanelPosition = [entrustsPanelX entrustsPanelY entrustsPanelW entrustsPanelH];
entrusts.panelbox = uipanel('Parent', frame, 'Title', 'Entrusts', ...
    'Units', 'Normalized', ...
    'Position',entrustsPanelPosition,...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
%
%status bar
statusbarPanelY = mktdataPlotPanelY;
statusbarPanelX = rightBlockX;
statusbarPanelWidth = rightBlockW;
statusbarPanelPosition = [statusbarPanelX statusbarPanelY statusbarPanelWidth statusbarPanelH];
statusbar.panelbox = uipanel('Parent', frame, 'Title', 'status', ...
    'Units', 'Normalized', ...
    'Position', statusbarPanelPosition, ...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
