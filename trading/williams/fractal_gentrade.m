function [trade] = fractal_gentrade(resstruct,code,idx,mode,longshort,freq)

signalinfo = struct('name','fractal',...
    'hh',resstruct.hh(idx),'ll',resstruct.ll(idx),...
    'frequency',freq,...
    'mode',mode,...
    'nfractal',4,...
    'hh1',resstruct.px(idx,3),...
    'll1',resstruct.px(idx,4));

try
    instrument = code2instrument(code);
    ticksize = instrument.tick_size;
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
    cond1 = isempty(find(resstruct.px(idx-8:idx-1,5)-resstruct.teeth(idx-8:idx-1)+2*ticksize<0,1,'first'));
    
    %2.TDST level up在HH的上方；且HH形成在alligator teeth的上方；在TDST level up
    %上方一个tick挂买单
    cond2 = resstruct.lvlup(idx-1)>resstruct.hh(idx-1);
    
    %3.HH在TDST level up的上方；在HH上方2个tick挂买单
    cond3 = resstruct.hh(idx-1)>resstruct.lvlup(idx-1);
    
    if cond1
        opendt = resstruct.px(idx+1,1);
        openpx = max(resstruct.px(idx,2),resstruct.hh(idx)+ticksize);
    elseif cond2 && strcmpi(mode,'breachup-lvlup')
        opendt = resstruct.px(idx+1,1);
        openpx = max(resstruct.px(idx,2),resstruct.lvlup(idx-1)+ticksize);
    elseif cond3 && strcmpi(mode,'breachup-lvlup')
        opendt = resstruct.px(idx+1,1);
        openpx = max(resstruct.px(idx,2),resstruct.hh(idx-1)+2*ticksize);
    else
        opendt = resstruct.px(idx+1,1)+1/86400;
        openpx = resstruct.px(idx+1,2);
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
    
    if resstruct.teeth(idx) > trade.riskmanager_.pxstoploss_
        trade.riskmanager_.pxstoploss_;
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
    cond1 = isempty(find(resstruct.px(idx-8:idx-1,5)-resstruct.teeth(idx-8:idx-1)-2*ticksize>0,1,'first'));
        
    %2.TDST level dn在LL的下方；且LL形成在alligator teeth的下方；在TDST level dn
    %下方一个tick挂买单
    cond2 = resstruct.lvldn(idx-1)<resstruct.ll(idx-1);
    
    %3.LL在TDST level dn的下方；在LL下方2个tick挂卖单
    cond3 = resstruct.ll(idx-1)<resstruct.lvldn(idx-1);
    
    if cond1
        opendt = resstruct.px(idx+1,1);
        openpx = min(resstruct.px(idx,2),resstruct.ll(idx)-ticksize);
    elseif cond2 && strcmpi(mode,'breachdn-lvldn')
        opendt = resstruct.px(idx+1,1);
        openpx = min(resstruct.px(idx,2),resstruct.lvldn(idx-1)-ticksize);
    elseif cond3 && strcmpi(mode,'breachdn-lvldn')
        opendt = resstruct.px(idx+1,1);
        openpx = min(resstruct.px(idx,2),resstruct.ll(idx-1)-ticksize);
    else
        opendt = resstruct.px(idx+1,1)+1/86400;
        openpx = resstruct.px(idx+1,2);
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
            trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
        end
    end
    
    if resstruct.teeth(idx) < trade.riskmanager_.pxstoploss_
        trade.riskmanager_.pxstoploss_;
        trade.riskmanager_.closestr_ = 'fractal:teeth';
    end
    
    trade.status_ = 'set';
    
else
    error('fractal_gentrade:invalid longshort input')
end
end