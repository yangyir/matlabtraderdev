function pnl = calcrunningpnl(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.addParameter('MDEFut',{},...
        @(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('MDEOpt',{},...
        @(x) validateattributes(x,{'cMDEOpt'},{},'','MDEOpt'));
    p.parse(varargin{:});
    codestr = p.Results.Code;
    mdefut = p.Results.MDEFut;
    mdeopt = p.Results.MDEOpt;
    if ~strcmpi(codestr,'all')
        instrumentstrs = regexp(codestr,',','split');
        n = length(instrumentstrs);
    else
        n = size(obj.book_.positions_,1);
        instrumentstrs = cell(n,1);
        for i = 1:n
            instrumentstrs{i} = obj.book_.positions_{i}.code_ctp_;
        end
    end
    
    pnl = zeros(n,1);
    for i = 1:n
        code = instrumentstrs{i};
        isopt = isoptchar(code);
        if ~isopt && isempty(mdefut), pnl(i) = NaN;continue;end
        if isopt && isempty(mdeopt), pnl(i) = NaN;continue;end
        
        [flag,idx] = obj.book_.hasposition(code);
        if ~flag, pnl(i) = NaN; continue;end
        
        pos = obj.book_.positions_{idx};
        
        if ~isopt
            tick = mdefut.getlasttick(code);
        else
            q = mdeopt.qms_.getquote(code);
            tick(1) = q.last_trade;
            tick(2) = q.bid1;
            tick(3) = q.ask1;
        end
        
        if isempty(tick), pnl(i) = NaN;continue;end
        bid = tick(2);
        ask = tick(3);
        if bid == 0 || ask == 0, pnl(i) = NaN; continue;end
        
        volume = pos.direction_ * pos.position_total_;
        instrument = pos.instrument_;
        multi = instrument.contract_size;
        if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
            multi = multi/100;
        end
        cost = pos.cost_open_;

        if volume > 0
            pnl(i) = (bid-cost)*volume*multi;
        elseif volume < 0
            pnl(i) = (ask-cost)*volume*multi;
        end
        
    end
    
end