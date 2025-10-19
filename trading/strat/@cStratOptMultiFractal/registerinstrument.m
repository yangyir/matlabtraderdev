function [] = registerinstrument(stratoptfractal,instrument)
%cStratOptMultiFractal
    registerinstrument@cStrat(stratoptfractal,instrument);
    
    
    if isempty(stratoptfractal.mde_opt_.underlier_)
        error('ERROR:%s:registerinstrument:invalid instrument with unknown underlier',class(stratoptfractal));
    end
    
    %only one underlier is allowed
    %todo:for more than one 
    if isempty(stratoptfractal.hh_) 
        stratoptfractal.hh_ = 0;
        stratoptfractal.ll_ = 0;
        stratoptfractal.jaw_ = 0;
        stratoptfractal.teeth_ = 0;
        stratoptfractal.lips_ = 0;
        stratoptfractal.bs_ = 0;
        stratoptfractal.ss_ = 0;
        stratoptfractal.bc_ = 0;
        stratoptfractal.sc_ = 0;
        stratoptfractal.lvlup_ = 0;
        stratoptfractal.lvldn_ = 0;
        stratoptfractal.wad_ = 0;
        
        if ischar(instrument)
            ctpcode = instrument;
        else
            ctpcode = instrument.code_ctp;
        end
        
        try
            tdsqlag = stratoptfractal.riskcontrols_.getconfigvalue('code',ctpcode,'propname','tdsqlag');
            stratoptfractal.mde_opt_.tdsqlag_ = tdsqlag;
        catch
            stratoptfractal.mde_opt_.tdsqlag_ = 4;
        end
    
        try
            tdsqconsecutive = stratoptfractal.riskcontrols_.getconfigvalue('code',ctpcode,'propname','tdsqconsecutive');
            stratoptfractal.mde_opt_.tdsqconsecutive_ = tdsqconsecutive;
        catch
            stratoptfractal.mde_opt_.tdsqconsecutive_ = 9;
        end
    
        try
            nfractals = stratoptfractal.riskcontrols_.getconfigvalue('code',ctpcode,'propname','nfractals');
            stratoptfractal.mde_opt_.nfractals_ = nfractals;
        catch
            stratoptfractal.mde_opt_.nfractals_ = 2;
        end
        
    end
    
end