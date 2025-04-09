classdef DataProcessor < handle
    properties
        Name
        History = []
    end
    
    methods
        function obj = DataProcessor(name)
            obj.Name = name;
        end
        
        function onNewData(obj, ~, eventData)
            data = eventData.MarketData;
            
            % 记录历史数据
            obj.History = [obj.History; data];
            
            % 显示处理结果
            fprintf('[%sDataProcessor] %s Latest Price: %.2f (%.2f, %.2f%%)\n', ...
                obj.Name, data.Symbol, data.Price, ...
                data.Change, data.ChangePct);
            
            % 简单分析
            if abs(data.ChangePct) > 1
                fprintf('--> Warning: %s price moves over1%%!\n', data.Symbol);
            end
        end
    end
end