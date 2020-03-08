function [ payoff,iskoed ] = payoff_sharkfin_bear(px,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('startdate',today,@isnumeric);
    p.addParameter('expirydate',today+90,@isnumeric);
    p.addParameter('knockoutlevel',1,@isnumeric);
    p.addParameter('minimumpayoff',0,@isnumeric);
    p.addParameter('knockoutpayoff',0,@isnumeric);
    p.addParameter('participateratio',1,@isnumeric);
    
    p.parse(varargin{:});
    startdt = p.Results.startdate;
    expirydt = p.Results.expirydate;
    kolvl = p.Results.knockoutlevel;
    minpayoff = p.Results.minimumpayoff;
    kopayoff = p.Results.knockoutpayoff;
    pr = p.Results.participateratio;
    
    startidx = find(px(:,1)>=startdt,1,'first');
    expiryidx = find(px(:,1)>=expirydt,1,'first');
    
    if isempty(startidx) || isempty(expiryidx)
        payoff = NaN;
        return
    end
    
    S0 = px(startidx,5);
    S1 = px(expiryidx,5);
    
    iskoed = S1/S0 <= kolvl;
    if iskoed
        payoff = kopayoff;
    else
        if S1/S0 > 1
            payoff = minpayoff;
        else
            payoff = (1-S1/S0)*pr+minpayoff;
        end
    end
    
    payoff = payoff * (expirydt-startdt)/365;

end

