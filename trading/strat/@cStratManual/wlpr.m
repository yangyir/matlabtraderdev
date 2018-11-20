function wrinfo = wlpr(obj,instrument,nperiods)
%cStrat
    if ~obj.usehistoricaldata_
        fprintf('%s:wlpr:invalid function call without historical data\n',class(obj));
        return
    end
    
    if nargin < 3
        nperiods = 144;
    end
    
    histcandles = obj.mde_fut_.gethistcandles(instrument);
    candlesticks = obj.mde_fut_.getcandles(instrument);
    if ~isempty(histcandles)
        histcandles = histcandles{1};
    else
        histcandles = [];
    end
    
    if ~isempty(candlesticks)
        candlesticks = candlesticks{1};
    else
        candlesticks = [];
    end
    
    if isempty(histcandles) && isempty(candlesticks)
        timevec = [];
        highpx = [];
        lowpx = [];
        closepx = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        highpx = candlesticks(:,3);
        lowpx = candlesticks(:,4);
        closepx = candlesticks(:,5);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        highpx = histcandles(:,3);
        lowpx = histcandles(:,4);
        closepx = histcandles(:,5);
    else
        timevec = [histcandles(:,1);candlesticks(:,1)];
        highpx = [histcandles(:,3);candlesticks(:,3)];
        lowpx = [histcandles(:,4);candlesticks(:,4)];
        closepx = [histcandles(:,5);candlesticks(:,5)];
    end
    
    if size(timevec,1) < nperiods
        fprintf('%s:wlpr:gethighperiods:insufficient historical data\n',class(obj))
        return
    end
    
    timevec = timevec(end-nperiods-1:end,:);
    highpx = highpx(end-nperiods-1:end,:);
    lowpx = lowpx(end-nperiods-1:end,:);
    
    highp = max(highpx);
    lowp = min(lowpx);
    closep = closepx(end);
    wr = (highp - closep)/(highp-lowp)*(-100);
    idxh = highpx == highp;
    th = timevec(idxh);
    idxl = lowpx == lowp;
    tl = timevec(idxl);
    
    wrinfo = struct('candletime1',timevec(end),...
        'candletime2',datestr(timevec(end),'yyyy-mm-dd HH:MM'),...
        'numofperiods',nperiods,...
        'wlpr',wr,...
        'highestprice',highp,...
        'lowestprice',lowp,...
        'closeprice',closep,...
        'highestcandletime1',th,...
        'highestcandletime2',datestr(th,'yyyy-mm-dd HH:MM'),...
        'lowestcandletime1',tl,...
        'lowestcandletime2',datestr(tl,'yyyy-mm-dd HH:MM'));
    
    
end