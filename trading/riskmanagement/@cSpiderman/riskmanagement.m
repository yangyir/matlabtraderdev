function [unwindtrade] = riskmanagement(obj,varargin)
%cSpiderman
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return;end
    
    trade = obj.trade_;
    if strcmpi(trade.status_,'closed'), return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('MDEOpt',{},@(x) validateattributes(x,{'cMDEOpt'},{},'','MDEFut'));
    p.addParameter('Debug',false,@islogical);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('Strategy',{},...
        @(x) validateattributes(x,{'cStratFutMultiFractal','cStratOptMultiFractal'},{},'','Strategy'));
    p.addParameter('KellyTables',{},@isstruct);
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    mdeopt = p.Results.MDEOpt;
    strat = p.Results.Strategy;
    kellytables = p.Results.KellyTables;
    
    if isempty(mdefut) && isempty(mdeopt), return;end
    if ~isempty(mdefut) && ~isempty(mdeopt)
        error('ERROR;%s:riskmanagement:invalid combination of cMDEFut and cMDEOpt',class(obj));
    end
    
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    instrument = trade.instrument_;
    
    ismdeopt = isa(strat,'cStratOptMultiFractal') && ~isempty(mdeopt);
    
    if ~ismdeopt
        lasttick = mdefut.getlasttick(instrument);
    else
        lasttick = mdeopt.getlasttick(instrument);
    end
    if isempty(lasttick), return; end
    ticktime = lasttick(1);
    unwindtrade = obj.riskmanagementwithtick(lasttick,varargin{:});
    if ~isempty(unwindtrade)
        return
    end
   
    if ~ismdeopt
        candleCell = mdefut.getcandles(instrument);
    else
        candleCell = mdeopt.getcandles(instrument);
    end
    if isempty(candleCell), return;end
    candleK = candleCell{1};
    buckets = candleK(:,1);
    
    if ticktime < buckets(end), return;end
    
    if strcmpi(trade.status_,'unset')
%         openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        if ~strcmpi(trade.opensignal_.frequency_,'1440m')
            idxopen = find(candleK(:,1) <= trade.opendatetime1_,1,'last')-1;
        else
            idxopen = find(candleK(:,1) <= trade.opendatetime1_,1,'last');
        end
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
                if ~ismdeopt
                    [~,ss,~,~,~,~,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                else
                    [~,ss,~,~,~,~,px] = mdeopt.calc_tdsq_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                end
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
                if ~ismdeopt
                    [bs,~,~,~,~,~,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                else
                    [bs,~,~,~,~,~,px] = mdeopt.calc_tdsq_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                end
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
            if ~ismdeopt
                [~,teeth,~] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
            else
                [~,teeth,~] = mdeopt.calc_alligator_('IncludeLastCandle',0,'RemoveLimitPrice',1);
            end
            if trade.opendirection_ == 1
                if obj.pxstoploss_ < teeth(end)
                    obj.pxstoploss_ = floor(teeth(end)/instrument.tick_size)*instrument.tick_size;
                    obj.closestr_ = 'fractal:teeth';
                end
            elseif trade.opendirection_ == -1
                if obj.pxstoploss_ > teeth(end)
                    obj.pxstoploss_ = ceil(teeth(end)/instrument.tick_size)*instrument.tick_size;
                    obj.closestr_ = 'fractal:teeth';
                end
            end
            if trade.opendirection_ == 1
                if ~ismdeopt
                    [wad,px] = mdefut.calc_wad_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                else
                    [wad,px] = mdeopt.calc_wad_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                end
                obj.wadopen_ = wad(end);
                obj.cpopen_ = px(end,5);
                obj.wadhigh_ = wad(end);
                obj.cphigh_ = px(end,5);
            elseif trade.opendirection_ == -1
                if ~ismdeopt
                    [wad,px] = mdefut.calc_wad_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                else
                    [wad,px] = mdeopt.calc_wad_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                end
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
    
    if ~ismdeopt
        freq = mdefut.getcandlefreq(instrument);
    else
        freq = mdeopt.getcandlefreq(instrument);
    end
    runningmm = hour(runningt)*60+minute(runningt);
    tickm = hour(ticktime)*60+minute(ticktime);
    runriskmanagementbeforemktclose = false;
    
%     %for DEBUG
%     if runningmm == trade.oneminb4close1_
%         fprintf('%s\t%s\n',datestr(runningt),datestr(ticktime));
%     end
%     
%     %for DEBUG
%     if runningmm == trade.oneminb4close2_
%         fprintf('%s\t%s\n',datestr(runningt),datestr(ticktime));
%     end
    
%     fprintf('%s\t%s\n',datestr(runningt),datestr(ticktime));
    
    if freq ~= 1440
        if runningmm == trade.oneminb4close1_ && tickm == trade.oneminb4close1_ && (second(runningt) >= 59 || second(ticktime) >= 59)
            runriskmanagementbeforemktclose = true;
        elseif runningmm == trade.oneminb4close2_ && tickm == trade.oneminb4close2_ && (second(runningt) >= 59 || second(ticktime) >= 59)
            runriskmanagementbeforemktclose = true;
        end
    else
        if runningmm == trade.oneminb4close1_ && tickm == trade.oneminb4close1_ && (second(runningt) >= 59 || second(ticktime) >= 59)
            runriskmanagementbeforemktclose = true;
        end
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
        if ~runriskmanagementbeforemktclose
            if ~ismdeopt
                [bs,ss,lvlup,lvldn,bc,sc,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                [idxHH,idxLL,hh,ll] = mdefut.calc_fractal_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
                wad = mdefut.calc_wad_(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
            else
                [bs,ss,lvlup,lvldn,bc,sc,px] = mdeopt.calc_tdsq_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                [idxHH,idxLL,hh,ll] = mdeopt.calc_fractal_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = mdeopt.calc_alligator_('IncludeLastCandle',0,'RemoveLimitPrice',1);
                wad = mdeopt.calc_wad_('IncludeLastCandle',0,'RemoveLimitPrice',1);
            end
        else
            if ~ismdeopt
                [bs,ss,lvlup,lvldn,bc,sc,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [idxHH,idxLL,hh,ll] = mdefut.calc_fractal_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                wad = mdefut.calc_wad_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            else
                [bs,ss,lvlup,lvldn,bc,sc,px] = mdeopt.calc_tdsq_('IncludeLastCandle',1,'RemoveLimitPrice',1);
                [idxHH,idxLL,hh,ll] = mdeopt.calc_fractal_('IncludeLastCandle',1,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = mdeopt.calc_alligator_('IncludeLastCandle',1,'RemoveLimitPrice',1);
                wad = mdeopt.calc_wad_('IncludeLastCandle',1,'RemoveLimitPrice',1);
            end
        end
         
        extrainfo = struct('p',px,'hh',hh,'ll',ll,...
            'idxhh',idxHH,'idxll',idxLL,...
            'jaw',jaw,'teeth',teeth,'lips',lips,...
            'bs',bs,'ss',ss,'bc',bc,'sc',sc,...
            'lvlup',lvlup,'lvldn',lvldn,'wad',wad,...
            'latestopen',lasttick(4),...
            'latestdt',lasttick(1));
        
        unwindtrade = obj.riskmanagementwithcandle([],...
            'debug',debug,...
            'usecandlelastonly',true,...
            'updatepnlforclosedtrade',updatepnlforclosedtrade,...
            'extrainfo',extrainfo,...
            'runriskmanagementbeforemktclose',runriskmanagementbeforemktclose,...
            'kellytables',kellytables);
        
        obj.bucket_count_ = this_count;
    else
        if runriskmanagementbeforemktclose
            %only unwind existing trade
            if ~ismdeopt
                [bs,ss,lvlup,lvldn,bc,sc,px] = mdefut.calc_tdsq_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [idxHH,idxLL,hh,ll] = mdefut.calc_fractal_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = mdefut.calc_alligator_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                wad = mdefut.calc_wad_(instrument,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            else
                [bs,ss,lvlup,lvldn,bc,sc,px] = mdeopt.calc_tdsq_('IncludeLastCandle',1,'RemoveLimitPrice',1);
                [idxHH,idxLL,hh,ll] = mdeopt.calc_fractal_('IncludeLastCandle',1,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = mdeopt.calc_alligator_('IncludeLastCandle',1,'RemoveLimitPrice',1);
                wad = mdeopt.calc_wad_('IncludeLastCandle',1,'RemoveLimitPrice',1);
            end
            
            oldtick = lasttick;
            if ~ismdeopt
                lasttick = mdefut.getlasttick(instrument);
            else
                lasttick = mdeopt.getlasttick(instrument);
            end
            if isempty(lasttick)
                lasttick = oldtick;
            end
            px(end,5) = lasttick(4);
            extrainfo = struct('p',px,'hh',hh,'ll',ll,...
                'idxhh',idxHH,'idxll',idxLL,...
                'jaw',jaw,'teeth',teeth,'lips',lips,...
                'bs',bs,'ss',ss,'bc',bc,'sc',sc,...
                'lvlup',lvlup,'lvldn',lvldn,'wad',wad,...
                'latestopen',lasttick(4),...
                'latestdt',lasttick(1));
             unwindtrade = obj.riskmanagementwithcandle([],...
                 'debug',debug,...
                 'usecandlelastonly',true,...
                 'updatepnlforclosedtrade',updatepnlforclosedtrade,...
                 'extrainfo',extrainfo,...
                 'runriskmanagementbeforemktclose',runriskmanagementbeforemktclose,...
                 'kellytables',kellytables);
        end
    end
    
    
end