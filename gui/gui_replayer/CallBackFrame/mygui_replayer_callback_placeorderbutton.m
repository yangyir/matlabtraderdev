function mygui_replayer_callback_placeorderbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global STRAT_INSTANCE;
    
    ctpcodelist = get(handles.manualops.instrument_popupmenu,'string');
    ctpcodeidx = get(handles.manualops.instrument_popupmenu,'value');
    ctpcode = ctpcodelist{ctpcodeidx};
    %
    directionlist = get(handles.manualops.direction_popupmenu,'string');
    directionidx = get(handles.manualops.direction_popupmenu,'value');
    direction = directionlist{directionidx};
    %
    offsetlist = get(handles.manualops.offset_popupmenu,'string');
    offsetidx = get(handles.manualops.offset_popupmenu,'value');
    offset = offsetlist{offsetidx};
    %
    price = str2double(get(handles.manualops.price_edit,'string'));
    %
    volume = str2double(get(handles.manualops.volume_edit,'string'));
    %
    ordertypelist = get(handles.manualops.ordertype_popupmenu,'string');
    ordertypeidx = get(handles.manualops.ordertype_popupmenu,'value');
    ordertype = ordertypelist{ordertypeidx};
    
    ret = 0;
    if strcmpi(ordertype,'normal')
        if strcmpi(direction,'buy')
            if strcmpi(offset,'open')
                ret = STRAT_INSTANCE.longopen(ctpcode,volume,'overrideprice',price);    
            elseif strcmpi(offset,'close') 
                ret = STRAT_INSTANCE.longclose(ctpcode,volume,0,'overrideprice',price);
            elseif strcmpi(offset,'closetoday')
                ret = STRAT_INSTANCE.longclose(ctpcode,volume,1,'overrideprice',price);
            end
        elseif strcmpi(direction,'sell')
            if strcmpi(offset,'open')
                ret = STRAT_INSTANCE.shortopen(ctpcode,volume,'overrideprice',price);
            elseif strcmpi(offset,'close') 
                ret = STRAT_INSTANCE.shortclose(ctpcode,volume,0,'overrideprice',price);
            elseif strcmpi(offset,'closetoday')
                ret = STRAT_INSTANCE.shortclose(ctpcode,volume,1,'overrideprice',price);
            end
        end
        if ret == 0
            statusstr = 'entrust failed to be placed...';
            set(handles.statusbar.statustext,'string',statusstr);
        end
    elseif strcmpi(ordertype,'conditional')
        statusstr = 'warning:conditional order not implemented yet...';
        set(handles.statusbar.statustext,'string',statusstr);
    end
    
%     statusstr = 'status:market data engine stopped...';
%     set(handles.statusbar.statustext,'string',statusstr);
end