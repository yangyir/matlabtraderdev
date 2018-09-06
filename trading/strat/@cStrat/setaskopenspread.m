function [] = setaskopenspread(strategy,instrument,askspread)
%cStrat
    if ~isnumeric(askspread), error('cStrat:setaskopenspread:invalid spread input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.askopenspread_)
            strategy.askopenspread_ = askspread*ones(strategy.count,1);
        else
            if size(strategy.askopenspread_,1) < strategy.count
                strategy.askopenspread_ = [strategy.askopenspread_;askspread];
            end
        end
    else
        strategy.askopenspread_(idx) = askspread;
    end

end
%end of setaskopenspread