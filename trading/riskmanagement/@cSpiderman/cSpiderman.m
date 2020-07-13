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
        td13high_@double = NaN
        td13low_@double = NaN
        %
        wadopen_@double
        cpopen_@double
        %long trade
        wadhigh_@double = NaN
        cphigh_@double = NaN
        %short trade
        wadlow_@double = NaN
        cplow_@double = NaN
        %
        %
        fibonacci0_@double = NaN
        fibonacci1_@double = NaN
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
        [unwindtrade] = riskmanagement_wad(obj,varargin)
        [unwindtrade] = riskmanagement_tdsq(obj,varargin)
        [unwindtrade] = riskmanagement_fractal(obj,varargin)
        [unwindtrade] = riskmanagement_fibonacci(obj,varargin)
    end
    
    methods (Access = private)
        [ret] = riskmanagement_wadupdate(obj,varargin)
        [unwindtrade] = riskmanagement_daily(obj,varargin)
        [unwindtrade] = riskmanagement_daily_breachtd(obj,varargin)
        %
        [unwindtrade] = riskmanagement_intraday(obj,varargin)
        %
        [] = setspiderman(obj,varargin)
        %LONG
        [unwindtrade] = riskmanagement_intraday_breachuplvlup(obj,varargin)
        [unwindtrade] = riskmanagement_intraday_breachuplvldn(obj,varargin)
        %SHORT
        [unwindtrade] = riskmanagement_intraday_breachdnlvldn(obj,varargin)
        [unwindtrade] = riskmanagement_intraday_breachdnlvlup(obj,varargin)
    end
    
    methods (Access = private)
        [unwindtrade] = candlehighlow(obj,t,openp,highp,lowp,updateinfo)
    end
end

