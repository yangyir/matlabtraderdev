function [] = refreshplot(obj,varargin)
%cGUIFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('input',[],@isstruct);
    p.parse(varargin{:});
    input = p.Results.input;
    
    try
        codelist = get(obj.handles_.mktdataplot.popupmenu,'string');
        codeidx = get(obj.handles_.mktdataplot.popupmenu,'value');
        code2plot = codelist{codeidx};
        instr2plot = code2instrument(code2plot);
    catch e
        fprintf('%s\n',e.message);
        return
    end
        
    if isempty(input)
         [macdvec,sigvec] = obj.mdefut_.calc_macd_(instr2plot,'IncludeLastCandle',1);
         [bsvec,ssvec,levelupvec,leveldnvec] = obj.mdefut_.calc_tdsq_(instr2plot,'IncludeLastCandle',1);
    else
        macdvec = input.macdcell{codeidx};
        sigvec = input.sigcell{codeidx};
        levelupvec = input.levelupcell{codeidx};
        leveldnvec = input.leveldncell{codeidx};
        bsvec = input.bscell{codeidx};
        ssvec = input.sscell{codeidx};
    end
    
    try
        shift = 2*instr2plot.tick_size;
        candles2plot = obj.mdefut_.getallcandles(code2plot);
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
            levelup2plot = levelupvec(idxstart:end);
            leveldn2plot = leveldnvec(idxstart:end);
            bs = bsvec;
            ss = ssvec;
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
%             legend('macd','nineperma');
            linkaxes(ax,'x')
        end
    catch err
        fprintf('%s\n',err.message);
    end
    
end