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
        
        function [] = set.wrmode_(obj,val)
            if ~(strcmpi(val,'classic') || ...
                    strcmpi(val,'reverse') || ...
                    strcmpi(val,'flash') || ...
                    strcmpi(val,'flashma') || ...
                    strcmpi(val,'follow') || ...
                    strcmpi(val,'all'))
                error([class(obj),':invalid wrmode_'])
            end
            obj.wrmode_ = val;
        end
    end
    
end

