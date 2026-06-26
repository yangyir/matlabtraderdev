function clusters = buildfractalclusters(varargin)
% build fractal clusters
% inputs:
% px: [t,openpx,highpx,lowpx,closepx]
% nfractal:fractal period, default value = 2
% tolerance:multiplie of atr to define the buffer zone between fractals
% nlookback:n candles to look back

% output
% cluster; a struct contains
% .type: 'resistance' or 'support'
% .upperbound
% .lowerbound
% .strength:the number of factals in the clusters
% .endidx:the latest fractal index
%. allprices;fractal prices within the clusters

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('px',[],@isnumeric);
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('nfractal',2,@isnumeric);
    p.addParameter('tolerance',0.25,@isnumeric);    % 集群容差（ATR倍数）
    p.addParameter('nlookback',200,@isnumeric);     % 集群回溯K线数
    p.addParameter('maxtimegap',30,@isnumeric);     % 集群合并最大时间间隔
    p.parse(varargin{:});
    
    px = p.Results.px;
    topF = p.Results.topF;
    botF = p.Results.botF;
    atr = p.Results.atr;
    nfractal = p.Results.nfractal;
    tolerance = p.Results.tolerance;
    nlookback = p.Results.nlookback;
    maxtimegap = p.Results.maxtimegap;
    
    highpx = px(:,3);
    lowpx = px(:,4);
%     closepx = px(:,5);


%     atr = calcATR(highpx,lowpx,closepx,14);

    n = size(px,1);
    clusters = struct('type',{},'upperbound',{},'lowerbound',{},...
        'strength',{},'endidx',{},'allprices',{},'allindices',{});

    % ============== top fractals (resistance) ===================
    for i = nlookback+1:n
        if topF(i) == 0
            continue;
        end
        
        currentprice = highpx(i);
        currenttolerance = tolerance * atr(i);
        
        % look backwards and collect similar top fractals
        clusterprices = [];
        clusterindices = [];
        
        for j = i-1:-1:max(1,i-nlookback)
            if topF(j) == 0
                continue;
            end
            
            if abs(highpx(j) - currentprice) <= currenttolerance
                temp = [clusterprices;highpx(j)];
                clusterprices = temp;
                temp = [clusterindices;j];
                clusterindices = temp;
            end
        end
        
        temp = [clusterprices;currentprice];
        clusterprices = temp;
        temp = [clusterindices;i];
        clusterindices = temp;
        
        % in case we find more than one fractals within the price range
        if length(clusterprices) >= 2
            [sortedprices,idx] = sort(clusterprices);
            sortedindices = clusterindices(idx);
            
            clusters(end+1).type = 'resistance';
            clusters(end).upperbound = max(clusterprices);
            clusters(end).lowerbound = min(clusterprices);
            clusters(end).strength = length(clusterprices);
            clusters(end).endidx = i;
            clusters(end).allprices = sortedprices;
            clusters(end).allindices = sortedindices;
        end
    end
    
    % ============== bottom fractals (support) ===================
    for i = nlookback+1:n
        if botF(i) == 0
            continue;
        end
        
        currentprice = lowpx(i);
        currenttolerance = tolerance * atr(i);
        
        % look backwards and collect similar top fractals
        clusterprices = [];
        clusterindices = [];
        
        for j = i-1:-1:max(1,i-nlookback)
            if botF(j) == 0
                continue;
            end
            
            if abs(lowpx(j) - currentprice) <= currenttolerance
                temp = [clusterprices;lowpx(j)];
                clusterprices = temp;
                temp = [clusterindices;j];
                clusterindices = temp;
            end
        end
        
        temp = [clusterprices;currentprice];
        clusterprices = temp;
        temp = [clusterindices;i];
        clusterindices = temp;
        
        % in case we find more than one fractals within the price range
        if length(clusterprices) >= 2
            [sortedprices,idx] = sort(clusterprices);
            sortedindices = clusterindices(idx);
            
            clusters(end+1).type = 'support';
            clusters(end).upperbound = max(clusterprices);
            clusters(end).lowerbound = min(clusterprices);
            clusters(end).strength = length(clusterprices);
            clusters(end).endidx = i;
            clusters(end).allprices = sortedprices;
            clusters(end).allindices = sortedindices;
        end
    end
    %
    % merge clusters
    if length(clusters) > 1
        clusters = mergeoverlappingclusters('clusters',clusters,...
            'px',px,...
            'atr',atr,...
            'tolerance',tolerance,...
            'maxTimeGap',maxtimegap,...
            'nfractal',nfractal,...
            'topF',topF,...
            'botF',botF);
        
    end
     [~,index] = sortrows([clusters.endidx].'); 
     clusters = clusters(index);

end