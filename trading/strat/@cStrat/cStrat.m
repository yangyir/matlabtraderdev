classdef cStrat < handle
    %base abstract class of strategy
    properties
        name_@char
        
        mode_@char = 'realtime'
        
        %trading pnl related
        pnl_stop_type_@cell
        pnl_stop_@double            % stop ratio as of the margin used
        
        pnl_limit_type_@cell
        pnl_limit_@double           % limit ratio as of the margin used
                
        pnl_running_@double     % pnl for existing positions
        pnl_close_@double       % pnl for unwind positions
        
        %both futures and options related
        instruments_@cInstrumentArray
        %option related
        underliers_@cInstrumentArray
        
        %order/entrust related
        %positive bid spread means to order a sell with a higher price
        bidspread_@double
        %positive ask spread means to order a buy with a lower price
        askspread_@double
        
        %size related
        baseunits_@double
        maxunits_@double
        %
        executionperbucket_@double
        maxexecutionperbucket_@double
        executionbucketnumber_@double
        
        %market data engine
        mde_fut_@cMDEFut
        mde_opt_@cMDEOpt
        
        %portfolio/book
        portfolio_@cPortfolio
        %the portfolio as of last business date
        portfoliobase_@cPortfolio
        
        %
        autotrade_@double
        
        %
        counter_@CounterCTP
        
        %
        entrusts_@EntrustArray
        entrustspending_@EntrustArray
        entrustsfinished_@EntrustArray
        
        %timer
        timer_@timer
        timer_interval_@double = 0.5
        
        %debug mode
        timevec4debug_@double
        dtstart4debug_@double
        dtend4debug_@double
        dtcount4debug_@double = 0

    end
    
    %set/get methods
    methods
        [] = setstoptype(obj,instrument,stoptype)
        [] = setstopamount(obj,instrument,stop)
        [] = setlimittype(obj,instrument,limitype)
        [] = setlimitamount(obj,instrument,limit)
        type_ = getstoptype(obj,instrument)
        amount_ = getstopamount(obj,instrument)
        type_ = getlimittype(obj,instrument)
        amount_ = getlimitamount(obj,instrument)
        [] = setbidspread(obj,instrument,bidspread)
        [] = setaskspread(obj,instrument,askspread)
        bidspread = getbidspread(obj,instrument)
        askspread = getaskspread(obj,instrument)     
        [] = setbaseunits(obj,instrument,baseunits)
        baseunits = getbaseunits(obj,instrument)
        [] = setmaxunits(obj,instrument,maxunits)
        maxunits = getmaxunits(obj,instrument)
        [] = setautotradeflag(obj,instrument,autotrade)
        autotrade = getautotradeflag(obj,instrument)
        [] = setmdeconnection(obj,connstr)
        %
        [] = setmaxexecutionperbucket(obj,instrument,value)
        n = getmaxexecutionperbucket(obj,instrument)
        [] = setexecutionperbucket(obj,instrument,value)
        n = getexecutionperbucket(obj,instrument)
    end
    %end of set/get methods
    
    %instrument-related methods
    methods
        [] = registerinstrument(obj,instrument)
        [] = removeinstrument(obj,instrument)
        
        function [] = clear(obj)
            obj.instruments_.clear;
            obj.underliers_.clear;
            obj.mde_fut_ = {};
            obj.mde_opt_ = {};
            obj.counter_ = {};    
        end
        %end of clear
        
        function n = count(obj)
            n = obj.instruments_.count;
        end
        %end of count
        
        function n = countunderliers(obj)
            n = obj.underliers_.count;
        end
        %end of countunderliers
        
    end
    %end of instrument-related methods
    
    %option-specific methods
    methods
        %note:todo:this method might be removed later
        function [strikes,calls,puts] = breakdownopt(obj,underlier)
            if ~isa(underlier,'cInstrument')
                error('cStrat:breakdownopt:invalid underlier input')
            end
            n = obj.count;
            strikes = zeros(n,1);
            calls = cInstrumentArray;
            puts = cInstrumentArray;
            underlierstr = underlier.code_ctp;
            list = obj.instruments_.getinstrument;
            count_strike = 0;
            for i = 1:n
                if isa(list{i},'cOption') && strcmpi(list{i}.code_ctp_underlier,underlierstr)
                    if strcmpi(list{i}.opt_type,'C')
                        calls.addinstrument(list{i});
                    else
                        puts.addinstrument(list{i});
                    end
                    strike_i = list{i}.opt_strike;
                    if ischar(strike_i), strike_i = str2double(strike_i); end
                    if i == 1
                        count_strike = count_strike+1;
                        strikes(count_strike,1) = strike_i;
                    else  
                        %check with duplicate strikes
                        flag = false;
                        for j = 1:count_strike
                            if strike_i == strikes(j)
                                flag = true;
                                break
                            end
                        end
                        if ~flag
                            count_strike = count_strike+1;
                            strikes(count_strike,1) = strike_i;
                        end
                    end
                end
            end
            if count_strike > 0
                strikes = strikes(1:count_strike,:);
            end
        end
        %end of breakdownopt
        
                
    end
    %end of option-specific methods
    
    %trading-related methods
    methods
        %counter-related methods
        [] = registercounter(obj,counter)
        [] = loadportfoliofromcounter(obj)
        
        %local-file related
        [] = loadportfoliofromfile(obj,fn,dateinput)
        [] = saveportfoliotofile(obj,fn,clearportfolio)
        
        %process portfolio with entrusts
        pnl = updateportfoliowithentrust(obj,e)
        [] = updateentrusts(obj)
        [] = withdrawentrusts(obj,instrument)
        
        %long/short open/close positions
        [ret,e] = shortopensingleinstrument(obj,code_ctp,lots,spread)
        [ret,e] = shortclosesingleinstrument(obj,code_ctp,lots,closetodayflag,spread)
        [ret,e] = longopensingleinstrument(obj,ctp_code,lots,spread)
        [ret,e] = longclosesingleinstrument(obj,ctp_code,lots,closetodayflag,spread)
        
        [] = unwindposition(obj,instrument,spread)
        pnl = calcrunningpnl(obj,instrument)
        
    end
    %end of trading-related methods
    
    %timer-related methods
    methods
        %start the timer
        [] = start(obj)
        %stop the timer    
        [] = stop(obj)
        %start the timer at specified time
        [] = startat(obj,dtstr)
        
    end
    %end of timer-related methods
    
    
    %abstract methods
    methods (Abstract)
        signals = gensignals(obj)
        [] = autoplacenewentrusts(obj,signals)
        [] = updategreeks(obj)
        [] = riskmanagement(obj,dtnum)
        [] = initdata(obj)
    end
    
    %timer-related private methods
    methods (Access = private)
        [] = settimer(obj)
        [] = replay_timer_fcn(obj,~,event)       
        [] = start_timer_fcn(obj,~,event)
        [] = stop_timer_fcn(obj,~,event)
        
    end
end