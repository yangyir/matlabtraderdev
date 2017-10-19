classdef cMDEFut < handle
    properties
        timer_@timer
        timer_interval_@double = 0.5
        qms_@cQMS
        ticks_@cell
        candles_@cell
        mode_@char = 'realtime'
    end
    
    properties (Access = private)
        ticks_count_@double = 0
        candles_count_@double
    end
    
    methods
        function obj = registerinstrument(obj,instrument)
            codestr = instrument.code_ctp;
            flag = isoptchar(codestr);
            if ~flag, obj.qms_.registerinstrument(instrument);end
        end
        %end of registerinstrument
        
        function [] = start(obj)
            obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_fcn,...
                'TimerFcn', @obj.replay_timer_fcn,...
                'StopFcn',@obj.stop_timer_fcn,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,5));
            start(obj.timer_);
        end
        %end of start
        
        function [] = startat(obj,dtstr)
            obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_fcn,...
                'TimerFcn', @obj.replay_timer_fcn,...
                'StopFcn',@obj.stop_timer_fcn,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,5));
            y = year(dtstr);
            m = month(tstr);
            d = day(tstr);
            hh = hour(tstr);
            mm = minute(tstr);
            ss = second(tstr);
            startat(obj.timer_,y,m,d,hh,mm,ss);
        end
        %end of startat
        
        function [] = stop(obj)
            if isempty(obj.timer_), return; else stop(obj.timer_); end
        end
        %end of stop
        
%         function data = ticks2candle(~,varargin)
%             
%         end
%         %end of ticks2candle
        
        
    end
    
    methods (Access = private)
        function [] = replay_timer_fcn(obj,~,event)
            disp([datestr(event.Data.time),' mde runs......']);
            obj.qms_.refresh;
            obj.saveticks2mem;
            obj.updatecandleinmem;
        end
        %end of replay_timer_function
        
        function [] = start_timer_fcn(~,~,event)
            disp([datestr(event.Data.time),' mde starts......']);
        end
        %end of start_timer_function
        
        function [] = stop_timer_fcn(~,~,event)
            disp([datestr(event.Data.time),' mde stops......']);
        end
        %end of stop_timer_function
        
        function [] = saveticks2mem(obj)
            if isempty(obj.ticks_)
                instruments = obj.qms_.instruments_.getinstrument;
                ns = size(instruments,1);
                n = 1e5;%note:this size shall be enough for day trading
                d = cell(ns,1);
                for i = 1:ns, d{i} = zeros(n,4);end
                obj.ticks_ = d;
            end
            
            qs = obj.qms_.getquote;
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            count = obj.ticks_count_+1;
            for i = 1:ns
                obj.ticks_{i}(count,1) = qs{i}.update_time1;
                obj.ticks_{i}(count,2) = qs{i}.bid1;
                obj.ticks_{i}(count,3) = qs{i}.ask1;
                obj.ticks_{i}(count,4) = qs{i}.last_trade;
            end
            obj.ticks_count_ = count;
        end
        %end of saveticks2men
        
        function [] = updatecandleinmem(obj)
            if isempty(obj.candles_)
                instruments = obj.qms_.instruments_.getinstrument;
                ns = size(instruments,1);
                for i = 1:ns
                    fut = instruments{i};
                    buckets = getintradaybuckets('date',today,...
                        'frequency','1m',...
                        'tradinghours',fut.trading_hours,...
                        'tradingbreak',fut.trading_break);
                    candle_ = [buckets,zeros(size(buckets,1),4)];
                    obj.candles_{i} = candle_;
                end
                obj.candles_count_ = zeros(ns,1);
            end
            
            if isempty(obj.ticks_), return; end
            ns = size(obj.ticks_,1);
            count = obj.ticks_count_;
            for i = 1:ns
                buckets = obj.candles_{i}(:,1);
                t = obj.ticks_{i}(count,1);
                px = obj.ticks_{i}(count,4);
                idx = buckets(1:end-1)<=t & buckets(2:end)>t;
                this_bucket = buckets(idx);
                if ~isempty(this_bucket)
                    this_count = find(buckets == this_bucket);
                    if this_count ~= obj.candles_count_(i)
                        obj.candles_count_(i) = this_count;
                        newset = true;
                    else
                        newset = false;
                    end
                    obj.candles_{i}(this_count,5) = px;
                    if newset
                        obj.candles_{i}(this_count,2) = px;
                        obj.candles_{i}(this_count,3) = px;
                        obj.candles_{i}(this_count,4) = px;
                    else
                        high = obj.candles_{i}(this_count,3);
                        low = obj.candles_{i}(this_count,4);
                        if px > high, obj.candles_{i}(this_count,3) = px; end
                        if px < low, obj.candles_{i}(this_count,4) = px;end
                    end
                end
            end
            
            
        end
        %end of updatecandleinmem
        
    end
    
end