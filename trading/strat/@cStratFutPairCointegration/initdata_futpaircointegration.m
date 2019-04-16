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
    
    timevec = cell(2,1);
    closep = cell(2,1);
    for i = 1:2
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
    
    [t,idx1,idx2] = intersect(timevec{1,1},timevec{2,1});
    obj.data_ = [t,closep{1,1}(idx1,1),closep{2,1}(idx2,1)];
                
    count = size(obj.data_,1);
    M = obj.lookbackperiod_;
%     N = obj.rebalanceperiod_;
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
end