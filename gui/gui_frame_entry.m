function handles = gui_frame_entry(ui_frame)
    close all;

    handles = gui_frame_init(ui_frame);
    %
    %general setup
    generalsetup_propnames = {'CounterName';'UseHistData';'RiskConfigFile';...
        'StartupFund';'ReplayTimeStart';'ReplayTimeEnd'};
    generalsetup_propvalues = {{'citic_kim_fut','ccb_ly_fut','ccb_yy_fut'};...
        {'yes','no'};{'.txt'};{'1000000'};{'yyyy-mm-dd'};{'yyyy-mm-dd'}};
    handles = gui_frame_generalsetup(handles,ui_frame,generalsetup_propnames,generalsetup_propvalues);
    %
    %trading status
    tradingstatus_propnames = {'PreInterest';'AvailableFund';'CurrentMargin';...
        'FrozenMargin';'RunningPnL';'ClosedPnL';'Time';...
        'StrategyStatus';'MDEStatus';'OpsStatus';
        'StrategyRunning';'MDERunning';'OpsRunning'};
    tradingstatus_values = {'u/a';'u/a';'u/a';...
        'u/a';'u/a';'u/a';datestr(now,'yyyy-mm-dd HH:MM:SS');...
        'sleep...';'sleep...';'sleep...';...
        'off';'off';'off'};
    handles = gui_frame_tradingstatus(handles,ui_frame,tradingstatus_propnames,tradingstatus_values);
    %
    %trading instruments
    handles = gui_frame_instruments(handles,ui_frame);
    %
    %market data
    handles = gui_frame_mktdatatbl(handles,ui_frame);
    %
    %market data ops
    buttonnames = {'Init Market Data Engine';'Start Market Data Engine';'Stop Market Data Engine';'Plot Market Data'};
    buttontags = {'mdefutInitButton';'mdefutStartButton';'mdefutStopButton';'mdefutPlotButton'};
    handles = gui_frame_mktdataops(handles,ui_frame,buttonnames,buttontags);
    %
    %market data plot
    handles = gui_frame_mktdataplot(handles,ui_frame);
    %
    %positions
    handles = gui_frame_positions(handles,ui_frame);
    %
    %manual ops
    handles = gui_frame_manualops(handles,ui_frame);
    %
    %entrusts
    handles = gui_frame_entrusts(handles,ui_frame);
    %
    %status bar
    panelbox = handles.statusbar.panelbox;
    handles.statusbar.statustext = uicontrol('Parent', panelbox, 'style', 'text', ...
        'Foregroundcolor', 'k', 'String', {'status:to be initialized...'}, ...
        'Units', 'Normalized', 'Position', [0.01 0.01 0.98 0.98], 'FontSize', 8, ...
        'FontWeight', 'bold');
end
