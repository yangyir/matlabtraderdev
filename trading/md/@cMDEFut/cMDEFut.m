classdef cMDEFut < handle
    %Note: the class of Market Data Engine for Futures
    %1.it will pop the tick data and process it the candle container
    %jobs: from 9am to 2:30am on the next day, it keeps pop tick data while
    %it sleeps from 1:30pm until 9pm
    %jobs:it saves tick data and candle data on 2:31am in case it trades
    %during the night and it clears its meomery afterawards
    %jobs:it inits the required data on 8:50am
    
    properties
        mode_@char = 'realtime'
        status_@char = 'sleep';
        
        timer_@timer
        timer_interval_@double = 0.5
        
        qms_@cQMS
        
        %real-time data
        ticks_@cell
        candles_@cell
        candle_freq_@double
        candles4save_@cell
        candlesaveflag_@logical = false
        
        %historical data,which is used for technical indicator calculation
        hist_candles_@cell
        
        technical_indicator_autocalc_@double
        technical_indicator_table_@cell
        
        %replay related properties
        replay_date1_@double
        replay_date2_@char
        replay_datetimevec_@double
        replay_count_@double = 0
        
        %debug related properties
        %note:debug and replay mode are very similar but debug mode is much
        %faster
        debug_start_dt1_@double
        debug_start_dt2_@char
        debug_end_dt1_@double
        debug_end_dt2_@char
        debug_count_@double = 0
        debug_ticks_@double
        
    end
    
    properties (Access = private)
        ticks_count_@double
        candles_count_@double
        candles4save_count_@double
    end
    
    methods
        %replay related
        [] = setreplaydate(obj,datein) 
        
        %set/get
        [] = setcandlefreq(obj,freq,instrument)
        freq_ = getcandlefreq(obj,instrument)
        n = getcandlecount(obj,instrument)
        candlesticks = getcandles(obj,instrument)
        candlesticks = getlastcandle(obj,instrument)
        [] = loadhistcandles(obj,instrument,histcandles)
        histcandles = gethistcandles(obj,instrument)
        tick = getlasttick(obj,instrument)
        
        %init data
        [ret] = initcandles(obj,instrument)
        
    end
    
    methods
        [] = settechnicalindicator(obj,instrument,indicators)
        [] = settechnicalindicatorautocalc(obj,instrument,calcflag)
        indicators = calc_technical_indicators(obj,instrument)
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        
        [] = refresh(obj)
        
        [] = savecandles2file(obj,dtnum)
            
        [] = start(obj)
        [] = startat(obj,dtstr)
        [] = stop(obj)
        
    end
    
    %% timer functions
    methods (Access = private)
        %timer functions
        [] = replay_timer_fcn(obj,~,event)
        [] = start_timer_fcn(obj,~,event)
        [] = stop_timer_fcn(obj,~,event)
        
        %data file i/o
        [] = saveticks2mem(obj)
        [] = updatecandleinmem(obj)
        
        %technical indicator calculator
        % William %R
        indicators = calc_wr_(obj,instrument,varargin)
    end
    
end