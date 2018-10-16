function mygui_replayer_callback_mdefutstopbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    try
        delete(timerfindall);
    catch
    end
    
    MDEFUT_INSTANCE.stop;
    
    statusstr = 'status:market data engine stopped...';
    set(handles.statusbar.statustext,'string',statusstr);
end