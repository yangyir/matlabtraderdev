function [trade] = fractal_gentrade(resstruct,code,idx,mode,longshort,freq)

if longshort == 1
    typein = 'breachup-B';
elseif longshort == -1
    typein = 'breachdn-S';
end


if strcmpi(freq,'daily')
    nfractal = 2;
    ticksizeratio = 1;
    signalinfo = struct('name','fractal',...
        'hh',resstruct.hh(idx),'ll',resstruct.ll(idx),...
        'frequency',freq,...
        'type',typein,...
        'mode',mode,...
        'nfractal',nfractal,...
        'hh1',resstruct.px(idx,3),...
        'll1',resstruct.px(idx,4));
else
    if strcmpi(freq,'30m')
        nfractal = 4;
        ticksizeratio = 0.5;
    elseif strcmpi(freq,'15m')
        nfractal = 4;
        ticksizeratio = 0.5;
    elseif strcmpi(freq,'5m')
        nfractal = 6;
        ticksizeratio = 0;
    else
        %default value of nfractal
        nfractal = 4;
        ticksizeratio = 1;
    end
    signalinfo = struct('name','fractal',...
        'hh',resstruct.hh(idx),'ll',resstruct.ll(idx),...
        'frequency',freq,...
        'type',typein,...
        'mode',mode,...
        'nfractal',nfractal,...
        'hh1',resstruct.px(idx,3),...
        'll1',resstruct.px(idx,4));
end

try   
    if strcmpi(code,'audusd') || strcmpi(code,'eurusd') || strcmpi(code,'gbpusd') || ...
            strcmpi(code,'usdcad') || strcmpi(code,'usdchf') || strcmpi(code,'eurchf') || ...
            strcmpi(code,'gbpeur') || strcmpi(code,'usdcnh')
        ticksize = 0.0001;%1bp
    elseif strcmpi(code,'usdjpy') || strcmpi(code,'eurjpy') || strcmpi(code,'gbpjpy') || strcmpi(code,'audjpy')
        ticksize = 0.01;
    elseif strcmpi(code,'usdx')
        ticksize = 0.01;
    elseif strcmpi(code,'gzhy')
        ticksize = 0.0025;
    elseif strcmpi(code,'tb01y') || strcmpi(code,'tb03y') || strcmpi(code,'tb05y') || ...
            strcmpi(code,'tb07y') || strcmpi(code,'tb10y') || strcmpi(code,'tb30y') 
        ticksize = 0.001;
    else
        instrument = code2instrument(code);
        ticksize = instrument.tick_size;
    end
    
catch
    ticksize = 0;
end

if longshort == 1
    riskmanager = struct('hh0_',resstruct.hh(idx),'hh1_',resstruct.hh(idx),...
        'll0_',resstruct.ll(idx),'ll1_',resstruct.ll(idx),...
        'type_','breachup-B',...
        'wadopen_',resstruct.wad(idx),...
        'cpopen_',resstruct.px(idx,5),'wadhigh_',resstruct.wad(idx),...
        'cphigh_',resstruct.px(idx,5),'wadlow_',resstruct.wad(idx),...
        'cplow_',resstruct.px(idx,5),...
        'fibonacci1_',0.618*resstruct.hh(idx)+0.382*resstruct.px(idx,3),...
        'fibonacci0_',resstruct.ll(idx),...
        'status_','unset');
    %新逻辑：
    %1.已经连续2*nfractal的K线排列在alligator teeth的上方；且HH形成在alligator
    %teeth的上方，在HH的上方一个tick挂买单
%     if strcmpi(freq,'daily')
%         cond1 = isempty(find(resstruct.px(idx-4:idx-1,5)-resstruct.teeth(idx-4:idx-1)+2*ticksize<0,1,'first'));
%     else
%         cond1 = isempty(find(resstruct.px(idx-8:idx-1,5)-resstruct.teeth(idx-8:idx-1)+2*ticksize<0,1,'first'));
%     end
    %1.1 introduce fractal_signal_conditional to check whether trade was
    %conditional trend or not
    ei = fractal_truncate(resstruct,idx-1);
    signal = fractal_signal_conditional(ei,ticksizeratio*ticksize,nfractal);
    if isempty(signal)
        cond1 = false;
    else
        if isempty(signal{1,1})
            cond1 = false;
        else
            if signal{1,1}(1) == 1
                cond1 = true;
            else
                cond1 = false;
            end
        end 
    end
    
    %2.TDST level up在HH的上方；且HH形成在alligator teeth的上方；在TDST level up
    %上方一个tick挂买单
%     cond2 = resstruct.lvlup(idx-1)>resstruct.hh(idx-1);
    
    %3.HH在TDST level up的上方；在HH上方2个tick挂买单
%     cond3 = resstruct.hh(idx-1)>resstruct.lvlup(idx-1);
    %from 20240828 onwards
    %all non-conditional-trended trade shall open with the next open or its
    %close price in case the next open price is not available
    %this is because for non-trened trades, no momenet would guarantee
    %whether the price shall breach the barrier until it happened
    
    if cond1
        if strcmpi(freq,'daily')
            opendt = resstruct.px(idx,1);
            openpx = max(resstruct.px(idx,2),signal{1,1}(2)+ticksize);
        else
            opendt = resstruct.px(idx,1);
            if strcmpi(freq,'5m')
                openpx = max(resstruct.px(idx,2),signal{1,1}(2));
            else
                openpx = max(resstruct.px(idx,2),signal{1,1}(2)+ticksize);
            end
        end
    else
        if strcmpi(freq,'daily')
            try
                opendt = resstruct.px(idx+1,1);
            catch
                opendt = resstruct.px(idx,1);
            end
        else
            try
                opendt = resstruct.px(idx+1,1)+1/86400;
            catch
                opendt = resstruct.px(idx,1);
            end
        end
        try
            openpx = resstruct.px(idx+1,2);
        catch
            openpx = resstruct.px(idx,5);
        end
    end
    
    trade = cTradeOpen('id',idx,'code',code,...
        'opendatetime',opendt,...
        'openprice',openpx,'opendirection',longshort,...
        'openvolume',1);
    
    trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
    trade.setriskmanager('name','spiderman','extrainfo',riskmanager);

    if resstruct.ss(idx) >= 9
        ssreached = resstruct.ss(idx);
        trade.riskmanager_.tdhigh_ = max(resstruct.px(idx-ssreached+1:idx,3));
        tdidx = find(resstruct.px(idx-ssreached+1:idx,3)==trade.riskmanager_.tdhigh_,1,'last')+idx-ssreached;
        trade.riskmanager_.tdlow_ = resstruct.px(tdidx,4);
        if trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) > trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
            trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
        end
    end
    
    if isnan(trade.riskmanager_.tdhigh_) && strcmpi(mode,'breachup-sshighvalue')
        ei_ = fractal_truncate(resstruct,idx);
        sslastidx = find(ei_.ss>=9,1,'last');
        sslastval = ei_.ss(sslastidx);
        sspxhigh = max(ei_.px(sslastidx-sslastval+1:sslastidx,3));
        tdidx = find(ei_.px(sslastidx-sslastval+1:sslastidx,3)==sspxhigh,1,'last')+sslastidx-sslastval;
        trade.riskmanager_.tdhigh_ = sspxhigh;
        trade.riskmanager_.tdlow_ = ei_.px(tdidx,4);
        if trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) > trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
            trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
        end
    end
    
    if isnan(trade.riskmanager_.td13low_) && strcmpi(mode,'breachup-highsc13')
        ei_ = fractal_truncate(resstruct,idx);
        sc13last = find(ei_.sc == 13,1,'last');
        trade.riskmanager_.td13low_ = ei_.px(sc13last,4);
    end
    
    if resstruct.teeth(idx) > trade.riskmanager_.pxstoploss_
        trade.riskmanager_.pxstoploss_ = floor(resstruct.teeth(idx)/ticksize)*ticksize;
        trade.riskmanager_.closestr_ = 'fractal:teeth';
    end
    
    trade.status_ = 'set';
    
elseif longshort == -1
    riskmanager = struct('hh0_',resstruct.hh(idx),'hh1_',resstruct.hh(idx),...
        'll0_',resstruct.ll(idx),'ll1_',resstruct.ll(idx),...
        'type_','breachdn-S',...
        'wadopen_',resstruct.wad(idx),...
        'cpopen_',resstruct.px(idx,5),'wadhigh_',resstruct.wad(idx),...
        'cphigh_',resstruct.px(idx,5),'wadlow_',resstruct.wad(idx),...
        'cplow_',resstruct.px(idx,5),...
        'fibonacci1_',resstruct.hh(idx),...
        'fibonacci0_',0.618*resstruct.ll(idx)+0.382*resstruct.px(idx,4),...
        'status_','unset');
    
    %新逻辑：
    %1.已经连续2*nfractal的K线排列在alligator teeth的下方；且LL形成在alligator
    %teeth的下方，在LL的下方一个tick挂买单
%     if strcmpi(freq,'daily')
%         cond1 = isempty(find(resstruct.px(idx-4:idx-1,5)-resstruct.teeth(idx-4:idx-1)-2*ticksize>0,1,'first'));
%     else
%         cond1 = isempty(find(resstruct.px(idx-8:idx-1,5)-resstruct.teeth(idx-8:idx-1)-2*ticksize>0,1,'first'));
%     end
    %
    ei = fractal_truncate(resstruct,idx-1);
    signal = fractal_signal_conditional(ei,ticksizeratio*ticksize,nfractal);
    if isempty(signal)
        cond1 = false;
    else
        if isempty(signal{1,2})
            cond1 = false;
        else
            if signal{1,2}(1) == -1
                cond1 = true;
            else
                cond1 = false;
            end
        end
    end    
    %2.TDST level dn在LL的下方；且LL形成在alligator teeth的下方；在TDST level dn
    %下方一个tick挂买单
%     cond2 = resstruct.lvldn(idx-1)<resstruct.ll(idx-1);
    
    %3.LL在TDST level dn的下方；在LL下方2个tick挂卖单
%     cond3 = resstruct.ll(idx-1)<resstruct.lvldn(idx-1);
    
    if cond1
        if strcmpi(freq,'daily')
            opendt = resstruct.px(idx,1);
            openpx = min(resstruct.px(idx,2),signal{1,2}(3)-ticksizeratio*ticksize);
        else
            opendt = resstruct.px(idx,1);
            if strcmpi(freq,'5m')
                openpx = min(resstruct.px(idx,2),signal{1,2}(3));
            else
                openpx = min(resstruct.px(idx,2),signal{1,2}(3)-ticksize);
            end
        end
    else
        if strcmpi(freq,'daily')
            try
                opendt = resstruct.px(idx+1,1);
            catch
                opendt = resstruct.px(idx,1);
            end
        else
            try
                opendt = resstruct.px(idx+1,1)+1/86400;
            catch
                opendt = resstruct.px(idx,1);
            end
        end
        try
            openpx = resstruct.px(idx+1,2);
        catch
            openpx = resstruct.px(idx,5);
        end
    end
    
    trade = cTradeOpen('id',idx,'code',code,...
        'opendatetime',opendt,...
        'openprice',openpx,'opendirection',longshort,...
        'openvolume',1);
    trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
    trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
    if resstruct.bs(idx) >= 9
        bsreached = resstruct.bs(idx);
        trade.riskmanager_.tdlow_ = min(resstruct.px(idx-bsreached+1:idx,4));
        tdidx = find(resstruct.px(idx-bsreached+1:idx,4)==trade.riskmanager_.tdlow_,1,'last')+idx-bsreached;
        trade.riskmanager_.tdhigh_ = resstruct.px(tdidx,3);
        if trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) < trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
            trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
        end
    end
    
    if isnan(trade.riskmanager_.tdlow_) && strcmpi(mode,'breachdn-bshighvalue')
        ei_ = fractal_truncate(resstruct,idx);
        bslastidx = find(ei_.bs>=9,1,'last');
        bslastval = ei_.bs(bslastidx);
        bspxlow = min(ei_.px(bslastidx-bslastval+1:bslastidx,4));
        tdidx = find(ei_.px(bslastidx-bslastval+1:bslastidx,4)==bspxlow,1,'last')+bslastidx-bslastval;
        trade.riskmanager_.tdlow_ = bspxlow;
        trade.riskmanager_.tdhigh_ = ei_.px(tdidx,3);
        if trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) < trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
            trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
        end
    end
    
    if isnan(trade.riskmanager_.td13low_) && strcmpi(mode,'breachdn-lowbc13')
        ei_ = fractal_truncate(resstruct,idx);
        bc13last = find(ei_.bc == 13,1,'last');
        trade.riskmanager_.td13high_ = ei_.px(bc13last,3);
    end
    
    if resstruct.teeth(idx) < trade.riskmanager_.pxstoploss_
        trade.riskmanager_.pxstoploss_ = ceil(resstruct.teeth(idx)/ticksize)*ticksize;
        trade.riskmanager_.closestr_ = 'fractal:teeth';
    end
    
    trade.status_ = 'set';
    
else
    error('fractal_gentrade:invalid longshort input')
end
end