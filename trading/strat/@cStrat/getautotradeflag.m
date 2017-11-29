function autotrade = getautotradeflag(strategy,instrument)
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        error('cStrat:getautotradeflag:instrument not found')
    end
    autotrade = strategy.autotrade_(idx);

end
%end of getautotradeflag