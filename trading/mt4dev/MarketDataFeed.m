classdef MarketDataFeed < handle
    events
        NewDataArrived       % 新数据到达事件
        ErrorOccurred        % 错误发生事件
    end
    
    properties
        Symbol
        Running = false
        UpdateInterval = 1   % 默认1秒更新一次
    end
    
    properties (Access = private)
        Timer
        LastPrice
    end
    
    methods
        function obj = MarketDataFeed(symbol)
            obj.Symbol = symbol;
            obj.LastPrice = 100 + 20*rand(); % 初始随机价格
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
                % 模拟价格变动: 随机游走
                change = 0.5 - rand() + 0.2*(rand()-0.5);
                newPrice = obj.LastPrice + change;
                
                % 创建包含详细数据的事件数据
                data = struct(...
                    'Symbol', obj.Symbol, ...
                    'Timestamp', now, ...
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
    end
end