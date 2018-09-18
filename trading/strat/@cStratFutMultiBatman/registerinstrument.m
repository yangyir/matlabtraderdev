function [] = registerinstrument(strategy,instrument)
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument);
    
    %bandwidthmin_
    if isempty(strategy.bandwidthmin_)
        strategy.bandwidthmin_ = ones(strategy.count,1)/3;
    else
        if size(strategy.bandwidthmin_,1) < strategy.count
            strategy.bandwidthmin_ = [strategy.bandwidthmin_;1/3];
        end
    end
    
    %bandwidthmax_
    if isempty(strategy.bandwidthmax_)
        strategy.bandwidthmax_ = ones(strategy.count,1)/2;
    else
        if size(strategy.bandwidthmax_,1) < strategy.count
            strategy.bandwidthmax_ = [strategy.bandwidthmax_;1/2];
        end
    end
    
end