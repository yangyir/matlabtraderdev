function mygui_replayer_callback_mdefutstartbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    replayspeedcell = get(handles.generalsetup.ReplaySpeed_PopupMenu,'string');
    idx = get(handles.generalsetup.ReplaySpeed_PopupMenu,'value');
    replayspeedval = str2double(replayspeedcell{idx});
    
    tblRowName = get(handles.mdefut.table,'RowName');
    tblColName = get(handles.mdefut.table,'ColumnName');
    
    %column name: last trade, bid, ask, update time, last
    %close,change,wlhigh,wllow
    n = size(tblRowName,1);
    ncol = length(tblColName);
    data = cell(n,ncol);
    
    lastClose = zeros(n,1);
    lastHH = zeros(n,1);
    lastLL = zeros(n,1);
    for i = 1:n
        histcandles = MDEFUT_INSTANCE.gethistcandles(tblRowName{i});
        lastClose(i) = histcandles{1}(end,5);
        lastHH(i) = max(histcandles{1}(end-143:end,3));
        lastLL(i) = min(histcandles{1}(end-143:end,4));
    end
    
    try
        delete(timerfindall);
    catch
    end
    
    MDEFUT_INSTANCE.start;
    
    while ~strcmpi(MDEFUT_INSTANCE.status_,'sleep')
        for i = 1:n
            lasttick = MDEFUT_INSTANCE.getlasttick(tblRowName{i});
            if isempty(lasttick)
                data{i,1} = 'nan';
                data{i,2} = data{i,1};
                data{i,3} = data{i,1};
                data{i,4} = 'nan';
                data{i,5} = num2str(lastClose(i));
                data{i,6} = 'nan';
                data{i,7} = num2str(lastHH(i));
                data{i,8} = num2str(lastLL(i));
            else
                data{i,1} = num2str(lasttick(2));
                data{i,2} = data{i,1};
                data{i,3} = data{i,1};
                data{i,4} = datestr(lasttick(1),'HH:MM:SS');
                data{i,5} = num2str(lastClose(i));
                data{i,6} = num2str(lasttick(2)-lastClose(i));
                wrinfo = MDEFUT_INSTANCE.calc_technical_indicators(tblRowName{i});
                data{i,7} = num2str(wrinfo{1}(2));
                data{i,8} = num2str(wrinfo{1}(3));
            end
        end
        set(handles.mdefut.table,'Data',data);
        
        pause(60/replayspeedval);
        
    end
        
    
    
end