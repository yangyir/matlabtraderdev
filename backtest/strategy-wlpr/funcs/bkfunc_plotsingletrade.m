function [] = bkfunc_plotsingletrade( trade,candles )
    wrmode = trade.opensignal_.wrmode_;
    nperiod = trade.opensignal_.lengthofperiod_;
    obs_period = nperiod;
    stop_period = nperiod;
    idx_shift = obs_period;
    
    idx = trade.opendatetime1_ > candles(1:end-1,1) & trade.opendatetime1_ < candles(2:end,1);
    if isempty(candles(idx,1))
        idx_open = size(candles,1);
    else
        idx_open = find(candles(:,1) == candles(idx,1));
    end
    %
    
    idx_close = find(candles(:,1) == trade.closedatetime1_);
    if isempty(idx_close)
        idx = candles(1:end-1,1) < trade.closedatetime1_ & candles(2:end,1) > trade.closedatetime1_;
        ct = candles(idx,1);
        idx_close = find(candles(:,1) == ct);
    end
    
    idx_stop = idx_close + stop_period;
    idx_stop = min(idx_stop,size(candles,1));
    stop_period = idx_stop-idx_open;
    
    pstoploss = trade.riskmanager_.pxstoploss_;
    
    wlpr = willpctr(candles(:,3),candles(:,4),candles(:,5),nperiod);

    figure(1)
    subplot(211)
    candle(candles(idx_open-idx_shift:idx_stop,3),candles(idx_open-idx_shift:idx_stop,4),candles(idx_open-idx_shift:idx_stop,5),candles(idx_open-idx_shift:idx_stop,2),'b');
    hold on;
    if trade.opendirection_ == 1
        plot(idx_shift+1,trade.openprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
        plot(idx_close-idx_open+idx_shift,trade.closeprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
    else
        plot(idx_shift,trade.openprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
        plot(idx_close-idx_open+idx_shift,trade.closeprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
    end
    plot(idx_shift+1:idx_shift+stop_period+1,trade.openprice_*ones(stop_period+1,1),'g:')
    plot(idx_shift+1:idx_shift+stop_period+1,pstoploss*ones(stop_period+1,1),'r:')

    if trade.opendirection_ == 1
        dirstr = 'long';
    else
        dirstr = 'short';
    end
    titlestr = sprintf('%s:%s %s trade open at %s on %s...\n',trade.code_,dirstr,wrmode,num2str(trade.openprice_),...
        trade.opendatetime2_);
    title(titlestr);
    hold off;
    %
    subplot(212)
    plot(wlpr(idx_open-idx_shift:idx_stop),'b');
    hold on;
    if trade.opendirection_ == 1
        plot(idx_shift+1,wlpr(idx_open-1),'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
        plot(idx_close-idx_open+idx_shift,wlpr(idx_close),'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','g');
    else
        plot(idx_shift+1,wlpr(idx_open-1),'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
        plot(idx_close-idx_open+idx_shift,wlpr(idx_close),'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
    end
    title('williams');
    grid on;hold off;

end

