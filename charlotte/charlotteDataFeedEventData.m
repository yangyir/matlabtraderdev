classdef charlotteDataFeedEventData < event.EventData
    properties
        MarketData
    end
    
    methods
        function obj = charlotteDataFeedEventData(data)
            obj.MarketData = data;
        end
    end
end