function handles = mygui_framework_unirisk()
%%
close all;
fgsz = [1, 1, 600, 600];
backcolor  = [1, 0.95, 0.85];
tbbackcolor = [0.8 1 0.8;0.6 1 1];
handles.output = figure('ToolBar', 'none', 'Menubar', 'none',...
    'Color', backcolor,'Position',fgsz);
set(handles.output, 'Name', '资管投研三部联合风控端', 'NumberTitle', 'off');
movegui(handles.output, 'north')
parent = handles.output;

% product
handles.product.panelbox = uipanel('Parent', parent, 'Title', '资产管理产品名称', ...
    'Units', 'Normalized', 'Position', [0.05 0.88 0.15 0.1],'FontSize', 10, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.product.panelbox;
handles.product.popup_counter = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
    'Backgroundcolor', 'k', 'Foregroundcolor', 'w', 'String', {'赢嘉1号','赢嘉2号'}, ...
    'Units', 'Normalized', 'Position', [0.05 0.8 0.9 0.05], 'FontSize', 10);

% risk
handles.risk.panelbox = uipanel('Parent', parent,'Title', '投资比例信息', ...
    'Units', 'Normalized', 'Position', [0.05 0.6 0.45 0.28], 'FontSize', 10, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.risk.panelbox;
handles.risk.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
    'Position', [0.03 0.03 0.9 0.9], 'FontSize' , 10 , ...
    'Data', num2cell(ones(9, 3)*NaN), 'ColumnWidth', num2cell(ones(1,3)*150), 'BackgroundColor', [1 1 1],...
    'RowName',{'定向计划资产总值（元）  ',...
    '衍生品资产占用保证金及权利金总额（元）    ','衍生品资产占用保证金及权利金占比（%）    ',...
    '商品期货合约保证金总额（元）    ','商品期货合约保证金占比（%）    ',...
    '权益类资产总额（元）   ','权益类资产占比（%）   ',...
    '固定收益类资产总额（元）   ','固定收益类资产占比（%）   '},...
     'FontSize' , 10 ,'ColumnName',{'O32','融航','合计'});
 
 % warning
handles.warning.panelbox = uipanel('Parent', parent,'Title', '风险监控信息', ...
    'Units', 'Normalized', 'Position', [0.05 0.35 0.45 0.2], 'FontSize', 10, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.warning.panelbox;
handles.warning.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
    'Position', [0.03 0.03 0.9 0.9], 'FontSize' , 10 , ...
    'Data', num2cell(ones(4, 3)*NaN), 'ColumnWidth', num2cell(ones(1,3)*150), 'BackgroundColor', [1 1 1],...
    'RowName',{'衍生品资产占用保证金及权利金占比（%）    ',...
    '商品期货合约保证金占比（%）    ','权益类资产占比（%）   ','固定收益类资产占比（%）   '},...
     'FontSize' , 10 ,'ColumnName',{'上限（%）','下限（%）','当前状态'});



%operation
handles.operation1.panelbox = uipanel('Parent', parent, 'Title', '', ...
    'Units', 'Normalized', 'Position', [0.05 0.2 0.08 0.05], 'FontSize', 9, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.operation1.panelbox;
handles.operation1.button_futquote   = uicontrol('Parent', panelbox, 'style', 'pushbutton', ...
    'Backgroundcolor', [1 1 1], 'Foregroundcolor', 'g', 'String', '启动监控', ...
    'Units', 'Normalized', 'Position', [0.03 0.06 0.88 0.94], 'FontSize', 9, ...
    'FontWeight', 'bold');

%operation
handles.operation2.panelbox = uipanel('Parent', parent, 'Title', '', ...
    'Units', 'Normalized', 'Position', [0.3 0.2 0.08 0.05], 'FontSize', 9, ...
    'FontWeight', 'bold', 'TitlePosition', 'lefttop');
panelbox = handles.operation2.panelbox;
handles.operation2.button_futquote   = uicontrol('Parent', panelbox, 'style', 'pushbutton', ...
    'Backgroundcolor', [1 1 1], 'Foregroundcolor', 'r', 'String', '暂停监控', ...
    'Units', 'Normalized', 'Position', [0.03 0.06 0.88 0.94], 'FontSize', 9, ...
    'FontWeight', 'bold');


