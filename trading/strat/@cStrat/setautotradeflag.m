function [] = setautotradeflag(strategy,instrument,autotrade)
    if ~isnumeric(autotrade), error('cStrat:setautotradeflag:invalid autotrade input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.autotrade_)
            strategy.autotrade_ = autotrade*ones(strategy.count,1);
        else
            if size(strategy.autotrade_,1) < strategy.count
                strategy.autotrade_ = [strategy.autotrade_;autotrade];
            end
        end
    else
        strategy.autotrade_(idx) = autotrade;
    end


end
%end of setautotradeflag