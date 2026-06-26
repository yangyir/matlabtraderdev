function score = scoreshadowhealth(px,fractalType,currentATR)
% 影线健康度评分 （0-2.5分）
% 对于一般健康的上涨的趋势(顶分型的左眼），我们希望看到：
% - 阳线实体饱满 （多头掌控）
% - 上影线短 （多头没有被空头反击）
% - 下影可以长 （多头在日内低位吸筹后拉回，这是健康的）
% 不健康的信号：
%   - 上涨过程中频繁出现上影线
%   - 下跌过程中频繁出现下影线
    O = px(:,2);
    H = px(:,3);
    L = px(:,4);
    C = px(:,5);
    
    n = length(C);
    if currentATR < 0.0001
        score = 0;
        return;
    end
    
    totalPenalty = 0;
    
    for i = 1:n
        totalRange = H(i) - L(i);
        if totalRange < 0.0001
            continue;
        end
        
        if strcmpi(fractalType,'top')
            upperShadow = H(i) - max(O(i),C(i));
            shadowATR = upperShadow / currentATR;
            % upperShadow = 最高价 - 实体上沿
            if shadowATR > 0.5
                totalPenalty = totalPenalty + 0.6;  % 长上影，严重扣分
            elseif shadowATR > 0.3 && shadowATR <= 0.5
                totalPenalty = totalPenalty + 0.3;  % 中等上影，适度扣分
            else
                % 上影线短或者没有，不扣分
            end
        elseif strcmpi(fractalType,'bottom')
            lowerShadow = min(O(i),C(i)) - L(i);
            % lowerShadow = 实体下沿 - 最低价
            shadowATR = lowerShadow / currentATR;
            
            if shadowATR > 0.5
                totalPenalty = totalPenalty + 0.6;  % 长下影，严重扣分
            elseif shadowATR > 0.3 && shadowATR <= 0.5
                totalPenalty = totalPenalty + 0.3; % 中等下影，适度扣分
            else
                % 下影线短或者没有，不扣分
            end
        end
    end
    
    score = max(0,2.5-totalPenalty);

end