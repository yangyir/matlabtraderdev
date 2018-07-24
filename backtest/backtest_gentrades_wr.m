function [trades] = backtest_gentrades_wr(code,px_input,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('TradeFrequency',1,@isnumeric);
    p.addParameter('LengthofPeriod',144,@isnumeric);
    p.addParameter('LengthofStopPeriod',[],@isnumeric);
    %note:the following fields might be replaced with more generic set-up
%     p.addParameter('StoplossRatio',[],@isnumeric);
%     p.addParameter('TargetRatio',[],@isnumeric);
    %
    %
    p.parse(varargin{:});
    freq_ = p.Results.TradeFrequency;
    nperiod_ = p.Results.LengthofPeriod;
    stopperiod_ = p.Results.LengthofStopPeriod;
    %
%     stoploss_ratio = p.Results.StoplossRatio;
%     target_ratio = p.Results.TargetRatio;
    %
    %
    if size(px_input,2) < 5, error('backtest_genpositions_wr:invalid price inputs');end
    if size(px_input,1) <= nperiod_, error('backtest_genpositions_wr:lenth of period input exceed the length of price inputs');end
    
    instrument = code2instrument(code);
%     tick_size = instrument.tick_size;
    %note:column order of px_used:time|open|high|low|close|
    px_used = timeseries_compress(px_input,'frequency',[num2str(freq_),'m'],...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
    
    trades = cTradeOpenArray;
    %note:tough control for future variabes which shall destroy the
    %backtest results
    idx_start = nperiod_ + 1;
    idx_end = size(px_used,1);
    
    for i = idx_start:idx_end
        pxMax = max(px_used(i-nperiod_:i-1,3));
        pxMin = min(px_used(i-nperiod_:i-1,4));
        pxHigh = px_used(i,3);
        pxLow = px_used(i,4);
        datetime = px_used(i,1);
        extrainfo = struct('frequency',[num2str(freq_),'m'],...
            'lengthofperiod',nperiod_,...
            'highesthigh',pxMax,...
            'lowestlow',pxMin);
        if pxHigh > pxMax && pxLow >= pxMin
            %open a short position with price at pxMax
            trade_i = cTradeOpen('code',code,...
                'opendatetime',datetime+1/86400,...
                'opendirection',-1,...
                'openvolume',1,...
                'openprice',pxMax,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',gettradestoptime(code,datetime,freq_,stopperiod_));
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        elseif pxHigh > pxMax && pxLow < pxMin
            %note: a big candle stick happens here and we shall open two
            %position one with short position and the other with long
            %position
            trade_i = cTradeOpen('code',code,...
                'opendatetime',datetime+1/86400,...
                'opendirection',-1,...
                'openvolume',1,...
                'openprice',pxMax,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',gettradestoptime(code,datetime,freq_,stopperiod_));
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
            %
            trade_i = cTradeOpen('code',code,...
                'opendatetime',datetime+1/86400,...
                'opendirection',1,...
                'openvolume',1,...
                'openprice',pxMin,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',gettradestoptime(code,datetime,freq_,stopperiod_));
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        elseif pxHigh <= pxMax && pxLow >= pxMin
            %the candle stick is within the previous (low,high) range
            %and do nothing
        elseif pxHigh < pxMax && pxLow < pxMin
            %open a long position with price at pxLow
            trade_i = cTradeOpen('code',code,...
                'opendatetime',datetime+1/86400,...
                'opendirection',1,...
                'openvolume',1,...
                'openprice',pxMin,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',gettradestoptime(code,datetime,freq_,stopperiod_));
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        end
    end
 
    
    
    
    
end