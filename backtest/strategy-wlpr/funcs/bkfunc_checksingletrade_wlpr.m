function [] = bkfunc_checksingletrade_wlpr(assetName,assetList_wlpr,dataIntradaybarUsed_wlpr,tradesAll_wlpr,tradeIdx)
    nAsset = length(assetList_wlpr);
    assetIdx = 0;
    for i = 1:nAsset
        if strcmpi(assetName,assetList_wlpr{i})
            assetIdx = i;
            break
        end
    end
    if assetIdx == 0
        error('bkfunc_checksingletrade_wlpr:mismatch between asset name and asset list!')
    end
    
    
    trades = tradesAll_wlpr{assetIdx};
    tradeOpen = trades.node_(tradeIdx);
    candle_db_freq = dataIntradaybarUsed_wlpr{assetIdx};
    wlpr = willpctr(candle_db_freq(:,3),candle_db_freq(:,4),candle_db_freq(:,5),144);
    
    
    idx = tradeOpen.opendatetime1_ > candle_db_freq(1:end-1,1) & tradeOpen.opendatetime1_ < candle_db_freq(2:end,1);
    idx_open = find(candle_db_freq(:,1) == candle_db_freq(idx,1));
    obs_period = 144;
    stop_period = 144;
    idx_stop = idx_open + stop_period;
    idx_shift = obs_period;
    figure(1)
    subplot(211)
    candle(candle_db_freq(idx_open-idx_shift:idx_open-1,3),candle_db_freq(idx_open-idx_shift:idx_open-1,4),candle_db_freq(idx_open-idx_shift:idx_open-1,5),candle_db_freq(idx_open-idx_shift:idx_open-1,2),'r');
    grid on;hold on;
    candle(candle_db_freq(idx_open-idx_shift:idx_stop,3),candle_db_freq(idx_open-idx_shift:idx_stop,4),candle_db_freq(idx_open-idx_shift:idx_stop,5),candle_db_freq(idx_open-idx_shift:idx_stop,2),'b');
        
    plot(idx_shift+1:idx_shift+stop_period+1,tradeOpen.openprice_*ones(stop_period+1,1),'g:')
%     plot(idx_shift+1:idx_shift+stop_period+1,candle_db_freq(idx_open,3)*ones(stop_period+1,1),'r:')
%     plot(idx_shift+1:idx_shift+stop_period+1,candle_db_freq(idx_open,4)*ones(stop_period+1,1),'r:')
    if tradeOpen.opendirection_ == 1
        dirstr = 'long';
    else
        dirstr = 'short';
    end
    titlestr = sprintf('%s trade open at %s...\n',dirstr,num2str(tradeOpen.openprice_));
    title(titlestr);
    hold off;
    subplot(212)
    plot(wlpr(idx_open-idx_shift:idx_stop),'b');
    title('williams');
    grid on;hold off;    
    
end
