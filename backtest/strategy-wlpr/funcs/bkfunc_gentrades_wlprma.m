function [trades,px_used] = bkfunc_gentrades_wlprma(code,px_input,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('SampleFrequency','1m',@ischar);
    p.addParameter('NPeriod',144,@isnumeric);
    p.addParameter('Lead',1,@isnumeric);
    p.addParameter('Lag',12,@isnumeric);
    
    p.parse(varargin{:});
    freq = p.Results.SampleFrequency;
    nperiod = p.Results.NPeriod;
    lead = p.Results.Lead;
    lag = p.Results.Lag;
    wrmode = 'flashma';
    
    trades = cTradeOpenArray;
   
    instrument = code2instrument(code);
    px_used = timeseries_compress(px_input,...
        'frequency',freq,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
    
    datetimevec = px_used(:,1);
    pxopen = px_used(:,2);
    pxhigh = px_used(:,3);
    pxlow = px_used(:,4);
    pxclose = px_used(:,5);
    
    wr = willpctr(pxhigh,pxlow,pxclose,nperiod);
    [short,long] = movavg(wr,lead,lag,'e');
   
    %rule:1)once a new high is achieved, open a short once the lead is break
    %down through the lag withoug a new high is achieved afterwards
    %2)once a new low is achieved, open a long once the lead is break up though
    %the lag without a new low is achieved afterwards
    idx_start = nperiod+1;
    idx_end = size(pxclose,1);
    for i = idx_start:idx_end
        pxMax = max(pxhigh(i-nperiod:i-1));
        pxMin = min(pxlow(i-nperiod:i-1));
        pxHigh = pxhigh(i);
        pxLow = pxlow(i);
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
            for j = idx_newmax:idx_end-1
                %we start from the next candle after the new high
                %and we stop in case a new max is reached
                pxHigh = pxhigh(j);
                pxLow = pxlow(j);
                
                
                %but we first check whether we can open a trade
                if pxHigh > pxMax, break;end    %if a new high is achieved, the loop stops
                if pxLow < pxMin, break;end     %if a new low is achi
                
                wrmalead = short(j);
                wrmalag = long(j);
                
                %             if pxHigh <= pxMax && pxLow >= pxLowVec(idx_newmax), continue;end
                if pxHigh <= pxMax && wrmalead >= wrmalag, continue;end
                %
                %             if pxLow < pxLowVec(idx_newmax) && pxOpen <= pxMax
                pxOpen = pxopen(j+1);
                datetime = datetimevec(j+1);
                if wrmalead < wrmalag && pxOpen <= pxMax
                    
                    opendatetime = datetime+1/86400;
                    %
                    id = trades.latest_ + 1;
                    trade_i = cTradeOpen('id',id,'code',code,...
                        'opendatetime',opendatetime,...
                        'opendirection',opendirection,...
                        'openvolume',1,...
                        'openprice',pxOpen);
                    trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                    trades.push(trade_i);
                    break
                end
                
            end
        end
        %
        if newMin
            pxMin = pxLow;
            opendirection = 1;
            idx_newmin = i;
            for j = idx_newmin:idx_end-1
                pxHigh = pxhigh(j);
                pxLow = pxlow(j);
                
                %but we first check whether we can open a trade
                if pxHigh > pxMax, break;end
                if pxLow < pxMin, break;end
                
                wrmalead = short(j);
                wrmalag = long(j);
                
                if pxLow >= pxMin && wrmalead <= wrmalag, continue;end
                %
                pxOpen = pxopen(j+1);
                datetime = datetimevec(j+1);
                if wrmalead > wrmalag && pxOpen >= pxMin
                    opendatetime = datetime+1/86400;
                    
                    id = trades.latest_ + 1;
                    trade_i = cTradeOpen('id',id,'code',code,...
                        'opendatetime',opendatetime,...
                        'opendirection',opendirection,...
                        'openvolume',1,...
                        'openprice',pxOpen);
                    trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
                    trades.push(trade_i);
                    break
                end
                
            end
        end
    end
        
    
end