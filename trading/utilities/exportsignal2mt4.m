function exportsignal2mt4(signal,extrainfo,fn,printonscreen)
% utility function to export signal (struct) information to a
% txt file (fn), which can be read to MT4
    if isempty(signal)
        return
    end
    
    if signal.directionkellied == 0
        return
    end
    
    if nargin < 4
        printonscreen = 0;
    end
    
        
    symbol = signal.code;
    frequency = signal.frequency;
    if strcmpi(frequency,'5m') || strcmpi(frequency,'m5')
        freqappendix = 'M5';
    elseif strcmpi(frequency,'15m') || strcmpi(frequency,'m15')
        freqappendix = 'M15';
    elseif strcmpi(frequency,'30m')  || strcmpi(frequency,'m30') 
        freqappendix = 'M30';
    elseif strcmpi(frequency,'60m')  || strcmpi(frequency,'1h') || strcmpi(frequency,'h1')
        freqappendix = 'H1';
    elseif strcmpi(frequency,'4h') || strcmpi(frequency,'h4')
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
        exportformat = '%s\t%s\t%s\t%d\t%4.2f\t%4.2f\t%s\t%4.3f\t%4.3f\t%4.2f\t%4.2f\n';
    elseif strcmpi(signal.code,'USDJPY')
        exportformat = '%s\t%s\t%s\t%d\t%4.3f\t%4.3f\t%s\t%4.3f\t%4.3f\t%4.3f\t%4.3f\n';
    else
        exportformat = '%s\t%s\t%s\t%d\t%4.5f\t%4.5f\t%s\t%4.3f\t%4.3f\t%4.5f\t%4.5f\n';
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
        wprob,...
        signal.signalkellied(2),...
        signal.signalkellied(3));
    
    fclose(fid);
    
    if printonscreen
        if strcmpi(freqappendix,'m15')
            signaldisptimestr = datestr(extrainfo.px(end,1)+1/96,'yyyy-mm-dd HH:MM');
        elseif strcmpi(freqappendix,'m30')
            signaldisptimestr = datestr(extrainfo.px(end,1)+1/48,'yyyy-mm-dd HH:MM');
        elseif strcmpi(freqappendix,'h1')
            signaldisptimestr = datestr(extrainfo.px(end,1)+1/24,'yyyy-mm-dd HH:MM');
        elseif strcmpi(freqappendix,'h4')
            signaldisptimestr = datestr(extrainfo.px(end,1)+1/6,'yyyy-mm-dd HH:MM');
        end
        
        if signal.directionkellied == 1
            signalstr = 'upper bound at ';
            signalboundary = signal.signalkellied(2);
        else
            signalstr = 'lower bound at ';
            signalboundary = signal.signalkellied(3);
        end
        
        %USDJPY:-->2026-07-17 20:00:signal H1:upper at 162.454 with prob 0.53 and kelly 0.356: --> signal name
        %USDJPY:->2026-07-17 20:00:signal:lower at 162.454
        if strcmpi(signal.code,'XAUUSD')
            exportformat2 = '\n%10s:-->%s:signa:%s%5.2f with prob %3.2f and kelly %3.2f:-->%50s\n';
        elseif strcmpi(signal.code,'USDJPY')
            exportformat2 = '\n%10s:-->%s:signa:%s%5.3f with prob %3.2f and kelly %3.2f:-->%50s\n';
        else
            exportformat2 = '\n%10s:-->%s:signal:%s%5.5f with prob %3.2f and kelly %3.2f:-->%50s\n';
        end
 
       
        fprintf(exportformat2,...
            [symbol,'-',upper(freqappendix)],....
            signaldisptimestr,...
            signalstr,...
            signalboundary,...
            wprob,...
            kelly,...
            comment);
    end
    
        
end