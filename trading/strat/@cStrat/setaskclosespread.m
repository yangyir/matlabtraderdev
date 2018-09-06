function [] = setaskclosespread(strategy,instrument,askspread)
%cStrat
    if ~isnumeric(askspread), error('cStrat:setaskclosespread:invalid spread input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.askclosespread_)
            strategy.askclosespread_ = askspread*ones(strategy.count,1);
        else
            if size(strategy.askclosespread_,1) < strategy.count
                strategy.askclosespread_ = [strategy.askclosespread_;askspread];
            end
        end
    else
        strategy.askclosespread_(idx) = askspread;
    end


end
%end of setaskclosespread