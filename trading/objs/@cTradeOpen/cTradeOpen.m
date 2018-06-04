classdef cTradeOpen < handle
    %class to define open trade position
    properties
        countername_@char
        ctpcode_@char
        instrument_@cInstrument
        opendatetime1_@double
        opendatetime2_@char
        openprice_@double
        opendirection_@double
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
        riskmanagementmethod_@char
        
    end
    
    methods
        function obj = cTradeOpen(varargin)
            obj = init(obj,varargin{:});
        end
        
        [] = update(obj,varargin)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
    
end

