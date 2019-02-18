classdef cWilliamsRInfo < cSignalInfo
    
    properties
        lengthofperiod_@double
        highesthigh_@double
        lowestlow_@double
        wrmode_@char
        %
        overrideriskmanagername_@char
        overridepxtarget_@double = -9.99
        overridepxstoploss_@double = -9.99
        
    end
    
    methods
        function obj = cWilliamsRInfo
            obj.name_ = 'WilliamsR';
        end
    end
    
end

