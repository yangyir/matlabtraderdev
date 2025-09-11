function [] = registerinstrument(stratfractalopt,instrument)
    %a cStratOptMultiFractal function
    if ischar(instrument)
        codestr = instrument;
    elseif isa(instrument,'cInstrument')
        codestr = instrument.code_ctp;
    else
        error('cStrat:registerinstrument:invalid instrument input')
    end
    
    [optflag,~,~,underlierstr,~] = isoptchar(codestr);
    
    if ~optflag
        error('%s:%s:option input is required...',class(stratfractalopt),'registerinstrument')
    end
    
    registerinstrument@cStrat(stratfractalopt,instrument);
    
    n = stratfractalopt.countunderliers;
    
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
    wad = cell(n,1);
    if isempty(stratfractalopt.hh_)
        stratfractalopt.hh_ = hh;
        stratfractalopt.ll_ = ll;
        stratfractalopt.jaw_ = jaw;
        stratfractalopt.teeth_ = teeth;
        stratfractalopt.lips_ = lips;
        stratfractalopt.bs_ = bs;
        stratfractalopt.ss_ = ss;
        stratfractalopt.bc_ = bc;
        stratfractalopt.sc_ = sc;
        stratfractalopt.lvlup_ = lvlup;
        stratfractalopt.lvldn_ = lvldn;
        stratfractalopt.wad_ = wad;
    else
        m = size(stratfractalopt.hh_);
        hh(1:m) = stratfractalopt.hh_;
        ll(1:m) = stratfractalopt.ll_;
        jaw(1:m) = stratfractalopt.jaw_;
        teeth(1:m) = stratfractalopt.teeth_;
        lips(1:m) = stratfractalopt.lips_;
        bs(1:m) = stratfractalopt.bs_;
        ss(1:m) = stratfractalopt.ss_;
        bc(1:m) = stratfractalopt.bc_;
        sc(1:m) = stratfractalopt.sc_;
        lvlup(1:m) = stratfractalopt.lvlup_;
        lvldn(1:m) = stratfractalopt.lvldn_;
        wad(1:m) = stratfractalopt.wad_;
        %
        stratfractalopt.hh_ = hh;
        stratfractalopt.ll_ = ll;
        stratfractalopt.jaw_ = jaw;
        stratfractalopt.teeth_ = teeth;
        stratfractalopt.lips_ = lips;
        stratfractalopt.bs_ = bs;
        stratfractalopt.ss_ = ss;
        stratfractalopt.bc_ = bc;
        stratfractalopt.sc_ = sc;
        stratfractalopt.lvlup_ = lvlup;
        stratfractalopt.lvldn_ = lvldn;
        stratfractalopt.wad_ = wad;
    end
    
    [~,idx] = stratfractalopt.mde_fut_.qms_.instruments_.hasinstrument(underlierstr);
    if idx < 0, error('%s:%s:unknown error',class(stratfractalopt),'registerinstrument');end
    
    try
        tdsqlag = stratfractalopt.riskcontrols_.getconfigvalue('code',underlierstr,'propname','tdsqlag');
        stratfractalopt.mde_fut_.tdsqlag_(idx) = tdsqlag;
    catch
        stratfractalopt.mde_fut_.tdsqlag_(idx) = 4;
    end
    
    try
        tdsqconsecutive = stratfractalopt.riskcontrols_.getconfigvalue('code',underlierstr,'propname','tdsqconsecutive');
        stratfractalopt.mde_fut_.tdsqconsecutive_(idx) = tdsqconsecutive;
    catch
        stratfractalopt.mde_fut_.tdsqconsecutive_(idx) = 9;
    end
    
    try
        nfractals = stratfractalopt.riskcontrols_.getconfigvalue('code',underlierstr,'propname','nfractals');
        stratfractalopt.mde_fut_.nfractals_(idx) = nfractals;
    catch
        stratfractalopt.mde_fut_.nfractals_(idx) = 2;
    end

end