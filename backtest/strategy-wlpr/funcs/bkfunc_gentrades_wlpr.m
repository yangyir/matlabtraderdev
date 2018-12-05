function [trades,px_used] = bkfunc_gentrades_wlpr(code,px_input,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('SampleFrequency','1m',@ischar);
    p.addParameter('NPeriod',144,@isnumeric);
    p.addParameter('NStopPeriod',[],@isnumeric);
    p.addParameter('AskOpenSpread',0,@isnumeric);
    p.addParameter('BidOpenSpread',0,@isnumeric);
    p.addParameter('WRMode','classic',@ischar);
    p.addParameter('OverBought',0,@isnumeric);
    p.addParameter('OverSold',-100,@isnumeric);
    
    p.parse(varargin{:});
    freq = p.Results.SampleFrequency;     % unit of how many minutes
    nperiod = p.Results.NPeriod;
    nstopperiod = p.Results.NStopPeriod;
    
    askopenspread = p.Results.AskOpenSpread;
    if askopenspread < 0,error('bkfunc_gentrades_wlpr:invalid negative ask open spread input!');end
    
    bidopenspread = p.Results.BidOpenSpread;
    if bidopenspread < 0,error('bkfunc_gentrades_wlpr:invalid negative bid open spread input!');end
    
    wrmode = p.Results.WRMode;
    if ~(strcmpi(wrmode,'classic') || strcmpi(wrmode,'follow') ...
            || strcmpi(wrmode,'reverse1') || strcmpi(wrmode,'reverse2') ...
            || strcmpi(wrmode,'all'))
        error('bkfunc_gentrades_wlpr:invalid wrmode input')
    end

    [nobs,ncols] = size(px_input);
    if ncols < 5,error('bkfunc_gentrades_wlpr:invalid price inputs');end
    
    if nobs <= nperiod ,error('bkfunc_gentrades_wlpr:length of period input exceed the number of obserations');end
    
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
    
    trades = cTradeOpenArray;
    %note:tough control for future variabes which shall destroy the
    %backtest results
    idx_start = nperiod + 1;
    idx_end = size(px_used,1);
    %
    if strcmpi(wrmode,'classic')
        wr = willpctr(pxHighVec,pxLowVec,pxCloseVec,nperiod);
        overbought = p.Results.OverBought;
        oversold = p.Results.OverSold;
        for i = idx_start:idx_end
            pxMax = max(pxHighVec(i-nperiod:i-1));
            pxMin = min(pxLowVec(i-nperiod:i-1));
%             pxHigh = pxHighVec(i);
%             pxLow = pxLowVec(i);
            datetime = dateTimeVec(i);
            extrainfo = struct('frequency',freq,...
                'lengthofperiod',nperiod,...
                'highesthigh',pxMax,...
                'lowestlow',pxMin,...
                'wrmode',wrmode);
            %note: we add 1 sec to the timevec indicting it fells between the
            %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
            opendatetime = datetime+1/86400;
            if ~isempty(nstopperiod)
                stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
            else
                stopdatetime = [];
            end
            %
            %open a short position with the open price of this candle
            if wr(i-1) >= overbought
                trade_i = cTradeOpen('code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',-1,...
                    'openvolume',1,...
                    'openprice',pxOpenVec(i),...
                    'targetprice',[],...
                    'stoplossprice',[],...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
            %open a long position with the open price of this candle
            if wr(i-1) <= oversold
                %note: we add 1 sec to the timevec indicting it fells between the
                %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
                trade_i = cTradeOpen('code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',1,...
                    'openvolume',1,...
                    'openprice',pxOpenVec(i),...
                    'targetprice',[],...
                    'stoplossprice',[],...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
        end
        %
    elseif strcmpi(wrmode,'reverse1')
        for i = idx_start:idx_end
            pxMax = max(pxHighVec(i-nperiod:i-1));
            pxMin = min(pxLowVec(i-nperiod:i-1));
            pxHigh = pxHighVec(i);
            pxLow = pxLowVec(i);
            datetime = dateTimeVec(i);
            extrainfo = struct('frequency',freq,...
                'lengthofperiod',nperiod,...
                'highesthigh',pxMax,...
                'lowestlow',pxMin,...
                'tradetype',wrmode);
            %note: we add 1 sec to the timevec indicting it fells between the
            %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
            opendatetime = datetime+1/86400;
            if ~isempty(nstopperiod)
                stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
            else
                stopdatetime = [];
            end
            if pxHigh > pxMax + bidopenspread*ticksize
                trade_i = cTradeOpen('code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',-1,...
                    'openvolume',1,...
                    'openprice',pxMax + ticksize*bidopenspread,...
                    'targetprice',[],...
                    'stoplossprice',[],...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
            if pxLow < pxMin - askopenspread*ticksize
                trade_i = cTradeOpen('code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',1,...
                    'openvolume',1,...
                    'openprice',pxMin - askopenspread*ticksize,...
                    'targetprice',[],...
                    'stoplossprice',[],...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
        end
        %
    elseif strcmpi(wrmode,'reverse2')
        idx_check = idx_start;
        while idx_check <= idx_end
            pxMax = max(pxHighVec(idx_check-nperiod:idx_check-1));
            pxMin = min(pxLowVec(idx_check-nperiod:idx_check-1));
            newMax = false;
            newMin = false;
            for i = idx_check:idx_end
                pxHigh = pxHighVec(i);
                pxLow = pxLowVec(i);
                if pxHigh > pxMax
                    %if a new high is breached, we break the loop
                    pxMax = pxHigh;
                    idx_check = i+1;
                    newMax = true;
                    break
                end
                %
                if pxLow < pxMin
                    %if a new low is breached, we break the loop
                    pxMin = pxLow;
                    idx_check = i+1;
                    newMin = true;
                    break
                end
            end
            %
            if newMax || newMin
                extrainfo = struct('frequency',freq,...
                    'lengthofperiod',nperiod,...
                    'highesthigh',pxMax,...
                    'lowestlow',pxMin,...
                    'tradetype',wrmode);
                for i = idx_check:idx_end
                    %we start from the next candle onwards
                    pxHigh = pxHighVec(i);
                    pxLow = pxLowVec(i);
                    pxOpen = pxOpenVec(i);
                    datetime = dateTimeVec(i);
                    %note: we add 1 sec to the timevec indicting it fells between the
                    %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
                    opendatetime = datetime+1/86400;
                    if ~isempty(nstopperiod)
                        stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
                    else
                        stopdatetime = [];
                    end
                    
                    if newMax && pxLow < pxLowVec(idx_check)
                        trade_i = cTradeOpen('code',code,...
                            'opendatetime',opendatetime,...
                            'opendirection',-1,...
                            'openvolume',1,...
                            'openprice',min(pxOpen,pxLowVec(idx_check)),...
                            'targetprice',[],...
                            'stoplossprice',pxMax,...
                            'stopdatetime',stopdatetime);
                        trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                        trades.push(trade_i);
                        idx_check = i;
                        break
                    end
                    %
                    if newMin && pxHigh > pxHighVec(idx_check)
                        trade_i = cTradeOpen('code',code,...
                            'opendatetime',opendatetime,...
                            'opendirection',1,...
                            'openvolume',1,...
                            'openprice',max(pxOpen,pxHighVec(idx_check)),...
                            'targetprice',[],...
                            'stoplossprice',pxMin,...
                            'stopdatetime',stopdatetime);
                        trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                        trades.push(trade_i);
                        idx_check = i;
                    end
                end
            else
                idx_check = idx_check + 1;
            end
        end
        %
    elseif strcmpi(wrmode,'follow')
        for i = idx_start:idx_end
            pxMax = max(pxHighVec(i-nperiod:i-1));
            pxMin = min(pxLowVec(i-nperiod:i-1));
            pxHigh = pxHighVec(i);
            pxLow = pxLowVec(i);
            datetime = dateTimeVec(i);
            extrainfo = struct('frequency',freq,...
                'lengthofperiod',nperiod,...
                'highesthigh',pxMax,...
                'lowestlow',pxMin,...
                'tradetype',wrmode);
            %note: we add 1 sec to the timevec indicting it fells between the
            %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
            opendatetime = datetime+1/86400;
            if ~isempty(nstopperiod)
                stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
            else
                stopdatetime = [];
            end
            if pxHigh > pxMax + askopenspread*ticksize
                trade_i = cTradeOpen('code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',1,...
                    'openvolume',1,...
                    'openprice',pxMax + ticksize*askopenspread,...
                    'targetprice',[],...
                    'stoplossprice',[],...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
            if pxLow < pxMin - bidopenspread*ticksize
                trade_i = cTradeOpen('code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',-1,...
                    'openvolume',1,...
                    'openprice',pxMin - bidopenspread*ticksize,...
                    'targetprice',[],...
                    'stoplossprice',[],...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
        end
        %
    elseif strcmpi(wrmode,'all')
        error('ERROR:bkfunc_gentrades_wlpr:wrmode %s not supported',wrmode);
    end
        
    
end