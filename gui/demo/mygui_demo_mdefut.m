function handles = mygui_demo_mdefut(mdefut)
    global MDEFUT_INSTANCE;
    MDEFUT_INSTANCE = mdefut;
    
    handles = mygui_framework_mdefut;
    
    idx = get(handles.counter.popup_counter,'value');
    strings = get(handles.counter.popup_counter,'string');
    countername = strings{idx};
    
    MDEFUT_INSTANCE.login('Connection','CTP','CounterName',countername);
    
    MDEFUT_INSTANCE.fileioflag_ = false;
    
    MDEFUT_INSTANCE.printflag_ = false;
        
    table_fut = handles.instruments.table;
    
    codectp_list = get(table_fut,'RowName');
    
    for i = 1:size(codectp_list,1)
        MDEFUT_INSTANCE.registerinstrument(codectp_list{i});
    end
    
    try
        delete(timerfindall);
    catch
    end
    
    MDEFUT_INSTANCE.start;
    
    set(handles.operation.button_futquote,'CallBack',{@mygui_callback_getquote, handles});
end