function structuresUpdated = updatestructurelevels(varargin)
    % 动态更新结构位：处理二次测试与级别升级
    %
    % 三种失效方式：
    % 1. 时间过期（time_expired)
    % 2. 被有效突破 (broken_up / broken_down)
    % 3. 被反向结构否定 （negated_by_support / negated_by_resistance)
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('structures',{},@isstruct);
    p.addParameter('px',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('maxstructureage',100,@isnumeric);  % 结构位回溯期
    p.addParameter('invalidationATR',1,@isnumeric);    % 结构位失效ATR倍数
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('referenceIdx',[],@isnumeric);      % 当前回测时间点（K线索引）
    p.parse(varargin{:});
    structures = p.Results.structures;
    px = p.Results.px;
    atr = p.Results.atr;
    maxstructureage = p.Results.maxstructureage;
    invalidationatr = p.Results.invalidationATR;
    topF = p.Results.topF;
    botF = p.Results.botF;
    referenceIdx = p.Results.referenceIdx;
    
    H = px(:,3);O = px(:,2); L = px(:,4); C = px(:,5);
    n = length(H);
    if isempty(referenceIdx)
        referenceIdx = n;   % 默认实盘模式
    end
    
    for s = 1:length(structures)
        if ~structures(s).isactive
            continue;
        end
        
        formidx = structures(s).formationidx;
        
        % 结构位还没形成 （在referenceIdx之后才出现）
        if formidx > referenceIdx
            continue;   % 不做任何判断，保持原状态
        end
        
        % 检查时间过期
        age = referenceIdx - formidx;
        if age > maxstructureage
            structures(s).isactive = false;
            structures(s).terminationreason = 'time_expired';
            structures(s).terminationidx = referenceIdx;
            continue;
        end
        
        % 检查是否被有效突破（结构位失效）
        isInvalidated = false;
        currentprice = structures(s).price;
        if strcmpi(structures(s).type, 'resistance_rejection') % 压力位
            % 压力位失效：价格有效突破该压力位          
            for k = formidx+1:referenceIdx
                % 收盘价突破，且不是毛刺(有实体突破）
                if C(k) > currentprice && C(k) > O(k) % 阳线突破
                    % 检查突破的持续性：后续K线没有立刻跌回
                    if k+2 <= referenceIdx
                        if C(k+1) > currentprice || C(k+2) > currentprice
                            isInvalidated = true;
                            structures(s).terminationreason = 'broken_up';
                            structures(s).terminationidx = k;
                            break;
                        end
                    else
                        % 确认K线不足，保守处理：不判定失效
                        continue;
                    end
                end
                
                % 大幅跳空突破
                if C(k) > currentprice + atr(k) * invalidationatr
                    isInvalidated = true;
                    structures(s).terminationreason = 'broken_up_strong';
                    structures(s).terminationidx = k;
                    break;
                end
            end
            %         
        elseif strcmpi(structures(s).type, 'support_rejection') % 支撑位
            % 支撑位失效：价格有效跌破该支撑位
            for k = formidx+1:referenceIdx
                % 收盘价突破，且不是毛刺（有实体突破）
                if C(k) < currentprice && C(k) < O(k) % 阴线突破
                    if k+2 <= referenceIdx
                        if C(k+1) < currentprice || C(k+2) < currentprice
                            isInvalidated = true;
                            structures(s).terminationreason = 'broken_down';
                            structures(s).terminationidx = k;
                            break;
                        end
                    else
                        % 确认K线不足，保守处理：不判定失效
                        continue;
                    end
                end
                
                % 大幅跳空突破
                if C(k) < currentprice - atr(k) * invalidationatr
                    isInvalidated = true;
                    structures(s).terminationreason = 'broken_down_strong';
                    structures(s).terminationidx = k;
                    break;
                end
            end 
        end
        
        if isInvalidated
            structures(s).isactive = false;
            continue;  % 已失效，跳过后续升级检查
        end
        
        % 检查2
        isNegated = false;
        if strcmpi(structures(s).type, 'resistance_rejection') % 压力位
            % 检查是否在下方形成了有效的支撑结构
            for k = formidx+1:referenceIdx
                if botF(k) == 1
                    % 底分型形成，且离当前结构位够远
                    if L(k) < currentprice - atr(k)*0.5
                        % 下方形成了有深度的反向结构
                        isNegated = true;
                        structures(s).terminationreason = 'negated_by_support';
                        structures(s).terminationidx = k;
                        break;
                    end
                end
            end
        elseif strcmpi(structures(s).type, 'support_rejection') % 支撑位
            % 检查是否在上方形成了有效的压力结构
            for k = formidx+1:referenceIdx
                if topF(k) == 1
                    % 顶分型形成，且离当前结构位够远
                    if H(k) > currentprice + atr(k)*0.5
                        % 上方形成了有深度的反向结构
                        isNegated = true;
                        structures(s).terminationreason = 'negated_by_resistance';
                        structures(s).terminationidx = k;
                        break;
                    end
                end
            end
        end
        
        if isNegated
            structures(s).isactive = false;
            continue; % 已失效，跳过后续升级检查
        end
        
        % 检查从形成后至今的K线，寻找二次测试
        for i = formidx+1:referenceIdx
            if strcmpi(structures(s).type, 'resistance_rejection') % 压力位
                % 寻找向上测试该结构位的K线
                if H(i) > structures(s).price
                    % 计算穿透度
                    penetration = (H(i) - structures(s).price) / atr(i);
                    
                    % 分析这次测试的质量
                    isQualityTest = C(i) > O(i) && ... % 阳线
                        (C(i)-O(i)) / (H(i)-L(i)+0.0001) > 0.5;  % 实体占比大
                    
                    if isQualityTest && penetration > 0.2
                        % 这是一次有质量的深入测试
                        % 检查后续2根K线是否出现反包 （空头防守反击成功）
                        if i+2 <= referenceIdx && ...
                                C(i+1) < O(i+1) && ... % 第一根确认K线为阴线
                                (C(i+2) < C(i+1) || C(i+1) < structures(s).price)
                            % 防守反击成功：升级结构位到新的高点
                            structures(s).price = H(i);
                            structures(s).strength = structures(s).strength + 1;
                            structures(s).retestcount = structures(s).retestcount + 1;
                            break;
                        elseif i+2 > referenceIdx
                            continue;
                        end
                    else
                        % 无力的毛刺测试，强化原结构位
                        structures(s).strength = structures(s).strength + 0.5;
                        structures(s).retestcount = structures(s).retestcount + 0.5;
                    end
                end
            elseif strcmpi(structures(s).type, 'support_rejection') % 支撑位
                % 寻找向下测试该结构位的K线
                if L(i) < structures(s).price
                    % 计算穿透度
                    penetration = (structures(s).price - L(i)) / atr(i);
                    
                    % 分析这次测试的质量
                    isQualityTest = C(i) < O(i) && ... % 阴线
                        (O(i) - C(i)) / (H(i)-L(i)+0.0001) > 0.5;
                    
                    if isQualityTest && penetration > 0.2
                        % 这是一次有质量的深入测试
                        % 检查后续2根K线是否出现反包 （空头防守反击成功）
                        if i+2 <= referenceIdx && ...
                                C(i+1) > O(i+1) && ... % 第一根确认K线为阳线
                                (C(i+2) > C(i+1) || C(i+1) > structures(s).price)
                            structures(s).price = L(i);
                            structures(s).strength = structures(s).strength + 1;
                            structures(s).retestcount = structures(s).retestcount + 1;
                            break;
                        elseif i+2 < referenceIdx
                            continue;
                        end
                    else
                        % 无力的毛刺测试，强化原结构位
                        structures(s).strength = structures(s).strength + 0.5;
                        structures(s).retestcount = structures(s).retestcount + 0.5;
                    end
                end
            end
        end
    end
    
    structuresUpdated = structures;
    
end