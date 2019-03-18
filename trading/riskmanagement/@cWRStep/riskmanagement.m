function [unwindtrade] = riskmanagement(obj,varargin)
%cWRStep
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
    if isempty(candleCell), return;end
    
    candleK = candleCell{1};
    buckets = candleK(:,1);
    
    lasttick = mdefut.getlasttick(instrument);
    if isempty(lasttick), return; end
    ticktime = lasttick(1);
    
    unwindtrade = obj.riskmanagementwithtick(lasttick,varargin{:});
    
    if ~isempty(unwindtrade)
        return; 
    end
    
    if strcmpi(trade.status_,'unset')
        %set the trade when the candle moves to the next candle after the
        %trade open
        %as we will use the Williams%R calculated with the close price of
        %the open bucket for risk management purposes
        openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        candleTime = candleK(end,1);
        if openBucket < candleTime
            trade.status_ = 'set';
            obj.status_ = 'set';
        end
    end
    
    if ~strcmpi(trade.status_,'set'), return; end
        
    %below the trade is still alive and we check with the latest poped-up
    %candle to determine whether we need to update the wrstep properties
    
    %first we need to check whether it is right time to update batman

    if ticktime < buckets(end)
        fprintf('cWRStep:riskmanagement:last tick time shall beyond last candle record time\n')
        fprintf('\tnow:%s\n',datestr(now));
        fprintf('\tticktime:%s\n',datestr(ticktime));
        fprintf('\tbuckettime:%s\n',datestr(buckets(end)));
        return
    end
    
    this_count = size(buckets,1)-1;

    
    if this_count ~= obj.bucket_count_
        %this shall be the time we update wrstep info
        if this_count < 1
            histcandleCell = mdefut.gethistcandles(instrument);
            if isempty(histcandleCell), return; end
            candlepoped = histcandleCell{1}(end,:);
        else
            candlepoped = candleK(this_count,:);
        end
        
        ti = mdefut.calc_technical_indicators(instrument);
        wr = ti{1}(1);
        
        unwindtrade = obj.riskmanagementwithcandle(candlepoped,wr,...
            'debug',debug,...
            'usecandlelastonly',true,...
            'updatepnlforclosedtrade',updatepnlforclosedtrade);
        
        if ~isempty(unwindtrade), trade.status_ = 'closed';end
        
        obj.bucket_count_ = this_count;
    end
end