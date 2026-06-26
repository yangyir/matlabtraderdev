function [effectiveLevel,strength,levelType,details] = geteffectivelevel(varargin)
    % 获取当前位置的最有效结构位 (综合评分版）
    %
    % 综合考量：价格贴进度、结构强度、时效性、来源可靠度、左眼形态
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('currentIdx',[],@isnumeric); % 当前分型所在的K线索引
    p.addParameter('currentPrice',[],@isnumeric);   % 当前分型的价格
    p.addParameter('fractalType','',@ischar);       % top or bottom
    p.addParameter('clusters',{},@isstruct);
    p.addParameter('structures',{},@isstruct);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('maxClusterAge',50,@isnumeric);  % 集群最大存活K线数
    p.addParameter('maxStructureAge',100,@isnumeric);   % 结构位最大存活K线数
    p.addParameter('leftEyeScores',{},@isstruct);
    p.addParameter('leftEyeWeight',0.3,@isnumeric);
    p.addParameter('proximityATR',0.2,@isnumeric);
    p.parse(varargin{:});
    currentIdx = p.Results.currentIdx;
    currentprice = p.Results.currentPrice;
    fractalType = p.Results.fractalType;
%     px = p.Results.px;
%     topF = p.Results.topF;
%     botF = p.Results.botF;
    clusters = p.Results.clusters;
    structures = p.Results.structures;
    atr = p.Results.atr;
    maxClusterAge = p.Results.maxClusterAge;
    maxStructureAge = p.Results.maxStructureAge;
    leftEyeScores = p.Results.leftEyeScores;
    letfEyeWeight = p.Results.leftEyeWeight;
    proximityATR = p.Results.proximityATR;  % 贴近阈值 （ATR倍数，默认0.2）
    
%     H = px(:,3);L = px(:,4);
    
    % 首先检查拒绝结构位 （优先级最高）
    currentATR = atr(currentIdx);
    proximityThreshold = currentATR * proximityATR;
    
    % 初始化输出
    effectiveLevel = [];
    strength = 0;
    levelType = '';
    details = struct();
    
    % 收集所有候选结构位
    candidates = struct('level',{},'strength',{},'type',{},...
        'source',{},'leftEyeBonus',{},'totalScore',{});
    
    % 第一步：从强拒绝结构中寻找候选（优先级最高）
    for s = 1:length(structures)
        % 必须处于活跃状态
        if ~structures(s).isactive
            continue;
        end
        
        if currentIdx < structures(s).formationidx
            continue;
        end
        
        % 时效性检查
        if currentIdx - structures(s).formationidx > maxStructureAge;
            continue;
        end
        
        % 类型必须匹配
        if strcmpi(fractalType,'top') && ...
                ~strcmpi(structures(s).type,'resistance_rejection')
            continue;
        end
        if strcmpi(fractalType,'bottom') && ...
                ~strcmpi(structures(s).type,'support_rejection')
            continue;
        end
        
        % 价格贴进度检查
        dist = abs(structures(s).price - currentprice);
        if dist <= proximityThreshold
            % 强度加权：基础强度 + 时间衰减
            age = currentIdx - structures(s).formationidx;
            timeDecay = max(0.3,1 - age/maxStructureAge);
            adjustedStrength = structures(s).strength * timeDecay;
            
            candidates(end+1).level = structures(s).price;
            candidates(end).strength = adjustedStrength;
            candidates(end).type = structures(s).type;
            candidates(end).source = 'rejection';
%             candidates(end).retestcount = structures(s).retestcount;
            candidates(end).formationidx = structures(s).formationidx;
        end
    end
    %
    % 第二步：从分型集群中寻找候选
    for c = 1:length(clusters)
        if currentIdx < clusters(c).endidx
            continue;
        end
        
        % 时效性检查
        if currentIdx - clusters(c).endidx > maxClusterAge
            continue;
        end
        
        % 类型匹配
        if strcmpi(fractalType,'resistance') && ...
                ~strcmpi(structures(s).type,'resistance')
            continue;
        end
        if strcmpi(fractalType,'support') && ...
                ~strcmpi(structures(s).type,'support')
            continue;
        end
        
        % 价格贴进度检查：当前分型价格必须在集群区间内
        isInside = (currentprice >= clusters(c).lowerbound && ...
            currentprice <= clusters(c).upperbound);
        
        % 或者非常接近集群边界
        nearBoundary = (abs(currentprice - clusters(c).upperbound) <= proximityThreshold) || ...
            (abs(currentprice - clusters(c).lowerbound) <= proximityThreshold);
        
        if isInside || nearBoundary
            % 确定有效价格水平
            if strcmpi(fractalType,'resistance')
                clusterLevel = clusters(c).upperbound;  % 取上沿为压力
            else
                clusterLevel = clusters(c).lowerbound;  % 取下沿为支撑
            end
            
            % 强度计算：集群强度 + 时间衰减
            age = currentIdx - clusters(c).endidx;
            timeDecay = max(0.3, 1 - age/maxClusterAge);
            adjustedStrength = clusters(c).strength * timeDecay;
            
            candidates(end+1).level = clusterLevel;
            candidates(end).strength = adjustedStrength;
            candidates(end).type = clusters(c).type;
            candidates(end).source = 'cluster';
            candidates(end).formationidx = clusters(c).endidx;
        end
    end
    
    % 第三步：孤立分型作为弱结构
    if isempty(candidates)
        candidates(end+1).level = currentprice;
        candidates(end).strength = 1.0;
        candidates(end).type = fractalType;
        candidates(end).source = 'isolated_fractal';
        candidates(end).formationidx = currentIdx;
    end
    
    % 左眼评分加成（如果可用）
    currentLeftEyeBonus = 0;
    if ~isempty(leftEyeScores)
        if strcmpi(fractalType,'top') && isfield(leftEyeScores,'top')
            if currentIdx <= length(leftEyeScores) && ...
                    ~isempty(leftEyeScores(currentIdx).top)
                currentLeftEyeBonus = leftEyeScores(currentIdx).top.score * letfEyeWeight;
            end
        elseif strcmpi(fractalType,'bottom') && isfield(leftEyeScores,'bottom')
            if ~isempty(leftEyeScores(currentIdx).bottom)
                currentLeftEyeBonus = leftEyeScores(currentIdx).bottom.score * letfEyeWeight;
            end
        end
    end
    
    % 第四步：综合评分与择优
    for i = 1:length(candidates)
        baseScore = candidates(i).strength;
        
        % 来源加权：拒绝结构位 > 集群
        if strcmpi(candidates(i).source,'rejection')
            sourceWeight = 1.2;
        elseif strcmpi(candidates(i).source,'cluster')
            sourceWeight = 1.0;
        else
            sourceWeight = 0.6;
        end
        
        candidates(i).totalScore = baseScore * sourceWeight + currentLeftEyeBonus;
        candidates(i).leftEyeBonus = currentLeftEyeBonus;
    end
    
    % 按综合得分降序排列
    [~, sortIdx] = sort([candidates.totalScore], 'descend');
    candidates = candidates(sortIdx);
    
    % 选择得分最高的候选
    best = candidates(1);
    
    effectiveLevel = best.level;
    strength = best.totalScore;
    
    % 生成类型描述
    if strcmpi(best.source,'rejection')
        levelType = best.type;  % 'resistance_rejection' 或 'support_rejection'
    elseif strcmpi(best.source,'cluster')
        if strcmpi(fractalType,'top')
            levelType = 'resistance_cluster';
        else
            levelType = 'support_cluster';
        end
    else
        if strcmpi(fractalType,'top')
            levelType = 'resistance_isolatedfractal';
        else
            levelType = 'support_isolatedfractal';
        end
    end
    
    % 返回详细信息
    details = struct(...
        'effectiveLevel', effectiveLevel, ...
        'totalScore', best.totalScore, ...
        'baseStrength', best.strength, ...
        'source', best.source, ...
        'leftEyeBonus', best.leftEyeBonus, ...
        'allCandidates', candidates);
    
end