classdef MarketDataEventData < event.EventData
    properties
        MarketData
    end
    
    methods
        function obj = MarketDataEventData(data)
            obj.MarketData = data;
        end
    end
end