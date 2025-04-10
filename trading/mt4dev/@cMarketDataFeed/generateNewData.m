function generateNewData(obj)
    try
        % 模拟价格变动: 随机游走
%         change = 0.5 - rand() + 0.2*(rand()-0.5);
%         newPrice = obj.LastPrice + change;
        obj.QMS.refresh;
        quote = obj.QMS.getquote(obj.Symbol);
        newPrice = quote.last_trade;
        % 创建包含详细数据的事件数据
        data = struct(...
            'Symbol', obj.Symbol, ...
            'Timestamp', quote.update_time1, ...
            'Price', newPrice, ...
            'Change', newPrice - obj.LastPrice, ...
            'ChangePct', (newPrice - obj.LastPrice)/obj.LastPrice*100);

        obj.LastPrice = newPrice;

        % 触发事件并传递数据
        notify(obj, 'NewDataArrived', MarketDataEventData(data));
    catch ME
        % 触发错误事件
        notify(obj, 'ErrorOccurred', ...
            ErrorEventData(ME.message));
    end
end