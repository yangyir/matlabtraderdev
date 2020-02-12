function [] = registerinstrument(stratfractal,instrument)
%cStratFutMultiFractal
    registerinstrument@cStrat(stratfractal,instrument);
    
    n = stratfractal.count;
    
    hh = cell(n,1);
    ll = cell(n,1);
    jaw = cell(n,1);
    teeth = cell(n,1);
    lips = cell(n,1);
    bs = cell(n,1);
    ss = cell(n,1);
    bc = cell(n,1);
    sc = cell(n,1);
    lvlup = cell(n,1);
    lvldn = cell(n,1);
    if isempty(stratfractal.hh_)
        stratfractal.hh_ = hh;
        stratfractal.ll_ = ll;
        stratfractal.jaw_ = jaw;
        stratfractal.teeth_ = teeth;
        stratfractal.lips_ = lips;
        stratfractal.bs_ = bs;
        stratfractal.ss_ = ss;
        stratfractal.bc_ = bc;
        stratfractal.sc_ = sc;
        stratfractal.lvlup_ = lvlup;
        stratfractal.lvldn_ = lvldn;
    else
        m = size(stratfractal.hh_);
        hh(1:m) = stratfractal.hh_;
        ll(1:m) = stratfractal.ll_;
        jaw(1:m) = stratfractal.jaw_;
        teeth(1:m) = stratfractal.teeth_;
        lips(1:m) = stratfractal.lips_;
        bs(1:m) = stratfractal.bs_;
        ss(1:m) = stratfractal.ss_;
        bc(1:m) = stratfractal.bc_;
        sc(1:m) = stratfractal.sc_;
        lvlup(1:m) = stratfractal.lvlup_;
        lvldn(1:m) = stratfractal.lvldn_;
        %
        stratfractal.hh_ = hh;
        stratfractal.ll_ = ll;
        stratfractal.jaw_ = jaw;
        stratfractal.teeth_ = teeth;
        stratfractal.lips_ = lips;
        stratfractal.bs_ = bs;
        stratfractal.ss_ = ss;
        stratfractal.bc_ = bc;
        stratfractal.sc_ = sc;
        stratfractal.lvlup_ = lvlup;
        stratfractal.lvldn_ = lvldn;
    end
    %
    targetportfolio = zeros(n,1);
    if isempty(stratfractal.targetportfolio_)
        stratfractal.targetportfolio_ = targetportfolio;
    else
        m = size(stratfractal.targetportfolio_);
        targetportfolio(1:m) = stratfractal.targetportfolio_;
        stratfractal.targetportfolio_ = targetportfolio;
    end
    
    if ischar(instrument)
        ctpcode = instrument;
    else
        ctpcode = instrument.code_ctp;
    end
    
    [~,idx] = stratfractal.mde_fut_.qms_.instruments_.hasinstrument(ctpcode);
    if idx < 0, error('%s:%s:unknown error',class(stratfractal),'registerinstrument');end
    
    try
        tdsqlag = stratfractal.riskcontrols_.getconfigvalue('code',ctpcode,'propname','tdsqlag');
        stratfractal.mde_fut_.tdsqlag_(idx) = tdsqlag;
    catch
        stratfractal.mde_fut_.tdsqlag_(idx) = 4;
    end
    
    try
        tdsqconsecutive = stratfractal.riskcontrols_.getconfigvalue('code',ctpcode,'propname','tdsqconsecutive');
        stratfractal.mde_fut_.tdsqconsecutive_(idx) = tdsqconsecutive;
    catch
        stratfractal.mde_fut_.tdsqconsecutive_(idx) = 9;
    end
    
    try
        nfractals = stratfractal.riskcontrols_.getconfigvalue('code',ctpcode,'propname','nfractals');
        stratfractal.mde_fut_.nfractals_(idx) = nfractals;
    catch
        stratfractal.mde_fut_.nfractals_(idx) = 2;
    end
    
end