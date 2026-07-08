function structuresUpdated = updatestructurelevels(varargin)
    % update structure levels with second test and updates
    %
    % the structure became invalid because
    % 1. time_expired
    % 2. broken_up / broken_down
    % 3. negated_by_support / negated_by_resistance
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('structures',{},@isstruct);
    p.addParameter('px',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('maxstructureage',100,@isnumeric);  % structure look backs
    p.addParameter('invalidationATR',1,@isnumeric);    % invalidation multiplier
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('nfractal',2,@isnumeric);
    p.addParameter('referenceIdx',[],@isnumeric);      % idx of current candle
    p.addParameter('proximityatr',1,@isnumeric);
    p.parse(varargin{:});
    structures = p.Results.structures;
    px = p.Results.px;
    atr = p.Results.atr;
    maxstructureage = p.Results.maxstructureage;
    invalidationatr = p.Results.invalidationATR;
    topF = p.Results.topF;
    botF = p.Results.botF;
    nfractal = p.Results.nfractal;
    referenceIdx = p.Results.referenceIdx;
    proximityatr = p.Results.proximityatr;
    
    H = px(:,3);O = px(:,2); L = px(:,4); C = px(:,5);
    n = length(H);
    if isempty(referenceIdx)
        referenceIdx = n;   % default:real-time trading mode
    end
    
    useflag = ones(length(structures),1);

    for s = 1:length(structures)
        if ~structures(s).isactive
            useflag(s) = 0;
            continue;
        end
        
        formidx = structures(s).formationidx;
        
        % the structure has not formed yet (this happens in backtesting
        % code execution)
        if formidx > referenceIdx
            useflag(s) = 0;
            continue;
        end
        
        % check whether the structure is expired
        age = referenceIdx - formidx;
        if age > maxstructureage
            structures(s).isactive = false;
            structures(s).terminationreason = 'time_expired';
            structures(s).terminationidx = referenceIdx;
            useflag(s) = 0;
            continue;
        end
        
        % check1: whethet the structure has been breached in the past
        isInvalidated = false;
        currentprice = structures(s).price;
        if strcmpi(structures(s).type, 'resistance_rejection') % resistance
            % the strcuture becomes invalid if the price is breached
            for k = formidx+1:referenceIdx
                % check by the close price rather than the high price
                if C(k) > currentprice && C(k) > O(k) % also with px closed above open
                    % check whether the price is consistently above the
                    % resistance level in the next 2 candles
                    if k+2 <= referenceIdx
                        if C(k+1) > currentprice || C(k+2) > currentprice
                            isInvalidated = true;
                            structures(s).terminationreason = 'broken_up';
                            structures(s).terminationidx = k;
                            useflag(s) = 0;
                            break;
                        end
                    else
                        % insufficient candle sticks
                        continue;
                    end
                end
                
                % if the close is well above the resistance
                if C(k) > currentprice + atr(k) * invalidationatr
                    isInvalidated = true;
                    structures(s).terminationreason = 'broken_up_strong';
                    structures(s).terminationidx = k;
                    useflag(s) = 0;
                    break;
                end
            end
            %         
        elseif strcmpi(structures(s).type, 'support_rejection') % support
            % the structure becomes invalid if the price is breached
            for k = formidx+1:referenceIdx
                % check by the close price rather than the low price
                if C(k) < currentprice && C(k) < O(k) % also with px closes below open
                    if k+2 <= referenceIdx
                        if C(k+1) < currentprice || C(k+2) < currentprice
                            isInvalidated = true;
                            structures(s).terminationreason = 'broken_down';
                            structures(s).terminationidx = k;
                            useflag(s) = 0;
                            break;
                        end
                    else
                        % insufficient candle sticks
                        continue;
                    end
                end
                
                % if the close is well below the support
                if C(k) < currentprice - atr(k) * invalidationatr
                    isInvalidated = true;
                    structures(s).terminationreason = 'broken_down_strong';
                    structures(s).terminationidx = k;
                    useflag(s) = 0;
                    break;
                end
            end 
        end
        
        if isInvalidated
            structures(s).isactive = false;
            if useflag(s), useflag(s) = 0; end
            continue;  % forget about further check once the structure is invalid
        end
        
        % check 2: whether the structure has been negated  (acitve +
        % dormant)
        isNegated = false;
        if strcmpi(structures(s).type, 'resistance_rejection')
            % check whether a strong support is formed
            for k = formidx+1:referenceIdx
                if botF(k) == 1
                    % a bottom fractal is formed within the distance
                    totalrange = H(k) - L(k);
                    avgatrwindow = mean(atr(max(1,k-2*nfractal-1):min(referenceIdx,k+nfractal)));
                    if totalrange < avgatrwindow * 0.6
                        continue;
                    end

                    if L(k) < currentprice - atr(k)*0.5
                        % the fractal price is lower enough, e.g. 0..5atr
                        % from current price
                        structures(s).isdormant = true;
                        structures(s).dormantreason = 'negated_by_support';
                        structures(s).dormantnegateidx = k;
                        structures(s).dormantnegateprice = L(k);
                        isNegated = true;
                        break;
                    end
                end
            end
        elseif strcmpi(structures(s).type, 'support_rejection')
            % check whether a strong resistance is formed
            for k = formidx+1:referenceIdx
                if topF(k) == 1
                    % a top fractal is formed within the distance
                    totalrange = H(k) - L(k);
                    avgatrwindow = mean(atr(max(1,k-2*nfractal-1):min(referenceIdx,k+nfractal)));
                    if totalrange < avgatrwindow * 0.6
                        continue;
                    end
                    
                    if H(k) > currentprice + atr(k)*0.5
                        % the fractal price is higher enough,
                        structures(s).isdormant = true;
                        structures(s).dormantreason = 'negated_by_resistance';
                        structures(s).dormantnegateidx = k;
                        structures(s).dormantnegateprice = H(k);
                        isNegated = true;
                        break;
                    end
                end
            end
        end
        
        if isNegated
            if strcmpi(structures(s).type, 'resistance_rejection')
                for k = structures(s).dormantnegateidx+1:referenceIdx
                    distancetoresistance = structures(s).price - C(k);
                    if distancetoresistance > 0 && distancetoresistance < proximityatr*atr(k) && ...
                            C(k) > O(k)
                        structures(s).isdormant = false;
                        structures(s).dormantreason = '';
                        structures(s).strength = structures(s).strength * 0.8;
                        break
                    end
                end
            elseif strcmpi(structures(s).type, 'support_rejection')
                for k = structures(s).dormantnegateidx+1:referenceIdx
                    distancetosupport = C(k) - structures(s).price;
                    if distancetosupport > 0 && distancetosupport < proximityatr*atr(k) && ...
                            C(k) < O(k)
                        structures(s).isdormant = false;
                        structures(s).dormantreason = '';
                        structures(s).strength = structures(s).strength * 0.8;
                        break
                    end
                end
            end 
        end

        if structures(s).isdormant
            continue;% forget about further check once the structure is dormant
        end
        
        % ADDITIONAL CEHCK
        for i = formidx+1:referenceIdx
            if strcmpi(structures(s).type, 'resistance_rejection') % resistance
                % find any candle stick with high price breached
                if H(i) > structures(s).price
                    % calculate how much breached w.r.t.atr
                    penetration = (H(i) - structures(s).price) / atr(i);
                    
                    % the quality
                    isQualityTest = C(i) > O(i) && ... % close > open
                        (C(i)-O(i)) / (H(i)-L(i)+0.0001) > 0.5;  % body > 0.5totalrange
                    
                    if isQualityTest && penetration > 0.2
                        % this is a breach with good quality
                        % check what happens in the next 2 candle sticks
                        if i+2 <= referenceIdx && ...
                                C(i+1) < O(i+1) && ... % close < open
                                (C(i+2) < C(i+1) || C(i+1) < structures(s).price)
                            % failed to breach, the bear wins
                            % the structure is upgrated with new highs
                            structures(s).price = H(i);
                            structures(s).strength = structures(s).strength + 1;
                            structures(s).retestcount = structures(s).retestcount + 1;
                            break;
                        elseif i+2 > referenceIdx
                            continue;
                        end
                    else
                        % this a breach with bad (not good enough) quanlity
                        structures(s).strength = structures(s).strength + 0.5;
                        structures(s).retestcount = structures(s).retestcount + 0.5;
                    end
                end
            elseif strcmpi(structures(s).type, 'support_rejection') % support
                % find any candle stick with low price breached
                if L(i) < structures(s).price
                    % calculate how much breached w.r.t. atr
                    penetration = (structures(s).price - L(i)) / atr(i);
                    
                    % the quality
                    isQualityTest = C(i) < O(i) && ... % close < open
                        (O(i) - C(i)) / (H(i)-L(i)+0.0001) > 0.5;
                    
                    if isQualityTest && penetration > 0.2
                        % this is a breach with good quality
                        % check what happens in the next 2 candle stick
                        if i+2 <= referenceIdx && ...
                                C(i+1) > O(i+1) && ... % close > open
                                (C(i+2) > C(i+1) || C(i+1) > structures(s).price)
                            structures(s).price = L(i);
                            structures(s).strength = structures(s).strength + 1;
                            structures(s).retestcount = structures(s).retestcount + 1;
                            break;
                        elseif i+2 < referenceIdx
                            continue;
                        end
                    else
                        % this is a breach with bad (not good enough)
                        % quality
                        structures(s).strength = structures(s).strength + 0.5;
                        structures(s).retestcount = structures(s).retestcount + 0.5;
                    end
                end
            end
        end
    end
    

    idx = 1:length(structures);
    idx = idx';
    idx = idx(useflag~=0);

    structuresUpdated = structures(idx);
    
end