function [ handles,mdefut,strat,ops ] = guientry_rp_manual
    %
    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;
    
    handles = guiframework_rp_manual;
    
    mdefut = cMDEFut;
    MDEFUT_INSTANCE = mdefut;
    MDEFUT_INSTANCE.mode_ = 'replay';
    MDEFUT_INSTANCE.gui_ = handles;
    %
    trader = cTrader;
    trader.init('replay_trader');
    book = cBook('BookName','replay_book','TraderName',trader.name_,'CounterName','replay_counter');
    trader.addbook(book);
    ops = cOps('Name','replay_ops');
    ops.registerbook(book);
    ops.registermdefut(mdefut);
    OPS_INSTANCE = ops;
    OPS_INSTANCE.mode_ = 'replay';
    OPS_INSTANCE.gui_ = handles;
    %
    strat = cStratManual;
    STRAT_INSTANCE = strat;
    STRAT_INSTANCE.mode_ = 'replay';
    STRAT_INSTANCE.registermdefut(MDEFUT_INSTANCE);
    STRAT_INSTANCE.registerhelper(OPS_INSTANCE);
    STRAT_INSTANCE.gui_ = handles;
    
    
    set(handles.mktdataops.mdefutInitButton,'CallBack',{@mygui_replayer_callback_mdefutinitbutton, handles});
    set(handles.mktdataops.mdefutStartButton,'CallBack',{@mygui_replayer_callback_mdefutstartbutton, handles});
    set(handles.mktdataops.mdefutStopButton,'CallBack',{@mygui_replayer_callback_mdefutstopbutton, handles});
    set(handles.mktdataops.mdefutPlotButton,'CallBack',{@mygui_replayer_callback_mdefutplotbutton, handles});
    set(handles.manualops.placeorderbutton,'CallBack',{@mygui_replayer_callback_placeorderbutton, handles});
end