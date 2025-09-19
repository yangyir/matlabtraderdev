function candlesticks = getallcandles(mdeopt,instrument)
% a cMDEOpt function
    histcandles = mdeopt.gethistcandles(instrument);
    candlesticks = mdeopt.getcandles(instrument);
    
    if isempty(histcandles)
        histcandles = [];
    else
        histcandles = histcandles{1};
    end
    
    if isempty(candlesticks)
        candlesticks = [];
    else
        candlesticks = candlesticks{1};
    end
    
    if isempty(histcandles) && isempty(candlesticks)
        timevec = [];
        openp = [];
        highp = [];
        lowp = [];
        closep = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        openp = candlesticks(:,2);
        highp = candlesticks(:,3);
        lowp = candlesticks(:,4);
        closep = candlesticks(:,5);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        openp = histcandles(:,2);
        highp = histcandles(:,3);
        lowp = histcandles(:,4);
        closep = histcandles(:,5);
    elseif ~isempty(histcandles) && ~isempty(candlesticks)
        timevec = [histcandles(:,1);candlesticks(:,1)];
        openp = [histcandles(:,2);candlesticks(:,2)];
        highp = [histcandles(:,3);candlesticks(:,3)];
        lowp = [histcandles(:,4);candlesticks(:,4)];
        closep = [histcandles(:,5);candlesticks(:,5)];
    end
    
    %remove possible zeros
    checks = openp.*highp.*lowp.*closep;
    idx = checks ~= 0;
    timevec = timevec(idx);
    openp = openp(idx);
    highp = highp(idx);
    lowp = lowp(idx);
    closep = closep(idx);
    
    K = [timevec,openp,highp,lowp,closep];
    candlesticks = cell(1,1);
    candlesticks{1} = K;

end