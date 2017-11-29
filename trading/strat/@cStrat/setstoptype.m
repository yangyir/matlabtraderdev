function [] = setstoptype(strategy,instrument,stoptype)
    if ~ischar(stoptype), error('cStrat:setstoptype:invalid stoptype input'); end
    if ~(strcmpi(stoptype,'rel') || strcmpi(stoptype,'abs'))
        error('cStrat:setstoptype:invalid stoptype input')
    end

    if isempty(strategy.pnl_stop_type_), strategy.pnl_stop_type_ = cell(strategy.count,1);end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:setstoptype:instrument not found');end

    strategy.pnl_stop_type_{idx} = stoptype;

end
%setstoptype