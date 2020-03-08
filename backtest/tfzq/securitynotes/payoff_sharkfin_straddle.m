function [ payoff,iskoed ] = payoff_sharkfin_straddle(px,varargin)
%PAYOFF_SHARKFIN Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('startdate',today,@isnumeric);
    p.addParameter('expirydate',today+90,@isnumeric);
    p.addParameter('knockoutupperlevel',1,@isnumeric);
    p.addParameter('knockoutlowerlevel',1,@isnumeric);
    p.addParameter('minimumpayoff',0,@isnumeric);
    p.addParameter('knockoutupperpayoff',0,@isnumeric);
    p.addParameter('knockoutlowerpayoff',0,@isnumeric);
    p.addParameter('participateratioupper',1,@isnumeric);
    p.addParameter('participateratiolower',1,@isnumeric);
    
    p.parse(varargin{:});
    startdt = p.Results.startdate;
    expirydt = p.Results.expirydate;
    kolvlup = p.Results.knockoutupperlevel;
    kolvldn = p.Results.knockoutlowerlevel;
    minpayoff = p.Results.minimumpayoff;
    kopayoffup = p.Results.knockoutupperpayoff;
    kopayoffdn = p.Results.knockoutlowerpayoff;
    prup = p.Results.participateratioupper;
    prdn = p.Results.participateratiolower;
    
    startidx = find(px(:,1)>=startdt,1,'first');
    expiryidx = find(px(:,1)>=expirydt,1,'first');
    
    if isempty(startidx) || isempty(expiryidx)
        payoff = NaN;
        return
    end
    
    S0 = px(startidx,5);
    S1 = px(expiryidx,5);
    
    iskoed = S1/S0 >= kolvlup || S1/S0 <= kolvldn ;
    if iskoed
        if S1/S0 >= kolvlup
            payoff = kopayoffup;
        else
            payoff = kopayoffdn;
        end
    else
        if S1/S0 < 1
            payoff = (1-S1/S0)*prup+minpayoff;
        else
            payoff = (S1/S0-1)*prdn+minpayoff;
        end
    end
    
    payoff = payoff * (expirydt-startdt)/365;

end

