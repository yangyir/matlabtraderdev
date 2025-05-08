function [] = exporttrade2mt4(trade,extrainfo,fn)
% utility function to export trade (a cTradeOpen instance) information to a
% txt file (fn), which can be read to MT4
% fn = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\matlab_trades.txt'];
    if isempty(trade)
        return
    end
    
    symbol = trade.code_;
    frequency = trade.opensignal_.frequency_;
    if strcmpi(frequency,'5m')
        freqappendix = 'M5';
    elseif strcmpi(frequency,'15m')
        freqappendix = 'M15';
    elseif strcmpi(frequency,'30m') 
        freqappendix = 'M30';
    elseif strcmpi(frequency,'60m')  || strcmpi(frequency,'1h')
        freqappendix = 'H1';
    elseif strcmpi(frequency,'4h')
        freqappendix = 'H4';
    else
        freqappendix = 'D1';
    end
    
    if trade.opendirection_ == 1
        cmd = 0;%OP_BUY
    else
        cmd = 1;%OP_SELL
    end

    fid = fopen(fn,'a');
    
    if strcmpi(symbol,'XAUUSD')
        exportformat = '%s\t%s\t%3s\t%d\t%4.2f\t%4.2f\t%s\t%s\t%s\n';
    elseif strcmpi(symbol,'USDJPY')
        exportformat = '%s\t%s\t%3s\t%d\t%4.3f\t%4.3f\t%s\t%s\t%s\n';
    else
        exportformat = '%s\t%s\t%3s%d\t%4.4f\t%4.4f\t%s\t%s\t%s\n';
    end
    
    fprintf(fid,exportformat,...
        datestr(extrainfo.px(end,1),'yyyy.mm.dd HH:MM'),...
        symbol,...
        freqappendix,...
        cmd,...
        trade.openprice_,...
        trade.riskmanager_.pxstoploss_,...
        datestr(trade.opendatetime1_,'yyyy.mm.dd HH:MM'),...
        trade.status_,...
        trade.opensignal_.mode_);
    
    fclose(fid);
end