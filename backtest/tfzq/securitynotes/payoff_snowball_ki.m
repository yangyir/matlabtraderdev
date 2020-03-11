function [ payoff,iskoed,iskied ] = payoff_snowball_ki(px,varargin)

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('startdate',today,@isnumeric);
    p.addParameter('expirydate',today+90,@isnumeric);
    p.addParameter('knockoutlevel',1,@isnumeric);
    p.addParameter('knockinlevel',0.7,@isnumeric);
    p.addParameter('knockoutpayoff',0,@isnumeric);
    p.addParameter('participateratio',1,@isnumeric);
    
    p.parse(varargin{:});
    startdt = p.Results.startdate;
    expirydt = p.Results.expirydate;
    kolvl = p.Results.knockoutlevel;
    kilvl = p.Results.knockinlevel;
    kopayoff = p.Results.knockoutpayoff;
    pr = p.Results.participateratio;
    
    startidx = find(px(:,1)>=startdt,1,'first');
    expiryidx = find(px(:,1)>=expirydt,1,'first');
    
    if isempty(startidx) || isempty(expiryidx)
        payoff = NaN;
        return
    end
    
    iskied = ~isempty(find(px(startidx+1:expiryidx,5)./px(startidx,5)<kilvl,1,'first'));
        
    S0 = px(startidx,5);
    S1 = px(expiryidx,5);
    
    if S1/S0>=kolvl
        iskoed = true;
        payoff = kopayoff;
    else
        iskoed = false;
        if iskied
            if S1/S0 > kilvl
                payoff = kopayoff;
            else
                payoff = (S1/S0-1)*pr;
            end
        else
            payoff = kopayoff;
        end
    end
    
    payoff = payoff * (expirydt-startdt)/365;

end

