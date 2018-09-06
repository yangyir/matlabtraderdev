function [] = setbidopenspread(strategy,instrument,bidspread)
%cStrat
    if ~isnumeric(bidspread), error('cStrat:setbidopenspread:invalid spread input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, 
        if isempty(strategy.bidopenspread_)
            strategy.bidopenspread_ = bidspread*ones(strategy.count,1);
        else
            if size(strategy.bidopenspread_,1) < strategy.count
                strategy.bidopenspread_ = [strategy.bidopenspread_;bidspread];
            end
        end

    else
        strategy.bidopenspread_(idx) = bidspread;
    end

end
%end of setbidopenspread