function guicallback_cancelorderbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global STRAT_INSTANCE;
    
    ctpcodelist = get(handles.manualops.instrument_popupmenu,'string');
    ctpcodeidx = get(handles.manualops.instrument_popupmenu,'value');
    ctpcode = ctpcodelist{ctpcodeidx};
    
    STRAT_INSTANCE.withdrawentrusts(ctpcode);
    
%     statusstr = 'status:market data engine stopped...';
%     set(handles.statusbar.statustext,'string',statusstr);
end