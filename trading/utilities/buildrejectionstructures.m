function structures = buildrejectionstructures(varargin)
    % 基于强拒绝行为构建结构体
    % 基于分型位置及其右眼的强拒绝行为构建结构位
    % 两种检测模式：分型自身强拒绝  + 右眼强拒绝
    % 返回值：包含拒绝时间的结构体数组
    % 模式：'self' = 自身拒绝， 'early' = 右眼早期拒绝， ’defensive' = 防守反击
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('px',[],@isnumeric);
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('nlookback',100,@isnumeric); % 结构位回溯期
    p.addParameter('nfractal',2,@isnumeric);
    p.addParameter('scoreThreshold',4,@isnumeric); % 强拒绝最低得分
    p.addParameter('rightEyeWindowLength',3,@isnumeric);    % 右眼观察窗口长度 
    p.addParameter('referenceIdx',[],@isnumeric);
    p.addParameter('maxStructureAge',[],@isnumeric);
    p.parse(varargin{:});
    px = p.Results.px;
    O = px(:,2);H = px(:,3);L = px(:,4);C = px(:,5);
    nfractal = p.Results.nfractal;
    topF = p.Results.topF;
    botF = p.Results.botF;
    if isempty(topF) || isempty(botF)
        [topF,botF] = identifyfractals(H,L,nfractal);
    end
    atr = p.Results.atr;
    if isempty(atr)
        atr = calcATR(H,L,C);
    end
    nlookback = p.Results.nlookback;
    scorethreshold = p.Results.scoreThreshold;
    righteyewindowlength = p.Results.rightEyeWindowLength;
    referenceIdx = p.Results.referenceIdx;
    n = length(H);
    if isempty(referenceIdx)
        referenceIdx = n;
    end
    maxstructureage = p.Results.maxStructureAge;
    
    structures = struct('price',{},'type',{},'strength',{},...
        'formationidx',{},'fractalidx',{},'isactive',{},'retestcount',{});
    
    for i = nlookback+1:min(n,referenceIdx-nfractal)
        % only deal with fractals
        istopF = topF(i) == 1;
        isbotF = botF(i) == 1;
        
        if ~istopF && ~isbotF
            continue;
        end
        
        if ~isempty(maxstructureage)
            age = referenceIdx - i;
            if age > maxstructureage
                continue;
            end
        end
        
        % =========== 低波动率环境过滤 =================
        totalrange = H(i) - L(i);
        % 这里针对JPYUSD可能需要做修改
        if totalrange < 0.0001
%             fprintf('total range is %4.4f on %s\n',totalrange,datestr(px(i,1),'yyyy-mm-dd HH:MM'));
            continue;
        end
        % 取当前K线附近的ATR均值
        avgatrwindow = mean(atr(max(1,i-2*nfractal-1):min(referenceIdx,i+nfractal)));
        % 如果整根K线的波幅连平均ATR的60%都不到，
        % 说明市场处于低波动状态，长影线可能只是随机噪声
        if totalrange < avgatrwindow * 0.6
            continue;
        end
        
        % ============ 分型K线本身形态 ===========
        body = abs(C(i) - O(i));
        realbodyratio = body / totalrange;
        
        % ------顶分型：检查是否有长上影（自身就是强拒绝）--------
        if istopF
            currentatr = atr(i);
            if currentatr < 0.0001, continue;end
            
            isrejection = false;
            rejectionscore = 0;
            rejectionmode = '';
            
            % 模式1：分型K线自身强拒绝（长上影）
            uppershadow = H(i) - max(O(i),C(i));
            uppershadowatr = uppershadow / currentatr;
            if realbodyratio < 0.4 && uppershadowatr > 0.3
                isrejection = true;
                % 自身强拒绝得分
                rejectionscore = rejectionscore + 3;
                if C(i) < O(i)
                    rejectionscore = rejectionscore + 1;%阴线加分
                end
                if uppershadowatr > 0.5
                    rejectionscore = rejectionscore + 1; %极长上影额外加分
                end
                rejectionmode = 'self';
            end
            
            % ---- 模式2+3：顶分型右眼强拒绝检测 ----
            % 分型K线本身不是长上影，但右眼出现了反包
            for k = i+1:min(referenceIdx,i+righteyewindowlength)
                if k > referenceIdx
                    break;
                end
                
                isbearish = C(k) < O(k);
                brokebelow = C(k) < H(i);
                
                if isbearish && brokebelow
                    % 计算右眼K线的下跌力度(ATR归一化）
                    declineatr = (H(i) - C(k)) / currentatr;
                    
                    if k <= i+2
                        % 右眼早期 （分型后1-2根）
                        if ~isrejection || strcmpi(rejectionmode,'self')
                            isrejection = true;
                            rejectionscore = rejectionscore + 4;
                            rejectionmode = 'early';
                            
                            % 下跌力度加分
                            if declineatr > 0.5
                                rejectionscore = rejectionscore + 1;
                            end
                        end
                    end
                    
                    if k > i+2
                        % 右眼后期（防守反击）
                        rejectionscore = rejectionscore + 2;
                        if strcmpi(rejectionmode,'early')
                            rejectionmode = 'early_defensive';
                        elseif ~isrejection
                            isrejection = true;
                            rejectionmode = 'defensive';
                        end
                    end
                end
                
                % 如果出现阳线创新高，拒绝失败
                if ~isbearish && H(k) > H(i)
                    isrejection = false;
                    rejectionscore = 0;
                    rejectionmode = '';
                    break;
                end   
            end
            
            if isrejection && rejectionscore >= scorethreshold
                structures(end+1).price = H(i); % 结构位取分型的最高点
                structures(end).type = 'resistance_rejection';
                structures(end).strength = rejectionscore;
                structures(end).formationidx = i;
                structures(end).fractalidx = i;
                structures(end).isactive = true;
                structures(end).retestcount = 0;
                structures(end).rejectionmode = rejectionmode;
                structures(end).terminationreason = '';
            end
        end
        
        % -----底分型：检查是否有长下影 （自身就是强拒绝）--------
        if isbotF
            currentatr = atr(i);
            if currentatr < 0.0001, continue;end
            
            isrejection = false;
            rejectionscore = 0;
            rejectionmode = '';
            
            % 模式1：分型K线自身强拒绝（长下影）
            lowershadow = min(O(i),C(i)) - L(i);
            lowershadowatr = lowershadow / currentatr;
            
            if realbodyratio < 0.4 && lowershadowatr > 0.3
                isrejection = true;
                rejectionscore = rejectionscore + 3;
                if C(i) > O(i)
                    rejectionscore = rejectionscore + 1; % 阳线加分
                end
                if lowershadowatr > 0.5
                    rejectionscore = rejectionscore + 1; % 极长下影线加分
                end
                rejectionmode = 'self';
            end
            
            % ---- 模式2+3：顶分型右眼强拒绝检测 ----
            % 分型K线本身不是长上影，但右眼出现了反包
            for k = i+1:min(referenceIdx,i+righteyewindowlength)
                if k > referenceIdx
                    break;
                end
                
                isbullish = C(k) > O(k);
                brokeabove = C(k) > L(i);
                
                if isbullish && brokeabove
                    rallyatr = (C(k) - L(i)) / currentatr;
                    
                    if k <= i+2
                        if ~isrejection || strcmpi(rejectionmode,'self')
                            isrejection = true;
                            rejectionscore = rejectionscore + 4;
                            rejectionmode = 'early';
                            
                            if rallyatr > 0.5
                                rejectionscore = rejectionscore + 1;
                            end
                        end
                    end
                    
                    if k > i+2
                        rejectionscore = rejectionscore + 2;
                        if strcmpi(rejectionmode,'early')
                            rejectionmode = 'early_defensive';
                        elseif ~isrejection
                            isrejection = true;
                            rejectionmode = 'defensive';
                        end
                    end
                end
                
                if ~isbullish && L(k) < L(i)
                    isrejection = false;
                    rejectionscore = 0;
                    rejectionmode = '';
                    break;
                end
            end
            
            if isrejection && rejectionscore >= scorethreshold
                structures(end+1).price = L(i); % 结构位取分型的最低点
                structures(end).type = 'support_rejection';
                structures(end).strength = rejectionscore;
                structures(end).formationidx = i;
                structures(end).fractalidx = i;
                structures(end).isactive = true;
                structures(end).retestcount = 0;
                structures(end).rejectionmode = rejectionmode;
                structures(end).terminationreason = '';
            end
            
        end
        
    end
end