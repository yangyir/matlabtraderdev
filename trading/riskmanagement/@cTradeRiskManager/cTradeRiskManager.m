classdef cTradeRiskManager < handle
%des:manage risk trade by trade rather than on aggregage positions    
    properties
        name_@char
        trade_@cTradeOpen
        status_@char = 'unset'
        %
        pxtarget_@double = -9.99
        pxstoploss_@double = -9.99
        %
        closestr_@char = 'none'
    end
    
    methods (Abstract)
        [] = riskmanagement(obj,varargin)
    end
    
    methods
        function set.status_(obj,status)
            if strcmpi(status,'unset') || strcmpi(status,'set') ||...
                    strcmpi(status,'closed')
                obj.status_ = status;
            else
                error('cTradeRiskManager:invalid status')
            end
        end
    end
    
    methods
        function [] = settarget(obj,target)
            obj.pxtarget_ = target;
            
        end
        %
        function [] = setstoploss(obj,stoploss)
            obj.pxstoploss_ = stoploss;
        end
    end
    
    methods
        [unwindtrade] = riskmanagementwithtick(obj,tick,varargin)
    end
    
end

