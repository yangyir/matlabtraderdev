function [] = registerinstrument(strategy,instrument)
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument);
    
    %a negative set values indicates that the value is not set
    strategy.setpxopen(instrument,-1);
    strategy.setpxhigh(instrument,-1);
    strategy.setpxstoploss(instrument,-1);
    strategy.setpxtarget(instrument,-1);
    strategy.setpxwithdrawmin(instrument,-1);
    strategy.setpxwithdrawmax(instrument,-1);
    
    if isempty(strategy.doublecheck_), strategy.doublecheck_ = zeros(strategy.count,1); end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    
    if flag
        strategy.doublecheck__(idx) = 0;
    else
        error('cStratFutBatman:registerinstrument:instrument not found!')
    end
    
    
end