function generateNewData(obj)
    try
        % ģ��۸�䶯: �������
%         change = 0.5 - rand() + 0.2*(rand()-0.5);
%         newPrice = obj.LastPrice + change;
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