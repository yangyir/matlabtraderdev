function handles = mygui_replayer_entry(mdefut)
    global MDEFUT_INSTANCE;
    MDEFUT_INSTANCE = mdefut;
    
    handles = mygui_replayer_framework;
    MDEFUT_INSTANCE.mode_ = 'replay';
    
    set(handles.mdefutButtons.mdefutInitButton,'CallBack',{@mygui_replayer_callback_mdefutinitbutton, handles});
    set(handles.mdefutButtons.mdefutStartButton,'CallBack',{@mygui_replayer_callback_mdefutstartbutton, handles});
    set(handles.mdefutButtons.mdefutStopButton,'CallBack',{@mygui_replayer_callback_mdefutstopbutton, handles});
    set(handles.mdefutButtons.mdefutPlotButton,'CallBack',{@mygui_replayer_callback_mdefutplotbutton, handles});
    
end