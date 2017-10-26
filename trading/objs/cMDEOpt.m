classdef cMDEOpt < handle
    %Note: the class of Market Data Engine for listed options
    properties
        mode_@char = 'realtime'
        status_@char = 'sleep';
        
        timer_@timer
        timer_interval_@double = 0.5
        
        qms_@cQMS
        
        %real-time data
%         ticks_@cell
%         candles_@cell
%         candle_freq_@double
%         candles4save_@cell
%         candlesaveflag_@logical = false
        
        %historical data,which is used for technical indicator calculation
%         hist_candles_@cell
        
%         technical_indicator_autocalc_@double
%         technical_indicator_table_@cell
        
        %replay related properties
        replay_date1_@double
        replay_date2_@char
        replay_datetimevec_@double
        replay_count_@double = 0
        
    end
    
    methods
        function obj = registerinstrument(obj,instrument)
        end
        %end of registerinstrument
    end
end