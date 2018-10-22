classdef cStrat < cMyTimerObj
    %base abstract class of strategy
    properties (Access = private)

        %both futures and options related
        instruments_@cInstrumentArray
        %option related
        underliers_@cInstrumentArray
        
        executionbucketnumber_@double
        %
        calsignal_bucket_@double
        calcsignal_@double
        %
        preequity_@double
        currentequity_@double     %number
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
        %risk control 
        riskcontrols_@cStratConfigArray
        
    end
    
    %set/get methods
    methods
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
        [ret,e,msg] = shortopen(obj,code_ctp,lots,varargin)
        [ret,e,msg] = shortclose(obj,code_ctp,lots,closetodayflag,varargin)
        [ret,e,msg] = longopen(obj,code_ctp,lots,varargin)
        [ret,e,msg] = longclose(obj,code_ctp,lots,closetodayflag,varargin)
        
        [] = unwindpositions(obj,instrument,varargin)
        [ret,e] = unwindtrade(obj,tradein)
        pnl = calcrunningpnl(obj,instrument)
        
        [] = refresh(obj,varargin)
        
        %risk control for placing entrust
        [] = loadriskcontrolconfigfromfile(obj,varargin)
        [ret,errmsg] = riskcontrol2placeentrust(obj,instrument,varargin)
        %
        [t] = getreplaytime(obj,varargin)
        
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