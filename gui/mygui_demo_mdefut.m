function handles = mygui_demo_mdefut(mdefut)
    global MDEFUT_INSTANCE;
    MDEFUT_INSTANCE = mdefut;
    
    handles = mygui_framework_mdefut;
    
    table_fut = handles.instruments.table;
    
    codectp_list = get(table_fut,'RowName');
    
    for i = 1:size(codectp_list,1)
        MDEFUT_INSTANCE.registerinstrument(codectp_list{i});
    end
    
    set(handles.instruments.table
end