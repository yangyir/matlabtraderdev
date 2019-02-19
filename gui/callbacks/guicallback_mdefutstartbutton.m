function guicallback_mdefutstartbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    global OPS_INSTANCE;
    global STRAT_INSTANCE;
    
    try
        delete(timerfindall);
    catch
    end
    
    if strcmpi(MDEFUT_INSTANCE.mode_,'realtime')
        if ~MDEFUT_INSTANCE.qms_.isconnect
            MDEFUT_INSTANCE.login('Connection','CTP','CounterName','citic_kim_fut');
        end
    end
    
    MDEFUT_INSTANCE.start;
    OPS_INSTANCE.start;
    STRAT_INSTANCE.start;
    
    statusstr = 'market data engine is running...';
    set(handles.statusbar.statustext,'string',statusstr);
    
end