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
    
    if isempty(strategy.tdsellcountdown_)
        strategy.tdsellcountdown_ = cell(n,1);
    else
        if size(strategy.tdsellcountdown_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tdsellcountdown_,1)
                temp{i,1} = strategy.tdsellcountdown_{i};
            end
            strategy.tdsellcountdown_ = temp;
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
    
    if isempty(strategy.signals_)
        strategy.signals_ = cell(n,3);
    else
        if size(strategy.signals_,1) < n
            temp = cell(n,3);
            for i = 1:size(strategy.signals_,1)
                temp{i,1} = strategy.signals_{i,1};
                temp{i,2} = strategy.signals_{i,2};
                temp{i,3} = strategy.signals_{i,3};
            end
            strategy.signals_ = temp;
        end
    end
    
    if isempty(strategy.tags_)
        strategy.tags_ = cell(n,1);
    else
        if size(strategy.tags_,1) < n
            temp = cell(n,1);
            for i = 1:size(strategy.tags_,1)
                temp{i,1} = strategy.tags_{i};
            end
            strategy.tags_ = temp;
        end
    end
    
    if isempty(strategy.macdbs_)
        strategy.macdbs_ = cell(n,1);
        strategy.macdss_ = cell(n,1);
    else
        if size(strategy.macdbs_,1) < n
            temp1 = cell(n,1);
            temp2 = cell(n,1);
            for i = 1:size(strategy.macdbs_,1)
                temp1{i,1} = strategy.macdbs_{i,1};
                temp2{i,1} = strategy.macdss_{i,1};
            end
            strategy.macdbs_ = temp1;
            strategy.macdss_ = temp2;
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
    
    try
        useperfect = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','useperfect');
        strategy.useperfect_(idx) = useperfect;
    catch
        strategy.useperfect_(idx) = 1;
    end
    
    try
        usesemiperfect = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usesemiperfect');
        strategy.usesemiperfect_(idx) = usesemiperfect;
    catch
        strategy.usesemiperfect_(idx) = 1;
    end
    
    try
        useimperfect = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','useimperfect');
        strategy.useimperfect_(idx) = useimperfect;
    catch
        strategy.useimperfect_(idx) = 1;
    end
    
    try
        usesinglelvlup = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usesinglelvlup');
        strategy.usesinglelvlup_(idx) = usesinglelvlup;
    catch
        strategy.usesinglelvlup_(idx) = 1;
    end
    
    try
        usesinglelvldn = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usesinglelvldn');
        strategy.usesinglelvldn_(idx) = usesinglelvldn;
    catch
        strategy.usesinglelvldn_(idx) = 1;
    end
    
    try
        usedoublerange = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usedoublerange');
        strategy.usedoublerange_(idx) = usedoublerange;
    catch
        strategy.usedoublerange_(idx) = 1;
    end
    
    try
        usedoublebullish = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usedoublebullish');
        strategy.usedoublebullish_(idx) = usedoublebullish;
    catch
        strategy.usedoublebullish_(idx) = 1;
    end
    
    try
        usedoublebearish = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usedoublebearish');
        strategy.usedoublebearish_(idx) = usedoublebearish;
    catch
        strategy.usedoublebearish_(idx) = 1;
    end
    
    try
        usesimpletrend = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','usesimpletrend');
        strategy.usesimpletrend_(idx) = usesimpletrend;
    catch
        strategy.usesimpletrend_(idx) = 1;
    end
    
    
    
    
    
    

end