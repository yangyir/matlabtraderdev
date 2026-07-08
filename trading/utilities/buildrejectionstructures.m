function structures = buildrejectionstructures(varargin)
    % build strcutures based on rejection
    % all the structures are at the fractal points
    % and how the price evolves right after the fractal points
    % either rejected on the fractal point or in later candle sticks
    % mode£º'self' = on itself£¬ 'early' = with later candles£¬ 'defensive'
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('px',[],@isnumeric);
    p.addParameter('topF',[],@isnumeric);
    p.addParameter('botF',[],@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.addParameter('nlookback',100,@isnumeric); % structure look backs
    p.addParameter('nfractal',2,@isnumeric);
    p.addParameter('scoreThreshold',4,@isnumeric); % least score
    p.addParameter('rightEyeWindowLength',3,@isnumeric);    % length on the right
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
    
    n = length(H);
    
    structures = struct('price',{},'type',{},'strength',{},...
        'formationidx',{},'fractalidx',{},'isactive',{},...
        'isdormant',{},'dormantreason',{},...
        'dormantnegateidx',{},'dormantnegateprice',{},...
        'retestcount',{},'rejectionmode',{},...
        'terminationreason',{},'terminationidx',{});
    
    for i = nlookback+1:n-nfractal
        % only deal with fractals
        istopF = topF(i) == 1;
        isbotF = botF(i) == 1;
        
        if ~istopF && ~isbotF
            continue;
        end
        
        
        % =========== filter out low-vol regime =================
        totalrange = H(i) - L(i);
        % note:implementation for JPYUSD futures
        if totalrange < 0.0001
            continue;
        end
        % take the average atr around the point
        avgatrwindow = mean(atr(max(1,i-2*nfractal-1):min(n,i+nfractal)));
        % in case the candle range is less than 60% of the average atr,
        % it might be just a noise and shall be eliminated from future
        % analysis
        if totalrange < avgatrwindow * 0.6
            continue;
        end
        
        % ============ fractal candle itself ===========
        body = abs(C(i) - O(i));
        realbodyratio = body / totalrange;
        
        % ----- top fractal£ºcheck for upper shadow line and reject--------
        if istopF
            currentatr = atr(i);
            if currentatr < 0.0001, continue;end
            
            isrejection = false;
            rejectionscore = 0;
            rejectionmode = '';
            
            % ---- mode1£ºself rejection -----
            uppershadow = H(i) - max(O(i),C(i));
            uppershadowatr = uppershadow / currentatr;
            if realbodyratio < 0.4 && uppershadowatr > 0.3
                isrejection = true;
                % score if it rejects
                rejectionscore = rejectionscore + 3;
                if C(i) < O(i)
                    rejectionscore = rejectionscore + 1;% score in case the close is below the open
                end
                if uppershadowatr > 0.5
                    rejectionscore = rejectionscore + 1; % extra score for long upper shadow line
                end
                rejectionmode = 'self';
            end
            
            % ---- mode2+3£ºright rejection ----
            % fractal candle is not rejected but on its RHs
            for k = i+1:min(n,i+righteyewindowlength)
                                
                isbearish = C(k) < O(k);
                
                if isbearish
                    % normarlized with current atr
                    declineatr = (H(i) - C(k)) / currentatr;
                    
                    if k <= i+2
                        % early within 2 candle sticks
                        if ~isrejection || strcmpi(rejectionmode,'self')
                            isrejection = true;
                            rejectionscore = rejectionscore + 4;
                            rejectionmode = 'early';
                            
                            % extra score for a bigger price drop
                            if declineatr > 0.5
                                rejectionscore = rejectionscore + 1;
                            end
                        end
                    end
                    
                    if k > i+2
                        % after 2 candle sticks
                        rejectionscore = rejectionscore + 2;
                        if strcmpi(rejectionmode,'early')
                            rejectionmode = 'early_defensive';
                        elseif ~isrejection
                            isrejection = true;
                            rejectionmode = 'defensive';
                        end
                    end
                end
                
                % rejection fails if new high was achieved
                if ~isbearish && H(k) > H(i)
                    isrejection = false;
                    rejectionscore = 0;
                    rejectionmode = '';
                    break;
                end   
            end
            
            if isrejection && rejectionscore >= scorethreshold
                structures(end+1).price = H(i);
                structures(end).type = 'resistance_rejection';
                structures(end).strength = rejectionscore;
                structures(end).formationidx = i;
                structures(end).fractalidx = i;
                structures(end).isactive = true;
                structures(end).retestcount = 0;
                structures(end).rejectionmode = rejectionmode;
                structures(end).terminationreason = '';
                structures(end).isdormant = false;
                structures(end).dormantreason = '';
            end
        end
        
        % ----- bottom fractal£ºcheck for lower shadow line and reject--------
        if isbotF
            currentatr = atr(i);
            if currentatr < 0.0001, continue;end
            
            isrejection = false;
            rejectionscore = 0;
            rejectionmode = '';
            
            % ---- mode1£ºself rejection -----
            lowershadow = min(O(i),C(i)) - L(i);
            lowershadowatr = lowershadow / currentatr;
            
            if realbodyratio < 0.4 && lowershadowatr > 0.3
                isrejection = true;
                rejectionscore = rejectionscore + 3;
                if C(i) > O(i)
                    rejectionscore = rejectionscore + 1;
                end
                if lowershadowatr > 0.5
                    rejectionscore = rejectionscore + 1;
                end
                rejectionmode = 'self';
            end
            
            % ---- mode2+3£ºright rejection ----
            % fractal candle is not rejected but on its RHs
            for k = i+1:min(n,i+righteyewindowlength)
                
                isbullish = C(k) > O(k);
                
                if isbullish
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
                structures(end+1).price = L(i);
                structures(end).type = 'support_rejection';
                structures(end).strength = rejectionscore;
                structures(end).formationidx = i;
                structures(end).fractalidx = i;
                structures(end).isactive = true;
                structures(end).retestcount = 0;
                structures(end).rejectionmode = rejectionmode;
                structures(end).terminationreason = '';
                structures(end).isdormant = false;
                structures(end).dormantreason = '';
            end
            
        end
        
    end
end