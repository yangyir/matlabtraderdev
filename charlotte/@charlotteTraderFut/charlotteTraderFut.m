classdef charlotteTraderFut < handle
    events
        DummyTradeOpenM5
        DummyTradeCloseM5
        DummyTradeOpenM30
        DummyTradeCloseM30
    end
    
    properties
        mode_@char
        trades_m5_@cTradeOpenArray
        trades_m30_@cTradeOpenArray
        %
        entrusts_m5_@EntrustArray
        entrustspending_m5_@EntrustArray
        entrustsfinished_m5_@EntrustArray
        condentrustspending_m5_@EntrustArray
        %
        entrusts_m30_@EntrustArray
        entrustspending_m30_@EntrustArray
        entrustsfinished_m30_@EntrustArray
        condentrustspending_m30_@EntrustArray
        %
        useDummy4Opt_@logical
    end
    
    properties (Access = private)
        counter_@CounterCTP
    end
    
    methods
        function obj = charlotteTraderFut
            obj.trades_m5_ = cTradeOpenArray;
            obj.trades_m30_ = cTradeOpenArray;
            %
            obj.counter_ = CounterCTP.ccb_ly_fut;
            %
            obj.entrusts_m5_ = EntrustArray;
            obj.entrustspending_m5_ = EntrustArray;
            obj.entrustsfinished_m5_ = EntrustArray;
            obj.condentrustspending_m5_ = EntrustArray;
            %
            obj.entrusts_m30_ = EntrustArray;
            obj.entrustspending_m30_ = EntrustArray;
            obj.entrustsfinished_m30_ = EntrustArray;
            obj.condentrustspending_m30_ = EntrustArray;
            %
            obj.useDummy4Opt_ = false;
        end
    end
    
    methods
        % login/logoff and also load/save trades
        [] = onMarketOpen(obj,~,eventData)
        [] = onMarketClose(obj,~,eventData)
        % new tick arrives, risk management, update entrusts status
        [] = onNewData(obj,~,eventData)
        % candle level risk management
        [] = onNewBarSetM5(obj,~,eventData)
        [] = onNewBarSetM30(obj,~,eventData)
        % open-up new trade or unwind existing trade
        [] = onNewSignalM5(obj,~,eventData)
        [] = onNewSignalM30(obj,~,eventData)
        %
        [] = loadtrades(obj,varargin)
        [] = savetrades(obj,varargin)
        %
        % option trading strategy with dummy futures underlying related
        [] = onDummyTradeOpenM5(obj,~,eventData)
        [] = onDummyTradeCloseM5(obj,~,eventData)
        [] = onDummyTradeOpenM30(obj,~,eventData)
        [] = onDummyTradeCloseM30(obj,~,eventData)
    end
end