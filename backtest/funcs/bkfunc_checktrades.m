function [] = bkfunc_checktrades(trades,candles,figidx)
    trade = trades.node_(1);
    nperiod = trade.opensignal_.lengthofperiod_;
    wlpr = willpctr(candles(:,3),candles(:,4),candles(:,5),nperiod);
    
    figure(figidx)
    subplot(211)
    candle(candles(:,3),candles(:,4),candles(:,5),candles(:,2),'b');
    grid on;hold on;
    ntrades = trades.latest_;
    for i = 1:ntrades
        trade = trades.node_(i);
        idx = trade.opendatetime1_ > candles(1:end-1,1) & trade.opendatetime1_ < candles(2:end,1);
        if isempty(candles(idx,1))
            idx_open = size(candles,1);
        else
            idx_open = find(candles(:,1) == candles(idx,1));
        end
        if trade.opendirection_ == 1
            plot(idx_open,trade.openprice_,'marker','o','color','r','markersize',10,'linewidth',3,'markerfacecolor','r');
        else
            plot(idx_open,trade.openprice_,'marker','o','color','g','markersize',10,'linewidth',3,'markerfacecolor','g');
        end
    end
    
    title(trade.code_);
    hold off;
    subplot(212)
    plot(1:nperiod-1,wlpr(1:nperiod-1),'r');
    hold on;
    plot(nperiod:size(wlpr,1),wlpr(nperiod:end),'b');
    title('williams');
    grid on;hold off;    
    
    
    
end