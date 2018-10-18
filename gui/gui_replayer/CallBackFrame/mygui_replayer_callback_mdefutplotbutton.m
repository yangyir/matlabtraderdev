function mygui_replayer_callback_mdefutplotbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);
    handles.mktdataplot.flag = true;
    
    codelist = get(handles.mktdataplot.popupmenu,'string');
    codeidx = get(handles.mktdataplot.popupmenu,'value');
    code2plot = codelist{codeidx};
    
    
    
end