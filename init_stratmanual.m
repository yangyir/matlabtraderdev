function strat = init_stratmanual(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Counter',{},...
        @(x) validateattributes(x,{'CounterCTP'},{},'','Counter'));
    p.addParameter('MDEFut',{},...
        @(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('MDEOpt',{},...
        @(x) validateattributes(x,{'cMDEOpt'},{},'','MDEOpt'));
    p.addParameter('InstrumentList',{},@iscell);
    p.parse(varargin{:});
    
    counter = p.Results.Counter;
    mdefut = p.Results.MDEFut;
    mdeopt = p.Results.MDEOpt;
    instrument_list = p.Results.InstrumentList;
       
    if isempty(instrument_list)
        error('init_stratmanual:empty instrument list is not allowed!')
    end
    
    strat = cStratManual;
    strat.registercounter(counter);
    strat.mde_fut_ = mdefut;
    strat.mde_opt_ = mdeopt;
       
    n = size(instrument_list,1);
    for i = 1:n
        code = instrument_list{i};
        instrument = code2instrument(code);
        if isa(instrument,'cFutures')
            if isempty(mdefut), error('init_stratmanual:invalid input of mdefut'); end
            mdefut.registerinstrument(instrument);
        elseif isa(instrument,'cOption')
            if isempty(mdeopt), error('init_stratmanual:invalid input of mdeopt'); end
            mdeopt.registerinstrument(instrument);
        end
    end
    
    
    
end