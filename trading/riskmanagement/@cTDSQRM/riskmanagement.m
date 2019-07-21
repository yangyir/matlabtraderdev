function [unwindtrade] = riskmanagement(obj,varargin)
%cTDSQRM
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return;end
    if isempty(obj.trade_), return;end
    if strcmpi(obj.trade_.status_,'closed'), return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('Debug',false,@islogical);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    
    trade = obj.trade_;
    instrument = trade.instrument_;
    lasttick = mdefut.getlasttick(instrument);
    if isempty(lasttick), return; end
    
    unwindtrade = obj.riskmanagementwithtick(lasttick,varargin{:});
    %knock-out trade on tick level
    if ~isempty(unwindtrade), return; end
    
    candleCell = mdefut.getcandles(instrument);
    if isempty(candleCell), return;end
    candleK = candleCell{1};
    buckets = candleK(:,1);
    
    if strcmpi(trade.status_,'unset')
        %set the trade when the candle moves to the next candle after the
        %trade open
        %as we will use the TDSQ with MACD and Williams%R of the close
        %price for risk management purposes
        openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        candleTime = buckets(end,1);
        if openBucket < candleTime
            trade.status_ = 'set';
            obj.status_ = 'set';
        end
    end
    
    if ~strcmpi(trade.status_,'set'),return;end
    
    %below the trade is still alive and we check whether the latest update
    %candle to determine whehter we need to unwind trade trade
    
    ticktime = lasttick(1);
    if ticktime < buckets(end)
        fprintf('cWRStep:riskmanagement:last tick time shall beyond last candle record time\n')
        fprintf('\tnow:%s\n',datestr(now));
        fprintf('\tticktime:%s\n',datestr(ticktime));
        fprintf('\tbuckettime:%s\n',datestr(buckets(end)));
        return
    end
    
    this_count = size(buckets,1)-1;
    
    if this_count ~= obj.bucket_count_
        %this shall be the time we update the tdsq with other indicators
    end
        

    
%     debug = p.Results.Debug;
%     updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
%     
%     
%     
%     
%     
%     
    
    
    
    
    
    
    
    
end