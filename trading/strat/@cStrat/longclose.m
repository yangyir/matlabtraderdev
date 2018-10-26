function [ret,e,msg] = longclose(strategy,ctp_code,lots,closetodayFlag,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = false;
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
        msg = sprintf('%s:longclose:strategy is not running...',class(strategy));
        fprintf('%s\n',msg);
        return
    end

    
    if ~ischar(ctp_code)
        ret = 0;
        e = [];
        msg = sprintf('%s:longclose:invalid order code...',class(strategy));
        fprintf('%s\n',msg);
        return
    end
    
    if lots <= 0
        ret = 0;
        e = [];
        msg = sprintf('%s:longclose:invalid order volume...',class(strategy));
        fprintf('%s\n',msg);
        return
    end
    
    if nargin < 4, closetodayFlag = 0;end
        
    isopt = isoptchar(ctp_code);
    instrument = code2instrument(ctp_code);
    f1 = strategy.instruments_.hasinstrument(instrument);
    if ~f1
        msg = sprintf('%s:longclose:%s not registered in strategy...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        ret = 0;
        e = [];
        return; 
    end
    
    try
        [f2,idxp] = strategy.helper_.book_.hasshortposition(instrument);
    catch
        f2 = false;
        idxp = 0;
    end
    
    if ~f2
        msg = sprintf('%s:longclose:%s not traded in strategy...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        ret = 0;
        e = [];
        return; 
    end
    
    volume = abs(strategy.helper_.book_.positions_{idxp}.position_total_);
    direction = strategy.helper_.book_.positions_{idxp}.direction_;
    if volume <= 0 || direction ~= -1
        msg = sprintf('%s:longclose:%s:existing short position not found...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        ret = 0;
        e = [];
        return
    end
    
    if abs(volume) < abs(lots)
        msg = sprintf('%s:longclose:%s:input size exceeds existing size...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        ret = 0;
        e = [];
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
                    entrust_i.direction == 1
                volumepending = volumepending + entrust_i.volume;
            end
        end
    catch err
        msg = sprintf('%s:longclose:%s:internal error when some pending entrust exists:%s...',class(strategy),ctp_code,err.message);
        fprintf('%s\n',msg);
        ret = 0;
        e = [];
        return
    end
    
    if abs(volume) < abs(lots) + volumepending
        msg = sprintf('cStrat:longclose:%s:input size exceeds existing size with pending entrusts\n',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        ret = 0;
        e = [];
        return
    end
    
    if strcmpi(strategy.mode_,'realtime')
        if isopt
            q = strategy.mde_opt_.qms_.getquote(ctp_code);
        else
            q = strategy.mde_fut_.qms_.getquote(ctp_code);
        end
        askpx = q.ask1;
    elseif strcmpi(strategy.mode_,'replay')
        if isopt
            error('cStrat:longopen:not implemented yet for option in replay mode')
        else
            tick = strategy.mde_fut_.getlasttick(ctp_code);
        end
        askpx = tick(3);
    end
    
    if ~isempty(overridepx)
        if overridepx == -1
            entrusttype = 'market';
            price = askpx;
        else
            if overridepx < askpx
                entrusttype = 'limit';
            elseif overridepx == askpx
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
            spread2use = strategy.riskcontrols_.getconfigvalue('code',ctp_code,'propname','askclosespread');
        end
        if spread2use == 0
            entrusttype = 'market';
        elseif spread2use > 0
            entrusttype = 'limit';
        else
            entrusttype = 'stop';
        end
        price = askpx - spread2use*instrument.tick_size;
    end
    
    if isempty(ordertime)
        if strcmpi(strategy.mode_,'realtime')
            ordertime = now;
        else
            ordertime = strategy.getreplaytime;
        end
    end 
    
    if closetodayFlag
        [ret,e,msg] = strategy.trader_.placeorder(ctp_code,'b','ct',price,lots,strategy.helper_,'time',ordertime);
    else
        [ret,e,msg] = strategy.trader_.placeorder(ctp_code,'b','c',price,lots,strategy.helper_,'time',ordertime);
    end
    
    if ret
        e.date = floor(ordertime);
        e.date2 = datestr(e.date,'yyyy-mm-dd');
        e.time = ordertime;
        e.time2 = datestr(e.time,'yyyy-mm-dd HH:MM:SS');
        e.entrustType = entrusttype;
        if ~isempty(tradeid), e.tradeid_ = tradeid;end
        strategy.updatestratwithentrust(e);
    end
    
end
%end of longopensigleinstrument