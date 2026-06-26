function clusters = mergeoverlappingclusters(varargin)
% merge overlapping fractal clusters
% if any two clusters have the price range overlapped, they will be merged
% into a bigger cluster
% 合并条件：同类型 + 价格重叠/接近 + 时间接近 + 结构未被切断
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('clusters',{},@isstruct);
    p.addParameter('px',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('tolerance',0.25,@isnumeric);    %集群容差（ATR倍数）
    p.addParameter('maxTimeGap',30,@isnumeric);    %集群合并最大时间间隔
    p.addParameter('nfractal',2,@isnumeric);
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('structureLevels',{},@isstruct);
    
    p.parse(varargin{:});
    clusters = p.Results.clusters;
    
    n = length(clusters);
    if n < 2
        return;
    end
    
    px = p.Results.px;
    atr = p.Results.atr;
    tolerance = p.Results.tolerance;
    maxTimeGap = p.Results.maxTimeGap;
    nfractal = p.Results.nfractal;
    topF = p.Results.topF;
    botF = p.Results.botF;
    structureLevels = p.Results.structureLevels;

    merged = true;
    while merged
        merged = false;
        newclusters = struct('type',{},'upperbound',{},'lowerbound',{},...
            'strength',{},'endidx',{},'allprices',{},'allindices',{});
        skipflags = zeros(n,1);
        
        for i = 1:n
            if skipflags(i)
                continue;
            end
            
            currentcluster = clusters(i);
            
            for j = i+1:n
                if skipflags(j)
                    continue;
                end
                
                % 条件1：同类型
                if ~strcmpi(currentcluster.type,clusters(j).type)
                    continue;
                end
                
                % 条件2：时间间隔
                allindices_i = currentcluster.allindices;
                allindices_j = clusters(j).allindices;
                
                minTimeDist = inf;
                for idx_i = 1:length(allindices_i)
                    for idx_j = 1:length(allindices_j)
                        dist = abs(allindices_i(idx_i) - allindices_j(idx_j));
                        if dist < minTimeDist
                            minTimeDist = dist;
                        end
                    end
                end
                if minTimeDist > maxTimeGap
                    continue;
                end
                %
                
                % 条件3：检查2个分型集群中间区间是否出现了切断
                if isempty(structureLevels)
                    isSevered = checkstructuralseverance('cluster1',currentcluster,...
                        'cluster2',clusters(j),...
                        'px',px,...
                        'atr',atr,...
                        'tolerance',tolerance,...
                        'nfractal',nfractal,...
                        'topF',topF,...
                        'botF',botF);
                else
                    isSevered = checkstructuralseverance('cluster1',currentcluster,...
                        'cluster2',clusters(j),...
                        'px',px,...
                        'atr',atr,...
                        'tolerance',tolerance,...
                        'nfractal',nfractal,...
                        'topF',topF,...
                        'botF',botF,...
                        'rejectionstructures',structureLevels);
                end
                if isSevered
                    continue;   %结构被切断，不合并
                end
    
                % 条件4：价格区间 
                overlap = currentcluster.lowerbound <= clusters(j).upperbound && ...
                    currentcluster.upperbound >= clusters(j).lowerbound;
                
                % or the range is very close
                idx1 = currentcluster.endidx;
                idx2 = clusters(j).endidx;
                startidx = max(1, min(idx1, idx2) - 2*nfractal-1);
                endidx = min(length(atr), max(idx1, idx2) + 2*nfractal+1);
                avgatr = mean(atr(startidx:endidx));
                extendedtol = avgatr * tolerance * 1.5;
                nearoverlap = abs(currentcluster.upperbound - clusters(j).lowerbound) <= extendedtol || ...
                    abs(currentcluster.lowerbound - clusters(j).upperbound) <= extendedtol;
                
                if overlap || nearoverlap
                    % 所有条件满足，合并
                    currentcluster.allprices = [currentcluster.allprices;clusters(j).allprices];
                    currentcluster.allindices = [currentcluster.allindices;clusters(j).allindices];
                    currentcluster.upperbound = max(currentcluster.upperbound,clusters(j).upperbound);
                    currentcluster.lowerbound = min(currentcluster.lowerbound,clusters(j).lowerbound);
                    currentcluster.strength = currentcluster.strength + clusters(j).strength;
                    currentcluster.endidx = max(currentcluster.endidx,clusters(j).endidx);
                    skipflags(j) = 1;
                    merged = true;
                end
            end
            
            newclusters(end+1) = currentcluster;
        end
        
        clusters = newclusters;
        n = length(clusters);
    end

end