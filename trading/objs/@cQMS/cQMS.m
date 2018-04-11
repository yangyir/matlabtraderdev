classdef cQMS < handle
    %class of quotes management system (QMS)
    properties
%         regulartimer_@timer
%         regulartimer_interval_@double = 60
        instruments_@cInstrumentArray
        watcher_@cWatcher
    
    end
    
    methods
%         function [] = start(self)
%            % init timer
%             self.regulartimer_ = timer('Period', self.regulartimer_interval_,...
%                 'StartFcn',@self.start_timer_function,...
%                 'TimerFcn', @self.replay_timer_function,...
%                 'StopFcn',@self.stop_timer_function,...
%                 'BusyMode', 'drop',...
%                 'ExecutionMode', 'fixedSpacing',...
%                 'StartDelay', min(self.regulartimer_interval_,10));
%             %start timer
%             start(self.regulartimer_); 
%         end
%         %end of start
%         
%         function [] = stop(self)
%             if isempty(self.regulartimer_)
%                 return;
%             else
%                 stop(self.regulartimer_);
%             end
%         end
%         %end of stop
        
        flag = isconnect(obj)
        [] = setdatasource(self,connstr)
        [] = registerinstrument(self,instrument)
        [] = removeinstrument(self,instrument)
        [] = refresh(self,timestr)
        quote = getquote(self,instrument)
        
    end
    
%     methods (Access = private)
%         function [] = replay_timer_function(self,~,event)
% 
%             self.refresh;
%             
%             fprintf('\nQMS refreshed on %s......\n',datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'));
%             
%             quotes = self.watcher_.qs;
%             for i = 1:size(quotes,1);
%                 quotes{i}.print;
%             end
%         end
%         %end of replay_timer_function
%         
%         function [] = start_timer_function(~,~,event)
%             disp([datestr(event.Data.time),' qms timer starts...']);
%         end
%         %end of start_timer_function
%         
%         function [] = stop_timer_function(~,~,event)
%             disp([datestr(event.Data.time),' qms timer stops...']);
%         end
%         %end of stop_timer_function
%     end
    
end