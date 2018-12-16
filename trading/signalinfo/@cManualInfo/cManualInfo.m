classdef cManualInfo < cSignalInfo
    properties
        riskmanagername_@char
        pxtarget_@double
        pxstoploss_@double
    end
    
    
    methods
        function [] = set.riskmanagername_(obj,namein)
            if ~(strcmpi(namein,'standard') || strcmpi(namein,'batman'))
                error('cManualInfo:invalid riskmanagername')
            end
            obj.riskmanagername_ = namein;
        end
    end
    
    methods
        function obj = cManualInfo
            obj.name_ = 'Manual';
        end
    end
end