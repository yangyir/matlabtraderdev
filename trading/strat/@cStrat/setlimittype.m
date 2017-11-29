function [] = setlimittype(strategy,instrument,limitype)
    if ~ischar(limitype), error('cStrat:setlimittype:invalid limitype input'); end
    if ~(strcmpi(limitype,'rel') || strcmpi(limitype,'abs'))
        error('cStrat:setstoptype:invalid limitype input')
    end

    if isempty(strategy.pnl_limit_type_), strategy.pnl_limit_type_ = cell(strategy.count,1);end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:setlimittype:instrument not found');end

    strategy.pnl_limit_type_{idx} = limitype;

end
%setlimittype