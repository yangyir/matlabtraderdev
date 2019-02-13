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
        %real-time data
        ticks_@cell
        ticksquick_@double
        candles_@cell
        candle_freq_@double
        candles4save_@cell
        %historical data,which is used for technical indicator calculation
        hist_candles_@cell
        
        technical_indicator_autocalc_@double
        technical_indicator_table_@cell
        %
        %
        replayer_@cReplayer
        replay_datetimevec_@double
        replay_idx_@double
        replay_updatetime_@logical = true
        %
        datenum_open_@cell
        datenum_close_@cell
        %
        lastclose_@double
    end
    
    properties (GetAccess = public, SetAccess = private)
        newset_@double
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
        function obj = cMDEFut(varargin)
            obj = init(obj,varargin{:});
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
        %login/logout
        [ret] = login(obj,varargin)
        [ret] = logoff(obj)
        
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
        vol = calc_hv(obj,instrument,varargin)
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj,varargin)
        %
        [] = refreshreplaymode(obj,varargin)
        [] = refreshreplaymode2(obj,varargin)
                
        [] = savecandles2file(obj,dtnum)
        
        [] = printmarket(obj)
        
        [bid,ask, timet] = getmarketdata(obj, code) % updated bu sunq
        
        [] = move2cobdate(obj,cobdate)
        
        [ret] = ismarketopen(obj,varargin)
        
    end
    
    methods (Static = true)
        [] = demo(~)
    end
    
    %% timer functions
    methods (Access = private)
        obj = init(obj,varargin)
        %data file i/o
        [] = saveticks2mem(obj)
        [] = updatecandleinmem(obj)
        [newset_] = updatecandleinmem_sunq(obj) % sunq
        %technical indicator calculator
        % William %R
        indicators = calc_wr_(obj,instrument,varargin)
        
    end
    
end