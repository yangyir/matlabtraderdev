function [trades] = irene_gentradesfromcode(varargin)
%
%utility function to generate all possible trades without kelly information,
%i.e.any breached trade or any conditional trade with either high or low
%price breached the barrier
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('code','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.addParameter('datefrom','',@ischar);
p.addParameter('dateto','',@ischar);
p.parse(varargin{:});
code = p.Results.code;
freq = p.Results.frequency;
datefrom = p.Results.datefrom;
dateto = p.Results.dateto;

if ~isempty(datefrom)
    datefromnum = datenum(datefrom,'yyyy-mm-dd');
    if ~(strcmpi(freq,'1440m') || strcmpi(freq,'daily'))
        datefromnum = datefromnum + 3/24;
    end
else
    datefromnum = 0;
end
if ~isempty(dateto)
    datetonumm = datenum(dateto,'yyyy-mm-dd');
    if ~(strcmpi(freq,'1440m') || strcmpi(freq,'daily'))
        datetonumm = datetonumm + 1 + 3/24;
    end
else
    datetonumm = inf;
end

if strcmpi(freq,'30m')
    nfractal = 4;
    ticksizeratio = 0.5;
elseif strcmpi(freq,'15m')
    nfractal = 4;
    ticksizeratio = 0.5;
elseif strcmpi(freq,'5m')
    nfractal = 6;
    ticksizeratio = 0;
elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
    nfractal = 2;
    ticksizeratio = 1;
else
    nfractal = 4;
    ticksizeratio = 0.5;
end

fut = code2instrument(code);
ticksize = fut.tick_size;

trades = cTradeOpenArray;

[dt1,dt2,datastruct] = irene_findactiveperiod('code',code,'frequency',freq);
if isempty(dt1)
    return
end

idx1 = find(datastruct.px(:,1) > max(dt1,datefromnum),1,'first');
if ~(strcmpi(freq,'1440m') || strcmpi(freq,'daily'))
    idx2 = find(datastruct.px(:,1) <= min(dt2+1,datetonumm),1,'last');
else
    idx2 = find(datastruct.px(:,1) > min(dt2,datetonumm),1,'first');
end


if idx1 < 21
    idx1 = 21;
end

for i = idx1:idx2
    ei1 = fractal_truncate(datastruct,i-1);
    ei2 = fractal_truncate(datastruct,i);
    [signalcond,~,~] = fractal_signal_conditional(ei1,ticksizeratio*ticksize,nfractal);
    [signaluncond,opuncond,status] = fractal_signal_unconditional(ei2,ticksizeratio*ticksize,nfractal);
    if isempty(signalcond) && isempty(signaluncond)
        %DO NOTHING
    elseif isempty(signalcond) && ~isempty(signaluncond)
        if status.istrendconfirmed
            %trended with no conditional signal generated beforehand
            %NO TRADE HERE
        else
            %untrended with no conditional signal generated beforehand,
            %APPARENTLY
            trade = fractal_gentrade(datastruct,code,i,opuncond.comment,opuncond.direction,freq,0);
            trade.bookname_ = 'tb';
            trade.riskmanager_.setusefractalupdateflag(0);
            trades.push(trade);
        end
    elseif ~isempty(signalcond) && isempty(signaluncond)
        %conditional signal generated beforehand without any valid breach
        if ei1.px(end,5) < ei1.lips(end) && ei1.hh(end) < ei1.lips(end) && ~isnan(ei1.lvlup(end)) && ei1.px(end,5) < ei1.lvlup(end)
            signalcond{1,1}(1) = 0;
        end
        %
        if ei1.px(end,5) > ei1.lips(end) && ei1.ll(end) > ei1.lips(end) && ~isnan(ei1.lvldn(end)) && ei1.px(end,5) > ei1.lvldn(end)
            signalcond{1,2}(1) = 0;
        end
        %
        if ~isempty(signalcond{1,1}) && signalcond{1,1}(1) == 1
            if ei2.px(end,3) - signalcond{1,1}(2) - ticksizeratio*ticksize >= -1e-6 && ...
                    ei2.px(end,2) < signalcond{1,1}(2) + 2.0*(signalcond{1,1}(2)-signalcond{1,1}(3))
                %high price breached-up through the signal barrier
                if signalcond{1,1}(9) == 21
                    mode = 'conditional-uptrendconfirmed-1';
                elseif signalcond{1,1}(9) == 22
                    mode = 'conditional-uptrendconfirmed-2';
                elseif signalcond{1,1}(9) == 23
                    mode = 'conditional-uptrendconfirmed-3';
                else
                    mode = 'conditional-uptrendconfirmed';
                end
                trade = fractal_gentrade(datastruct,code,i,mode,1,freq,1);
                trade.openprice_ = signalcond{1,1}(2) + sign(ticksizeratio)*ticksize;
                trade.bookname_ = 'tc';
                trade.riskmanager_.setusefractalupdateflag(0);
                if strcmpi(mode,'conditional-uptrendconfirmed-2')
                    sslastidx = find(ei1.ss>=9,1,'last');
                    sslastval = ei1.ss(sslastidx);
                    tdhigh = max(ei1.px(sslastidx-sslastval+1:sslastidx,3));
                    tdidx = find(ei1.px(sslastidx-sslastval+1:sslastidx,3) == tdhigh,1,'last') + sslastidx-sslastval;
                    tdlow = ei1.px(tdidx,4);
                    trade.riskmanager_.tdhigh_ = tdhigh;
                    trade.riskmanager_.tdlow_ = tdlow;
                end
                if strcmpi(mode,'conditional-uptrendconfirmed-3')
                    sclastidx = find(ei1.sc==13,1,'last');
                    trade.riskmanager_.td13low_ = ei1.px(sclastidx,4);
                end
                trades.push(trade);
            end
        elseif ~isempty(signalcond{1,2}) && signalcond{1,2}(1) == -1
            if ei2.px(end,4) - signalcond{1,2}(3) + ticksizeratio*ticksize <= 1e-6 && ...
                    ei2.px(end,2) > signalcond{1,2}(3) - 2.0*(signalcond{1,2}(2)-signalcond{1,2}(3))
                %low price breached-dn through the signal barrier
                if signalcond{1,2}(9) == -21
                    mode = 'conditional-dntrendconfirmed-1';
                elseif signalcond{1,2}(9) == -22
                    mode = 'conditional-dntrendconfirmed-2';
                elseif signalcond{1,2}(9) == -23
                    mode = 'conditional-dntrendconfirmed-3';
                else
                    mode = 'conditional-dntrendconfirmed';
                end
                trade = fractal_gentrade(datastruct,code,i,mode,-1,freq,1);
                trade.openprice_ = signalcond{1,2}(3) - sign(ticksizeratio)*ticksize;
                trade.bookname_ = 'tc';
                trade.riskmanager_.setusefractalupdateflag(0);
                if strcmpi(mode,'conditional-dntrendconfirmed-2')
                    bslastidx = find(ei1.bs>=9,1,'last');
                    bslastval = ei1.bs(bslastidx);
                    tdlow = max(ei1.px(bslastidx-bslastval+1:bslastidx,4));
                    tdidx = find(ei1.px(bslastidx-bslastval+1:bslastidx,4) == tdlow,1,'last') + bslastidx-bslastval;
                    tdhigh = ei1.px(tdidx,3);
                    trade.riskmanager_.tdhigh_ = tdhigh;
                    trade.riskmanager_.tdlow_ = tdlow;
                end
                if strcmpi(mode,'conditional-dntrendconfirmed-3')
                    bclastidx = find(ei1.bc==13,1,'last');
                    trade.riskmanager_.td13high_ = ei1.px(bclastidx,3);
                end
                trades.push(trade);
            end
        end
    elseif ~isempty(signalcond) && ~isempty(signaluncond)
        if signaluncond(1) == 1 && ~isempty(signalcond{1,1}) && signalcond{1,1}(1) == 1
            %LONG TREND CONTINUED WITH BREACHING THE UPPER BARRIER
            if ei2.px(end,3) - signalcond{1,1}(2) - ticksizeratio*ticksize >= -1e-6  && ...
                    ei2.px(end,2) < signalcond{1,1}(2) + 2.0*(signalcond{1,1}(2)-signalcond{1,1}(3))
                trade = fractal_gentrade(datastruct,code,i,opuncond.comment,1,freq,1);
                trade.openprice_ = signalcond{1,1}(2) + sign(ticksizeratio)*ticksize;
                trade.bookname_ = 'tc';
                trade.riskmanager_.setusefractalupdateflag(0);
                trades.push(trade);
            end
        elseif signaluncond(1) == 1 && ~isempty(signalcond{1,2}) && signalcond{1,2}(1) == -1
            %SHORT TREND HAS BROKEN
            trade = fractal_gentrade(datastruct,code,i,opuncond.comment,1,freq,0);
            trade.bookname_ = 'tb';
            trade.riskmanager_.setusefractalupdateflag(0);
            trades.push(trade);
        elseif signaluncond(1) == -1 && ~isempty(signalcond{1,2}) && signalcond{1,2}(1) == -1
            %SHORT TREND CONTINUED WITH BREACHING THE LOWER BARRIER
            if ei2.px(end,4) - signalcond{1,2}(3) + ticksizeratio*ticksize <= 1e-6 && ...
                    ei2.px(end,2) > signalcond{1,2}(3) - 2.0*(signalcond{1,2}(2)-signalcond{1,2}(3))
                trade = fractal_gentrade(datastruct,code,i,opuncond.comment,-1,freq,1);
                trade.openprice_ = signalcond{1,2}(3) - sign(ticksizeratio)*ticksize;
                trade.bookname_ = 'tc';
                trade.riskmanager_.setusefractalupdateflag(0);
                trades.push(trade);
            end
        elseif signaluncond(1) == -1 && ~isempty(signalcond{1,1}) && signalcond{1,1}(1) == 1
            %LONG TREND HAS BROKEN
            trade = fractal_gentrade(datastruct,code,i,opuncond.comment,-1,freq,0);
            trade.bookname_ = 'tb';
            trade.riskmanager_.setusefractalupdateflag(0);
            trades.push(trade);
        end
    end
end
%
end