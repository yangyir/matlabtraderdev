classdef charlotteDataFeedFX < handle
    events
        NewDataArrived       % event of new data fed in
        ErrorOccurred        % event of error happened
    end
    
    properties
        codes_@cell
        running_@logical = false
        updateinterval_@double = 1   % default interval of 1 second
        mode_@char = 'realtime'
    end
    
    properties (Access = private)
        instruments_@cInstrumentArray
        timer_
        lastbartime_@double
        freq_@cell
        dir_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\']
        fn_@cell
        replaydatefrom_@double
        replaydateto_@double
        replaycounts_@double
        replaydata_@cell
    end
    
    methods
        function obj = charlotteDataFeedFX()
            obj.codes_ = charlotte_select_fx_pairs;
            
            try
                ncodes = size(obj.codes_,1);
                obj.lastbartime_ = zeros(ncodes,1);
                obj.fn_ = cell(ncodes,1);
                obj.freq_ = cell(ncodes,1);
            catch
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Failed to create an instance of charlotteDataFeedFX'));
            end
        end
        %
        function set.updateinterval_(obj, interval)
            if interval > 0
                obj.updateinterval_ = interval;
                obj.stop();
                obj.start();
            else
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Interval must be positive'));
            end
        end
    end
    
    methods
        [] = start(obj)
        [] = stop(obj)
        [] = delete(obj)
        [] = setFrequency(obj,code,freq)
        [freq] = getFrequency(obj,code)
        [lastbartime] = getLastBarTime(obj,code)
        [] = setReplayPeriod(obj,rplfrom,rplto)
        [data] = getReplayData(obj,code)
        [idx] = getRepayCount(obj,code)
    end
    
    methods (Access = private)
        [] = initData(obj)
        [] = generateNewData(obj)
    end
end