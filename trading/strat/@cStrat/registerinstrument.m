function [] = registerinstrument(strategy,instrument)
%cStrat
%note:any risk control per instrument is not set-up here
%a seperate funcs called 'loadriskcontrolconfigfromfile' is used instead
%for setting up risk controls. We strictly forbidden to set up any risk
%control variables via any code process but with loading data from the file
%directly.i.e.any default risk control values will prevent strategy from
%placing any entrust

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
    
    %calsignal_bucket_
    strategy.setcalcsignalbucket(instrument,0);
    
    %calcsignal_
    strategy.setcalcsignal(instrument,0);
    
    %replaceconditionalsignal_
    strategy.setreplaceconditionalsignal(instrument,0);
    
%     %executionperbucket_
%     strategy.setexecutionperbucket(instrument,0);
%     
%     %executionbucketnumber_
%     strategy.setexecutionbucketnumber(instrument,1);
    
    if ~optflag
        strategy.mde_fut_.registerinstrument(instrument);
    else
        strategy.mde_fut_.registerinstrument(u);
        strategy.mde_opt_.registerinstrument(instrument);
    end
    
    samplefreq = strategy.riskcontrols_.getconfigvalue('code',codestr,'propname','samplefreq');
    samplefreqnum = str2double(samplefreq(1:end-1));
    strategy.mde_fut_.setcandlefreq(samplefreqnum,instrument);
    
    try
        np = strategy.riskcontrols_.getconfigvalue('code',ctpcode,'propname','numofperiod');
    catch
        np = 144;
    end
    param = struct('name','WilliamR','values',{{'numofperiods',np}});
    strategy.mde_fut_.settechnicalindicator(instrument,param);
    
end
%end of 'registerinstrument'