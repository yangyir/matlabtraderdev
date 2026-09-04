function [res] = charlotte_tradeanalysis(tradein,eiSignal,eiExecution)
    
    
    if ~strcmpi(tradein.opensignal_.name_,'fractal')
        res = [];
        return;
    end

    
    directionOpen = tradein.opendirection_;
    dtOpen = tradein.opendatetime1_;
    idxOpenSignal = find(eiSignal.px(:,1) >= dtOpen,1,'first');
    idxExecutionStart = find(eiExecution.px(:,1) >= eiSignal.px(idxOpenSignal,1),1,'first');
    idxExecutionEnd = find(eiExecution.px(:,1) < eiSignal.px(idxOpenSignal+1,1),1,'last');

    atrSignal = eiSignal.atr(idxOpenSignal-1);
    atrExecution = eiExecution.atr(idxExecutionStart-1);

    if eiSignal.px(idxOpenSignal,5) > eiSignal.px(idxOpenSignal,2)
        candleOnOpen = 'bull';
    elseif eiSignal.px(idxOpenSignal,5) < eiSignal.px(idxOpenSignal,2)
        candleOnOpen = 'bear';
    else
        candleOnOpen = 'flat';
    end

    signalName = tradein.opensignal_.mode_;
    if directionOpen == 1
        if strcmpi(signalName,'breachup-lvlup') || strcmpi(signalName,'conditional-uptrendconfirmed-1')
            breachType = 1;
        elseif strcmpi(signalName,'breachup-sshighvalue') || strcmpi(signalName,'conditional-uptrendconfirmed-2')
            breachType = 2;
        elseif strcmpi(signalName,'breachup-highsc13') || strcmpi(signalName,'conditional-uptrendconfirmed-3')
            breachType = 3;
        elseif strcmpi(signalName,'conditional-uptrendconfirmed') || strcmpi(signalName,'mediumbreach-trendconfirmed') || strcmpi(signalName,'strongbreach-trendconfirmed') || strcmpi(signalName,'volblowup') || strcmpi(signalName,'volblowup2')
            breachType = 4;
        else
            breachType = [];
        end
    elseif directionOpen == -1
        if strcmpi(signalName,'breachdn-lvldn') || strcmpi(signalName,'conditional-dntrendconfirmed-1')
            breachType = -1;
        elseif strcmpi(signalName,'breachdn-bshighvalue') || strcmpi(signalName,'conditional-dntrendconfirmed-2')
            breachType = -2;
        elseif strcmpi(signalName,'breachdn-lowbc13') || strcmpi(signalName,'conditional-dntrendconfirmed-3')
            breachType = -3;
        elseif strcmpi(signalName,'conditional-dntrendconfirmed') || strcmpi(signalName,'mediumbreach-trendconfirmed') || strcmpi(signalName,'strongbreach-trendconfirmed') || strcmpi(signalName,'volblowup') || strcmpi(signalName,'volblowup2')
            breachType = -4;
        else
            breachType = [];
        end
    end
    
    tr1 = eiSignal.px(idxOpenSignal,3) - eiSignal.px(idxOpenSignal,4);
    tr2 = abs(eiSignal.px(idxOpenSignal,3) - eiSignal.px(idxOpenSignal-1,5));
    tr3 = abs(eiSignal.px(idxOpenSignal,4) - eiSignal.px(idxOpenSignal-1,5));
    bodyRatioOnOpen = abs(eiSignal.px(idxOpenSignal,2) - eiSignal.px(idxOpenSignal,5)) / tr1;
    trOnOpen = max([tr1,tr2,tr3]);


    eiExecution_ = fractal_truncate(eiExecution,idxExecutionEnd,idxExecutionStart);
    nExecution_ = size(eiExecution_.px,1);
    
    
    firstBreachSizeATR = [];
    firstBounceBackExecutionIdx = [];
    executionRevMax = [];
    executionRevMax2 = [];
    tradeCategory = [];
    breachMaxATR = [];

    if directionOpen == 1
        barrier = tradein.opensignal_.hh_;
        breachOnOpen = eiSignal.px(idxOpenSignal,5) > barrier;
        if breachOnOpen
            tradeCategory = 1;
        end
        firstBreachExecutionIdx = find(eiExecution_.px(:,5) > barrier,1,'first');
        if isempty(firstBreachExecutionIdx), firstBreachExecutionIdx = [];end
        if ~isempty(firstBreachExecutionIdx)
            firstBreachSize = eiExecution_.px(firstBreachExecutionIdx,5) - barrier;
            firstBreachSizeATR = firstBreachSize/atrSignal;
            breachMaxATR = eiExecution_.px(firstBreachExecutionIdx,3);

            if firstBreachExecutionIdx < nExecution_ 
                firstBounceBackExecutionIdx = firstBreachExecutionIdx + find(eiExecution_.px(firstBreachExecutionIdx+1:end,4) <= barrier,1,'first');
                executionRevMax = (barrier - min(eiExecution_.px(firstBreachExecutionIdx+1:end,4)))/atrExecution;
                executionRevMax2 = (eiExecution_.px(firstBreachExecutionIdx,5) - min(eiExecution_.px(firstBreachExecutionIdx+1:end,4)))/atrExecution;
                hh = max(eiExecution_.px(firstBreachExecutionIdx+1:end,3));
                breachMaxATR = max(hh,breachMaxATR);
            else
                eiExecution__ = fractal_truncate(eiExecution,idxExecutionEnd+nExecution_,idxExecutionEnd+1);
                firstBounceBackExecutionIdx = firstBreachExecutionIdx + find(eiExecution__.px(1:end,4) <= barrier,1,'first');
                executionRevMax = (barrier - min(eiExecution__.px(:,4)))/atrExecution;
                executionRevMax2 = (eiExecution_.px(firstBreachExecutionIdx,5) - min(eiExecution__.px(:,4)))/atrExecution;
            end
            breachMaxATR = (breachMaxATR - barrier)/atrSignal;
        end
        shadowRatio = (eiSignal.px(idxOpenSignal,3) - eiSignal.px(idxOpenSignal,5))/(eiSignal.px(idxOpenSignal,3) - eiSignal.px(idxOpenSignal,4));
    else
        barrier = tradein.opensignal_.ll_;
        breachOnOpen = eiSignal.px(idxOpenSignal,5) < barrier;
        if breachOnOpen
            tradeCategory = 1;
        end
        firstBreachExecutionIdx = find(eiExecution_.px(:,5) < barrier,1,'first');
        if isempty(firstBreachExecutionIdx), firstBreachExecutionIdx = [];end
        if ~isempty(firstBreachExecutionIdx)
            firstBreachSize = barrier - eiExecution_.px(firstBreachExecutionIdx,5);
            firstBreachSizeATR = firstBreachSize/atrSignal;
            breachMaxATR = eiExecution_.px(firstBreachExecutionIdx,4);

            if firstBreachExecutionIdx < nExecution_
                firstBounceBackExecutionIdx = firstBreachExecutionIdx + find(eiExecution_.px(firstBreachExecutionIdx+1:end,3) >= barrier,1,'first');
                executionRevMax = (max(eiExecution_.px(firstBreachExecutionIdx+1:end,3)) - barrier)/atrExecution;
                executionRevMax2 = (max(eiExecution_.px(firstBreachExecutionIdx+1:end,3)) - eiExecution_.px(firstBreachExecutionIdx,5))/atrExecution;
                ll = min(eiExecution_.px(firstBreachExecutionIdx+1:end,4));
                breachMaxATR = min(ll,breachMaxATR);
            else
                eiExecution__ = fractal_truncate(eiExecution,idxExecutionEnd+nExecution_,idxExecutionEnd+1);
                firstBounceBackExecutionIdx = firstBreachExecutionIdx + find(eiExecution__.px(:,3) >= barrier,1,'first');
                executionRevMax = (max(eiExecution__.px(:,3)) - barrier)/atrExecution;
                executionRevMax2 = (max(eiExecution__.px(:,3)) - eiExecution_.px(firstBreachExecutionIdx,5))/atrExecution;
            end
            breachMaxATR = (barrier - breachMaxATR)/atrSignal;
        end
        shadowRatio = (eiSignal.px(idxOpenSignal,5) - eiSignal.px(idxOpenSignal,4))/(eiSignal.px(idxOpenSignal,3) - eiSignal.px(idxOpenSignal,4));
    end

    breachAfter = false;
    breachAfterDistance = [];
    breachAfterReverseMax = [];
    if tradeCategory == 1
        
        %

    elseif isempty(tradeCategory)
        nBarsSignal = size(eiSignal.px,1);
        if directionOpen == 1
            for i = idxOpenSignal+1:nBarsSignal
                if eiSignal.px(i,4) < eiSignal.teeth(i-1)
                    tradeCategory = 3;
                    break;
                end
                if eiSignal.px(i,5) > barrier
                    tradeCategory = 2;
                    breachAfter = true;
                    breachAfterDistance = i - idxOpenSignal;
                    breachAfterReverseMax = (barrier - min(eiSignal.px(idxOpenSignal+1:i,4)))/atrSignal;
                    break;
                end
            end
        else
            for i = idxOpenSignal+1:nBarsSignal
                if eiSignal.px(i,3) > eiSignal.teeth(i-1)
                    tradeCategory = 3;
                    break;
                end
                if eiSignal.px(i,5) < barrier
                    tradeCategory = 2;
                    breachAfter = true;
                    breachAfterDistance = i - idxOpenSignal;
                    breachAfterReverseMax = (max(eiSignal.px(idxOpenSignal+1:i,3)) - barrier)/atrSignal;
                    break;
                end
            end
        end
        %
    end



    res = struct('tradecategory',tradeCategory, ...
        'direction',directionOpen,...
        'strength',tradein.tradername_,...
        'breachtype',breachType,...
        'candleonopen',candleOnOpen,...
        'rangeonopen',tr1,...
        'tronopen',trOnOpen,...
        'atronopen',atrSignal,...
        'bodyratioonopen',bodyRatioOnOpen,...
        'shadowratioonopen',shadowRatio,...
        'shadowatronopen',shadowRatio*tr1/atrSignal,....
        'breachonopen',breachOnOpen,...
        'breachafter',breachAfter,...
        'breachafterdist',breachAfterDistance,...
        'breachafterreversemax',breachAfterReverseMax,...
        'firstbreachexecutionidx',firstBreachExecutionIdx,...
        'breachmaxatr',breachMaxATR,...
        'firstbreachsizeatr',firstBreachSizeATR,...
        'firstbouncebackexecutionidx',firstBounceBackExecutionIdx,...
        'executionreversemax',executionRevMax,...
        'executionreversemax2',executionRevMax2,...
        'atrratio',atrSignal/atrExecution);

%     fractal_plottrade(tradein,1);



end