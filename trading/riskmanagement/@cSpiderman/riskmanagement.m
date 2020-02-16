function [unwindtrade] = riskmanagement(obj,varargin)
%cSpiderman
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return;end
    
    trade = obj.trade_;
    if strcmpi(trade.status_,'closed'), return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('Debug',false,@islogical);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('Strategy',{},...
        @(x) validateattributes(x,{'cStratFutMultiFractal'},{},'','Strategy'));
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    strat = p.Results.Strategy;
    if isempty(mdefut), return;end
    
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    instrument = trade.instrument_;
    lasttick = mdefut.getlasttick(instrument);
    if isempty(lasttick), return; end
    ticktime = lasttick(1);
    unwindtrade = obj.riskmanagementwithtick(lasttick,varargin{:});
    if ~isempty(unwindtrade), return;end
   
    candleCell = mdefut.getcandles(instrument);
    if isempty(candleCell), return;end
    candleK = candleCell{1};
    buckets = candleK(:,1);
    
    if strcmpi(trade.status_,'unset')
        openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        candleTime = candleK(end,1);
        if openBucket <= candleTime
            trade.status_ = 'set';
            obj.status_ = 'set';
        end
    end
    
    if ~strcmpi(trade.status_,'set'), return; end
    if ticktime < buckets(end), return;end
    
    this_count = size(buckets,1)-1;
    if this_count ~= obj.bucket_count_
        %the last candle has just finished
        if this_count < 1
            histcandleCell = mdefut.gethistcandles(instrument);
            if isempty(histcandleCell), return; end
            candlepoped = histcandleCell{1}(end,:);
        else
            candlepoped = candleK(this_count,:);
        end
        
        [~,idx] = strat.hasinstrument(instrument);
        [~,~,px] = mdefut.calc_macd_(instrument,'includelastcandle',0,'removelimitprice',1);
        extrainfo = struct('p',px,'hh',strat.hh_{idx},'ll',strat.ll_{idx},...
            'jaw',strat.jaw_{idx},'teeth',strat.teeth_{idx},'lips',strat.lips_{idx},...
            'bs',strat.bs_{idx},'ss',strat.ss_{idx},'bc',strat.bc_{idx},'sc',strat.sc_{idx},...
            'lvlup',strat.lvlup_{idx},'lvldn',strat.lvldn_{idx});
        
        unwindtrade = obj.riskmanagementwithcandle(candlepoped,...
            'debug',debug,...
            'usecandlelastonly',true,...
            'updatepnlforclosedtrade',updatepnlforclosedtrade,...
            'extrainfo',extrainfo);
        
        obj.bucket_count_ = this_count;
    end
    
    
end