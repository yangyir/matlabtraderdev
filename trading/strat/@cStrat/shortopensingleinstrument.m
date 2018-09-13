function [ret,e] = shortopensingleinstrument(strategy,ctp_code,lots,spread,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = false;
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.addParameter('signalinfo',{},@isstruct);
    p.parse(varargin{:});
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    signalinfo = p.Results.signalinfo;
    
    if ~ischar(ctp_code)
        ret = 0;
        e = [];
        fprintf('cStrat:shortopensingleinstrument:invalid order code...\n')
        return
    end
    
    if lots <= 0 
        ret = 0;
        e = [];
        fprintf('cStrat:shortopensingleinstrument:invalid order volume...\n')
        return
    end

    isopt = isoptchar(ctp_code);
    instrument = code2instrument(ctp_code);
    
    [bool,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool
        ret = 0;
        e = [];
        fprintf('cStrat:shortopensingleinstrument:%s not registered in strategy...\n',ctp_code)
        return; 
    end
    %only place entrusts in case the instrument has been registered
    %with the strategy
    
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
                error('cStrat:shortopeninstrument:not implemented yet for option in replay mode')
            else
                tick = strategy.mde_fut_.getlasttick(ctp_code);
            end
            bidpx = tick(2);
        end

        if nargin < 4
            orderprice = bidpx + strategy.bidopenspread_(idx)*instrument.tick_size;
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
    
    [ret,e] = strategy.trader_.placeorder(ctp_code,'s','o',orderprice,lots,strategy.helper_,'time',ordertime,'signalinfo',signalinfo);

    if ret
        e.date = floor(ordertime);
        e.date2 = datestr(e.date,'yyyy-mm-dd');
        e.time = ordertime;
        e.time2 = datestr(e.time,'yyyy-mm-dd HH:MM:SS');
        strategy.updatestratwithentrust(e);
    end
    
end
%end of shortopensigleinstrument