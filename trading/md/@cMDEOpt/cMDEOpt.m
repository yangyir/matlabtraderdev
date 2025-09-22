classdef cMDEOpt < cMyTimerObj
    %Note: the class of Market Data Engine for listed options
    properties
        qms_@cQMS
        %
        options_@cInstrumentArray
        underlier_@cInstrument
        %
        %
        %for underlier (only 1) and rest options
        ticks_@cell
        ticksquick_@double
        candles_@cell
        candle_freq_@double
        candles4save_@cell
        %historical data,which is used for technical indicator calculation
        hist_candles_@cell
        %
        %Williams Fractals
        nfractals_@double
        
        datenum_open_@double
        datenum_close_@double
        %
        lastclose_@double
        %
        savetick_@logical = false
        %
        showfigures_@logical = true
        
    end
    
    properties (Hidden = true)
        %MACD
        macdlead_@double
        macdlag_@double
        macdavg_@double
        %TDSQ
        tdsqlag_@double
        tdsqconsecutive_@double
    end
    
    properties (GetAccess = public, SetAccess = private)
        newset_@double
    end
    
    properties
        delta_@double
        gamma_@double
        vega_@double
        theta_@double
        impvol_@double
        %
        deltacarry_@double
        gammacarry_@double
        vegacarry_@double
        thetacarry_@double
        %
        deltacarryyesterday_@double
        gammacarryyesterday_@double
        vegacarryyesterday_@double
        thetacarryyesterday_@double
        impvolcarryyesterday_@double
        pvcarryyesterday_@double
        %
        replayer_@cReplayer
        replay_datetimevec_@double
        replay_idx_@double
        replay_updatetime_@logical = true
        
    end
    
    properties (Access = private)
        quotes_@cell
        pivottable_@cell
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
        function obj = cMDEOpt(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        %login/logout
        [ret] = login(obj,varargin)
        [ret] = logoff(obj)
        %
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
        %option specific ones
        [calls,puts] = loadoptions(obj,code_ctp_underlier,numstrikes)
        [] = plotvolslice(obj,code_ctp_underlier,numstrikes,varargin)
        tbl = voltable(obj)
        res = getgreeks(obj,instrument)
        res = getatmgreeks(obj,code_ctp_underlier,varargin)
        res = getportfoliogreeks(obj,instruments,weights)
        %underlier specific ones
        % MACD
        [macdvec,sig,diffbar] = calc_macd_(obj,varargin)
        % TDSQ
        [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown,p] = calc_tdsq_(obj,varargin)
        % William's fractal
        [idxHH,idxLL,HH,LL] = calc_fractal_(obj,varargin)
        % William's alligator
        [jaw,teeth,lips] = calc_alligator_(obj,varargin)
        %William's accumulate/distribute
        [wad,p] = calc_wad_(obj,varargin)
        
    end
    
    
    methods
        
        [] = registerinstrument(obj,instrument)
        %
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj,varargin)
        %
        [] = refreshreplaymode(obj,varargin)
        [ret] = ismarketopen(obj,varargin)
        
        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = savequotes2mem(obj) 
        [] = savequotes2memreplay(obj)
        [] = saveticks2mem(obj)
        [] = updatecandleinmem(obj)
        tbl = genpivottable(obj)
        tbl = displaypivottable(obj)
        [] = printunderlier(obj)
    end
    
    methods (Static = true)
        [] = pnlriskbreakdowneod(obj,underlier_code_ctp,numofstrikes)
    end
    
    
end