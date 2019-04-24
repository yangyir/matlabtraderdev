function [] = updatapairdata(obj)
%cStratFutPairCointegration
    instruments = obj.getinstruments;
    timevec = cell(2,1);
    closep = cell(2,1);
    
    calcsignalbucket = obj.getcalcsignalbucket(instruments{obj.referencelegindex_});
    
    if calcsignalbucket == 1
        return
    end
      
    if isempty(obj.data_)
        error('cStratFutPairCointegration:updatapairdata:internal error')
    end
    
    for i = 1:2
        histcandles = obj.mde_fut_.gethistcandles(instruments{i});
        if isempty(histcandles)
            histcandles = [];
        else
            histcandles = histcandles{1};
        end
          
        candlesticks = obj.mde_fut_.getcandles(instruments{i});

        if isempty(candlesticks)
            candlesticks = [];
        else
            candlesticks = candlesticks{1};
            try
                candlesticks = candlesticks(1:calcsignalbucket-1,:);
            catch
                candlesticks = candlesticks(1:end,:);
            end
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

     obj.data_ = [timevec{1,1},closep{1,1},closep{2,1}];
end