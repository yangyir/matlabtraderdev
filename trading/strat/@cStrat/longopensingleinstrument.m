function [ret,e] = longopensingleinstrument(strategy,ctp_code,lots,spread,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = false;
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.addParameter('signalinfo',{},@isstruct);
    p.parse(varargin{:});
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    signalinfo = p.Results.signalinfo;
    if lots == 0
        return
    end

%     if isempty(strategy.counter_)
%         fprintf('cStrat:counter not registered in strategy\n');
%         return
%     end
    
    if ~ischar(ctp_code)
        error('cStrat:longopensingleinstrument:invalid ctp_code input')
    end
    
    isopt = isoptchar(ctp_code);
    if isopt
        instrument = cOption(ctp_code);
    else
        instrument = cFutures(ctp_code);
    end
    instrument.loadinfo([ctp_code,'_info.txt']);
    
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool
        fprintf('cStrat:longopensingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    %only place entrusts in case the instrument has been registered
    %with the strategy
    
    if ~isempty(overridepx)
        price = overridepx;
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

        if nargin < 4
            price = askpx - strategy.askspread_(idx)*instrument.tick_size;
        else
            price = askpx - spread*instrument.tick_size;
        end
    end
    
    if isempty(ordertime), ordertime = now; end 
    
    [ret,e] = strategy.trader_.placeorder(ctp_code,'b','o',price,lots,strategy.helper_,'time',ordertime,'signalinfo',signalinfo);
    if ret
        e.date = floor(ordertime);
        e.time = ordertime;
        strategy.updatestratwithentrust(e);
    end
    
end
%end of longopensigleinstrument