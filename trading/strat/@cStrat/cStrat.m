classdef cStrat < cMyTimerObj
    %base abstract class of strategy
    properties (Access = private)

        %both futures and options related
        instruments_@cInstrumentArray
        %option related
        underliers_@cInstrumentArray
        
        %sample frequency, e.g. 5m, 15m
        samplefreq_@double

        %trading pnl related per underlier
        pnl_stop_type_@double       % 0-rel and 1-abs
        pnl_stop_@double            % stop ratio as of the margin used
        
        pnl_limit_type_@double      % 0-rel and 1-abs
        pnl_limit_@double           % limit ratio as of the margin used
                
        pnl_running_@double         % pnl for existing positions
        pnl_close_@double           % pnl for closed positions
        
        %order/entrust related
        %positive bid spread means to order a sell with a higher price
        bidopenspread_@double
        bidclosespread_@double
        %positive ask spread means to order a buy with a lower price
        askopenspread_@double
        askclosespread_@double
        
        %size related
        baseunits_@double
        maxunits_@double
        %automatic trading?
        autotrade_@double
        %
        executionperbucket_@double
        maxexecutionperbucket_@double
        executionbucketnumber_@double
        %
        calsignal_bucket_@double
        calcsignal_@double
        %
        totalequity_@double     %number
        currentmargin_@double   %number
        availablefund_@double   %number
        frozenmargin_@double    %number
        
    end
       
    properties (GetAccess = public, SetAccess = private)
        calcsignal_interval_@double = 60
        %trading
        trader_@cTrader
        helper_@cOps
        %
        %market data engine
        mde_fut_@cMDEFut
        mde_opt_@cMDEOpt
        %
        
    end
    
    %set/get methods
    methods
        [] = setsamplefreq(obj,instrument,freq)
        freq = getsamplefreq(obj,instrument)
        %
        [] = setstoptype(obj,instrument,stoptype)
        type_ = getstoptype(obj,instrument)
        %
        [] = setstopamount(obj,instrument,stop)
        amount_ = getstopamount(obj,instrument)
        %
        [] = setlimittype(obj,instrument,limitype)
        type_ = getlimittype(obj,instrument)
        %
        [] = setlimitamount(obj,instrument,limit)
        amount_ = getlimitamount(obj,instrument)
        %
        [] = setpnlrunning(obj,instrument,pnl)
        pnl = getpnlrunning(obj,instrument)
        %
        [] = setpnlclose(obj,instrument,pnl)
        pnl = getpnlclose(obj,instrument)
        %
        [] = setbidopenspread(obj,instrument,spread)
        spread = getbidopenspread(obj,instrument)
        [] = setbidclosespread(obj,instrument,spread)
        spread = getbidclosespread(obj,instrument)
        %
        [] = setaskopenspread(obj,instrument,spread)
        spread = getaskopenspread(obj,instrument)
        [] = setaskclosespread(obj,instrument,spread)
        spread = getclosespread(obj,instrument)
        %
        [] = setbaseunits(obj,instrument,baseunits)
        baseunits = getbaseunits(obj,instrument)
        %
        [] = setmaxunits(obj,instrument,maxunits)
        maxunits = getmaxunits(obj,instrument)
        %
        [] = setautotradeflag(obj,instrument,autotrade)
        autotrade = getautotradeflag(obj,instrument)
        %
        [] = setmaxexecutionperbucket(obj,instrument,value)
        n = getmaxexecutionperbucket(obj,instrument)
        %
        [] = setexecutionperbucket(obj,instrument,value)
        n = getexecutionperbucket(obj,instrument)
        %
        [] = setexecutionbucketnumber(obj,instrument,value)
        n = getexecutionbucketnumber(obj,instrument)
        %
        [] = setcalcsignalbucket(obj,instrument,val)
        calcsignalbucket = getcalcsignalbucket(obj)
        %
        [] = setcalcsignal(obj,instrument,val)
        calcsignal = getcalcsignal(obj)
        %
        [flag] = istime2calcsignal(obj,t)
        %
%         [] = setmarginalloc(obj,instrument,val)
%         alloc =  getmarginalloc(obj,instrument)
        
        [ret] = setavailablefund(obj,val,varargin)
        val = getcurrentmargin(obj)
        val = getavailablefund(obj)
        val = getfrozenmargin(obj)

    end
    %end of set/get methods
    
    %instrument-related methods
    methods
        [] = registerinstrument(obj,instrument)
        [] = removeinstrument(obj,instrument)
        [flag,idx] = hasinstrument(obj,instrument)
        [instruments] = getinstruments(obj)
        [] = clear(obj)
        [n] = count(obj)
        [n] = countunderliers(obj)
    end
    %end of instrument-related methods
   
    %trading-related methods
    methods
        %register mdefut/mdeopt/ops
        [] = registermdefut(obj,mdefut)
        [] = registermdeopt(obj,mdeopt)
        [] = registerhelper(obj,helper)
        
        %process portfolio with entrusts
        [] = updatestratwithentrust(obj,e)
        [] = withdrawentrusts(obj,instrument,varargin)
        
        %long/short open/close positions
        [ret,e] = shortopen(obj,code_ctp,lots,varargin)
        [ret,e] = shortclose(obj,code_ctp,lots,closetodayflag,varargin)
        [ret,e] = longopen(obj,code_ctp,lots,varargin)
        [ret,e] = longclose(obj,code_ctp,lots,closetodayflag,varargin)
        
        [] = unwindpositions(obj,instrument,varargin)
        [ret,e] = unwindtrade(obj,tradein)
        pnl = calcrunningpnl(obj,instrument)
        
        [] = refresh(obj,varargin)
        
        %risk control for placing entrust
        [ret] = riskcontrol2placeentrust(obj,instrument,varargin)
        
    end
    %end of trading-related methods
    
    methods
        function [] = print(obj,varargin)
            variablenotused(obj);
        end
        
        function [] = savemktdata(obj,varargin)
            %cStrat doesn't run savemktdata,cMDEFut/cMDEOpt runs it
            variablenotused(obj);
        end
        
        function [] = savetrades(obj,varargin)
            %cStrat doesn't run savetrades, cOps runs it
            variablenotused(obj);
        end
        
        function [] = loadmktdata(obj,varargin)
            %cStrat doesn't run loadmktdata,cMDEFut/cMDEOpt runs it
            variablenotused(obj);
        end
        
        function [] = loadtrades(obj,varargin)
            %cStrat doesn't run loadtrades,cOps runs it
            variablenotused(obj);
        end
        
        [t] = getreplaytime(obj,varargin)
    end
    

    methods 
        
    end
    
    
    %abstract methods
    methods (Abstract)
        signals = gensignals(obj)
        [] = autoplacenewentrusts(obj,signals)
        [] = updategreeks(obj)
        [] = riskmanagement(obj,dtnum)
        [] = initdata(obj)
    end
    
end