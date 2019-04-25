function [] = initdata_futpaircointegration(obj)
%cStratFutPairCointegration
    instruments = obj.getinstruments;
    n = obj.count;
    if n ~= 2
        error('ERROR:%s:initdata_futpaircointegration:invalid number of instruments')
    end
    
    for i = 1:n
        try
            samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
        catch
            samplefreqstr = '1m';
        end

        samplefreqnum = str2double(samplefreqstr(1:end-1));

        if samplefreqnum == 1
            nbdays = 2;
        else
            error('ERROR:%s:initdata_futpaircointegration:unsupported sample freq %s of %s',class(obj),samplefreqstr,instruments{i}.code_ctp)
        end
        
        obj.mde_fut_.initcandles(instruments{i},'NumberofPeriods',nbdays);
    end
    
    for i = 1:n
        %NOTE: a new method for populating historical data for pairs trading
        histcandles = obj.mde_fut_.gethistcandles(instruments{i});
        if isempty(histcandles), continue;end
        histcandles = histcandles{1};
        bds = unique(floor(histcandles(:,1)));
        nbds = length(bds);
        datacell = cell(nbds,1);
        for j = 1:nbds
            buckets = getintradaybuckets2('date',bds(j),'frequency',samplefreqstr,'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break);
            idx = floor(histcandles(:,1)) == bds(j);
            A = table(buckets,'variablenames',{'datetime'});
            B = table(histcandles(idx,1),histcandles(idx,2),histcandles(idx,3),histcandles(idx,4),histcandles(idx,5),'variablenames',{'datetime','open','high','low','close'});
            mytable = outerjoin(A,B,'mergekeys',true);
            mymat = [mytable.datetime,mytable.open,mytable.high,mytable.low,mytable.close];
            for k = 2:size(mymat,1)
                if isnan(mymat(k,2))
                    mymat(k,2:5) = mymat(k-1,5);
                end
            end
            datacell{j} = mymat;
        end
        datamat = cell2mat(datacell);
        obj.mde_fut_.hist_candles_{i} = datamat;
    end

    timevec = cell(n,1);
    closep = cell(n,1);
    for i = 1:n
        histcandles = obj.mde_fut_.gethistcandles(instruments{i});
        candlesticks = obj.mde_fut_.getcandles(instruments{i});
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
            timevec{i,1} = [];
            closep{i,1} = [];
        elseif isempty(histcandles) && ~isempty(candlesticks)
            timevec{i,1} = candlesticks(:,1);
            closep{i,1} = candlesticks(:,5);
        elseif ~isempty(histcandles) && isempty(candlesticks)
            timevec{i,1} = histcandles(:,1);
            closep{i,1} = histcandles(:,5);
        elseif ~isempty(histcandles) && ~isempty(candlesticks)
            timevec{i,1} = [histcandles(:,1);candlesticks(:,1)];
            closep{i,1} = [histcandles(:,5);candlesticks(:,5)];
        end
    end
    
%     [t,idx1,idx2] = intersect(timevec{1,1},timevec{2,1});
%     obj.data_ = [t,closep{1,1}(idx1,1),closep{2,1}(idx2,1)];
    t = timevec{1,1}(:,1);
    obj.data_ = [t,closep{1,1}(:,1),closep{2,1}(:,1)];
    
    if isempty(obj.lastrebalancedatetime1_)        
        count = size(obj.data_,1);
        M = obj.lookbackperiod_;
        idx = count;
        if count < M
            obj.cointegrationparams_ = {};
            return
        end
        [h,~,~,~,reg1] = egcitest(obj.data_(max(idx-M+1,1):idx,2:3));
        if h ~= 0
            obj.cointegrationparams_ = reg1;
        else
            obj.cointegrationparams_ = {};
        end
        obj.lastrebalancedatetime1_ = obj.data_(idx,1);
        obj.lastrebalanceindex_ = idx;
    else
        M = obj.lookbackperiod_;
        idx = t <= obj.lastrebalancedatetime1_;
        temp = t(idx);
        idx = length(temp);
        if idx <= 0, error('invalid last rebalance date/time specified');end
        [h,~,~,~,reg1] = egcitest(obj.data_(max(idx-M+1,1):idx,2:3));
        if h ~= 0
            obj.cointegrationparams_ = reg1;
        else
            obj.cointegrationparams_ = {};
        end
        obj.lastrebalanceindex_ = idx;
    end