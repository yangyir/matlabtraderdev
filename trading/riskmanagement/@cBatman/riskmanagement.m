function [unwindtrade] = riskmanagement(obj,varargin)
%cBatman
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return; end

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('Debug',false,@islogical);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    if isempty(mdefut), return; end
    
    trade = obj.trade_;
    if strcmpi(trade.status_,'closed'), return; end
     
    instrument = trade.instrument_;
    candleCell = mdefut.getcandles(instrument);
%     if isempty(candleCell), error('cBatman:riskmanagement:internal error');end
    if isempty(candleCell), return;end
    candleK = candleCell{1};
    buckets = candleK(:,1);
    
    %20181121:big bug fix
    %mantory stoploss shall always be checked for every tick whether breach
    %the stoploss
    %rule1:we check this regardless whether the trade has been set
    %rule2:once the stoploss is breached, we shall inform the strat/trader
    %to unwind the trade
    lasttick = mdefut.getlasttick(instrument);
    if isempty(lasttick), return; end
    ticktime = lasttick(1);
    tickbid = lasttick(2);
    tickask = lasttick(3);
    ticktrade = lasttick(4);
    
    isstoplossbreached = ((trade.opendirection_ == 1 && ticktrade < obj.pxstoploss_) || ...
                (trade.opendirection_ == -1 && ticktrade > obj.pxstoploss_));
    
    if isstoplossbreached    
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        trade.status_ = 'closed';
        unwindtrade = trade;
        if debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
                datestr(ticktime,'yyyy-mm-dd HH:MM'),...
                num2str(obj.pxstoploss_));
        end
        
        if updatepnlforclosedtrade
            trade.runningpnl_ = 0;
            if trade.opendirection_ == 1
                trade.closepnl_ = trade.openvolume_*(tickbid-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
                trade.closeprice_ = tickbid;
            elseif trade.opendirection_ == -1
                trade.closepnl_ = -trade.openvolume_*(tickask-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
                trade.closeprice_ = tickask;
            end
            trade.closedatetime1_ = ticktime;
        end
        
        return
    else
        %mandatory stop loss is not breached and the trade is still alive
        if trade.opendirection_ == 1
            trade.runningpnl_ = trade.openvolume_*(tickbid-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
        else
            trade.runningpnl_ = -trade.openvolume_*(tickask-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
        end
    end
    
    if strcmpi(trade.status_,'unset')
        %set the trade when the candle moves to the next candle after the
        %trade open
        openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        candleTime = candleK(end,1);
        if openBucket < candleTime
            trade.status_ = 'set';
        end
    end
    
    if ~strcmpi(trade.status_,'set'), return; end
        
    %below the trade is still alive and we check with the latest poped-up
    %candle to determine whether we need to update the batman properties
    
    %first we need to check whether it is right time to update batman
    %properties
    equalorNot = (round(buckets(2:end) *10e+07) == round(ticktime*10e+07));
    if sum(sum(equalorNot)) == 0
        idx = buckets(1:end-1) < ticktime & buckets(2:end) >= ticktime;
    else
        idx = buckets(1:end-1) <ticktime & equalorNot;
    end
    this_bucket = buckets(idx);
    if ~isempty(this_bucket)
        this_count = find(buckets == this_bucket);
    else
        if ticktime > buckets(end)
            this_count = size(buckets,1);
        else
            this_count = 0;
        end
    end
    
    if this_count ~= obj.bucket_count_
        %this shall be the time we update batman info
        if this_count == 0
            fprintf('todo\n')
            %here we shall use the last historical data for updating batman
            %info:TODO
            return
        end
        
        candlepoped = candleK(this_count,:);
        
        unwindtrade = obj.riskmanagementwithcandle(candlepoped,...
            'debug',debug,...
            'usecandlelastonly',true,...
            'updatepnlforclosedtrade',updatepnlforclosedtrade);
        
        if ~isempty(unwindtrade), trade.status_ = 'closed';end
        
        obj.bucket_count_ = this_count;
    end
    
end