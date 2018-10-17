function mygui_replayer_callback_mdefutstopbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    try
        MDEFUT_INSTANCE.stop;
        delete(timerfindall);
    catch
    end
    
    statusstr = 'status:market data engine stopped...';
    set(handles.statusbar.statustext,'string',statusstr);
end