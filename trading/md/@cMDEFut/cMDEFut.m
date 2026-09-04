classdef cMDEFut < cMyTimerObj
    %Note: the class of Market Data Engine for Futures
    %1.it will pop the tick data and process it the candle container
    %jobs: from 9am to 2:30am on the next day, it keeps pop tick data while
    %it sleeps from 1:30pm until 9pm
    %jobs:it saves tick data and candle data on 2:31am in case it trades
    %during the night and it clears its meomery afterawards
    %jobs:it inits the required data on 8:50am
    
    properties
        qms_                %@cQMS
        %real-time data
        ticks_ = {}         %@cell
        ticksquick_ = []    %@double
        candles_ = {}       %@cell
        candle_freq_ = []   %@double
        candles4save_ = {}  %@cell
        %historical data,which is used for technical indicator calculation
        hist_candles_ = {}  %@cell
        
        %William %R number of period
        wrnperiod_ = []     %@double
        %MACD
        macdlead_ = []      %@double
        macdlag_ = []       %@double
        macdavg_ = []       %@double
        %TDSQ
        tdsqlag_ = []           %@double
        tdsqconsecutive_ = []   %@double
        %Williams Fractals
        nfractals_ = []         %@double
        %
        replayer_               %@cReplayer
        replay_datetimevec_ = []
        replay_idx_ = []
        replay_updatetime_ = true
        %
        datenum_open_ = {}
        datenum_close_ = {}
        %
        lastclose_ = []
        %
        savetick_ = false
        %
        showfigures_ = true
    end
    
    properties (Hidden = true)
        technical_indicator_autocalc_ = []
        technical_indicator_table_ = {}
    end
    
    properties (GetAccess = public, SetAccess = private)
        newset_ = []
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        iseveningrequired_
    end
    
    properties (Access = private)
        ticks_count_ = []
        candles_count_ = []
        candles4save_count_ = []
        categories_ = []
        num21_00_00_
        num21_00_0_5_
        num00_00_00_
        num00_00_0_5_
        
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
        candlesticks = getallcandles(obj,instrument)
        tick = getlasttick(obj,instrument)
        %init data
        [ret] = initcandles(obj,instrument,varargin)
        
    end
    
    methods
        [] = settechnicalindicator(obj,instrument,indicators)
        [] = settechnicalindicatorautocalc(obj,instrument,calcflag)
        vol = calc_hv(obj,instrument,varargin)
        indicators = calc_technical_indicators(obj,instrument,varargin)
        %technical indicator calculator
        % William %R
        [indicators,wrseries,maxcandle,mincandle] = calc_wr_(obj,instrument,varargin)
        % MACD
        [macdvec,sig,diffbar] = calc_macd_(obj,instrument,varargin)
        % TDSQ
        [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown,p] = calc_tdsq_(obj,instrument,varargin)
        % William's fractal
        [idxHH,idxLL,HH,LL] = calc_fractal_(obj,instrument,varargin)
        % William's alligator
        [jaw,teeth,lips] = calc_alligator_(obj,instrument,varargin)
        %William's accumulate/distribute
        [wad,p] = calc_wad_(obj,instrument,varargin)
        
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
        
        
    end
    
end