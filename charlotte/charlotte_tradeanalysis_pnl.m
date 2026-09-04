function res = charlotte_tradeanalysis_pnl(tradein,eiSignal,eiExecution,params)
% a very simple and fast pnl run
% nearly 95%+ features of the real trading risk management mechanism
% for trade with trended / conditional-trended signals only


    if ~strcmpi(tradein.opensignal_.name_,'fractal')
        res = [];
        return;
    end

    directionOpen = tradein.opendirection_;
    dtOpen = tradein.opendatetime1_;
    idxOpenSignal = find(eiSignal.px(:,1) >= dtOpen,1,'first');
    idxExecutionStart = find(eiExecution.px(:,1) >= eiSignal.px(idxOpenSignal,1),1,'first');
    idxExecutionEnd = find(eiExecution.px(:,1) < eiSignal.px(idxOpenSignal+1,1),1,'last');
    eiExecution_ = fractal_truncate(eiExecution,idxExecutionEnd,idxExecutionStart);
    nExecution_ = size(eiExecution_.px,1);
    
    atrSignal = eiSignal.atr(idxOpenSignal-1);
    atrExecution = eiExecution.atr(idxExecutionStart-1);

    if directionOpen == 1
        barrier = tradein.opensignal_.hh_;
        breachIdx = find(eiExecution_.px(:,5) > barrier,1,'first');
    else
        barrier = tradein.opensignal_.ll_;
        breachIdx = find(eiExecution_.px(:,5) > barrier,1,'first');
    end

    if isempty(breachIdx)
        % no breach of the barrier within the execution candles with igher frequency
        res = [];
        return
    end

    if breachIdx < nExecution_
        if directionOpen == 1
            pxSL = barrier-params.executionslm*atrExecution;
            slIdx = breachIdx + find(eiExecution_.px(breachIdx+1:nExecution_,4) < pxSL,1,'first');
        else
            pxSL = barrier+params.executionslm*atrExecution;
            slIdx = breachIdx + find(eiExecution_.px(breachIdx+1:nExecution_,3) > pxSL,1,'first');
        end
        if ~isempty(slIdx)
            res.direction = directionOpen;
            res.openpx1 = barrier;
            res.openpx2 = eiExecution_.px(breachIdx,5);
            res.opendt1 = eiExecution_.px(breachIdx,1);
            res.closedt1 = eiExecution_.px(slIdx,1);
            res.closepx = pxSL;
            res.closestr = 'execution stoploss';
            return
        end

    end

end