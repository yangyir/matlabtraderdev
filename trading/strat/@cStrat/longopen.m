function [ret,e] = longopen(strategy,ctp_code,lots,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = false;
    p.addParameter('spread',[],@isnumeric);
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.addParameter('signalinfo',{},@isstruct);
    p.parse(varargin{:});
    spread = p.Results.spread;
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    signalinfo = p.Results.signalinfo;
    
    if ~ischar(ctp_code)
        ret = 0;
        e = [];
        fprintf('cStrat:longopen:invalid order code...\n')
        return
    end
    
    if lots <= 0
        ret = 0;
        e = [];
        fprintf('cStrat:longopen:invalid order volume...\n')
        return
    end
            
    isopt = isoptchar(ctp_code);
    instrument = code2instrument(ctp_code);
    %only place entrusts in case the instrument has been registered
    %with the strategy
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool
        ret = 0;
        e = [];
        fprintf('cStrat:longopen:%s not registered in strategy...\n',ctp_code)
        return; 
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
            spread2use = strategy.askopenspread_(idx);
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
    
    [ret,e] = strategy.trader_.placeorder(ctp_code,'b','o',price,lots,strategy.helper_,'time',ordertime,'signalinfo',signalinfo);
    if ret
        e.date = floor(ordertime);
        e.date2 = datestr(e.date,'yyyy-mm-dd');
        e.time = ordertime;
        e.time2 = datestr(e.time,'yyyy-mm-dd HH:MM:SS');
        e.entrustType = entrusttype; 
        strategy.updatestratwithentrust(e);
    end
    
end
%end of longopen