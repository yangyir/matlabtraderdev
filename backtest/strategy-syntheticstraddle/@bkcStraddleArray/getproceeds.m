function premium = getproceeds(obj,datein,varargin)
%bkcStraddleArray
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('FixedPremium',[],@isnumeric);
    p.parse(varargin{:});
    fixedpremium = p.Results.FixedPremium;
    usefixedpremium = ~isempty(fixedpremium);
    premium = 0;
    n = obj.latest_;
    for i = 1:n
        straddle_i = obj.node_(i);
        [unwindidx,unwinddt] = straddle_i.unwindinfo(varargin{:});
        if unwinddt == datein
            ret = straddle_i.pvs_(unwindidx)/straddle_i.pvs_(1);
            if usefixedpremium
                premium = premium + fixedpremium*ret;
            else
                premium = premium + pv0*ret;
            end
        end
    end
end