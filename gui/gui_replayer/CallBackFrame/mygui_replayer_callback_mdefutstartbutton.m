function mygui_replayer_callback_mdefutstartbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    try
        delete(timerfindall);
    catch
    end
    
    MDEFUT_INSTANCE.start;
    
    statusstr = 'status:market data engine is running...';
    set(handles.statusbar.statustext,'string',statusstr);
    
end