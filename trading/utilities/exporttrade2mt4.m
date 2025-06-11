function [] = exporttrade2mt4(trade,extrainfo,fn)
% utility function to export trade (a cTradeOpen instance) information to a
% txt file (fn), which can be read to MT4
% fn = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\matlab_trades.txt'];
    if isempty(trade)
        return
    end
    
    if nargin < 3
       freq = trade.opensignal_.frequency_;
       freqappendix = freq2mt4freq(freq);
       opendtstr = datestr(extrainfo.px(end,1),'yyyymmdd');
       
       fn = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Trade\',trade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
    end
    
    symbol = trade.code_;
    frequency = trade.opensignal_.frequency_;
    freqappendix = freq2mt4freq(frequency);
    
    if trade.opendirection_ == 1
        cmd = 0;%OP_BUY
    elseif trade.opendirection_ == -1
        cmd = 1;%OP_SELL
    elseif trade.opendirection_ == 2
        cmd = 4;%OP_BUYSTOP
    elseif trade.opendirection_ == -2
        cmd = 5;%OP_SELLSTOP
    else
        'haha'
    end
    
    fid = fopen(fn,'a');
    
    if fid < 0
        fprintf('exporttrade2mt4:invalid file name...\n');
        return
    end
    
    if strcmpi(symbol,'XAUUSD')
        exportformat = '%s\t%s\t%3s\t%d\t%4.2f\t%4.2f\t%s\t%s\t%s\t%4.4f\n';
    elseif strcmpi(symbol,'USDJPY')
        exportformat = '%s\t%s\t%3s\t%d\t%4.3f\t%4.3f\t%s\t%s\t%s\t%4.4f\n';
    else
        exportformat = '%s\t%s\t%3s\t%d\t%4.5f\t%4.5f\t%s\t%s\t%s\t%4.4f\n';
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
        trade.opensignal_.mode_,...
        trade.opensignal_.kelly_);
    
    fclose(fid);
end