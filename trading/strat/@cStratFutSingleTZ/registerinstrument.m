function [] = registerinstrument(strategy,instrument)
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument)
    
    strategy.tradinglengthperday_ = instrument.trading_length;
    
end