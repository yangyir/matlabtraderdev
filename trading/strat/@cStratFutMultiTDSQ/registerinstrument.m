function [] = registerinstrument(strategy,instrument)
%cStratFutMultiTDSQ
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument);
    
    n = strategy.count;
    
    if isempty(strategy.tdbuysetup_)
        strategy.tdbuysetup_ = cell(n,1);
    else
        if size(strategy.tdbuysetup_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdbuysetup_,1)
                temp{i,1} = strategy.tdbuysetup_{i};
            end
            strategy.tdbuysetup_ = temp; 
        end
    end
    
    if isempty(strategy.tdsellsetup_)
        strategy.tdsellsetup_ = cell(n,1);
    else
        if size(strategy.tdsellsetup_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdsellsetup_,1)
                temp{i,1} = strategy.tdsellsetup_{i};
            end
            strategy.tdsellsetup_ = temp; 
        end
    end
    
    if isempty(strategy.tdbuycountdown_)
        strategy.tdbuycountdown_ = cell(n,1);
    else
        if size(strategy.tdbuycountdown_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdbuycountdown_,1)
                temp{i,1} = strategy.tdbuycountdown_{i};
            end
            strategy.tdbuycountdown_ = temp; 
        end
    end
    
    if isempty(strategy.tdsellcoundown_)
        strategy.tdsellcoundown_ = cell(n,1);
    else
        if size(strategy.tdsellcoundown_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdsellcoundown_,1)
                temp{i,1} = strategy.tdsellcoundown_{i};
            end
            strategy.tdsellcoundown_ = temp;
        end
    end
    
    if isempty(strategy.tdstlevelup_)
        strategy.tdstlevelup_ = cell(n,1);
    else
        if size(strategy.tdstlevelup_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdstlevelup_,1)
                temp{i,1} = strategy.tdstlevelup_{i};
            end
            strategy.tdstlevelup_ = temp;
        end
    end
    
    if isempty(strategy.tdstleveldn_)
        strategy.tdstleveldn_ = cell(n,1);
    else
        if size(strategy.tdstleveldn_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdstleveldn_,1)
                temp{i,1} = strategy.tdstleveldn_{i};
            end
            strategy.tdstleveldn_ = temp;
        end
    end
    
    if isempty(strategy.wr_)
        strategy.wr_ = cell(n,1);
    else
        if size(strategy.wr_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.wr_,1)
                temp{i,1} = strategy.wr_{i};
            end
            strategy.wr_ = temp;
        end
    end
    
    if isempty(strategy.macdvec_)
        strategy.macdvec_ = cell(n,1);
    else
        if size(strategy.macdvec_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.macdvec_,1)
                temp{i,1} = strategy.macdvec_{i};
            end
            strategy.macdvec_ = temp;
        end
    end
    
    if isempty(strategy.nineperma_)
        strategy.nineperma_ = cell(n,1);
    else
        if size(strategy.nineperma_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.nineperma_,1)
                temp{i,1} = strategy.nineperma_{i};
            end
            strategy.nineperma_ = temp;
        end
    end
    
        if ischar(instrument)
        ctpcode = instrument;
    else
        ctpcode = instrument.code_ctp;
    end
    
    [~,idx] = strategy.mde_fut_.qms_.instruments_.hasinstrument(ctpcode);
    if idx < 0
        error('unknown error')
    end
    
    try
        wrnp = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','wrnperiod');
        strategy.mde_fut_.wrnperiod_(idx) = wrnp;
    catch
        strategy.mde_fut_.wrnperiod_(idx) = 144;
    end
    
    
    try
        macdlead = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','macdlead');
        strategy.mde_fut_.macdlead_(idx) = macdlead;
    catch
        strategy.mde_fut_.macdlead_(idx) = 12;
    end
    
    try
        macdlag = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','macdlag');
        strategy.mde_fut_.macdlag_(idx) = macdlag;
    catch
        strategy.mde_fut_.macdlag_(idx) = 26;
    end
    
    try
        macdnavg = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','macdnavg');
        strategy.mde_fut_.macdavg_(idx) = macdnavg;
    catch
        strategy.mde_fut_.macdavg_(idx) = 9;
    end
    
    try
        tdsqlag = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','tdsqlag');
        strategy.mde_fut_.tdsqlag_(idx) = tdsqlag;
    catch
        strategy.mde_fut_.tdsqlag_(idx) = 4;
    end
    
    try
        tdsqconsecutive = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','tdsqconsecutive');
        strategy.mde_fut_.tdsqconsecutive_(idx) = tdsqconsecutive;
    catch
        strategy.mde_fut_.tdsqconsecutive_(idx) = 9;
    end
    

end