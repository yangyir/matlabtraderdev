function [] = refresh(mdefut,varargin)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime') || strcmpi(mdefut.mode_,'demo')
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
        h = mdefut.gui_;
        name = get(h.frame,'name');
        if strcmpi(name,'CTP MDEFUT')
            try
                tblRowName = get(mdefut.gui_.mktdatatbl.table,'RowName');
                tblColName = get(mdefut.gui_.mktdatatbl.table,'ColumnName');
                tbldata = get(mdefut.gui_.mktdatatbl.table,'Data');
                nrows = size(tblRowName,1);
                ncols = length(tblColName);
                data = cell(nrows,ncols);
                for i = 1:nrows
                    instr = code2instrument(tblRowName{i});
                    lasttick = mdefut.getlasttick(tblRowName{i});
                    lastClose = mdefut.lastclose_(i);
                    wrinfo = mdefut.calc_wr_(instr,'IncludeLastCandle',1);
                    [macdvec,sigvec] = mdefut.calc_macd_(instr,'IncludeLastCandle',1);
                    [bs,ss,levelup,leveldn] = mdefut.calc_tdsq_(instr,'IncludeLastCandle',1);
                    
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

                        data{i,4} = datestr(lasttick(1),'dd/mmm HH:MM:SS');
                        data{i,5} = num2str(lastClose);
                        data{i,6} = sprintf('%3.1f%%',100*(lasttick(4)/lastClose-1));
                        data{i,7} = sprintf('%3.1f',wrinfo(1));
                        data{i,8} = num2str(wrinfo(2));
                        data{i,9} = num2str(wrinfo(3));
                        data{i,10} = num2str(bs(end));
                        data{i,11} = num2str(ss(end));
                        data{i,12} = num2str(levelup(end));
                        data{i,13} = num2str(leveldn(end));
                        data{i,14} = sprintf('%3.3f',macdvec(end));
                        data{i,15} = sprintf('%3.3f',sigvec(end));
                    end
                end
                set(mdefut.gui_.mktdatatbl.table,'Data',data);
            catch err
                fprintf('%s\n',err.message);
            end
            %
            % update plot
            try
                codelist = get(mdefut.gui_.mktdataplot.popupmenu,'string');
                codeidx = get(mdefut.gui_.mktdataplot.popupmenu,'value');
                code2plot = codelist{codeidx};
                instr2plot = code2instrument(code2plot);
                shift = 2*instr2plot.tick_size;
                candles2plot = mdefut.getallcandles(code2plot);
                candles2plot = candles2plot{1};
                ltotal = size(candles2plot,1);
                if ltotal > 0
                    if ltotal <= 200
                        idxstart = 1;
                    else
                        idxstart = ltotal - 199;
                    end
%                     candles2plot = candles2plot(idxstart:end,:);
                    datevec2plot = candles2plot(idxstart:end,1);
                    pxopen2plot = candles2plot(idxstart:end,2);
                    pxhigh2plot = candles2plot(idxstart:end,3);
                    pxlow2plot = candles2plot(idxstart:end,4);
                    pxclose2plot = candles2plot(idxstart:end,5);
                    macdvec2plot = macdvec(idxstart:end);
                    sigvec2plot = sigvec(idxstart:end);
                    levelup2plot = levelup(idxstart:end);
                    leveldn2plot = leveldn(idxstart:end);
                    ax(1) = subplot(2,1,1);
                    plot(levelup2plot,'r:','LineWidth',2);hold on;
                    plot(leveldn2plot,'g:','LineWidth',2);
%                     legend('tdst-resistence','tdst-support');
                    candle(pxhigh2plot,pxlow2plot,pxclose2plot,pxopen2plot);
                    xtick = get(ax(1),'XTick');
                    nxtick = length(xtick);
                    xticklabel = cell(nxtick,1);
                    for i = 1:nxtick
                        if xtick(i) > length(datevec2plot), continue;end
                        if xtick(i) == 0
                            xticklabel{i} = datestr(datevec2plot(1),'dd/mmm HH:MM');
                        else
                            xticklabel{i}= datestr(datevec2plot(xtick(i)),'dd/mmm HH:MM');
                        end
                    end
                    set(ax(1),'XTickLabel',xticklabel,'fontsize',8);grid on;
                    hold off;
                    idxend = size(candles2plot,1);
                    for i = idxstart:idxend
                        if bs(i,1) == 9
                            for k = 1:9
                                if i-idxstart+2-k < 1, continue;end
                                text(i-idxstart+2-k,candles2plot(i+1-k,4)-shift,num2str(bs(i+1-k,1) ),'color','r','fontweight','bold','fontsize',8);
                            end
                        end
                        if ss(i,1) == 9
                            for k = 1:9
                                if i-idxstart+2-k < 1, continue;end
                                text(i-idxstart+2-k,candles2plot(i+1-k,3)+shift,num2str(ss(i+1-k,1) ),'color','g','fontweight','bold','fontsize',8);
                            end
                        end
                    end
                    %
                    if bs(idxend,1) ~= 0
                        i = idxend;
                        for k = 1:9
                            if bs(i-k+1) ~= 0
                                text(i-idxstart+2-k,candles2plot(i+1-k,4)-shift,num2str(bs(i+1-k,1) ),'color','r','fontweight','bold','fontsize',8);
                            else
                                break
                            end
                        end
                    end
                    %
                    if ss(idxend,1) ~= 0
                        i = idxend;
                        for k = 1:9
                            if ss(i-k+1) ~= 0
                                text(i-idxstart+2-k,candles2plot(i+1-k,3)+shift,num2str(ss(i+1-k,1) ),'color','g','fontweight','bold','fontsize',8);
                            else
                                break
                            end
                        end
                    end
                    %
                    %
                    ax(2) = subplot(2,1,2);
                    plot(macdvec2plot,'b');hold on;
                    plot(sigvec2plot,'r');grid on;
                    xtick = get(ax(2),'XTick');
                    nxtick = length(xtick);
                    xticklabel = cell(nxtick,1);
                    for i = 1:nxtick
                        if xtick(i) > length(datevec2plot), continue;end
                        if xtick(i) == 0
                            xticklabel{i} = datestr(datevec2plot(1),'dd/mmm HH:MM');
                        else
                            xticklabel{i}= datestr(datevec2plot(xtick(i)),'dd/mmm HH:MM');
                        end
                    end
                    set(ax(2),'XTickLabel',xticklabel,'fontsize',8);grid on;
                    hold off;
                    legend('macd','nineperma');
                    linkaxes(ax,'x')
                end
            catch err
                fprintf('%s\n',err.message);
            end
        else
            %GUI WITH STRAT AND OPS
            %update mde status
            if strcmpi(mdefut.mode_,'realtime')
                set(mdefut.gui_.tradingstats.time_edit,'string',datestr(now,'dd/mmm HH:MM:SS'));
            else
                set(mdefut.gui_.tradingstats.time_edit,'string',mdefut.replay_time2_);
            end
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
                        data{i,9} = sprintf('%4.2f%',wrinfo{1}(1));
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
                            data{i,6} = sprintf('%4.2f%%',100*(lasttick(4)/lastClose-1));
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
    
end
%end of refresh