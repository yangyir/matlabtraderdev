function [ret,e] = shortclosesingleinstrument(strategy,ctp_code,lots,closetodayFlag,spread,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.addParameter('tradeid','',@ischar);
    p.parse(varargin{:});
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    tradeid = p.Results.tradeid;
    if lots <= 0 
        return; 
    end

    if nargin < 4
        closetodayFlag = 0;
    end

    if ~ischar(ctp_code)
        error('cStrat:shortclosesingleinstrument:invalid ctp_code input')
    end
    
    isopt = isoptchar(ctp_code);
    instrument = code2instrument(ctp_code);
    
    [f1, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~f1
        fprintf('cStrat:shortclosesingleinstrument:%s not registered in strategy\n',ctp_code);
        ret = 0;
        e = [];
        return; 
    end
        
    try
        [f2,idxp] = strategy.helper_.book_.hasposition(instrument);
    catch
        f2 = false;
        idxp = 0;
    end
    
    if ~f2
        fprintf('cStrat:shortclosesingleinstrument:%s not traded in strategy\n',ctp_code);
        ret = 0;
        e = [];
        return; 
    end
    
    volume = abs(strategy.helper_.book_.positions_{idxp}.position_total_);
    
    if volume <= 0
        fprintf('cStrat:shortclosesingleinstrument:%s:existing long position not found\n',ctp_code);
        ret = 0;
        e = [];
        return
    end
    
    if abs(volume) < abs(lots)
        fprintf('cStrat:shortclosesingleinstrument:%s:input size exceeds existing size\n',ctp_code);
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
                    entrust_i.direction == -1
                volumepending = volumepending + entrust_i.volume;
            end
        end
    catch err
        fprintf('cStrat:shortclosesingleinstrument:%s:internal error when some pending entrust exists:%s...\n',ctp_code,err.message);
        ret = 0;
        e = [];
        return
    end
    
    if abs(volume) < abs(lots) + volumepending
        fprintf('cStrat:shortclosesingleinstrument:%s:input size exceeds existing size with pending entrusts\n',ctp_code);
        ret = 0;
        e = [];
        return
    end
    
    if ~isempty(overridepx)
        orderprice = overridepx;
    else
        if strcmpi(strategy.mode_,'realtime')
            if isopt
                q = strategy.mde_opt_.qms_.getquote(ctp_code);
            else
                q = strategy.mde_fut_.qms_.getquote(ctp_code);
            end
            bidpx = q.bid1;
        elseif strcmpi(strategy.mode_,'replay')
            if isopt
                error('not implemented yet')
            else
                tick = strategy.mde_fut_.getlasttick(ctp_code);
            end
            bidpx = tick(2);
        end

        if nargin < 5
            orderprice = bidpx + strategy.bidclosespread_(idx)*instrument.tick_size;
        else
            orderprice = bidpx + spread*instrument.tick_size;
        end
    end
    
    if isempty(ordertime)
        if strcmpi(strategy.mode_,'realtime')
            ordertime = now;
        else
            ordertime = strategy.getreplaytime;
        end
    end 
    
    if closetodayFlag
        [ret,e] = strategy.trader_.placeorder(ctp_code,'s','ct',orderprice,lots,strategy.helper_,'time',ordertime);
    else
        [ret,e] = strategy.trader_.placeorder(ctp_code,'s','c',orderprice,lots,strategy.helper_,'time',ordertime);
    end
    
    if ret
        e.date = floor(ordertime);
        e.time = ordertime;
        if ~isempty(tradeid), e.tradeid_ = tradeid;end
        strategy.updatestratwithentrust(e);
    end
    
end
%end of shortclosesigleinstrument