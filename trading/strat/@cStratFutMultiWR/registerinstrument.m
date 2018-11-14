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
    param = struct('name','WilliamR','values',{{'numofperiods',np}});
    strategy.mde_fut_.settechnicalindicator(instrument,param);

end
%end of registerinstrument