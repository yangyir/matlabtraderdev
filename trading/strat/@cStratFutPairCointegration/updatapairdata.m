function [] = updatapairdata(obj)
%cStratFutPairCointegration
    instruments = obj.getinstruments;
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
end