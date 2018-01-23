function [] = registerinstrument(strategy,instrument)
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument);

    %numofperiods_
    default_numofperiods_ = 144;
    if isempty(strategy.numofperiods_)
        strategy.numofperiods_ = default_numofperiods_*ones(strategy.count,1); 
        params = struct('numofperiods',default_numofperiods_);
        strategy.setparameters(instrument,params);
    else
        if size(strategy.numofperiods_) < strategy.count
            strategy.numofperiods_ = [strategy.numofperiods_;default_numofperiods_];
            params = struct('numofperiods',default_numofperiods_);
            strategy.setparameters(instrument,params);
        end
    end

    %tradingfreq_
    default_tradingfreq_ = 1;
    if isempty(strategy.tradingfreq_)
        strategy.tradingfreq_ = default_tradingfreq_*ones(strategy.count,1);
        strategy.settradingfreq(instrument,default_tradingfreq_);
    else
        if size(strategy.tradingfreq_) < strategy.count
            strategy.tradingfreq_ = [strategy.tradingfreq_;default_tradingfreq_];
            strategy.settradingfreq(instrument,default_tradingfreq_);
        end
    end

    %overbought_
    default_overbought_ = 0;
    if isempty(strategy.overbought_)
        strategy.overbought_ = default_overbought_*ones(strategy.count,1);
    else
        if size(strategy.overbought_) < strategy.count
            strategy.overbought_ = [strategy.overbought_;default_overbought_];
        end
    end

    %oversold_
    default_oversold_ = -100;
    if isempty(strategy.oversold_)
        strategy.oversold_ = default_oversold_*ones(strategy.count,1);
    else
        if size(strategy.oversold_) < strategy.count
            strategy.oversold_ = [strategy.oversold_;default_oversold_];
        end
    end

    %william %r
    if isempty(strategy.wr_)
        strategy.wr_ = NaN(strategy.count,1);
    else
        if size(strategy.wr_) < strategy.count
            strategy.wr_ = [strategy.wr_;NaN];
        end
    end

end
%end of registerinstrument