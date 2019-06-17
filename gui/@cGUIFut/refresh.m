function [] = refresh(obj,varargin)
    try
        tblRowName = get(obj.handles_.mktdatatbl.table,'RowName');
        tblColName = get(obj.handles_.mktdatatbl.table,'ColumnName');
        nrows = size(tblRowName,1);
        ncols = length(tblColName);
        data = cell(nrows,ncols);
        for i = 1:nrows
            instr = code2instrument(tblRowName{i});
            lasttick = obj.mdefut_.getlasttick(tblRowName{i});
            lastClose = obj.mdefut_.lastclose_(i);
            wrinfo = obj.mdefut_.calc_wr_(instr,'IncludeLastCandle',1);
            [macdvec,sigvec] = obj.mdefut_.calc_macd_(instr,'IncludeLastCandle',1);
            [bs,ss,levelup,leveldn] = obj.mdefut_.calc_tdsq_(instr,'IncludeLastCandle',1);

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
        set(obj.handles_.mktdatatbl.table,'Data',data);
    catch err
        fprintf('%s\n',err.message);
    end
    %
    % update plot
    try
        codelist = get(obj.handles_.mktdataplot.popupmenu,'string');
        codeidx = get(obj.handles_.mktdataplot.popupmenu,'value');
        code2plot = codelist{codeidx};
        instr2plot = code2instrument(code2plot);
        shift = 2*instr2plot.tick_size;
        candles2plot = obj.handles_.getallcandles(code2plot);
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
end