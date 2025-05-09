function exportsignal2mt4(signal,extrainfo,fn)
% utility function to export signal (struct) information to a
% txt file (fn), which can be read to MT4
    if isempty(signal)
        return
    end
    
    if signal.directionkellied == 0
        return
    end
    
        
    symbol = signal.code;
    frequency = signal.frequency;
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
    
    if nargin < 3
        fn = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Signal\',symbol,'.lmx_',freqappendix,'_signals_',datestr(extrainfo.px(end,1),'yyyymmdd'),'.txt'];
    end
    
    
    if isempty(strfind(signal.opkellied,'conditional'))
        if signal.directionkellied == 1
            cmd = 0;%OP_BUY
        elseif signal.directionkellied == -1
            cmd = 1;%OP_SELL
        end
    else
        if signal.directionkellied == 1
            cmd = 4;%OP_BUYSTOP
        elseif signal.directionkellied == -1
            cmd = 5;%OP_SELLSTOP
        end
    end
    
    if signal.directionkellied == 1
        price = signal.signalkellied(2);
    elseif signal.directionkellied == -1
        price = signal.signalkellied(3);
    end
    
    stoploss = extrainfo.teeth(end);
    
    if ~isempty(strfind(signal.opkellied,'conditional'))
        if signal.directionkellied == 1 && signal.signalkellied(9) == 22
            sslastidx = find(extrainfo.ss>=9,1,'last');
            sslastval = extrainfo.ss(sslastidx);
            tdhigh_ = max(extrainfo.px(sslastidx-sslastval+1:sslastidx,3));
            tdidx_ = find(extrainfo.px(sslastidx-sslastval+1:sslastidx,3) == tdhigh_,1,'last') + sslastidx-sslastval;
            tdlow_ = extrainfo.px(tdidx_,4);
            if 2*tdlow_-tdhigh_ > stoploss
                stoploss = 2*tdlow_-tdhigh_;
            end
        elseif signal.directionkellied == -1 && signal.signalkellied(9) == -22
            bslastidx = find(extrainfo.bs>=9,1,'last');
            bslastval = extrainfo.bs(bslastidx);
            tdlow_ = min(extrainfo.px(bslastidx-bslastval+1:bslastidx,4));
            tdidx_ = find(extrainfo.px(bslastidx-bslastval+1:bslastidx,4) == tdlow_,1,'last') + bslastidx-bslastval;
            tdhigh_ = extrainfo.px(tdidx_,3);
            if 2*tdlow_-tdhigh_ < stoploss
                stoploss = 2*tdhigh_-tdlow_;
            end
        end
    end
    %        
    if signal.directionkellied == 1 && extrainfo.ss(end) >= 9
        ssreached = extrainfo.ss(end);
        tdhigh_ = max(extrainfo.px(end-ssreached+1:end,3));
        tdidx = find(extrainfo.px(end-ssreached+1:end,3)==tdhigh_,1,'last')+size(extrainfo.px,1)-ssreached;
        tdlow_ = extrainfo.px(tdidx,4);
        if 2*tdlow_ - tdhigh_ > stoploss
            stoploss = 2*tdlow_-tdhigh_;
        end
    end
    %
    if signal.directionkellied == 1 && extrainfo.sc(end) == 13
        td13high_ = extrainfo.px(end,3);
        td13low_ = extrainfo.px(end,4);
        if 2*td13low_ - td13high_ > stoploss
            stoploss = 2*td13low_ - td13high_;
        end
    end
    %
    if signal.directionkellied == -1 && extrainfo.bs(end) >= 9
        bsreached = extrainfo.bs(end);
        tdlow_ = min(extrainfo.px(end-bsreached+1:end,4));
        tdidx = find(extrainfo.px(end-bsreached+1:end,4)==tdlow_,1,'last')+size(extrainfo.px,1)-bsreached;
        tdhigh_ = extrainfo.px(tdidx,3);
        if 2*tdhigh_ - tdlow_ < stoploss
            stoploss = 2*tdhigh_ - tdlow_;
        end
    end
    %
    if signal.directionkellied == -1 && extrainfo.bc(end) == 13
        td13low_ = extrainfo.px(end,4);
        td13high_ = extrainfo.px(end,3);
        if 2*td13high_-td13low_ > stoploss
            stoploss = 2*td13high_-td13low_;
        end
    end
    
    comment = signal.opkellied;
    kelly = signal.kelly;
    wprob = signal.wprob;
    
    if strcmpi(signal.code,'XAUUSD')
        exportformat = '%s\t%s\t%s\t%d\t%4.2f\t%4.2f\t%s\t%4.4f\t%4.4f\n';
    elseif strcmpi(signal.code,'USDJPY')
        exportformat = '%s\t%s\t%s\t%d\t%4.3f\t%4.3f\t%s\t%4.4f\t%4.4f\n';
    else
        exportformat = '%s\t%s\t%s\t%d\t%4.4f\t%4.4f\t%s\t%4.4f\t%4.4f\n';
    end
    
    fid = fopen(fn,'a');
    fprintf(fid,exportformat,...
        datestr(extrainfo.px(end,1),'yyyy.mm.dd HH:MM'),...
        symbol,...
        freqappendix,...
        cmd,...
        price,...
        stoploss,...
        comment,...
        kelly,...
        wprob);
    
    fclose(fid);
    
    
        
end