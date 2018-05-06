function [ret,e] = longclosesingleinstrument(strategy,ctp_code,lots,closetodayFlag,spread,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = false;
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.parse(varargin{:});
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    if lots == 0, return; end

    if nargin < 4
        closetodayFlag = 0;
    end
    
    if isempty(strategy.counter_)
        fprintf('cStrat:counter not registered in strategy\n');
        return
    end

    if ~ischar(ctp_code)
        error('cStrat:shortclosesingleinstrument:invalid ctp_code input')
    end
    
    isopt = isoptchar(ctp_code);
    if isopt
        instrument = cOption(ctp_code);
    else
        instrument = cFutures(ctp_code);
    end
    instrument.loadinfo([ctp_code,'_info.txt']);
    
    [f1, idx] = strategy.instruments_.hasinstrument(instrument);
    [f2,idxp] = strategy.bookrunning_.hasposition(instrument);
    
    if ~f1
        fprintf('cStrat:shortclosesingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    
    if ~f2
        fprintf('cStrat:shortclosesingleinstrument:%s not traded in strategy\n',ctp_code)
        return; 
    end
    
    volume = abs(strategy.bookrunning_.positions_{idxp}.position_total_);
    %note:here is a bug and fixing this is on its way
    if volume >= 0
        fprintf('cStrat:longclosesingleinstrument:%s:existing short position not found\n',ctp_code);
    end
    
    if abs(volume) < abs(lots)
        fprintf('cStrat:longclosesingleinstrument:%s:input size exceeds existing size\n',ctp_code);
        lots = abs(volume);
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
            askpx = q.ask1;
        elseif strcmpi(strategy.mode_,'replay')
            if isopt
                error('not implemented yet')
            else
                tick = strategy.mde_fut_.getlasttick(ctp_code);
            end
            askpx = tick(3);
        end

        if nargin < 5
            orderprice = askpx - strategy.askspread_(idx)*instrument.tick_size;
        else
            orderprice = askpx - spread*instrument.tick_size;
        end
    end
    
    if isempty(ordertime), ordertime = now; end
    
    if closetodayFlag
        [ret,e] = strategy.trader_.placeorder(ctp_code,'b','ct',orderprice,lots,strategy.helper_,'time',ordertime);
    else
        [ret,e] = strategy.trader_.placeorder(ctp_code,'b','c',orderprice,lots,strategy.helper_,'time',ordertime);
    end
    
    if ret
        e.date = floor(ordertime);
        e.time = ordertime;
        strategy.updatestratwithentrust(e);
    end
    
end
%end of longopensigleinstrument