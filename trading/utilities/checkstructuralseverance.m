function isSevered = checkstructuralseverance(varargin)
% 检查两个分型集群之间的区间是否出现了“切断”事件
%
% 切断的定义：
% 对于压力集群（顶分型）：
%   - 区间内价格有效跌破集群下沿
%   - 或者形成反向（底分型）结构位
% 对于支撑集群（底分型）：
%   - 区间内价格有效突破集群上沿
%   - 或者形成反向（顶分型）结构位

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('cluster1',{},@isstruct);
    p.addParameter('cluster2',{},@isstruct);
    p.addParameter('px',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('tolerance',0.25,@isnumeric);
    p.addParameter('nfractal',2,@isnumeric);
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('rejectionstructures',{},@isstruct);
    p.parse(varargin{:});
    
    cluster1 = p.Results.cluster1;
    cluster2 = p.Results.cluster2;
    allindices = [cluster1.allindices; cluster2.allindices];
    earliestidx = min(allindices);
    latestidx = max(allindices);
    
    if earliestidx >= latestidx - 1
        isSevered = false;  % 区间太短，无法判定
        return;
    end
    
    px = p.Results.px;
    C = px(:,5); H = px(:,3); L = px(:,4); O = px(:,2);
    
    
    % 集群的价格区间 （合并后可能的区间）
    clusterlower = min(cluster1.lowerbound,cluster2.lowerbound);
    clusterupper = max(cluster1.upperbound,cluster2.upperbound);
    
    atr = p.Results.atr;
    nfractal = p.Results.nfractal;
    % 平均波动率 (覆盖了整个分型形成的K线）
    avgatr = mean(atr(max(1,earliestidx-nfractal):min(length(atr),latestidx+nfractal)));
    
    if strcmpi(cluster1.type,'resistance')
        % ======= 压力集群：检查是否有深度回调 =======
        
        % 检查1：价格是否有效跌破集群下沿 (单点深跌0.5ATR）
        % '有效跌破' = 收盘价低于下沿，且幅度超过ATR的一定比例
        penetrationthreshold = clusterlower - avgatr * 0.5;
        
        for k = earliestidx+1:latestidx-1
            if C(k) < penetrationthreshold
                isSevered = true;
                return
            end
        end
        
        % 检查2：中间是否出现了底分型（反向结构）
        % 如果有底分型，且其低点明显低于集群下沿
        botF = p.Results.botF;
        if ~isempty(botF)
            for k = earliestidx+1:latestidx-1
                if botF(k) == 1 && L(k) < clusterlower - avgatr * 0.3
                    isSevered = true;
                    return
                end
            end
        end
        
        % 检查3：连续多根K线收盘都在集群下沿下方
        % 说明价格已经“有效停留”在集群下方，这也是切断信号
        consecutivebelow = 0;
        for k = earliestidx+1:latestidx-1
            if C(k) < clusterlower % 收盘在集群下沿下方
                consecutivebelow = consecutivebelow + 1;
            else
                consecutivebelow = 0;
            end
            
            % 连续3根收盘在下方：说明不是毛刺，是有效下破
            if consecutivebelow >= 3
                isSevered = true;
                return
            end
        end
        %
        % 如果两个顶分型集群之间，已经存在一个之前记录的支撑强拒绝结构位，
        % 说明空头曾经在这里成功组织过反击，市场结构已经被切断
        rejectstructures = p.Results.rejectionstructures;
        for s = 1:length(rejectstructures)
            if strcmpi(rejectstructures(s).type,'support_rejection') && ...
                    rejectstructures(s).formationidx > earliestidx && ...
                    rejectstructures(s).formationidx < latestidx && ...
                    rejectstructures(s).price < clusterlower
                isSevered = true;
                return
            end
        end
        %
    elseif strcmpi(cluster1.type,'support')
        % ======= 支撑集群：检查是否有有效突破 =======
        
        % 检查1：价格是否有效突破集群上沿
        % '有效突破' = 收盘价高于上沿，且幅度超过ATR的一定比例
        penetrationthreshold = clusterupper + avgatr * 0.5;
        
        for k = earliestidx+1:latestidx-1
            if C(k) > penetrationthreshold
                isSevered = true;
                return
            end
        end
        
        % 检查2：中间是否出现了顶分型（反向结构）
        % 如果有顶分型，且其高点明显高于集群上沿
        topF = p.Results.topF;
        if ~isempty(topF)
            for k = earliestidx+1:latestidx-1
                if topF(k) == 1 && H(k) > clusterupper + avgatr * 0.3
                    isSevered = true;
                    return
                end
            end
        end
        
        % 检查3：连续多根K线收盘都在集群上沿上方
        % 说明价格已经“有效停留”在集群上方，这也是切断信号
        consecutiveabove = 0;
        for k = earliestidx+1:latestidx-1
            if C(k) < clusterupper % 收盘在集群上沿上方
                consecutiveabove = consecutiveabove + 1;
            else
                consecutiveabove = 0;
            end
            
            % 连续3根收盘在下方：说明不是毛刺，是有效下破
            if consecutiveabove >= 3
                isSevered = true;
                return
            end
        end
        %
        % 如果两个底分型集群之间，已经存在一个之前记录的压力强拒绝结构位，
        % 说明多头曾经在这里成功组织过反击，市场结构已经被切断
        rejectstructures = p.Results.rejectionstructures;
        for s = 1:length(rejectstructures)
            if strcmpi(rejectstructures(s).type,'resistance_rejection') && ...
                    rejectstructures(s).formationidx > earliestidx && ...
                    rejectstructures(s).formationidx < latestidx && ...
                    rejectstructures(s).price > clusterlower
                isSevered = true;
                return
            end
        end
        
    end
    
    isSevered = false;
    
end