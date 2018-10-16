function handles = mygui_replayer_framework
%%
lastbd = businessdate(getlastbusinessdate,-1);
close all;
fgWidth = 1800;
fgHeight = 1000;
fgsz = [0, 0, fgWidth, fgHeight];
backcolor  = [0.85, 0.85, 0.85];
tbbackcolor = [1 1 0.8;1 1 1];
handles.output = figure('ToolBar', 'none', 'Menubar', 'none',...
    'Color', backcolor,'Position',fgsz);
set(handles.output, 'Name', 'Strategy Replayer', 'NumberTitle', 'off');
movegui(handles.output, 'north')
parent = handles.output;
statusbarPanelH = 0.04;
%%
panel2LeftFrame = 0.01;
panel2RightFrame = 0.01;
panel2TopFrame = 0.02;
panel2BottomFrame = 0.02;
panel2panelH = 0.01;
panel2panelV = 0.01;
panelFontSize = 10;
%
%% general setup
generalsetupPanelW = 0.12;
generalsetupPanelH = 0.2;
generalsetupPanelX = panel2LeftFrame;
generalsetupPanelY = 1-generalsetupPanelH-panel2TopFrame;
handles.generalsetup.panelbox = uipanel('Parent', parent, 'Title', 'General Setup', ...
    'Units', 'Normalized',...
    'Position', [generalsetupPanelX generalsetupPanelY generalsetupPanelW generalsetupPanelH],...
    'FontSize', panelFontSize, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.generalsetup.panelbox;
%note: in the general set up panelbox, we will have 'Static Text' on the
%left hand side and 'Edit Text' and popup-menu on the right hand side
box2LeftPanel = 3*panel2LeftFrame;
box2RightPanel = 3*panel2RightFrame;
box2TopPanel = 2*panel2TopFrame;
box2BottomPanel = 2*panel2BottomFrame;
box2boxH = 4*panel2panelH;
box2boxV = 4*panel2panelV;
boxFontSize = 8;
boxBackGroundColor = [0.8 1 0.8];
textboxNames = {'StartDate';'EndDate';'SampleFreq';'ReplaySpeed';'StrategyName';'RiskConfig'};
textboxCount = size(textboxNames,1);
%
textboxX = box2LeftPanel;
textboxW = (1-box2LeftPanel-box2RightPanel-box2boxH)/2;
textboxH = (1-box2TopPanel-box2BottomPanel-(textboxCount-1)*box2boxV)/textboxCount;

for i = 1:textboxCount
    %on the left hand-side
    textboxname = [lower(textboxNames{i}),'_text'];
    textboxPosY = 1-box2TopPanel-i*textboxH-(i-1)*box2boxV;
    handles.generalsetup.(textboxname) = uicontrol('Parent', panelbox, 'style', 'text', ...
    'Foregroundcolor', 'k','String', textboxNames{i}, 'Units', 'Normalized',... 
    'Position', [textboxX textboxPosY textboxW textboxH],... 
    'FontSize', boxFontSize, ...
    'FontWeight', 'bold');
    %
    if strcmpi(textboxNames{i},'StartDate') || strcmpi(textboxNames{i},'EndDate')
        editboxname = [lower(textboxNames{i}),'_edit'];
        editboxPositionY = textboxPosY;
        editboxPositionX = textboxX + textboxW + box2boxH;
        handles.generalsetup.(editboxname) = uicontrol('Parent', panelbox, 'style', 'edit', ...
            'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {datestr(lastbd,'yyyy-mm-dd')}, ...
            'Units', 'Normalized',...
            'Position', [editboxPositionX editboxPositionY textboxW textboxH], ...
            'FontSize', boxFontSize, ...
            'FontWeight', 'bold');
    end
    %
    if strcmpi(textboxNames{i},'SampleFreq')
        popupmenuname = [lower(textboxNames{i}),'_popupmenu'];
        popupmenuPositionY = textboxPosY;
        popupmenuPositionX = textboxX + textboxW + box2boxH;
        handles.generalsetup.(popupmenuname) = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
            'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'1m','3m','5m','15m','30m','1h'}, ...
            'Units', 'Normalized', 'Position', [popupmenuPositionX popupmenuPositionY textboxW textboxH], 'FontSize', boxFontSize, ...
            'FontWeight', 'bold');
    end
    %
    if strcmpi(textboxNames{i},'StrategyName')
        popupmenuname = [lower(textboxNames{i}),'_popupmenu'];
        popupmenuPositionY = textboxPosY;
        popupmenuPositionX = textboxX + textboxW + box2boxH;
        handles.generalsetup.(popupmenuname) = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
            'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'manual','wlpr','batman','wlprbatman'}, ...
            'Units', 'Normalized', 'Position', [popupmenuPositionX popupmenuPositionY textboxW textboxH], 'FontSize', boxFontSize, ...
            'FontWeight', 'bold');
    end
    %
    if strcmpi(textboxNames{i},'ReplaySpeed')
        popupmenuname = [lower(textboxNames{i}),'_popupmenu'];
        popupmenuPositionY = textboxPosY;
        popupmenuPositionX = textboxX + textboxW + box2boxH;
        handles.generalsetup.(popupmenuname) = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
            'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'1','5','10','20','50'}, ...
            'Units', 'Normalized', 'Position', [popupmenuPositionX popupmenuPositionY textboxW textboxH], 'FontSize', boxFontSize, ...
            'FontWeight', 'bold');
    end
    %
    if strcmpi(textboxNames{i},'RiskConfig')
        editboxname = [lower(textboxNames{i}),'_edit'];
        editboxPositionY = textboxPosY;
        editboxPositionX = textboxX + textboxW + box2boxH;
        handles.generalsetup.(editboxname) = uicontrol('Parent', panelbox, 'style', 'edit', ...
            'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'RiskConfig.txt'}, ...
            'Units', 'Normalized',...
            'Position', [editboxPositionX editboxPositionY textboxW textboxH], ...
            'FontSize', boxFontSize, ...
            'FontWeight', 'bold');
    end
end

%% instruments
instrumentPanelX = panel2LeftFrame;
instrumentPanelW = generalsetupPanelW;
instrumentPanelY = panel2BottomFrame;
instrumentPanelH = generalsetupPanelY-instrumentPanelY-panel2panelV;
handles.instruments.panelbox = uipanel('Parent', parent, 'Title', 'Instruments', ...
    'Units', 'Normalized', ...
    'Position', [instrumentPanelX instrumentPanelY instrumentPanelW instrumentPanelH],...
    'FontSize', panelFontSize, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.instruments.panelbox;
instrumentList = {'CSI300';'SSE50';'CSI500';'GovtBond5y';'GovtBond10y';...
    'Gold';'Silver';...
    'Copper';'Aluminum';'Zinc';'Lead';'Nickel';...
    'Crude';'PTA';'LLDPE';'PP';'Methanol';......
    'Rebar';'IronOre';
    'Soymeal';'Sugar';'Corn';'Rubber';'Apple'};
ninstruments = size(instrumentList,1);
%all the check boxes in total will take 90% of the pannel'height and it is 60% wide as of the pannel's width 
checkboxWidth = 0.6;
checkboxX = 0.05;
checkboxH = 0.9*(1/(ninstruments+1));
checkbox2checkboxV = (1-checkboxH*ninstruments)/(ninstruments+1);
checkboxFontSize = 8;
for i = 1:ninstruments
    checkboxname = [instrumentList{i},'_checkbox'];
    checkboxPosY = 1-(checkbox2checkboxV*i+checkboxH*i);
    handles.instruments.(checkboxname) = uicontrol('Parent', panelbox, 'style', 'checkbox', ...
    'Foregroundcolor', 'k', 'String', instrumentList{i}, ...
    'Units', 'Normalized', ...
    'Position', [checkboxX checkboxPosY checkboxWidth checkboxH], ...
    'FontSize', checkboxFontSize, ...
    'FontWeight', 'bold');
end
%% mktdatatbl
mktdataTblPanelX = generalsetupPanelX + generalsetupPanelW + panel2panelH;
mktdataTblPanelW = 0.43;
mktdataTblPanelH = 0.4;
mktdataTblPanelY = 1-panel2TopFrame-mktdataTblPanelH;
handles.mktdatatbl.panelbox = uipanel('Parent', parent, 'Title', 'Market Data', ...
    'Units', 'Normalized', ...
    'Position', [mktdataTblPanelX mktdataTblPanelY mktdataTblPanelW mktdataTblPanelH],...
    'FontSize', 10, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.mktdatatbl.panelbox;

activefuts = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'activefutures\activefutures_',datestr(lastbd,'yyyymmdd'),'.txt']);
nfuts = size(activefuts,1);
%table will centred with 1.5% distance 2 each side of the panel
positionTblX = 0.015;
mktdataTblW = 1-2*positionTblX;
mktdataTblH = 1-2*positionTblX;
mktdataTblY = (1-mktdataTblH)/2;

columnnames = {'last trade','bid','ask','update time','last close','change','wlhigh','wllow'};
handles.mktdatatbl.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
    'Position', [positionTblX mktdataTblY mktdataTblW mktdataTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
    'Data', num2cell(ones(nfuts, length(columnnames))*NaN), 'ColumnWidth', num2cell(ones(1,5)*80), 'BackgroundColor', tbbackcolor,...
    'RowName',activefuts,...
    'ColumnName',columnnames);

%% mktdataops
mktdataOpsPanelX = mktdataTblPanelX;
mktdataOpsPanelW = mktdataTblPanelW;
mktdataOpsPanelH = 0.08;
mktdataOpsPanelY = mktdataTblPanelY - mktdataOpsPanelH-panel2panelV;
handles.mktdataops.panelbox = uipanel('Parent', parent, 'Title', 'Market Data Operations', ...
    'Units', 'Normalized', ...
    'Position', [mktdataOpsPanelX mktdataOpsPanelY mktdataOpsPanelW mktdataOpsPanelH],...
    'FontSize', panelFontSize, 'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.mktdataops.panelbox;
%
buttonNames = {'Init Market Data Engine';'Start Market Data Engine';'Stop Market Data Engine';'Plot Market Data'};
buttonTags = {'mdefutInitButton';'mdefutStartButton';'mdefutStopButton';'mdefutPlotButton'};
% buttons are 60% height of the panel centre in the middle and 80% width
nButtons = size(buttonNames,1);
buttonH = 0.6;
button2buttonH = (1-0.8)/(nButtons+1);
buttonW = 0.8/nButtons;
buttonY = (1-buttonH)/2;
buttonFontSize = 8;
for i = 1:nButtons  
    buttonX_i = i*button2buttonH + (i-1)*buttonW;
    handles.mktdataops.(buttonTags{i})   = uicontrol('Parent', panelbox, 'style', 'pushbutton', ...
        'Backgroundcolor', 'k', 'Foregroundcolor', 'r', 'String', buttonNames{i}, ...
        'Units', 'Normalized', ...
        'Position', [buttonX_i buttonY buttonW buttonH], 'FontSize', buttonFontSize, ...
        'FontWeight', 'bold');
end

%% mktdataplot
mktdataPlotPanelX = mktdataTblPanelX;
mktdataPlotPanelW = mktdataTblPanelW;
mktdataPlotPanelY = panel2BottomFrame;
mktdataPlotPanelH = mktdataOpsPanelY - mktdataPlotPanelY-panel2panelV;
handles.mktdataplot.panelbox = uipanel('Parent', parent, 'Title', 'Market Data Plot', ...
    'Units', 'Normalized', ...
    'Position', [mktdataPlotPanelX mktdataPlotPanelY mktdataPlotPanelW mktdataPlotPanelH],...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.mktdataplot.panelbox;
%the plot ara will be 85% height of the panel and 3% from left and right
mktdataPlotAxesX = 0.03;
mktdataPlotAxesW = 1-2*mktdataPlotAxesX;
mktdataPlotAxesH = 0.85;
mktdataPlotAxesY = (1-mktdataPlotAxesH)/2;
handles.mktdataplot.axes  = axes('Parent', panelbox, 'Units', 'Normalized', ...
    'Position', [mktdataPlotAxesX mktdataPlotAxesY mktdataPlotAxesW mktdataPlotAxesH], ...
    'FontSize', 8, 'FontWeight', 'bold');
% popup menu
mktdataPlotPopupmenuX = mktdataPlotAxesX;
mktdataPlotPopupmenuW = 0.15;
mktdataPlotPopupmenuH = 0.9*(1-mktdataPlotAxesH-mktdataPlotAxesY);
mktdataPlotPopupmenuY = mktdataPlotAxesH + mktdataPlotAxesY;
handles.mktdataplot.popupmenu  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
    'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', activefuts, 'Units', 'Normalized', ...
            'Position', [mktdataPlotPopupmenuX mktdataPlotPopupmenuY mktdataPlotPopupmenuW mktdataPlotPopupmenuH], 'FontSize', 8, ...
            'FontWeight', 'bold');

%% positions
positionPanelX = mktdataOpsPanelX + mktdataTblPanelW + panel2panelH;
positionPanelH = mktdataTblPanelH;
positionPanelY = 1 - positionPanelH- panel2TopFrame;
positionPanelW = 1 - positionPanelX - panel2RightFrame;
handles.positions.panelbox = uipanel('Parent', parent, 'Title', 'Positions', ...
    'Units', 'Normalized', ...
    'Position', [positionPanelX positionPanelY positionPanelW positionPanelH], ...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.positions.panelbox;
positionTblX = 0.015;
positionTblW = 1-2*positionTblX;
positionTblH = 1-2*positionTblX;
entrustTblY = (1-positionTblH)/2;

columnnames = {'direction','volume total','volume today','avg.open price','running pnl','close pnl'};
handles.positions.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
    'Position', [positionTblX entrustTblY positionTblW positionTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
    'Data', num2cell(zeros(nfuts, length(columnnames))), 'ColumnWidth', num2cell(ones(1,5)*100), 'BackgroundColor', tbbackcolor,...
    'RowName',activefuts,...
    'ColumnName',columnnames);


%% manualops
manualOpsPanelX = positionPanelX;
manualOpsPanelW = positionPanelW;
manualOpsPanelH = mktdataOpsPanelH;
manualOpsPanelY = mktdataOpsPanelY;
handles.manualops.panelbox = uipanel('Parent', parent, 'Title', 'Manual Operations', ...
    'Units', 'Normalized', ...
    'Position', [manualOpsPanelX manualOpsPanelY manualOpsPanelW manualOpsPanelH], ...
    'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.manualops.panelbox;
fields = {'instrument';'direction';'offset';'price';'volume';'ordertype';'condprice'};
nfields = size(fields,1);
fieldboxW = 0.8/nfields;
field2fieldH = 0.05/(nfields+1);
field2fieldV = 0.02;
fieldboxH = 0.38;
fieldLabelH = 0.25;
fieldboxY = (1-fieldboxH-fieldLabelH)/3;
for i = 1:nfields;
    fieldboxX_i = i*field2fieldH+(i-1)*fieldboxW;
    fieldboxY_i = fieldboxY + fieldboxH + field2fieldV;
    
    handles.manualops.(fields{i})  = uicontrol('Parent', panelbox, 'style', 'text', ...
         'Foregroundcolor', 'k', 'String', fields{i}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY_i fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');       
    %   
    if strcmpi(fields{i},'instrument')
        propname = [fields{i},'_popupmenu'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', activefuts, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    elseif strcmpi(fields{i},'direction')
        propname = [fields{i},'_popupmenu'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'buy','sell'}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    elseif strcmpi(fields{i},'offset')
        propname = [fields{i},'_popupmenu'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'open','close'}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    elseif strcmpi(fields{i},'price')
        propname = [fields{i},'_edit'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'edit', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'-1'}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    elseif strcmpi(fields{i},'volume')
        propname = [fields{i},'_edit'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'edit', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'1'}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    elseif strcmpi(fields{i},'ordertype')
        propname = [fields{i},'_popupmenu'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'normal','conditional'}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    elseif strcmpi(fields{i},'condprice')
        propname = [fields{i},'_edit'];
        handles.manualops.(propname)  = uicontrol('Parent', panelbox, 'style', 'edit', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'-1'}, 'Units', 'Normalized', ...
                'Position', [fieldboxX_i fieldboxY fieldboxW fieldboxH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    else
        error('internal error')
    end

end

buttonW = 0.15*0.9;
buttonH = 0.6;
buttonX = 0.86;
buttonY = (1-buttonH)/2;
handles.manualops.pushbutton  = uicontrol('Parent', panelbox, 'style', 'pushbutton', ...
        'Backgroundcolor', 'k', 'Foregroundcolor', 'r', 'String', {'Place Order'}, 'Units', 'Normalized', ...
                'Position', [buttonX buttonY buttonW buttonH], 'FontSize', 8, ...
                'FontWeight', 'bold');

%% entrusts
entrustsPanelX = positionPanelX;
entrustsPanelW = positionPanelW;
entrustsPanelY = mktdataPlotPanelY+statusbarPanelH+panel2panelV;
entrustsPanelH = manualOpsPanelY - entrustsPanelY-panel2panelV;

handles.entrusts.panelbox = uipanel('Parent', parent, 'Title', 'Entrusts', ...
    'Units', 'Normalized', ...
    'Position', [entrustsPanelX entrustsPanelY entrustsPanelW entrustsPanelH], 'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');

panelbox = handles.entrusts.panelbox;
%

entrustTblX = 0.015;
entrustTblW = 1-2*entrustTblX;
entrustTblH = 0.9;
entrustTblY = 0.01;

columnnames = {'id','instrument','direction',...
        'offset','status','price','volume','dealvolume','dealtime'};
handles.entrusts.table = uitable('Parent', panelbox, 'Units', 'Normalized', ...
    'Position', [entrustTblX entrustTblY entrustTblW entrustTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
    'Data', num2cell(zeros(nfuts, length(columnnames))), 'ColumnWidth', num2cell(ones(1,5)*100), 'BackgroundColor', tbbackcolor,...
    'ColumnName',columnnames);
%
entrustPopupmenuX = entrustTblX;
entrustPopupmenuW = 0.15;
entrustPopupmenuH = 1-entrustTblH-entrustTblY-2*0.01;
entrustPopupmenuY = entrustTblH + 2*entrustTblY;
handles.entrusts.popupmenu  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'all','pending','finished'}, 'Units', 'Normalized', ...
                'Position', [entrustPopupmenuX entrustPopupmenuY entrustPopupmenuW entrustPopupmenuH], 'FontSize', 8, ...
                'FontWeight', 'bold');

        
%% status bar
statusbarPanelY = mktdataPlotPanelY;
statusbarPanelX = positionPanelX;
statusbarPanelWidth = positionPanelW;
handles.statusbar.panelbox = uipanel('Parent', parent, 'Title', 'status', ...
    'Units', 'Normalized', ...
    'Position', [statusbarPanelX statusbarPanelY statusbarPanelWidth statusbarPanelH], 'FontSize', panelFontSize, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.statusbar.panelbox;
handles.statusbar.statustext = uicontrol('Parent', panelbox, 'style', 'text', ...
    'Foregroundcolor', 'k', 'String', {'status:to be initialized...'}, ...
    'Units', 'Normalized', 'Position', [0.01 0.01 0.98 0.98], 'FontSize', 8, ...
    'FontWeight', 'bold');
end