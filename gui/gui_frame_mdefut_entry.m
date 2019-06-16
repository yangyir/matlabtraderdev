function handles = gui_frame_mdefut_entry(ui)
    close all;
    
    handles = gui_frame_md_init(ui);
    %
    %generalsetup
    generalsetup_propnames = {'CounterName';'RiskConfigFile';...
        'Mode';'ReplayTimeStart';'ReplayTimeEnd'};
    generalsetup_propvalues = {{'ccb_ly_fut','ccb_yy_fut','citic_kim_fut'};...
        {'config_gui_mdefut_config1.txt'};{'realtime';'replay'};{'yyyy-mm-dd'};{'yyyy-mm-dd'}};
    handles = gui_frame_generalsetup(handles,ui,generalsetup_propnames,generalsetup_propvalues);
    %
    %mktdataops
    buttonnames = {'init';'run';'stop'};
    buttontags = {'mdefutInitButton';'mdefutStartButton';'mdefutStopButton'};
    handles = gui_frame_mktdataops(handles,ui,buttonnames,buttontags);
    %
    %mktdatatbl
    handles = gui_frame_mktdatatbl(handles,ui);
    %
    %mktdataplot
    handles = gui_frame_mktdataplot(handles,ui);
end