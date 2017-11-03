classdef cStratFutGovtBondYieldCurveSlope < cStrat
    
    properties
        tradingfreq_@double
        slope_bid_@double
        slope_ask_@double
        slope_lasttrade_@double
        impyld_05y_@double
        impyld_10y_@double
        fut_05y_@cFutures
        fut_10y_@cFutures
        
    end
    
    methods
        function obj = cStratFutGovtBondYieldCurveSlope
            obj.name_ = 'govtbondyieldcurveslope';
        end
        
        function [] = registerinstrument(obj,instrument)
            %registerinstrument of superclass
            registerinstrument@cStrat(obj,instrument);
            
            if ~isempty(strfind(instrument.code_bbg,'TFC'))
                obj.fut_05y_ = instrument;
            elseif ~isempty(strfind(instrument.code_bbg,'TFT'))
                obj.fut_10y_ = instrument;
            end
            
        end
        %end of 'registerinstrument'
            
    end
    
    methods
        function [] = printfinfo(obj)
            obj.calcyieldcurveslope;
            fprintf('bid:%2.1f;ask:%2.1f;trade:%2.1f;10y-impyld:%2.2f\n',...
                obj.slope_bid_*100,...
                obj.slope_ask_*100,...
                obj.slope_lasttrade_*100,...
                obj.impyld_10y_)
        end
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = {};
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
        end
        %end of autoplacenewentrusts
        
        function [] = riskmanagement(obj)
            
        end
    end
    
    methods (Access = private)
        function [] = calcyieldcurveslope(obj)            
            ticks05 = obj.mde_fut_.getlasttick(obj.fut_05y_);
            ticks10 = obj.mde_fut_.getlasttick(obj.fut_10y_);
            
            if isempty(ticks05), return; end
            if isempty(ticks10), return; end
            
            yld_trade_05 = ticks05(5);
            yld_bid_05 = ticks05(6);
            yld_ask_05 = ticks05(7);
            %
            yld_trade_10 = ticks10(5);
            yld_bid_10 = ticks10(6);
            yld_ask_10 = ticks10(7);
            
            obj.slope_bid_ = yld_ask_10 - yld_bid_05;
            obj.slope_lasttrade_ = yld_trade_10 - yld_trade_05;
            obj.slope_ask_ = yld_bid_10 - yld_ask_05;
            
            obj.impyld_05y_ = yld_trade_05;
            obj.impyld_10y_ = yld_trade_10;
        end
        %end of calcyieldcurveslope
        
        
    end
    
end