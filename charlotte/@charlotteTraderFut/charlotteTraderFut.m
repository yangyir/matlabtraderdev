classdef charlotteTraderFut < handle
    properties
        mode_@char
        trades_m1_@cTradeOpenArray
        trades_m5_@cTradeOpenArray
        trades_m15_@cTradeOpenArray
        trades_m30_@cTradeOpenArray
        trades_d1_@cTradeOpenArray
        %
        entrusts_@EntrustArray
        entrustspending_@EntrustArray
        entrustsfinished_@EntrustArray
        %
        condentrustspending_@EntrustArray
        
    end
    
    properties (Access = private)
        counter_@CounterCTP
    end
    
    methods
        function obj = charlotteTraderFut
            obj.trades_m1_ = cTradeOpenArray;
            obj.trades_m5_ = cTradeOpenArray;
            obj.trades_m15_ = cTradeOpenArray;
            obj.trades_m30_ = cTradeOpenArray;
            obj.trades_d1_ = cTradeOpenArray;
            %
            obj.counter_ = CounterCTP.ccb_ly_fut;
        end
    end
    
    methods
        [] = onMarketOpen(obj,~,eventData)
        [] = onMarketClose(obj,~,eventData)
        %
        [] = onNewData(obj,~,eventData)
        %
        [] = onNewBarSetM1(obj,~,eventData)
        [] = onNewBarSetM5(obj,~,eventData)
        [] = onNewBarSetM15(obj,~,eventData)
        [] = onNewBarSetM30(obj,~,eventData)
        [] = onNewBarSetD1(obj,~,eventData)
        %
        [] = onNewSignalM1(obj,~,eventData)
        [] = onNewSignalM5(obj,~,eventData)
        [] = onNewSignalM15(obj,~,eventData)
        [] = onNewSignalM30(obj,~,eventData)
        [] = onNewSignalD1(obj,~,eventData)
        
    end
end