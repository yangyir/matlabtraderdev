function [ret,e,msg] = shortclose(strategy,ctp_code,lots,closetodayFlag,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('spread',[],@isnumeric);
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.addParameter('tradeid','',@ischar);
    p.parse(varargin{:});
    spread = p.Results.spread;
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    tradeid = p.Results.tradeid;
    
    if isempty(strategy.timer_) || strcmpi(strategy.timer_.running,'off')
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:strategy is not running...',class(strategy));
        fprintf('%s\n',msg);
        return
    end

    
    if ~ischar(ctp_code)
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:invalid order code...',class(strategy));
        fprintf('%s\n',msg);
        return
    end
    
    if lots <= 0
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:invalid order volume...',class(strategy));
        fprintf('%s\n',msg);
        return
    end

    if nargin < 4, closetodayFlag = 0;end

    isopt = isoptchar(ctp_code);
    instrument = code2instrument(ctp_code);
    
    if isempty(ordertime)
        if strcmpi(strategy.mode_,'realtime') || strcmpi(strategy.mode_,'demo')
            ordertime = now;
        else
            ordertime = strategy.getreplaytime;
        end
    end
    
        
    if ~instrument.isable2trade(ordertime)
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:non-trableable time for %s...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return
    end
    
    f1 = strategy.instruments_.hasinstrument(instrument);
    if ~f1
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:%s not registered in strategy...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return; 
    end
        
    try
        [f2,idxp] = strategy.helper_.book_.haslongposition(instrument);
    catch
        f2 = false;
    end
    
    if ~f2
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:%s not traded in strategy...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return; 
    end
    
    volume = abs(strategy.helper_.book_.positions_{idxp}.position_total_);
    direction = strategy.helper_.book_.positions_{idxp}.direction_;
    if volume <= 0 || direction ~= 1
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:%s:existing long position not found...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return
    end
    
    if abs(volume) < abs(lots)
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:%s:input size exceeds existing size...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return
    end
    
    %note:yangyiran:20180907
    %we need also check whether there are pending entrusts which are aimed
    %to close some or all of the position
    try
        npending = strategy.helper_.entrustspending_.latest;
        volumepending = 0;
        for i = 1:npending
            entrust_i = strategy.helper_.entrustspending_.node(i);
            if strcmpi(entrust_i.instrumentCode,ctp_code) && ...
                    entrust_i.offsetFlag == -1 && ...
                    entrust_i.direction == -1
                volumepending = volumepending + entrust_i.volume;
            end
        end
    catch err
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:%s:internal error when some pending entrust exists:%s...',class(strategy),ctp_code,err.message);
        fprintf('%s\n',msg);
        return
    end
    
    if abs(volume) < abs(lots) + volumepending
        ret = 0;
        e = [];
        msg = sprintf('%s:shortclose:%s:input size exceeds existing size with pending entrusts...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return
    end
    
    if strcmpi(strategy.mode_,'realtime') || strcmpi(strategy.mode_,'demo')
        if isopt
            q = strategy.mde_opt_.qms_.getquote(ctp_code);
        else
            q = strategy.mde_fut_.qms_.getquote(ctp_code);
        end
        bidpx = q.bid1;
    elseif strcmpi(strategy.mode_,'replay')
        if isopt
            error('cStrat:shortopen:not implemented yet for option in replay mode')
        else
            tick = strategy.mde_fut_.getlasttick(ctp_code);
        end
        bidpx = tick(2);
    end
    
    if ~isempty(overridepx)
        if overridepx == -1
            entrusttype = 'market';
            price = bidpx;
        else
            if overridepx > bidpx
                entrusttype = 'limit';
            elseif overridepx == bidpx
                entrusttype = 'market';
            else
                entrusttype = 'stop';
            end
            price = overridepx;
        end
    else
        if ~isempty(spread)
            spread2use = spread;
        else
            spread2use = strategy.riskcontrols_.getconfigvalue('code',ctp_code,'propname','bidclosespread');
        end
        if spread2use == 0
            entrusttype = 'market';
        elseif spread2use > 0
            entrusttype = 'limit';
        else
            entrusttype = 'stop';
        end
        price = bidpx + spread2use*instrument.tick_size;
    end

    
 
    
    if closetodayFlag
        [ret,e,msg] = strategy.trader_.placeorder(ctp_code,'s','ct',price,lots,strategy.helper_,'time',ordertime);
    else
        [ret,e,msg] = strategy.trader_.placeorder(ctp_code,'s','c',price,lots,strategy.helper_,'time',ordertime);
    end
    
    if ret
        e.date = floor(ordertime);
        e.date2 = datestr(e.date,'yyyy-mm-dd');
        e.time = ordertime;
        e.time2 = datestr(e.time,'yyyy-mm-dd HH:MM:SS');
        e.entrustType = entrusttype;
        if ~isempty(tradeid), e.tradeid_ = tradeid;end
%         strategy.updatestratwithentrust(e);
    end
    
end
%end of shortclosesigleinstrument