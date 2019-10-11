function [marginaccountvalue,marginused,deltacarry] = runningpvsynthetic(obj,varargin)
%bkcVanillaArray
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('InitialMargin',1,@isnumeric);
    p.addParameter('VanillaNotional',1,@isnumeric);
    p.addParameter('MarginRate',0.1,@isnumeric);
    p.addParameter('ParticipateRate',0.8,@isnumeric);
    p.parse(varargin{:});
    initialmargin = p.Results.InitialMargin;
    vanillanotional = p.Results.VanillaNotional;
    marginrate = p.Results.MarginRate;
    pr = p.Results.ParticipateRate;
    
    n = obj.latest_;
    dts = zeros(n,1);
    spots = zeros(n,1);
    for i = 1:n
        dts(i) = obj.node_(i).opendt1_; 
        spots(i) = obj.node_(i).S_(1);
    end
    marginaccountvalue = zeros(n,1);
    marginaccountvalue(1) = initialmargin;
    marginused = zeros(n,1);
    deltacarry = zeros(n,1);
    
    for i = 1:n
        dt_i = dts(i);
        %compute theoretical cash delta
        for j = 1:i
            vanilla_j = obj.node_(j);
            tradedts_j = vanilla_j.tradedts_;
            idx_ij = find(tradedts_j == dt_i,1,'first');
            %check if the vanilla is traded on that dt
            if isempty(idx_ij), continue;end
            %check if the vanilla is still alive
            if ~vanilla_j.status_(idx_ij),continue;end
            deltacarry(i) = deltacarry(i) + vanilla_j.deltas_(idx_ij)*vanillanotional;
        end
        %compute margin used
        if i > 1
            marginaccountvalue(i) = marginaccountvalue(i-1)+deltacarry(i-1)*(spots(i)-spots(i-1))/spots(i-1);
        end
        
        if marginaccountvalue(i) <= 0
            warning('margin went bust on %s\n',datestr(dt_i,'yyyy-mm-dd'));
            break
        end
        
        if marginrate*abs(deltacarry(i))/pr > marginaccountvalue(i)
            %if the margin account is breached,  we can only trade with the
            %maximum deltacarry as required
            deltacarry(i) = sign(deltacarry(i))*marginaccountvalue(i)*pr;
            warning('margin breached on %s\n',datestr(dt_i,'yyyy-mm-dd'));
        end
        marginused(i) = marginrate*abs(deltacarry(i));
    end
end