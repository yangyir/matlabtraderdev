function score = scorebodyquality(px,fractalType)
% 实体质量评分（0-2.5分）
    O = px(:,2);
    H = px(:,3);
    L = px(:,4);
    C = px(:,5);
    
    n = length(C);
    
    if strcmpi(fractalType,'top')
        trendDirection = 1;
    else
        trendDirection = -1;
    end
    
    totalScore = 0;
    validBars = 0;
    
    for i = 1:n
        body = abs(C(i) - O(i));
        totalRange = H(i) - L(i);
        if totalRange < 0.0001
            continue;
        end
        
        bodyRatio = body / totalRange;
        
        isTrendBar = (trendDirection == 1 && C(i) > O(i)) || ...
            (trendDirection == -1 && C(i) < O(i));
        
        if isTrendBar
            if bodyRatio >= 0.7
                totalScore = totalScore + 1.0;
            elseif bodyRatio >= 0.5 && bodyRatio < 0.7
                totalScore = totalScore + 0.7;
            elseif bodyRatio >= 0.3 && bodyRatio < 0.5
                totalScore = totalScore + 0.4;
            else
                totalScore = totalScore + 0.1;
            end
            validBars = validBars + 1;
        end
    end
    
    if validBars == 0
        score = 0;
    else
        score = min(2.5,(totalScore/validBars)*2.5);
    end
end