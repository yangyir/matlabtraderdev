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
            || strcmpi(wrmode,'reverse') || strcmpi(wrmode,'flash') ...
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
%             if abs(wr(i-1) - overbought) <= instrument.tick_size/(pxMax-pxMin)
                id = trades.latest_ + 1;
                trade_i = cTradeOpen('id',id,'code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',-1,...
                    'openvolume',1,...
                    'openprice',pxOpenVec(i),...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
            %open a long position with the open price of this candle
            if wr(i-1) <= oversold
%             if abs(wr(i-1) - oversold) <= instrument.tick_size/(pxMax-pxMin)
                %note: we add 1 sec to the timevec indicting it fells between the
                %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
                id = trades.latest_ + 1;
                trade_i = cTradeOpen('id',id,'code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',1,...
                    'openvolume',1,...
                    'openprice',pxOpenVec(i),...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
        end
        %
    elseif strcmpi(wrmode,'reverse')
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
                'wrmode',wrmode);
            %note: we add 1 sec to the timevec indicting it fells between the
            %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
            opendatetime = datetime+1/86400;
            if ~isempty(nstopperiod)
                stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
            else
                stopdatetime = [];
            end
            if pxHigh > pxMax + bidopenspread*ticksize
                if pxOpenVec(i) > pxMax + bidopenspread*ticksize
                    px = pxOpenVec(i);
                else
                    px = pxMax + bidopenspread*ticksize;
                end
                id = trades.latest_ + 1;
                trade_i = cTradeOpen('id',id,'code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',-1,...
                    'openvolume',1,...
                    'openprice',px,...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
            if pxLow < pxMin - askopenspread*ticksize
                if pxOpenVec(i) < pxMin - askopenspread*ticksize
                    px = pxOpenVec(i);
                else
                    px = pxMin - askopenspread*ticksize;
                end
                id = trades.latest_ + 1;
                trade_i = cTradeOpen('id',id,'code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',1,...
                    'openvolume',1,...
                    'openprice',px,...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
        end
        %
    elseif strcmpi(wrmode,'flash')
        for i = idx_start:idx_end
            pxMax = max(pxHighVec(i-nperiod:i-1));
            pxMin = min(pxLowVec(i-nperiod:i-1));
            pxHigh = pxHighVec(i);
            pxLow = pxLowVec(i);
            newMax = pxHigh > pxMax;
            newMin = pxLow < pxMin;
            extrainfo = struct('frequency',freq,...
                'lengthofperiod',nperiod,...
                'highesthigh',max(pxHigh,pxMax),...
                'lowestlow',min(pxLow,pxMin),...
                'wrmode',wrmode);
            if newMax
                pxMax = pxHigh;
                opendirection = -1;
                idx_newmax = i;
                for j = idx_newmax+1:idx_end
                    %we start from the next candle after the new high
                    %and we stop in case a new max is reached
                    pxHigh = pxHighVec(j);
                    pxLow = pxLowVec(j);
                    pxOpen = pxOpenVec(j);
                    datetime = dateTimeVec(j);
                    %but we first check whether we can open a trade
                    if pxHigh <= pxMax && pxLow >= pxLowVec(idx_newmax), continue;end
                    %
                    if pxLow < pxLowVec(idx_newmax) && pxOpen <= pxMax
                        opendatetime = datetime+1/86400;
                        if ~isempty(nstopperiod)
                            stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
                        else
                             stopdatetime = [];
                        end
                        %
                        id = trades.latest_ + 1;
                        trade_i = cTradeOpen('id',id,'code',code,...
                            'opendatetime',opendatetime,...
                            'opendirection',opendirection,...
                            'openvolume',1,...
                            'openprice',min(pxOpen,pxLowVec(idx_newmax)),...
                            'stoplossprice',pxMax,...
                            'stopdatetime',stopdatetime);
                        trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                        trades.push(trade_i);
                        break
                    end
                    if pxHigh > pxMax, break;end
                    if pxLow < pxMin, break;end
                end
            end
            %
            if newMin
                pxMin = pxLow;
                opendirection = 1;
                idx_newmin = i;
                for j = idx_newmin+1:idx_end
                    pxHigh = pxHighVec(j);
                    pxLow = pxLowVec(j);
                    pxOpen = pxOpenVec(j);
                    datetime = dateTimeVec(j);
                    if pxLow >= pxMin && pxHigh <= pxHighVec(idx_newmin), continue;end
                    %
                    if pxHigh > pxHighVec(idx_newmin) && pxOpen >= pxMin
                        opendatetime = datetime+1/86400;
                        if ~isempty(nstopperiod)
                            stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
                        else
                            stopdatetime = [];
                        end
                        id = trades.latest_ + 1;
                        trade_i = cTradeOpen('id',id,'code',code,...
                            'opendatetime',opendatetime,...
                            'opendirection',opendirection,...
                            'openvolume',1,...
                            'openprice',max(pxOpen,pxHighVec(idx_newmin)),...
                            'stoplossprice',pxMin,...
                            'stopdatetime',stopdatetime);
                        trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                        trades.push(trade_i);
                        break
                    end
                    if pxHigh > pxMax, break;end
                    if pxLow < pxMin, break;end
                end
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
                'wrmode',wrmode);
            %note: we add 1 sec to the timevec indicting it fells between the
            %bucket starting from dateTimeVec(i) and dateTimeVec(i+1)
            opendatetime = datetime+1/86400;
            if ~isempty(nstopperiod)
                stopdatetime = gettradestoptime(code,opendatetime,freq,nstopperiod);
            else
                stopdatetime = [];
            end
            if pxHigh > pxMax + askopenspread*ticksize
                id = trades.latest_ + 1;
                trade_i = cTradeOpen('id',id,'code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',1,...
                    'openvolume',1,...
                    'openprice',pxMax + ticksize*askopenspread,...
                    'stopdatetime',stopdatetime);
                trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                trades.push(trade_i);
            end
            %
            if pxLow < pxMin - bidopenspread*ticksize
                id = trades.latest_ + 1;
                trade_i = cTradeOpen('id',id,'code',code,...
                    'opendatetime',opendatetime,...
                    'opendirection',-1,...
                    'openvolume',1,...
                    'openprice',pxMin - bidopenspread*ticksize,...
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