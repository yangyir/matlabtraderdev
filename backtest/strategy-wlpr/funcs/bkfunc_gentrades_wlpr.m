function [trades,px_used] = bkfunc_gentrades_wlpr(code,px_input,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('SampleFrequency','1m',@ischar);
    p.addParameter('NPeriod',144,@isnumeric);
    p.addParameter('NStopPeriod',[],@isnumeric);
    p.addParameter('LongOpenSpread',0,@isnumeric);
    p.addParameter('ShortOpenSpread',0,@isnumeric);
    
    p.parse(varargin{:});
    freq = p.Results.SampleFrequency;     % unit of how many minutes
    nperiod = p.Results.NPeriod;
    nstopperiod = p.Results.NStopPeriod;
    
    longopenspread = p.Results.LongOpenSpread;
    if longopenspread < 0
        error('bkfunc_gentrades_wlpr:invalid negative long open spread input!')
    end
    
    shortopenspread = p.Results.ShortOpenSpread;
    if shortopenspread < 0
        error('bkfunc_gentrades_wlpr:invalid negative short open spread input!')
    end

    [nobs,ncols] = size(px_input);
    if ncols < 5 
        error('bkfunc_gentrades_wlpr:invalid price inputs')
    end
    
    if nobs <= nperiod 
        error('bkfunc_gentrades_wlpr:length of period input exceed the number of obserations')
    end
    
    instrument = code2instrument(code);
    px_used = timeseries_compress(px_input,...
        'frequency',freq,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
    ticksize = instrument.tick_size;
    
    dateTimeVec = px_used(:,1);
    pxOpenVec = px_used(:,2);
    pxHighVec = px_used(:,3);
    pxLowVec = px_used(:,4);
    pxCloseVec = px_used(:,5);
        
    variablenotused(pxOpenVec);
    variablenotused(pxCloseVec);

    trades = cTradeOpenArray;
    %note:tough control for future variabes which shall destroy the
    %backtest results
    idx_start = nperiod + 1;
    idx_end = size(px_used,1);
    
    for i = idx_start:idx_end
        pxMax = max(pxHighVec(i-nperiod:i-1))+shortopenspread*ticksize;
        pxMin = min(pxLowVec(i-nperiod:i-1))-longopenspread*ticksize;
        pxHigh = pxHighVec(i);
        pxLow = pxLowVec(i);
        datetime = dateTimeVec(i);
        extrainfo = struct('frequency',freq,...
            'lengthofperiod',nperiod,...
            'highesthigh',pxMax-shortopenspread*ticksize,...
            'lowestlow',pxMin+longopenspread*ticksize);
        %note: we add 1 sec to the timevec indicting it fells between the
        %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
        opendatetime = datetime+1/86400;
        if ~isempty(nstopperiod)
            stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
        else
            stopdatetime = [];
        end
        if pxHigh > pxMax && pxLow >= pxMin
            %open a short position with price at pxMax
            trade_i = cTradeOpen('code',code,...
                'opendatetime',opendatetime,...
                'opendirection',-1,...
                'openvolume',1,...
                'openprice',pxMax + ticksize*shortopenspread,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',stopdatetime);
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        elseif pxHigh > pxMax && pxLow < pxMin
            %note: a big candle stick happens here and we shall open two
            %position one with short position and the other with long
            %position
            trade_i = cTradeOpen('code',code,...
                'opendatetime',opendatetime,...
                'opendirection',-1,...
                'openvolume',1,...
                'openprice',pxMax,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',stopdatetime);
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
            %
            trade_i = cTradeOpen('code',code,...
                'opendatetime',opendatetime,...
                'opendirection',1,...
                'openvolume',1,...
                'openprice',pxMin,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',stopdatetime);
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        elseif pxHigh <= pxMax && pxLow >= pxMin
            %the candle stick is within the previous (low,high) range
            %and do nothing
        elseif pxHigh < pxMax && pxLow < pxMin
            %open a long position with price at pxLow
            trade_i = cTradeOpen('code',code,...
                'opendatetime',opendatetime,...
                'opendirection',1,...
                'openvolume',1,...
                'openprice',pxMin,...
                'targetprice',[],...
                'stoplossprice',[],...
                'stopdatetime',stopdatetime);
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        end
    end
    
end