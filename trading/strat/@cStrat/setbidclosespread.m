function [] = setbidclosespread(strategy,instrument,bidspread)
%cStrat
    if ~isnumeric(bidspread), error('cStrat:setbidclosespread:invalid spread input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, 
        if isempty(strategy.bidclosespread_)
            strategy.bidclosespread_ = bidspread*ones(strategy.count,1);
        else
            if size(strategy.bidclosespread_,1) < strategy.count
                strategy.bidclosespread_ = [strategy.bidclosespread_;bidspread];
            end
        end

    else
        strategy.bidclosespread_(idx) = bidspread;
    end
    
end
%end of setbidclosespread