classdef charlotteDataFeedFX < handle
    
    events
%         NewDataArrived       % event of new data fed in
        ErrorOccurred        % event of error happened
%         CandleUpdated_M5
        CandleUpdated_M15
        CandleUpdated_M30
        CandleUpdated_H1
        CandleUpdated_H4
    end
    
    properties
        codes_
        running_ = false
        updateinterval_ = 1   % default interval of 1 second
        mode_ = 'realtime'
        onerror_ = 'resume'
    end
    
    properties (Access = private)
        instruments_
        timer_

%         lastbartime_m5_
        lastbartime_m15_
        lastbartime_m30_
        lastbartime_h1_
        lastbartime_h4_

%         fn_m5_
        fn_m15_
        fn_m30_
        fn_h1_
        fn_h4_
        %
        extrainfo_m15_
        extrainfo_m30_
        extrainfo_h1_
        extrainfo_h4_
        %
        %  replay-related
        replaydatefrom_
        replaydateto_
        replaytimevec_
        %
        replaydata_m15_
        replaydata_m30_
        replaydata_h1_
        replaydata_h4_
        %
        lastreplayidx_
    end

    properties (Access = private, Hidden = true)
        dir_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\']
    end
    
    methods
        function obj = charlotteDataFeedFX(varargin)
            obj = init(obj,varargin{:});
        end
        %
        function set.updateinterval_(obj, interval)
            if interval > 0
                obj.updateinterval_ = interval;
                obj.stop();
            else
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Interval must be positive'));
            end
        end
    end

    % event trigger method
    methods
        [] = OnError(obj,~,eventData)
        [] = OnCandleUpdated_M15(obj,~,eventData)
        [] = OnCandleUpdated_M30(obj,~,eventData)
        [] = OnCandleUpdated_H1(obj,~,eventData)
        [] = OnCandleUpdated_H4(obj,~,eventData)
    end
    
    methods
        [] = start(obj)
        [] = stop(obj)
        [] = delete(obj)
        [lastbartime] = getLastBarTime(obj,code,freq)
        [] = setReplayPeriod(obj,rplfrom,rplto)
        [data] = getReplayData(obj,code,freq)
        [ei] = getExtraInfo(obj,code,freq)
        [] = printExtraInfo(obj,extrainfo,freq)
    end
    
    methods (Access = private)
        [] = generateNewData(obj)
        obj = init(obj,varargin);
    end
end