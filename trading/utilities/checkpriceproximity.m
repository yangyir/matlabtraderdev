function proximityStatus = checkpriceproximity(varargin) 
    % check whether current price is close to latest structure
 
    % output:
    % proximityStatus
    %   .isnearresistance
    %   .isnearsupport
    %   .bias:  'up'/'down'/'neutral'
    %   .nearestresistancelevel
    %   .nearestresistancedistance
    %   .nearestsupportlevel
    %   .nearestsupportdistance


    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('currentIdx',[],@isnumeric); % current index
    p.addParameter('px',[],@isnumeric);   % current fractal price
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('clusters',{},@isstruct);
    p.addParameter('structures',{},@isstruct);
    p.addParameter('maxClusterAge',50,@isnumeric);  % cluster age
    p.addParameter('maxStructureAge',100,@isnumeric);   % structure age
    p.addParameter('proximityATR',0.2,@isnumeric); % check the distance between current price and the strcuture/fractal level
    p.parse(varargin{:});
    currentIdx = p.Results.currentIdx;
    px = p.Results.px;
    atr = p.Results.atr;
    clusters = p.Results.clusters;
    structures = p.Results.structures;
    maxClusterAge = p.Results.maxClusterAge;
    maxStructureAge = p.Results.maxStructureAge;
    proximityATR = p.Results.proximityATR;
    
    
    C = px(:,5);    % close price
    currentATR = atr(currentIdx);
    currentClose = px(currentIdx,5);

    % init outputs
    proximityStatus = struct();
    proximityStatus.isnearresistance = false;
    proximityStatus.isnearsupport = false;
    proximityStatus.nearestresistancelevel = [];
    proximityStatus.nearestresistancedistance = inf;
    proximityStatus.nearestsupportlevel = [];
    proximityStatus.nearestsupportdistance = inf;
    proximityStatus.bias = 'neutral';

    nearestResistanceDist = inf;
    nearestSupportDist = inf;
    


    % with first priority, check the strutures first
    for s = 1:length(structures)
        % it has to be active
        if ~structures(s).isactive
            continue;
        end
        
        if currentIdx < structures(s).formationidx
            continue;
        end
        
        % within structure age
        if currentIdx - structures(s).formationidx > maxStructureAge
            continue;
        end
        
        if strcmpi(structures(s).type,'resistance_rejection')
            if currentClose < structures(s).price
                dist = structures(s).price - currentClose;
                distATR = dist / currentATR;
                if distATR < nearestResistanceDist
                    nearestResistanceDist = distATR;
                    proximityStatus.nearestresistancelevel = structures(s).price;
                    proximityStatus.nearestresistancedistance = distATR;
                end
            end
        elseif strcmpi(structures(s).type,'support_rejection')
            if currentClose > structures(s).price
                dist = currentClose - structures(s).price;
                distATR = dist / currentATR;
                if distATR < nearestSupportDist
                    nearestSupportDist = distATR;
                    proximityStatus.nearestsupportlevel = structures(s).price;
                    proximityStatus.nearestsupportdistance = distATR;
                end
            end
        end
    end

    %
    % 2nd from clusters
    for c = 1:length(clusters)
        if currentIdx < clusters(c).endidx
            continue;
        end
        
        if currentIdx - clusters(c).endidx > maxClusterAge
            continue;
        end
        
        if strcmpi(clusters(c).type,'resistance')
            if currentClose < clusters(c).upperbound
                dist = clusters(c).upperbound - currentClose;
                distATR = dist / currentATR;
                if distATR < nearestResistanceDist
                    nearestResistanceDist = distATR;
                    proximityStatus.nearestresistancelevel = clusters(c).upperbound;
                    proximityStatus.nearestresistancedistance = distATR;
                end
            end
        elseif strcmpi(clusters(c).type,'support')
            if currentClose > clusters(c).lowerbound
                dist = currentClose - clusters(c).lowerbound;
                distATR = dist / currentATR;
                if distATR < nearestSupportDist
                    nearestSupportDist = distATR;
                    proximityStatus.nearestsupportlevel = clusters(c).lowerbound;
                    proximityStatus.nearestsupportdistance = distATR;
                end
            end
        end
    end

    if nearestResistanceDist <= proximityATR
        proximityStatus.isnearresistance = true;
    end

    if nearestSupportDist <= proximityATR
        proximityStatus.isnearsupport = true;
    end

    % update bias
    if ~isinf(nearestResistanceDist) && ~isinf(nearestSupportDist)
        if nearestResistanceDist < nearestSupportDist
            proximityStatus.bias = 'up';
        elseif nearestSupportDist < nearestResistanceDist
            proximityStatus.bias = 'down';
        else
            proximityStatus.bias = 'neutral';
        end
    elseif ~isinf(nearestResistanceDist)
        proximityStatus.bias = 'up';
    elseif ~isinf(nearestSupportDist)
        proximityStatus.bias = 'down';
    end
    
end