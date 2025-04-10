classdef charlotteErrorEventData < event.EventData
    properties
        Message
    end
    
    methods
        function obj = charlotteErrorEventData(message)
            obj.Message = message;
        end
    end
end