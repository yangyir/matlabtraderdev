function score = scoreretracedepth(px,fractalType,currentATR)
% 回测深度评分（0-2分）
% 评估的是左眼趋势中回调的深度和频次
% 对于顶分型的左眼，理想的情况是：
% 上涨 -> 小回调 -> 继续上涨 -> 小回调 -> 继续上涨， 回调幅度小，不破坏趋势结构
% 不理想的情况：
% 上涨 -> 深回调 （几乎吞没前一根阳线） + 勉强再涨。说明多头力量不凝聚，趋势质量差
    O = px(:,2);
    H = px(:,3);
    L = px(:,4);
    C = px(:,5);
    
    n = length(C);
    
    if n < 3
        score = 0;  % K线太少，无法判断
        return;
    end
    
    % 取分型形成时的ATR作为基准
    % 即currentATR
    if currentATR < 0.0001
        score = 0;
        return;
    end
    
    % 存储每段回调的深度
    retraceDepths = [];
    
    inRetrace = false;  % 是否正处于回调中
    retraceStart = 0;   % 回调开始的K线索引
    retraceExtremeClose = 0;    % 用收盘价的最值，而非影线最值
    
    for i = 1:n
        % 判断当前K线是否为反向K线，即回调K线
        % 顶分型左眼（上涨趋势）：阴线 = 回调
        % 底分型左眼（下跌趋势）：阳线 = 回调
        isReverseBar = (strcmpi(fractalType,'top') && C(i) < O(i)) || ...
            (strcmpi(fractalType,'bottom') && C(i) > O(i));
        
        if isReverseBar && ~inRetrace
            % 进入回调段
            inRetrace = true;
            retraceStart = i;
            retraceExtremeClose = C(i);
        elseif isReverseBar && inRetrace
            if strcmpi(fractalType,'top')
                retraceExtremeClose = min(retraceExtremeClose,C(i));
            elseif strcmpi(fractalType,'bottom')
                retraceExtremeClose = max(retraceExtremeClose,C(i));
            end
        elseif ~isReverseBar && inRetrace
            % 回调结束
            inRetrace = false;
            if retraceStart > 1
                preTrendClose = C(retraceStart - 1);
                if preTrendClose > 0
                    depth = abs(retraceExtremeClose - preTrendClose) / currentATR;
                    tmp = [retraceDepths, depth];
                    retraceDepths = tmp;
                end
            end
        end
    end
    
    % 处理末尾未结束的回调
    if inRetrace && retraceStart > 1
        preTrendClose = C(retraceStart - 1);
        if preTrendClose > 0
            depth = abs(retraceExtremeClose - preTrendClose) / currentATR;
            tmp = [retraceDepths, depth];
            retraceDepths = tmp;
        end
    end
    
    if isempty(retraceDepths)
        score = 2.0;
    else
        maxDepthATR = max(retraceDepths);
        if maxDepthATR < 0.3
            score = 2.0;    % 回调不到0.3倍ATR,极浅，非常健康
        elseif maxDepthATR < 0.5
            score = 1.5;    % 回调不到0.5倍ATR，浅回调，健康
        elseif maxDepthATR < 0.8
            score = 1.0;    % 回调不到0.8倍ATR，中等回调，可接受
        elseif maxDepthATR < 1.2
            score = 0.5;    % 回调不到1.2倍ATR，偏深，趋势存疑
        else
            score = 0;      % 回调超过1.2倍ATR，太深，趋势已经破坏
        end
        
        % 回调次数惩罚
        if length(retraceDepths) > 3
            score = score * 0.5;
        elseif length(retraceDepths) > 2
            score = score * 0.7;
        end 
    end
end