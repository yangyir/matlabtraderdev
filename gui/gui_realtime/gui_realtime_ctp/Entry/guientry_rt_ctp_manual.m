function [ handles,mdefut,strat,ops ] = guientry_rt_ctp_manual
    %
    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;
    
    handles = guiframework_rt_ctp_manual;
    
    mdefut = cMDEFut;
    MDEFUT_INSTANCE = mdefut;
    MDEFUT_INSTANCE.mode_ = 'realtime';
    MDEFUT_INSTANCE.gui_ = handles;
    %
    ops = cOps('Name','ops_ctp_manual');
    ops.registermdefut(mdefut);
    OPS_INSTANCE = ops;
    OPS_INSTANCE.mode_ = 'realtime';
    OPS_INSTANCE.gui_ = handles;
    %
    strat = cStratManual;
    STRAT_INSTANCE = strat;
    STRAT_INSTANCE.mode_ = 'realtime';
    STRAT_INSTANCE.registermdefut(MDEFUT_INSTANCE);
%     STRAT_INSTANCE.registerhelper(OPS_INSTANCE);
    STRAT_INSTANCE.gui_ = handles;
    
    
    set(handles.mktdataops.mdefutInitButton,'CallBack',{@guicallback_rt_ctp_mdefutinitbutton, handles});
    set(handles.mktdataops.mdefutStartButton,'CallBack',{@guicallback_mdefutstartbutton, handles});
    set(handles.mktdataops.mdefutStopButton,'CallBack',{@guicallback_mdefutstopbutton, handles});
    set(handles.mktdataops.mdefutPlotButton,'CallBack',{@guicallback_mdefutplotbutton, handles});
    set(handles.manualops.placeorderbutton,'CallBack',{@guicallback_placeorderbutton, handles});
    set(handles.manualops.cancelorderbutton,'CallBack',{@guicallback_cancelorderbutton, handles});
    
end