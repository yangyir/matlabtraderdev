classdef MarketDataFeed < handle
    events
        NewDataArrived       % �����ݵ����¼�
        ErrorOccurred        % �������¼�
    end
    
    properties
        Symbol
        Running = false
        UpdateInterval = 1   % Ĭ��1�����һ��
    end
    
    properties (Access = private)
        Timer
        LastPrice
    end
    
    methods
        function obj = MarketDataFeed(symbol)
            obj.Symbol = symbol;
            obj.LastPrice = 100 + 20*rand(); % ��ʼ����۸�
        end
        
        function start(obj)
            if ~obj.Running
                obj.Running = true;
                obj.Timer = timer(...
                    'ExecutionMode', 'fixedRate', ...
                    'Period', obj.UpdateInterval, ...
                    'TimerFcn', @(~,~)obj.generateNewData);
                start(obj.Timer);
            end
        end
        
        function stop(obj)
            if obj.Running
                stop(obj.Timer);
                delete(obj.Timer);
                obj.Running = false;
            end
        end
        
        function delete(obj)
            obj.stop();
        end
        
        function set.UpdateInterval(obj, interval)
            if interval > 0
                obj.UpdateInterval = interval;
%                 if obj.Running
                    obj.stop();
                    obj.start();
%                 end
            else
                notify(obj, 'ErrorOccurred', ...
                    ErrorEventData('Interval must be positive'));
            end
        end
    end
    
    methods (Access = private)
        function generateNewData(obj)
            try
                % ģ��۸�䶯: �������
                change = 0.5 - rand() + 0.2*(rand()-0.5);
                newPrice = obj.LastPrice + change;
                
                % ����������ϸ���ݵ��¼�����
                data = struct(...
                    'Symbol', obj.Symbol, ...
                    'Timestamp', now, ...
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
    end
end