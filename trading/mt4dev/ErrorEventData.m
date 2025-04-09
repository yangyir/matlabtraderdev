classdef ErrorEventData < event.EventData
    properties
        Message
    end
    
    methods
        function obj = ErrorEventData(message)
            obj.Message = message;
        end
    end
end