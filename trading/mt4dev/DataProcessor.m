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
            
            % ��¼��ʷ����
            obj.History = [obj.History; data];
            
            % ��ʾ������
            fprintf('[%sDataProcessor] %s Latest Price: %.2f (%.2f, %.2f%%)\n', ...
                obj.Name, data.Symbol, data.Price, ...
                data.Change, data.ChangePct);
            
            % �򵥷���
            if abs(data.ChangePct) > 1
                fprintf('--> Warning: %s price moves over1%%!\n', data.Symbol);
            end
        end
    end
end