function mygui_callback_getquote( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);
    
    global MDEFUT_INSTANCE;
    
    ctpcode_list = get(handles.instruments.table,'RowName');
    
    n = size(ctpcode_list,1);
    
    quote_data = cell(n,7);
    
    while ~strcmpi(MDEFUT_INSTANCE.status_,'sleep')
        for i = 1:n
            quote_i = MDEFUT_INSTANCE.qms_.getquote(ctpcode_list{i});
            quote_data{i,1} = num2str(quote_i.bid_size1);
            quote_data{i,2} = num2str(quote_i.bid1);
            quote_data{i,3} = num2str(quote_i.ask1);
            quote_data{i,4} = num2str(quote_i.ask_size1);
            quote_data{i,5} = datestr(quote_i.update_time1,'HH:MM:SS');
        end
        
        set(handles.instruments.table,'Data',quote_data);
        
        pause(1);
    end
    
end