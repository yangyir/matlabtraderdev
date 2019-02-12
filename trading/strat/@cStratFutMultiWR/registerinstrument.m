function [] = registerinstrument(strategy,instrument)
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument);

    %william %r
    if isempty(strategy.wr_)
        strategy.wr_ = NaN(strategy.count,1);
    else
        if size(strategy.wr_,1) < strategy.count
            strategy.wr_ = [strategy.wr_;NaN];
        end
    end
    %
    %highest of nperiods
    if isempty(strategy.maxnperiods_)
        strategy.maxnperiods_ = NaN(strategy.count,1);
    else
        if size(strategy.maxnperiods_,1) < strategy.count
            strategy.maxnperiods_ = [strategy.maxnperiods_;NaN];
        end
    end
    
    %lowest of nperiods
    if isempty(strategy.minnperiods_)
        strategy.minnperiods_ = NaN(strategy.count,1);
    else
        if size(strategy.minnperiods_,1) < strategy.count
            strategy.minnperiods_ = [strategy.minnperiods_;NaN];
        end
    end
    
    if ischar(instrument)
        ctpcode = instrument;
    else
        ctpcode = instrument.code_ctp;
    end
    
    try
        np = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','numofperiod');
    catch
        np = 144;
    end
    
    try
        includelastcandle = strategy.riskcontrols_.getconfigvalue('code',ctpcode,...
                'propname','includelastcandle');
    catch
        includelastcandle = 0;
    end
    param = struct('name','WilliamR','values',{{'numofperiods',np,'includelastcandle',includelastcandle}});
    strategy.mde_fut_.settechnicalindicator(instrument,param);

end
%end of registerinstrument