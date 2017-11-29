function [] = setbidspread(strategy,instrument,bidspread)
    if ~isnumeric(bidspread), error('cStrat:setbidspread:invalid bid spread input');end

    if isempty(strategy.bidspread_), strategy.bidspread_ = zeros(strategy.count,1); end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:setbidspread:instrument not found');end

    strategy.bidspread_(idx) = bidspread;

end
%end of setbidspread