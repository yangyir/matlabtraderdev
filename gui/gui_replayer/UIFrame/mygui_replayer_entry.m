function handles = mygui_replayer_entry(mdefut)
    global MDEFUT_INSTANCE;
    MDEFUT_INSTANCE = mdefut;
    
    handles = mygui_replayer_framework;
    MDEFUT_INSTANCE.mode_ = 'replay';
    
    set(handles.mktdataops.mdefutInitButton,'CallBack',{@mygui_replayer_callback_mdefutinitbutton, handles});
    set(handles.mktdataops.mdefutStartButton,'CallBack',{@mygui_replayer_callback_mdefutstartbutton, handles});
    set(handles.mktdataops.mdefutStopButton,'CallBack',{@mygui_replayer_callback_mdefutstopbutton, handles});
    set(handles.mktdataops.mdefutPlotButton,'CallBack',{@mygui_replayer_callback_mdefutplotbutton, handles});
    
end