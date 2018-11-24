function [] = refresh(mdefut,varargin)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            %refresh qms with the latest market quotes
            mdefut.qms_.refresh;
            %save ticks data into memory
            mdefut.saveticks2mem;
            %save candles data into memory
            mdefut.updatecandleinmem;
        %    
        elseif strcmpi(mdefut.mode_,'replay')
            mdefut.refreshreplaymode2;
        end
    end
    
    
    if ~isempty(mdefut.gui_)
        %update mde status
        set(mdefut.gui_.tradingstats.time_edit,'string',datestr(now,'dd/mmm HH:MM:SS'));
        set(mdefut.gui_.tradingstats.mdestatus_edit,'string',mdefut.status_);
        set(mdefut.gui_.tradingstats.mderunning_edit,'string',mdefut.timer_.running);
        %update mktdata table
        try
            tblRowName = get(mdefut.gui_.mktdatatbl.table,'RowName');
            tblColName = get(mdefut.gui_.mktdatatbl.table,'ColumnName');
            tbldata = get(mdefut.gui_.mktdatatbl.table,'Data');
            nrows = size(tblRowName,1);
            ncols = length(tblColName);
            data = cell(nrows,ncols);
            for i = 1:nrows
                if ncols > 4
                    histcandles = mdefut.gethistcandles(tblRowName{i});
                    lastClose = str2double(tbldata{i,5});
                    wrinfo = mdefut.calc_technical_indicators(tblRowName{i});
                    data{i,7} = num2str(wrinfo{1}(2));
                    data{i,8} = num2str(wrinfo{1}(3));
                    data{i,5} = num2str(lastClose);
                end
                lasttick = mdefut.getlasttick(tblRowName{i});
                
                if ~isempty(lasttick)
                    data{i,1} = num2str(lasttick(4));   %last trade
                    if abs(lasttick(2)) > 1e10
                        data{i,2} = '-';
                    else
                        data{i,2} = num2str(lasttick(2));   %bid
                    end
                    if abs(lasttick(3)) > 1e10
                        data{i,3} = '-';
                    else
                        data{i,3} = num2str(lasttick(3));   %ask
                    end
                        
                    data{i,4} = datestr(lasttick(1),'HH:MM:SS');
                    if ncols > 4
                        data{i,6} = num2str(lasttick(4)-lastClose);
                    end
                else
                    data{i,1} = num2str(lastClose);   %last trade
                    data{i,2} = num2str(lastClose);   %bid
                    data{i,3} = num2str(lastClose);   %ask
                    data{i,4} = datestr(histcandles{1}(end,1),'HH:MM:SS');
                    if ncols > 4
                        data{i,6} = num2str(0);
                    end
                end
            end
            set(mdefut.gui_.mktdatatbl.table,'Data',data);
        catch err
            fprintf('%s\n',err.message);
        end
        %update plot
        try
%             if ~mdefut.gui_.mktdataplot.flag, return; end
            
            codelist = get(mdefut.gui_.mktdataplot.popupmenu,'string');
            codeidx = get(mdefut.gui_.mktdataplot.popupmenu,'value');
            code2plot = codelist{codeidx};
            histcandles = mdefut.gethistcandles(code2plot);
            if ~isempty(histcandles)
                histcandles = histcandles{1};
            else
                histcandles = [];
            end
            lhist = size(histcandles,1);
            
            candles = mdefut.getcandles(code2plot);
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
                set(mdefut.gui_.mktdataplot.axes,'XTick',xgrid);
                set(mdefut.gui_.mktdataplot.axes,'XTickLabel',t_str);       
            end
        catch err
            fprintf(err.message);
        end
        
    end
    
end
%end of refresh