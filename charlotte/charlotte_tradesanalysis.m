function [output] = charlotte_tradesanalysis(trades,eiSignal,eiExecution)
% basic analysis of trades with signal at ei1, e.g. h4 candles and executed
% at ei2, e.g. m30
    output = [];
    if ~isa(trades,'cTradeOpenArray')
        error('charlotte_tradesanalysis: invalid trades input must be a cTradeOpenArray');
    end

    if ~isstruct(eiSignal)
        error('charlotte_tradesanalysis: invalid ei1 input must be a struct');
    end
    
    if ~isstruct(eiExecution)
        error('charlotte_tradesanalysis: invalid ei2 input must be a struct');
    end
    
    ntrades = trades.latest_;

    % sanity check to make sure all trades are trended
    for i = 1:ntrades
        if ~strcmpi(trades.node_(i).countername_,'tc')
            error('charlotte_tradesanalysis:invalid trades input')
        end
    end

    % category 1: break on open
    trades1 = cTradeOpenArray;
    % category 2: break after open
    trades2 = cTradeOpenArray;
    % category 3: wiped out without break
    trades3 = cTradeOpenArray;
    
    tradeID = (1:1:ntrades)';
    tradeCategory = zeros(ntrades,1);
    direction = zeros(ntrades,1);
    strengh = cell(ntrades,1);
    breachType = zeros(ntrades,1);
    candleOnOpen = cell(ntrades,1);
    rangeOnOpen = zeros(ntrades,1);
    trOnOpen = zeros(ntrades,1);
    atrOnOpen = zeros(ntrades,1);
    bodyRatioOnOpen = zeros(ntrades,1);
    shadowRatioOnOpen = zeros(ntrades,1);
    shadowATROnOpen = zeros(ntrades,1);
    breachAfterDist = zeros(ntrades,1);     % 0 for category 1, positive integer for category 2 and -1 for category 3
    breachAfterReverseMax = zeros(ntrades,1); % for category 2
    firstBreachExecutionIdx = zeros(ntrades,1);
    breachMaxATR = zeros(ntrades,1);
    firstBreachSizeATR = zeros(ntrades,1);
    firstBounceBackExecutionIdx = zeros(ntrades,1);
    executionReverseMax = zeros(ntrades,1); % maximum reverse from the barrier in terms of atrExecution
    executionReverseMax2 = zeros(ntrades,1);
    atrRatio = zeros(ntrades,1); % atrOpen / atrExecution
    %
    
    for i = 1:ntrades
        trade_i = trades.node_(i);
        res = charlotte_tradeanalysis(trade_i,eiSignal,eiExecution);
        direction(i) = res.direction;
        strengh{i} = res.strength;
        breachType(i) = res.breachtype;
        candleOnOpen{i} = res.candleonopen;
        rangeOnOpen(i) = res.rangeonopen;
        trOnOpen(i) = res.tronopen;
        atrOnOpen(i) = res.atronopen;
        bodyRatioOnOpen(i) = res.bodyratioonopen;
        shadowRatioOnOpen(i) = res.shadowratioonopen;
        shadowATROnOpen(i) = res.shadowatronopen;
        if isempty(res.breachafterdist)
            if res.breachonopen
                breachAfterDist(i) = 0;
            else
                breachAfterDist(i) = -1;
            end
            breachAfterReverseMax(i) = NaN;
        else
            breachAfterDist(i) = res.breachafterdist;
            breachAfterReverseMax(i) = res.breachafterreversemax;
        end
        if ~isempty(res.firstbreachexecutionidx)
            firstBreachExecutionIdx(i) = res.firstbreachexecutionidx;
            breachMaxATR(i) = res.breachmaxatr;
            firstBreachSizeATR(i) = res.firstbreachsizeatr;

            if isempty(res.firstbouncebackexecutionidx)
                firstBounceBackExecutionIdx(i) = NaN;
                try
                    executionReverseMax(i) = res.executionreversemax;% negative values
                    executionReverseMax2(i) = res.executionreversemax2;
                catch
                    executionReverseMax(i) = NaN;
                    executionReverseMax2(i) = NaN;
                end
            else
                firstBounceBackExecutionIdx(i) = res.firstbouncebackexecutionidx;
                executionReverseMax(i) = res.executionreversemax;
                executionReverseMax2(i) = res.executionreversemax2;
            end
            
        else
            firstBreachExecutionIdx(i) = NaN;
            breachMaxATR(i) = NaN;
            firstBreachSizeATR(i) = NaN;
            firstBounceBackExecutionIdx(i) = NaN;
            executionReverseMax(i) = NaN;
        end
        atrRatio(i) = res.atrratio;
        tradeCategory(i) = res.tradecategory;
            
        if tradeCategory(i) == 1
            trades1.push(trade_i);
        elseif tradeCategory(i) == 2
            trades2.push(trade_i);
        elseif tradeCategory(i) == 3
            trades3.push(trade_i);
        end
    end

    statsTable = table(tradeID,tradeCategory,direction,strengh,breachType,candleOnOpen,rangeOnOpen,trOnOpen,atrOnOpen,bodyRatioOnOpen,shadowRatioOnOpen,shadowATROnOpen,...
        breachAfterDist,breachAfterReverseMax,firstBreachExecutionIdx,breachMaxATR,firstBreachSizeATR,firstBounceBackExecutionIdx,executionReverseMax,executionReverseMax2,atrRatio);



    output = struct('trades1',trades1,...
        'trades2',trades2,...
        'trades3',trades3,...
        'statstable',statsTable);
end