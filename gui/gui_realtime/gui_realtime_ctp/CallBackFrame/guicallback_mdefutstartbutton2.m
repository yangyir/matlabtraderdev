function guicallback_mdefutstartbutton2( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    try
        delete(timerfindall);
    catch
    end
    
    if strcmpi(MDEFUT_INSTANCE.mode_,'realtime')
            counterlist = get(handles.generalsetup.countername_popupmenu,'string');
            counteridx = get(handles.generalsetup.countername_popupmenu,'value');
            countername = counterlist{counteridx};
        if ~MDEFUT_INSTANCE.qms_.isconnect
            MDEFUT_INSTANCE.login('Connection','CTP','CounterName',countername);
        end
    end
    
    MDEFUT_INSTANCE.printflag_ = false;
        
    MDEFUT_INSTANCE.start;
        
%     statusstr = 'market data engine is running...';
%     set(handles.statusbar.statustext,'string',statusstr);
    
end