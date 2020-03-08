function [ payoff ] = payoff_bullspread(px,varargin)
%PAYOFF_SHARKFIN Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('startdate',today,@isnumeric);
    p.addParameter('expirydate',today+90,@isnumeric);
    p.addParameter('minimumpayoff',0,@isnumeric);
    p.addParameter('upperstrikelevel',1,@isnumeric);
    p.addParameter('participateratio',1,@isnumeric);
    
    p.parse(varargin{:});
    startdt = p.Results.startdate;
    expirydt = p.Results.expirydate;
    upstrikelvl = p.Results.upperstrikelevel;
    minpayoff = p.Results.minimumpayoff;
    pr = p.Results.participateratio;
    
    startidx = find(px(:,1)>=startdt,1,'first');
    expiryidx = find(px(:,1)>=expirydt,1,'first');
    
    if isempty(startidx) || isempty(expiryidx)
        payoff = NaN;
        return
    end
    
    S0 = px(startidx,5);
    S1 = px(expiryidx,5);
    
    if S1/S0<=1
        payoff = minpayoff;
    else
        if S1/S0 >= upstrikelvl
            payoff = (upstrikelvl-1)*pr+minpayoff;
        else
            payoff = (S1/S0-1)*pr+minpayoff;
        end
    end
    
    payoff = payoff * (expirydt-startdt)/365;

end

