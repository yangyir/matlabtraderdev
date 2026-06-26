function score = scorecontinuity(px,fractalType)
% K线连续性评分 (0-3分)
    O = px(:,2);
    C = px(:,5);
    n = length(C);
    
    if strcmpi(fractalType,'top')
        trendBars = C > O;  % 阳线
    else
        trendBars = C < O;  % 阴线
    end
    
    maxConsecutive = 0;
    currentConsecutive = 0;
    
    for i = 1:n
        if trendBars(i)
            currentConsecutive = currentConsecutive + 1;
        else
            maxConsecutive = max(maxConsecutive,currentConsecutive);
            currentConsecutive = 0;
        end
    end
    maxConsecutive = max(maxConsecutive,currentConsecutive);
    
    reverseBars = sum(~trendBars);
    
    if maxConsecutive >= 5
        baseScore = 3.0;
    elseif maxConsecutive >= 3
        baseScore = 2.0;
    elseif maxConsecutive >= 2
        baseScore = 1.0;
    else
        baseScore = 0.5;
    end
    
    penalty = reverseBars * 0.3;
    score = max(0, baseScore - penalty);
end