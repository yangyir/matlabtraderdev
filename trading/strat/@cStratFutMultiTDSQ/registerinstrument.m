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
        strategy.tdstleveldn_ = NaN(n,1);
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