classdef cWilliamsRInfo < cSignalInfo
    
    properties
        lengthofperiod_@double
        highesthigh_@double
        lowestlow_@double
        wrmode_@char
    end
    
    methods
        function obj = cWilliamsRInfo
            obj.name_ = 'WilliamsR';
        end
    end
    
end

