classdef cTradeOpen < handle
    %class to define open trade position
    properties
        id_
        countername_@char
        bookname_@char
        code_@char
        instrument_@cInstrument
        opendatetime1_@double
        opendatetime2_@char
        openprice_@double
        opendirection_@double
        openvolume_@double
        targetprice_@double
        stoplossprice_@double
        stoptime1_@double
        stoptime2_@char
        closetime1_@double
        closetime2_@char
        closeprice_@double
        runningpnl_@double
        closepnl_@double
        status_@char
        %
        riskmanagementmethod_@char
        batman_@cBatman
        %
        extrainfo_@struct
    end
    
    methods
        function obj = cTradeOpen(varargin)
            obj = init(obj,varargin{:});
        end
        
        function set.status_(obj,status)
            if ~(strcmpi(status,'unset') || strcmpi(status,'set') ||...
                    strcmpi(status,'closed'))
                error('cTradeOpen:invalid status')
            end
            obj.status_ = status;
        end
        
       function set.riskmanagementmethod_(obj,method)
            if strcmpi(method,'standard') || ...
                    strcmpi(method,'batman')
                obj.riskmanagementmethod_ = method;
            else
                error('cTradeOpen:invalid risk management method')
            end
        end
        
        [] = update(obj,varargin)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
    
    methods (Static = true)

    end
    
end

