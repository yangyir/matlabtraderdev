classdef cBatmanManual < cSignalInfo
    properties
        frequency_@char
        pxtarget_@double
        pxstoploss_@double
    end
    
    methods
        function obj = cBatmanManual
            obj.name_ = 'BatmanManual';
        end
    end
end