classdef cMarketDataFeed < handle
    events
        NewDataArrived       % event of new data fed in
        ErrorOccurred        % event of error happened
    end
    
    properties
        Symbol
        Running@logical = false
        UpdateInterval@double = 1   % default interval of 1 second
    end
    
    properties (Access = private)
        Timer
        LastPrice
        QMS@cQMS
    end
    
    methods
        function obj = cMarketDataFeed(symbol)
            obj.Symbol = symbol;
            
            try
                obj.QMS = cQMS;
                obj.QMS.setdatasource('CTP');
                obj.QMS.ctplogin('countername','ccb_ly_fut');
                obj.QMS.registerinstrument(code2instrument(obj.Symbol));
                obj.QMS.refresh;
                quote = obj.QMS.getquote(obj.Symbol);
                obj.LastPrice = quote.last_trade;
                
            catch
                notify(obj, 'ErrorOccurred', ...
                    ErrorEventData('Failed to login to CTP'));
            end
        end
        %
        function set.UpdateInterval(obj, interval)
            if interval > 0
                obj.UpdateInterval = interval;
                obj.stop();
                obj.start();
            else
                notify(obj, 'ErrorOccurred', ...
                    ErrorEventData('Interval must be positive'));
            end
        end
    end
    
    methods
        start(obj)
        stop(obj)
        delete(obj)
    end
    
    methods (Access = private)
        generateNewData(obj)
    end
end