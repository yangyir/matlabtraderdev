classdef cQMS < handle
    %class of quotes management system (QMS)
    properties
        regulartimer_@timer
        regulartimer_interval_@double = 60
        instruments_@cInstrumentArray
        watcher_@cWatcher
    
    end
    
    methods
        function [] = start(self)
           % init timer
            self.regulartimer_ = timer('Period', self.regulartimer_interval_,...
                'StartFcn',@self.start_timer_function,...
                'TimerFcn', @self.replay_timer_function,...
                'StopFcn',@self.stop_timer_function,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(self.regulartimer_interval_,10));
            %start timer
            start(self.regulartimer_); 
        end
        %end of start
        
        function [] = stop(self)
            if isempty(self.regulartimer_)
                return;
            else
                stop(self.regulartimer_);
            end
        end
        %end of stop
        
        function flag = isconnect(obj)
            if isempty(obj.watcher_)
                flag = false;
            else
                flag = obj.watcher_.isconnect;
            end
        end
        %end of isconnect
        
        function [] = setdatasource(self,connstr)
            if ~(strcmpi(connstr,'bloomberg') || ...
                    strcmpi(connstr,'wind') || ...
                    strcmpi(connstr,'ctp') || ...
                    strcmpi(connstr,'local')) 
                error('cQMS:setdatasource:invalid datasource string')
            end
                     
            if isempty(self.watcher_)
                self.watcher_ = cWatcher;
            end
            self.watcher_.conn = connstr;
            
        end
        %end of setdatasource
        
        function [] = registerinstrument(self,instrument)
            
            if isempty(self.instruments_)
                self.instruments_ = cInstrumentArray;
            end
            
            if isempty(self.watcher_)
                self.watcher_ = cWatcher;
            end
            
            self.instruments_.addinstrument(instrument);
            
            self.watcher_.addsingle(instrument.code_ctp);
            
        end
        %end of addinstrument
        
        function [] = removeinstrument(self,instrument)

            if isempty(self.instruments_)
                return
            end
            
            if isempty(self.watcher_)
                return
            end

            self.instruments_.removeinstrument(instrument);
            
            self.watcher_.removesingle(instrument.code_ctp);
            
        end
        %end of removeinstrument
        
        function [] = refresh(self,timestr)
            if nargin <= 1
                self.watcher_.refresh;
            else
                self.watcher_.refresh(timestr);
            end
        end
        %end of refresh
        
        function quote = getquote(self,instrument)
            if nargin < 2
                quote = self.watcher_.qs;
                return
            end
            
            for i = 1:size(self.watcher_.qs,1)
                if strcmpi(instrument.code_ctp,self.watcher_.qs{i}.code_ctp)
                    idx = i;
                    break
                end
            end
            
%             [flag, idx] = self.watcher_.hassingle(instrument.code_ctp);
            if idx == 0
                quote = {};
            else
                quote = self.watcher_.qs{idx};
            end
        end
        %end of getquote
        
    end
    
    methods (Access = private)
        function [] = replay_timer_function(self,~,event)

            self.refresh;
            
            fprintf('\nQMS refreshed on %s......\n',datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'));
            
            quotes = self.watcher_.qs;
            for i = 1:size(quotes,1);
                quotes{i}.print;
            end
        end
        %end of replay_timer_function
        
        function [] = start_timer_function(~,~,event)
            disp([datestr(event.Data.time),' qms timer starts...']);
        end
        %end of start_timer_function
        
        function [] = stop_timer_function(~,~,event)
            disp([datestr(event.Data.time),' qms timer stops...']);
        end
        %end of stop_timer_function
    end
    
end