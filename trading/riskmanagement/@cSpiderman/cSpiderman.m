classdef cSpiderman < cTradeRiskManager
    properties
        type_   %@char
        hh0_    %@double
        ll0_    %@double
        hh1_    %@double
        ll1_    %@double
        %stoploss at candle level
        pxstoploss2_ = NaN                                        
        %TD-related
        tdhigh_ = NaN  
        tdlow_ = NaN
        td13high_ = NaN
        td13low_ = NaN
        %WAD-related
        wadopen_ = NaN
        cpopen_ = NaN
        %long trade
        wadhigh_ = NaN
        cphigh_ = NaN
        %short trade
        wadlow_ = NaN
        cplow_ = NaN
        %
        %FIBONACCI-related
        fibonacci0_ = NaN
        fibonacci1_ = NaN
        %
        %ATR-related
        atrpnlmax_ = 0
        atropen_ = 0
        % below are golden numbers
        atrmin_ = 0.8;
        atrmax_ = 1.8;
        atrlambda_ = 0.5;
    end
    
    properties (Access = private)
        bucket_count_ = -1
    end
    
    properties (GetAccess = public, SetAccess = private)
        usefractalupdate_ = 1
        usefibonacci_ = 1
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
        [unwindtrade] = riskmanagement_atr(obj,varargin)
        [unwindflag,msg] = riskmanagementwithcandleonopen(obj,varargin)
        [] = setusefractalupdateflag(obj,flagin)
        [] = setusefibonacciflag(obj,flagin)
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

