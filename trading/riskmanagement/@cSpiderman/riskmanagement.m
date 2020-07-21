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
    
    if ticktime < buckets(end), return;end
    
    if strcmpi(trade.status_,'unset')
%         openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        idxopen = find(candleK(:,1) <= trade.opendatetime1_,1,'last')-1;
        if idxopen > 0
            openBucket = candleK(idxopen,1);
            setflag = openBucket <= candleK(end,1);
        else
            setflag = true;
        end
        if setflag
            trade.status_ = 'set';
            obj.status_ = 'set';
            if trade.opendirection_ == 1 && isnan(obj.tdhigh_) && isnan(obj.tdlow_)
                [~,ss,~,~,~,~,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                if ss(end) >= 9
                    ssreached = ss(end);
                    obj.tdhigh_ = max(px(end-ssreached+1:end,3));
                    tdidx = find(px(end-ssreached+1:end,3)==obj.tdhigh_,1,'last')+length(px)-ssreached;
                    obj.tdlow_ = px(tdidx,4);
                    if obj.tdlow_ - (obj.tdhigh_-obj.tdlow_) > obj.pxstoploss_
                        obj.pxstoploss_ = obj.tdlow_ - (obj.tdhigh_-obj.tdlow_);
                    end
                end
            elseif trade.opendirection_ == -1 && isnan(obj.tdhigh_) && isnan(obj.tdlow_)
                [bs,~,~,~,~,~,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                if bs(end) >= 9
                    bsreached = bs(end);
                    obj.tdlow_ = min(px(end-bsreached+1:end,4));
                    tdidx = find(px(end-bsreached+1:end,4)==obj.tdlow_,1,'last')+length(px)-bsreached;
                    obj.tdhigh_ = px(tdidx,3);
                    if obj.tdhigh_ + (obj.tdhigh_-obj.tdlow_) < obj.pxstoploss_
                        obj.pxstoploss_ = obj.tdhigh_ + (obj.tdhigh_-obj.tdlow_);
                    end
                end
            end
            %
            if trade.opendirection_ == 1
                [wad,px] = mdefut.calc_wad_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                obj.wadopen_ = wad(end);
                obj.cpopen_ = px(end,5);
                obj.wadhigh_ = wad(end);
                obj.cphigh_ = px(end,5);
            elseif trade.opendirection_ == -1
                [wad,px] = mdefut.calc_wad_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                obj.wadopen_ = wad(end);
                obj.cpopen_ = px(end,5);
                obj.wadlow_ = wad(end);
                obj.cplow_ = px(end,5);
            end
        end
        this_count = size(buckets,1)-1;
        if this_count ~= obj.bucket_count_
            obj.bucket_count_ = this_count;
        end
        return
    end
    
    if ~strcmpi(trade.status_,'set'), return; end
    
    if strcmpi(strat.mode_,'replay')
        runningt = strat.replay_time1_;
    else
        runningt = now;
    end
    
    if ticktime - runningt < -1e-3
          return;
    end
    
    runningmm = hour(runningt)*60+minute(runningt);
    runriskmanagementbeforemktclose = false;
    
    if runningmm == trade.oneminb4close1_ && second(runningt) > 56
        runriskmanagementbeforemktclose = true;
    elseif runningmm == trade.oneminb4close2_ && second(runningt) > 56
        runriskmanagementbeforemktclose = true;
    end
    
    
%     if (runningmm == 899 || runningmm == 914) && second(runningt) > 56
%         cobd = floor(runningt);
%         nextbd = businessdate(cobd);
%         runriskmanagementbeforemktclose = nextbd - cobd <= 3;
%     end
    
    this_count = size(buckets,1)-1;
%     if this_count ~= obj.bucket_count_ || runriskmanagementbeforemktclose
    if this_count ~= obj.bucket_count_
        %the last candle has just finished
%         if this_count < 1
%             histcandleCell = mdefut.gethistcandles(instrument);
%             if isempty(histcandleCell), return; end
%             candlepoped = histcandleCell{1}(end,:);
%         else
%             candlepoped = candleK(this_count,:);
%         end
        
        if ~runriskmanagementbeforemktclose
            [bs,ss,lvlup,lvldn,bc,sc,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
            [~,~,hh,ll] = mdefut.calc_fractal_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
            wad = mdefut.calc_wad_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
        else
            [bs,ss,lvlup,lvldn,bc,sc,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [~,~,hh,ll] = mdefut.calc_fractal_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
%             candlepoped = px(end,:);
            wad = mdefut.calc_wad_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
        end
         
        extrainfo = struct('p',px,'hh',hh,'ll',ll,...
            'jaw',jaw,'teeth',teeth,'lips',lips,...
            'bs',bs,'ss',ss,'bc',bc,'sc',sc,...
            'lvlup',lvlup,'lvldn',lvldn,'wad',wad,...
            'latestopen',lasttick(4));
        
        unwindtrade = obj.riskmanagementwithcandle([],...
            'debug',debug,...
            'usecandlelastonly',true,...
            'updatepnlforclosedtrade',updatepnlforclosedtrade,...
            'extrainfo',extrainfo);
        
        obj.bucket_count_ = this_count;
    else
        if runriskmanagementbeforemktclose
            %only unwind existing trade
            [bs,ss,lvlup,lvldn,bc,sc,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [~,~,hh,ll] = mdefut.calc_fractal_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
%             candlepoped = px(end,:);
            wad = mdefut.calc_wad_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            extrainfo = struct('p',px,'hh',hh,'ll',ll,...
                'jaw',jaw,'teeth',teeth,'lips',lips,...
                'bs',bs,'ss',ss,'bc',bc,'sc',sc,...
                'lvlup',lvlup,'lvldn',lvldn,'wad',wad,...
                'latestopen',lasttick(4));
             unwindtrade = obj.riskmanagementwithcandle([],...
                 'debug',debug,...
                 'usecandlelastonly',true,...
                 'updatepnlforclosedtrade',updatepnlforclosedtrade,...
                 'extrainfo',extrainfo);
        end
    end
    
    
end