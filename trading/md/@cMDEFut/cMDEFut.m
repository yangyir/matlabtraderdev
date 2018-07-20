classdef cMDEFut < cMyTimerObj
    %Note: the class of Market Data Engine for Futures
    %1.it will pop the tick data and process it the candle container
    %jobs: from 9am to 2:30am on the next day, it keeps pop tick data while
    %it sleeps from 1:30pm until 9pm
    %jobs:it saves tick data and candle data on 2:31am in case it trades
    %during the night and it clears its meomery afterawards
    %jobs:it inits the required data on 8:50am
    
    properties
        qms_@cQMS
        display_@double = 0
        
        %real-time data
        ticks_@cell
        candles_@cell
        candle_freq_@double
        candles4save_@cell
        candlesaveflag_@logical = false
        newset_@double
        %historical data,which is used for technical indicator calculation
        hist_candles_@cell
        
        technical_indicator_autocalc_@double
        technical_indicator_table_@cell
        %
        %
        replayer_@cReplayer
        replay_datetimevec_@double
        replay_count_@double = 0
        replay_date1_@double
        replay_date2_@char
        replay_time1_@double
        replay_time2_@char
        %
        datenum_open_@cell
        datenum_close_@cell
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        iseveningrequired_@logical = false
    end
    
    properties (Access = private)
        ticks_count_@double
        candles_count_@double
        candles4save_count_@double
        categories_@double
        num21_00_00_@double
        num21_00_0_5_@double
        num00_00_00_@double
        num00_00_0_5_@double
        
    end
    
    methods
        function obj = cMDEFut
            obj.qms_ = cQMS;
        end
    end
    
    methods
        function flag = get.iseveningrequired_(obj)
            n = obj.qms_.instruments_.count;
            if n == 0
                flag = false;
            else
                flag = false;
                instruments = obj.qms_.instruments_.getinstrument;
                for i = 1:n
                    inst = instruments{i};
                    check = regexp(inst.trading_hours,';','split');
                    if length(check) > 2
                        flag = true;
                        break
                    end
                end
            end
        end
    end
    
    methods
        %replay
        [] = initreplayer(obj,varargin)
        
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
        [ret] = initcandles(obj,instrument,varargin)
        
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
        
        [] = printmarket(obj)
        
        [bid,ask, timet] = getmarketdata(obj, code) % updated bu sunq
        
        [] = move2cobdate(obj,cobdate)
        
    end
    
    methods (Static = true)
        [] = demo(~)
    end
    
    %% timer functions
    methods (Access = private)        
        %data file i/o
        [] = saveticks2mem(obj)
        [] = updatecandleinmem(obj)
        [newset_] = updatecandleinmem_sunq(obj) % sunq
        %technical indicator calculator
        % William %R
        indicators = calc_wr_(obj,instrument,varargin)
        
    end
    
end