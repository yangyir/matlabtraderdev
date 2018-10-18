function mygui_replayer_callback_mdefutplotbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);
    handles.mktdataplot.flag = true;
    
    global MDEFUT_INSTANCE;
    
    codelist = get(handles.mktdataplot.popupmenu,'string');
    codeidx = get(handles.mktdataplot.popupmenu,'value');
    code2plot = codelist{codeidx};
    histcandles = MDEFUT_INSTANCE.gethistcandles(code2plot);
    if ~isempty(histcandles)
        histcandles = histcandles{1};
    else
        histcandles = [];
    end
    lhist = size(histcandles,1);

    candles = MDEFUT_INSTANCE.getcandles(code2plot);
    if ~isempty(candles)
        candles = candles{1};
    else
        candles = [];
    end
    lcurrent = size(candles,1);

    %take maximum 200 candles into plot and all the current candles
    %shall be included
    ltotal = lhist + lcurrent;
    if ltotal > 0
        if ltotal <= 200
            idxstart = 1;
        else
            if lcurrent >= 200
                idxstart = lcurrent - 199;
            else
                idxstart = lhist-(200-lcurrent);
            end
        end
        candles2plot = [histcandles;candles];
        candles2plot = candles2plot(idxstart:end,:);
    else
        candles2plot = [];
    end

    if ~isempty(candles2plot)
        candle(candles2plot(:,3),candles2plot(:,4),candles2plot(:,5),candles2plot(:,2),'b');
        grid on;
        date_format = 'dd/mmm HH:MM';
        xgrid = [0 25 50 75 100 125 150 175 200];
        xgrid = xgrid';
        idx = xgrid < size(candles2plot,1);
        xgrid = xgrid(idx,:);
        t_num = zeros(1,length(xgrid));
        for i = 1:length(t_num)
            if xgrid(i) == 0
                t_num(i) = candles2plot(1,1);
            elseif xgrid(i) > size(candles2plot,1)
                t_start = candles2plot(1,1);
                t_last = candles2plot(end,1);
                t_num(i) = t_last + (xgrid(i)-size(candles2plot,1))*...
                    (t_last - t_start)/size(candles2plot,1);
            else
                t_num(i) = candles2plot(xgrid(i),1);
            end
        end
        if isempty(date_format)
            t_str = datestr(t_num);
        else
            t_str = datestr(t_num,date_format);
        end
        set(handles.mktdataplot.axes,'XTick',xgrid);
        set(handles.mktdataplot.axes,'XTickLabel',t_str);       
    end

    
end