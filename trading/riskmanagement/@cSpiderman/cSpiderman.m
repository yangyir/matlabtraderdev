classdef cSpiderman < cTradeRiskManager
    properties
        type_@char
        hh0_@double
        ll0_@double
        hh1_@double
        ll1_@double
        pxstoploss2_@double = -9.99                                         %stoploss at candle level
        tdhigh_@double = NaN
        tdlow_@double = NaN
        %
        wadopen_@double
        cpopen_@double
        %long trade
        wadhigh_@double = NaN
        cphigh_@double = NaN
        %short trade
        wadlow_@double = NaN
        cplow_@double = NaN
    end
    
    properties (Access = private)
        bucket_count_@double = -1
    end
       
    methods
        function obj = cSpiderman
            obj.name_ = 'spiderman';
        end
    end
    
    methods
        [unwindtrade] = riskmanagement(obj,varargin)
        [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
        [] = updatestoploss(obj,varargin)
    end
    
    methods (Access = private)
        [ret] = riskmanagement_wad(obj,varargin)
        [unwindtrade] = riskmanagement_daily(obj,varargin)
        [unwindtrade] = riskmanagement_daily_breachtd(obj,varargin)
        %
        [unwindtrade] = riskmanagement_intraday(obj,varargin)
    end
end

