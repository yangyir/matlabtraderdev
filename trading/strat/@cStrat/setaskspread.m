function [] = setaskspread(strategy,instrument,askspread)
    if ~isnumeric(askspread), error('cStrat:setaskspread:invalid bid spread input');end

    if isempty(strategy.askspread_), strategy.askspread_ = zeros(strategy.count,1); end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:setaskspread:instrument not found');end

    strategy.askspread_(idx) = askspread;

end
%end of setbidaskspread