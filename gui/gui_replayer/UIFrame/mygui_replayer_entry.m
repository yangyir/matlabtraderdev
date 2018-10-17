function [ handles,mdefut,strat,ops ] = mygui_replayer_entry
    %
    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;
    
    handles = mygui_replayer_framework;
    
    mdefut = cMDEFut;
    MDEFUT_INSTANCE = mdefut;
    MDEFUT_INSTANCE.mode_ = 'replay';
    MDEFUT_INSTANCE.gui_ = handles;
    %
    strat = cStratManual;
    STRAT_INSTANCE = strat;
    STRAT_INSTANCE.mode_ = 'replay';
    STRAT_INSTANCE.gui_ = handles;
    %
    ops = cOps;
    OPS_INSTANCE = ops;
    OPS_INSTANCE.mode_ = 'replay';
    OPS_INSTANCE.gui_ = handles;
    
    set(handles.mktdataops.mdefutInitButton,'CallBack',{@mygui_replayer_callback_mdefutinitbutton, handles});
    set(handles.mktdataops.mdefutStartButton,'CallBack',{@mygui_replayer_callback_mdefutstartbutton, handles});
    set(handles.mktdataops.mdefutStopButton,'CallBack',{@mygui_replayer_callback_mdefutstopbutton, handles});
    set(handles.mktdataops.mdefutPlotButton,'CallBack',{@mygui_replayer_callback_mdefutplotbutton, handles});
    set(handles.manualops.placeorderbutton,'CallBack',{@mygui_replayer_callback_placeorderbutton, handles});
end