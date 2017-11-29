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
        bidspread_@double;
        %positive ask spread means to order a buy with a lower price
        askspread_@double;
        
         %size related
        baseunits_@double
        maxunits_@double
        
        %market data engine
        mde_fut_@cMDEFut;
        mde_opt_@cMDEOpt;
        
        %portfolio/book
        portfolio_@cPortfolio;
        
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
    end
    %end of set/get methods
    
    %instrument-related methods
    methods
        [] = registerinstrument(obj,instrument)
        [] = removeinstrument(obj,instrument)
        
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
        
        function pnl = calcrunningpnl(obj, instrument)           
            if ~isa(instrument,'cInstrument')
                error('cStrat:calcrunningpnl:invalid instrument input')
            end
            
            %to check whether the instrument has been already traded or not
            [flag,idx] = obj.portfolio_.hasinstrument(instrument);
            
            pnl = 0;
            if flag
                volume = obj.portfolio_.instrument_volume(idx);
                [~,ii] = obj.instruments_.hasinstrument(instrument);
                
                if volume == 0
                    obj.pnl_running_(ii) = pnl;
                    return
                end
                
                cost = obj.portfolio_.instrument_avgcost(idx);
                if isa(instrument,'cFutures')
                    tick = obj.mde_fut_.getlasttick(instrument);
                else
                    q = obj.mde_opt_.qms_.getquote(instrument);
                    tick(1) = q.last_trade;
                    tick(2) = q.bid1;
                    tick(3) = q.ask1;
                end
                if isempty(tick)
                    obj.pnl_running_(ii) = pnl;
                    return
                end
                
                bid = tick(2);
                ask = tick(3);
                if bid == 0 || ask == 0
                    obj.pnl_running_(ii) = pnl;
                    return 
                end
                
                multi = instrument.contract_size;
                if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
                    multi = multi/100;
                end
                    
                %the running pnl is the pnl in case the positions are
                %completely unwind
                if volume > 0
                    pnl = (bid-cost)*volume*multi;
                elseif volume < 0
                    pnl = (ask-cost)*volume*multi;
                end
                obj.pnl_running_(ii) = pnl;
                
            end
            
        end
        %end of calcrunningpnl
        
    end
    %end of option-specific methods
    
    %trading-related methods
    methods
        [] = registercounter(obj,counter)
        
        [] = loadportfoliofromcounter(obj)
        
        pnl = updateportfoliowithentrust(obj,e)

        [] = unwindposition(obj,instrument)
        
        [] = withdrawentrusts(obj,instrument)
        
        [] = updateentrusts(obj)
        
        %long/short open/close positions
        [] = shortopensingleinstrument(obj,code_ctp,lots)
        [] = shortclosesingleinstrument(obj,code_ctp,lots)
        [] = longopensingleinstrument(obj,ctp_code,lots)
        [] = longclosesingleinstrument(obj,ctp_code,lots)
        
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
    
    %debug mode-related methods
    methods
        function [] = initdata4debug(obj,instrument,dtstart,dtend)
            if ~isa(instrument,'cInstrument')
                error('cStrat:initdata4debug:invalid instrument input')
            end
            c = bbgconnect;
            dcell = c.timeseries(instrument.code_bbg,{datestr(dtstart),datestr(dtend)},[],'trade');
            dnum = cell2mat(dcell(:,2:3));
            obj.timevec4debug_ = dnum(:,1);
            obj.dtstart4debug_ = datenum(dtstart);
            obj.dtend4debug_ = datenum(dtend);
            obj.dtcount4debug_ = 0;
            c.close;
            clear c
            
            obj.mode_ = 'debug';
            obj.mde_fut_.mode_ = 'debug';
            
            obj.mde_fut_.debug_start_dt1_ = obj.dtstart4debug_;
            obj.mde_fut_.debug_start_dt2_ = datestr(obj.dtstart4debug_);
            obj.mde_fut_.debug_end_dt1_ = obj.dtend4debug_;
            obj.mde_fut_.debug_end_dt2_ = datestr(obj.dtend4debug_);
            obj.mde_fut_.debug_count_ = 0;
            obj.mde_fut_.debug_ticks_ = dnum;
            
        end
        %end of init4debug
    end
    
    
    %abstract methods
    methods (Abstract)
        signals = gensignals(obj)
        [] = autoplacenewentrusts(obj,signals)
        [] = updategreeks(obj)
        [] = riskmanagement(obj,dtnum)
    end
    
    %timer-related private methods
    methods (Access = private)
        [] = settimer(obj)
        [] = replay_timer_fcn(obj,~,event)       
        [] = start_timer_fcn(obj,~,event)
        [] = stop_timer_fcn(obj,~,event)
        
    end
end