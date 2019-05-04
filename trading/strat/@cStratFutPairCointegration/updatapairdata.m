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
            ncandles = size(candlesticks,1);
            if calcsignalbucket - 1 > ncandles
                %the ref leg is more liquid and with more tick pops in,
                %however, the non-ref leg might not updated yet, we thus
                %add one row the same as the last row of the candlestick
                temp = zeros(calcsignalbucket - 1,size(candlesticks,2));
                temp(1:ncandles,:) = candlesticks;
                for k = ncandles + 1:size(temp,1)
                    temp(k,:) = candlesticks(end,:);
                end
                candlesticks = temp;
            else
                candlesticks = candlesticks(1:calcsignalbucket-1,:);
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

    temp = [timevec{1,1},closep{1,1},closep{2,1}];
    nold = size(obj.data_,1);
    obj.data_ = [obj.data_;temp(nold+1:end,:)];
    %
    if obj.data_(end,2) == 0
        obj.data_(end,2) = obj.data_(end-1,2);
    end
    
    if obj.data_(end,3) == 0
        obj.data_(end,3) = obj.data_(end-1,3);
    end
    

     
end