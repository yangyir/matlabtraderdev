function guicallback_mdefutstopbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    try
        MDEFUT_INSTANCE.stop;
        delete(timerfindall);
    catch
    end
    
    statusstr = 'market data engine stopped...';
    set(handles.statusbar.statustext,'string',statusstr);
end