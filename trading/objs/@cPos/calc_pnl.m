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
    
    
    if ~obj.is_opt_ && isempty(mdefut) && isempty(mdeopt), pnl = NaN;return;end
    
    if obj.is_opt_ && isempty(mdeopt), pnl = NaN;return;end
    
%     if isempty(mdefut.ticks_), pnl = NaN; return;end
    if ~isempty(mdefut)
        if isempty(mdefut.ticksquick_) && isempty(mdeopt), pnl = NaN; return;end
    end

    if ~obj.is_opt_
        if ~isempty(mdefut)
            tick = mdefut.getlasttick(obj.code_ctp_);
        else
            tick = mdeopt.getlasttick(obj.code_ctp_);
        end
    else
        tick = mdeopt.getlasttick(obj.code_ctp_);
    end

    if isempty(tick), pnl = NaN;return;end
    bid = tick(2);
    ask = tick(3);
    if bid == 0 || ask == 0, pnl = NaN; return;end
    if abs(bid) > 1e10 && abs(ask) > 1e10
        [~,idx] = mdefut.qms_.instruments_.hasinstrument(obj.code_ctp_);
        bid =  mdefut.lastclose_(idx);
        ask = bid;
    end

    volume = obj.direction_ * obj.position_total_;
    instrument = obj.instrument_;
    multi = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
        if multi == 1000000
            multi = multi/100;
        end
    end
    cost = obj.cost_open_;

    if volume > 0
        pnl = (bid-cost)*volume*multi;
    elseif volume < 0
        pnl = (ask-cost)*volume*multi;
    end

end