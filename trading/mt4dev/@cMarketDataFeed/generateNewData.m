function generateNewData(obj)
    try
        obj.QMS.refresh;
        quote = obj.QMS.getquote(obj.Symbol);
        newPrice = quote.last_trade;
        % ����������ϸ���ݵ��¼�����
        data = struct(...
            'Symbol', obj.Symbol, ...
            'Timestamp', quote.update_time1, ...
            'Price', newPrice, ...
            'Change', newPrice - obj.LastPrice, ...
            'ChangePct', (newPrice - obj.LastPrice)/obj.LastPrice*100);

        obj.LastPrice = newPrice;

        % �����¼�����������
        notify(obj, 'NewDataArrived', MarketDataEventData(data));
    catch ME
        % ���������¼�
        notify(obj, 'ErrorOccurred', ...
            ErrorEventData(ME.message));
    end
end