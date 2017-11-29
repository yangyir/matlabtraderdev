function [] = setautotradeflag(strategy,instrument,autotrade)
    if ~isnumeric(autotrade), error('cStrat:setautotradeflag:invalid autotrade input');end
    if ~(autotrade == 0 || autotrade == 1),error('cStrat:setautotradeflag:invalid autotrade input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);

    if ~flag
        error('cStrat:setautotradeflag:instrument not found')
    end

    strategy.autotrade_(idx) = autotrade;

end
%end of setautotradeflag