function [pnl] = calc_pnl(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},...
        @(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('MDEOpt',{},...
        @(x) validateattributes(x,{'cMDEOpt'},{},'','MDEOpt'));
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    mdeopt = p.Results.MDEOpt;
    
    
    if ~obj.is_opt_ && isempty(mdefut), pnl = NaN;return;end
    
    if obj.is_opt_ && isempty(mdeopt), pnl = NaN;return;end

    if ~obj.is_opt_
        tick = mdefut.getlasttick(obj.code_ctp_);
    else
        q = mdeopt.qms_.getquote(obj.code_ctp_);
        tick(1) = q.last_trade;
        tick(2) = q.bid1;
        tick(3) = q.ask1;
    end

    if isempty(tick), pnl = NaN;return;end
    bid = tick(2);
    ask = tick(3);
    if bid == 0 || ask == 0, pnl = NaN; return;end

    volume = obj.direction_ * obj.position_total_;
    instrument = obj.instrument_;
    multi = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
        multi = multi/100;
    end
    cost = pos.cost_open_;

    if volume > 0
        pnl = (bid-cost)*volume*multi;
    elseif volume < 0
        pnl = (ask-cost)*volume*multi;
    end

end