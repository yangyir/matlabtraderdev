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
    p.addParameter('PositionFrom','',@ischar);
    p.addParameter('FileName','',@ischar);
    p.addParameter('FutList',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','FutList'));
    p.addParameter('OptUndList',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','OptUndList'));
    p.parse(varargin{:});
    
    counter = p.Results.Counter;
    if isempty(counter)
        error('init_stratmanual:invalid or empty input of counter')
    end
    
    mdefut = p.Results.MDEFut;
    mdeopt = p.Results.MDEOpt;
    
    instrument_list = p.Results.InstrumentList;
    if isempty(instrument_list)
        error('init_stratmanual:empty instrument list is not allowed!')
    end
    
    position_from = p.Results.PositionFrom;
    if ~(strcmpi(position_from,'counter') || strcmpi(position_from,'file'))
        error('init_stratmanual:invalid input of positionfrom:either counter or file')
    end
    
    file_name = p.Results.FileName;
    fut_list = p.Results.FutList;
    opt_und_list = p.Results.OptUndList;
    
    strat = cStratManual;
    strat.registercounter(counter);
    if ~isempty(mdefut), strat.mde_fut_ = mdefut;end
    if ~isempty(mdeopt), strat.mde_opt_ = mdeopt;end
       
    n = size(instrument_list,1);
    for i = 1:n
        code = instrument_list{i};
        if ischar(code)
            instrument = code2instrument(code);
        else
            instrument = code;
        end
        if isa(instrument,'cFutures')
            if isempty(mdefut), error('init_stratmanual:invalid input of mdefut'); end
            strat.registerinstrument(instrument);
            mdefut.registerinstrument(instrument);
        elseif isa(instrument,'cOption')
            if isempty(mdeopt), error('init_stratmanual:invalid input of mdeopt'); end
            strat.registerinstrument(instrument);
            mdeopt.registerinstrument(instrument);
        end
    end
    
    if strcmpi(position_from,'counter')
        strat.loadbookfromcounter('FutList',fut_list,'OptUndList',opt_und_list);
    elseif strcmpi(position_from,'file')
        strat.loadpositionfromfile(file_name,today);
    end
    
    
end