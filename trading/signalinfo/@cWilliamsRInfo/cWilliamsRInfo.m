classdef cWilliamsRInfo < cSignalInfo
    
    properties
        frequency_@char
        lengthofperiod_@double
        highesthigh_@double
        lowestlow_@double
    end
    
    methods
        function obj = cWilliamsRInfo
            obj.name_ = 'WilliamsR';
        end
    end
    
end

