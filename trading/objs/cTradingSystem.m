classdef cTradingSystem < handle
    properties
        timer_@timer

        portfolio_@cPortfolio   %portfolio
        strat_@cStrat           %strategy
        qms_@cQMS               %quote management system
        counter_@CounterCTP
        
        entrusts_@EntrustArray
        
    end
    
    properties (Access = private)
        timer_interval_@double = 50
        pause_interval_@double = 10
    end
    
    properties (Hidden = true, GetAccess = public, SetAccess = public)
        mode_@char = 'realtimemanualtrading'
        replayinterval_@double = 1
    end
    
    properties (Hidden = true, GetAccess = private, SetAccess = private)
        replaytimevec_@double = [];
        replaycount_@double = 0;
    end
        
    methods
        function set.mode_(obj,mode)
            if strcmpi(mode,'realtimeautotrading') || ...
                    strcmpi(mode,'realtimemanualtrading') || ...
                    strcmpi(mode,'replay')
                obj.mode_ = mode;
            else
                error('cTradingSystem:invalid mode,must either be realtimemanualtrading,realtimeautotrading or replay');
            end
        end
    end
    
    
   %% register and counter related methods
    methods
        function [] = registerinstrument(obj,instrument)
            %note: the instrument shall be stored in portfolio_ which can
            %be accessed by strategy_
            if isempty(obj.portfolio_)
                obj.portfolio_ = cPortfolio;
            end
            obj.portfolio_.addinstrument(instrument);
            
            if ~isempty(obj.strat_)
                obj.strat_.registerinstrument(instrument);
            end
            
            if isempty(obj.qms_)
                obj.qms_ = cQMS;
            end
            obj.qms_.registerinstrument(instrument);
        end
        %end of registerinstrument

        function [] = counterlogin(obj,counterstr)
            v = version;
            if isempty(strfind(v,'R2014a'))
                warning('matlab version is not supported for CTP connection');
                return
            end
            
            try
                obj.counter_ = CounterCTP.(counterstr);
                obj.counter_.login;
            catch e
                fprintf([e.message,'\n']);
            end
        end
        %end of counterlogin
        
        function [] = counterlogoff(obj)
            if isempty(obj.counter_)
                return
            end
            try
               obj.counter_.logout;
            catch e
                fprintf([e.message,'\n']);
            end 
        end
        %end of counterlogoff
        
        function flag = isqmsconnect(obj)
            if isempty(obj.qms_)
                flag = false;
                return
            end
            flag = obj.qms_.isconnect;
        end
        %end of isqmsconnect
        
        function flag = iscounterlogin(obj)
            if isempty(obj.counter_)
                flag = false;
            else
                flag = obj.counter_.is_Counter_Login;
            end
        end
        %end of iscounterlogin
        
    end
    
   %% replay mode related methods
    methods
        function [] = switch2relaymode(obj)
            obj.mode_ = 'replay';
            %switch off the counter
            if obj.iscounterlogin
                obj.counter_.logout;
            end
            
            obj.qms_.watcher_.close;
            
            obj.qms_.setdatasource('local');
            
            for i = 1:obj.portfolio_.count
                obj.qms_.registerinstrument(obj.portfolio_.instrument_list{i});
            end
            
            obj.timer_interval_ = 1;    %we run it every one second in replay mode
            
        end
        %end of switch2replaymode
        
        function [] = loadrelaytimevec(obj,fromdate,todate)
            n = obj.portfolio_.count;
            timevec = cell(n,1);
            
            ds = obj.qms_.watcher_.ds; 
            for i = 1:n
                d = ds.intradaybar(obj.portfolio_.instrument_list{i},fromdate,todate,obj.replayinterval_,'trade');
                timevec{i} = d(:,1);
            end
            
            tv = cell2mat(timevec);
            tv = unique(tv);
            obj.replaytimevec_ = tv;           
            
        end
        %end of loadreplay
        
        function [] = replaysimtradeonce(obj)
            %historical simulation of how the trades are conducted
            if ~strcmpi(obj.mode_,'replay'), return; end
            
            %1.generate signals with historical quotes
            ntimevec = length(obj.replaytimevec_);
            if obj.replaycount_ >= ntimevec, warning('replay finished......'); return; end
            
            timestr = datestr(obj.replaytimevec_(obj.replaycount_+1));
            signals = gensignal(obj,timestr);
            obj.replaycount_ = obj.replaycount_ + 1;
            
            printportfolio = false;
            for i = 1:size(signals,1)
                if isempty(signals{i}), continue; end
                instrument = signals{i}.instrument;
                volume = signals{i}.volume;
                if volume == 0, continue; end
                printclass(signals{i}); 
                quote = obj.qms_.getquote(instrument);
                px = quote.last_trade;
                %note for replay mode, we assume entrusts given signals are
                %all fully filled.
                obj.portfolio_.addinstrument(instrument,px,volume);
                printportfolio = true;
            end
            if printportfolio, obj.portfolio_.print; end
            
        end
        %end of replaysimtrade
    end
    
   %% 
   % portfolio related methods
   methods
       function [] = loadportfoliofromcounter(obj)
           if ~obj.iscounterlogin
               warning('cTradingSystem:loadportfoliofromcounter:counter not connected!')
               return
           end
           
           %here we only load positions of the instruments registed with
           %the strategy itself
           if isempty(obj.strat_), return; end
           
           instrument_list = obj.strat_.instruments_.getinstrument;
           n = obj.strat_.count;
           for i = 1:n
               instrument_i = instrument_list{i};
               contract_size = instrument_i.contract_size;
               if strcmpi(instrument_i.asset_name,'govtbond_5y') || strcmpi(instrument_i.asset_name,'govtbond_10y')
                   contract_size = contract_size/100;
               end
               [pos,ret] = obj.counter_.queryPositions(instrument_i.code_ctp);
               if ret
                   px = pos.avg_price/contract_size;
                   volume = pos.total_position;
                   direction = pos.direction;
                   obj.portfolio_.updateinstrument(instrument_i,px,direction*volume);
               end
           end
       end
       %end loadportfoliofromcounter
   end
   
    
   %% 
   % trading related methods
    methods
        function [] = autotrade(obj)
             obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_function,...
                'TimerFcn', @obj.replay_timer_function,...
                'StopFcn',@obj.stop_timer_function,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,10));
            %start timer
            start(obj.timer_); 
        end
        %end autotrade
        
        function [] = manualtradeonce(obj)
            
            if ~obj.iscounterlogin && strcmpi(obj.mode_,'realtimeautotrading')
                warning('cTradingSystem:manualtrade:counter not connected!')
                return
            end
            
            signals = gensignal(obj);

            for i = 1:size(signals,1), printclass(signals{i}); end
            
            %firstly to withdraw any pending orders associated with the
            %instruments the signals have interests of
            obj.withdrawpendingentrusts(signals);
            
            %secondly to place new orders
            entrusts = obj.placenewentrusts(signals);
            for i = 1:entrusts.latest, obj.entrusts_.push(entrusts.node(i)); end    
            
        end
        %end of manualtrade
        
        function [] = stop(obj)
            stop(obj.timer_);
        end
        %end of stop
         
        function signals = gensignal(obj,timestr)
            
            if ~obj.isqmsconnect
                warning('cTradingSystem:gensignal:qms not connected!')
                return
            end
            
            %1st to refresh qms to get the latest quotes
            if nargin < 2
                obj.refreshmarketdata;
            else
                obj.refreshmarketdata(timestr);
            end
            
            quotes = obj.qms_.getquote;
            
            signals = obj.strat_.gensignal(obj.portfolio_,quotes);
            
        end
        %end of gensignal
        
    end
    
   %%
    methods
        function entrusts = placenewentrusts(obj,signals)

            entrusts = EntrustArray;
            
            if strcmpi(obj.mode_,'replay'), return; end
            
            if isempty(obj.strat_), return; end
            
            if ~obj.iscounterlogin
                warning('cTradingSystem:placenewentrusts:counter not connected!')
                return
            end
            
            entrusts = obj.strat_.placenewentrusts(obj.counter_,obj.qms_,obj.portfolio_,signals);
           
        end
    %   end of placenewentrusts
        
        
        function [ret] = withdrawpendingentrusts(obj,signals)
            
            if strcmpi(obj.mode_,'replay'), return; end
            
            if ~obj.iscounterlogin
                warning('cTradingSystem:withdrawpendingentrusts:counter not connected!')
                return
            end

            %note:if new signals are given, the first thing to do is to
            %withdraw all pending entrusts associated with the instruments
            %of the signals
            
            if nargin < 2
                signals = {};
            end
            
            if isempty(signals)
                [~,pendingEntrusts] = statsentrust(obj.counter_);
                nPending = length(pendingEntrusts);
                ret = zeros(nPending,1);
                for i = 1:nPending
                    ret(i) = withdrawentrust(obj.counter_,pendingEntrusts{i});
                end
            else
                ns = length(signals);
                ret = cell(ns);
                for i = ns
                    codestr = signals{i}.instrument;
                    [~,pendingEntrusts] = statsentrust(obj.counter_,codestr);
                    nPending = length(pendingEntrusts);
                    ret_i = zeros(nPending,1);
                    for j = 1:nPending
                        ret_i(j) = withdrawentrust(obj.counter_,pendingEntrusts{j});
                    end
                    ret{i} = ret_i;
                end
            end
        end
        %end of withdrawpendingentrusts
         
    end
    
   %% private methods
    methods (Access = private)
        function [] = replay_timer_function(obj,~,event)
           
            fprintf('\nautotrade conducted on %s......\n',datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'));
            
            if strcmpi(obj.mode_,'replay')
                obj.replaysimtradeonce
            elseif strcmpi(obj.mode_,'realtimeautotrading')
                obj.manualtradeonce;
                %the portfolio shall be updated as this is essential for the
                %strategy to generate correct signals when reading the
                %portfolio
                %maybe here we need to pause couple of seconds,e.g.10 seconds
                pause(obj.pause_interval_);
                obj.loadportfoliofromcounter
            elseif strcmpi(obj.mode_,'realtimemanualtrading')
                %this is the mode we update the signals only and the
                %trading is done via other functions
                %todo
            end
            
        end
        %end of replay_timer_function
        
        function [] = start_timer_function(~,~,event)
            disp([datestr(event.Data.time),' autotrade starts...']);
        end
        %end of start_timer_function
        
        function [] = stop_timer_function(~,~,event)
            disp([datestr(event.Data.time),' autotrade stops...']);
        end
        %end of stop_timer_function
        
        function [] = refreshmarketdata(obj,timestr)
            if nargin < 2
                obj.qms_.refresh;
            else
                obj.qms_.refresh(timestr);
            end
            %
        end
        %end of refresh
        

        
    end
end