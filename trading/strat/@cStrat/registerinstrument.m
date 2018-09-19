function [] = registerinstrument(strategy,instrument)
    if ischar(instrument)
        codestr = instrument;
    elseif isa(instrument,'cInstrument')
        codestr = instrument.code_ctp;
    else
        error('cStrat:registerinstrument:invalid instrument input')
    end

    if isempty(strategy.instruments_), strategy.instruments_ = cInstrumentArray;end
    %check whether the instrument is an option or not
    [optflag,~,~,underlierstr,~] = isoptchar(codestr);
    %note:yangyiran 20180726
    %we force the mde_fut_ and mde_opt_ set with its register function
    if ~optflag && isempty(strategy.mde_fut_)
        error('cStrat:registerinstrument:missing mdefut which shall be registed first...\n')
    end
    
    if optflag && isempty(strategy.mde_opt_)
        error('cStrat:registerinstrument:missing mdeopt which shall be registed first...\n')
    end
    
    if optflag
        if isempty(strategy.underliers_), strategy.underliers_ = cInstrumentArray;end
        u = code2instrument(underlierstr);
        strategy.underliers_.addinstrument(u);
    end
    if isa(instrument,'cInstrument')
        strategy.instruments_.addinstrument(instrument);
    elseif ischar(instrument)
        instrument = code2instrument(codestr);
        strategy.instruments_.addinstrument(instrument);
    end

    %pnl_stop_type_
    strategy.setstoptype(instrument,'rel');

    %pnl_stop_
    strategy.setstopamount(instrument,-inf);

    %pnl_limit_type_
    strategy.setlimittype(instrument,'rel');

    %pnl_limit_
    strategy.setlimitamount(instrument,inf);

    %pnl_running_
    strategy.setpnlrunning(instrument,0);

    %pnl_close_
    strategy.setpnlclose(instrument,0);

    %bidspread_
    strategy.setbidopenspread(instrument,0);
    strategy.setbidclosespread(instrument,0);

    %askspread_
    strategy.setaskopenspread(instrument,0);
    strategy.setaskclosespread(instrument,0);

    %autotrade_
    strategy.setautotradeflag(instrument,0);
    
     %baseunits
     strategy.setbaseunits(instrument,1);

    %maxunits
    strategy.setmaxunits(instrument,1);

    %executionperbucket
    strategy.setexecutionperbucket(instrument,0);

    %maxexecutionperbucket
    strategy.setmaxexecutionperbucket(instrument,1);

    %executionbucketnumber
    strategy.setexecutionbucketnumber(instrument,0);
    
    %calsignal_bucket_
    strategy.setcalcsignalbucket(instrument,0);
    
    %calcsignal_
    strategy.setcalcsignal(instrument,0);
    
    if ~optflag
        strategy.mde_fut_.registerinstrument(instrument);
    else
        strategy.mde_fut_.registerinstrument(u);
        strategy.mde_opt_.registerinstrument(instrument);
    end
    
    %samplefreq_
    strategy.setsamplefreq(instrument,1);
    
    
    
end
%end of 'registerinstrument'