function [] = stratplot2(obj,instrument1,instrument2,varargin)
%cStratManual
    if ~obj.usehistoricaldata_
        fprintf('%s:stratplot2:invalid function call without historical data\n',class(obj));
        return
    end
    
    instruments = {instrument1;instrument2};
    candles = cell(2,1);
    for i = 1:2
        histcandles = obj.mde_fut_.gethistcandles(instruments{1});
        candlesticks = obj.mde_fut_.getcandles(instruments{1});
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
            error('ERROR:%s:candelplot:invalid function call without data\n',class(obj));
        
        elseif isempty(histcandles) && ~isempty(candlesticks)
            candles_i = candlesticks;
        elseif ~isempty(histcandles) && isempty(candlesticks)
            candles_i = histcandles;
        else
            candles_i = [histcandles;candlesticks];
        end
        %remove candles with zero entries
        idx1 = candles_i(:,2) ~= 0;
        idx2 = candles_i(:,3) ~= 0;
        idx3 = candles_i(:,4) ~= 0;
        idx4 = candles_i(:,5) ~= 0;
        idx = idx1&idx2&idx3&idx4;
        candles{i} = candles_i(idx,:);
    end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
%     p.addParameter('
    
    
end