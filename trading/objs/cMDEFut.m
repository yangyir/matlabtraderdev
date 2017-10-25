classdef cMDEFut < handle
    %Note: the class of Market Data Engine for Futures
    %1.it will pop the tick data and process it the candle container
    %jobs: from 9am to 2:30am on the next day, it keeps pop tick data while
    %it sleeps from 1:30pm until 9pm
    %jobs:it saves tick data and candle data on 2:35am in case it trades
    %during the night
    %jobs:it clears its meomery on 3:00am
    %jobs:it inits the required data on 8:30am
    
    properties
        mode_@char = 'realtime'
        status_@char = 'sleep';
        
        timer_@timer
        timer_interval_@double = 0.5
        
        qms_@cQMS
        
        %real-time data
        ticks_@cell
        candles_@cell
        candle_freq_@double
        candles4save_@cell
        
        %historical data
        hist_candles_@cell
        
    end
    
    properties (Access = private)
        ticks_count_@double
        candles_count_@double
        candles4save_count_@double
    end
    
    % candle related methods
    methods
        function obj = setcandlefreq(obj,freq,instrument)
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            if nargin < 3
                for i = 1:ns
                    if obj.candle_freq_(i) ~= freq
                        obj.candle_freq_(i) = freq;
                        fut = instruments{i};
                        buckets = getintradaybuckets2('date',today,...
                            'frequency',[num2str(obj.candle_freq_(i)),'m'],...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        obj.candles_{i} = [buckets,zeros(size(buckets,1),4)];
                    end
                end
                
                return
            end
            
            if ~isa(instrument,'cInstrument')
                error('cMDEFut:getcandlefreq:invalid instrument input')
            end
            
            flag = false;
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    if obj.candle_freq_(i) ~= freq
                        obj.candle_freq_(i) =  freq;
                        fut = instruments{i};
                        buckets = getintradaybuckets2('date',today,...
                            'frequency',[num2str(obj.candle_freq_(i)),'m'],...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        obj.candles_{i} = [buckets,zeros(size(buckets,1),4)];
                    end
                    break
                end
            end
            
            if ~flag, error('cMDEFut:setcandlefreq:instrument not foung'); end
            
        end
        %end of setcandlefreq
        
        function freq_ = getcandlefreq(obj,instrument)
            if nargin < 2
                freq_ = obj.candle_freq_;
                return
            end
            
            if ~isa(instrument,'cInstrument')
                error('cMDEFut:getcandlefreq:invalid instrument input')
            end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
                      
            flag = false;
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    freq_ = obj.candle_freq_(i);
                    break
                end
            end
            
            if ~flag, error('cMDEFut:getcandlefreq:instrument not foung'); end
        end
        %end of getcandlefreq
        
        function n = getcandlecount(obj,instrument)
            if nargin < 2
                n = obj.candles_count_;
                return
            end
            
            if ~isa(instrument,'cInstrument'), error('cMDEFut:getcandlecount:invalid instrument input'); end
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            flag = false;
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    n = obj.candles_count_(i);
                    break
                end
            end
            
            if ~flag, error('cMDEFut:getcandlecount:instrument not found'); end
            
             
        end
        %end of getcandlecount
        
        function candlesticks = getcandles(obj,instrument)
            candlesticks = {};
            if isempty(obj.candles_count_), return; end
            
            if isempty(obj.candles_), return;end

            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            if nargin < 2    
                candlesticks = cell(ns,1);
                counts = obj.getcandlecount;
                for i = 1:ns
                    candlestick = obj.candles_{i};
                    candlestick = candlestick(1:counts(i),:);
                    candlesticks{i} = candlestick;
                end
                return
            end
            
            if ~isa(instrument,'cInstrument'), error('cMDEFut:getcandles:invalid instrument input'); end
            
            
            for i = 1:ns
                if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
                    candlesticks = obj.candles_{i};
                    count_i = obj.getcandlecount(instrument);
                    candlesticks = candlesticks(1:count_i,:);
                    break
                end
            end
            
        end
        %end of getcandles
        
        function candlesticks = getlastcandle(obj,instrument)
            if isempty(obj.candles_count_), return; end
            
            if isempty(obj.candles_), return;end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            counts = obj.getcandlecount;
            
            if nargin < 2    
                candlesticks = cell(ns,1);    
                for i = 1:ns
                    candlestick = obj.candles_{i};
                    if counts(i) > 0
                        candlestick = candlestick(counts(i),:);
                    else
                        candlestick = [];
                    end
                    candlesticks{i} = candlestick;
                end
                return
            end
            
            flag = false;
            for i = 1:ns
                if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
                    flag = true;
                    candlesticks = cell(1,1);
                    candlestick = obj.candles_{i};
                    if counts(i) > 0
                        candlestick = candlestick(counts(i),:);
                    else
                        candlestick = [];
                    end
                    candlesticks{1} = candlestick;
                    break
                end
            end
            
            if ~flag, error('cMDEFut:getlastcandle:instrument not found');end
            
        end
        %end of getlastcandle
        
        function obj = loadhistcandles(obj,instrument,histcandles)
            if ~isa(instrument,'cInstrument'), error('cMDEFut:loadhistcandles:invalid instrument input'); end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            if isempty(obj.hist_candles_), obj.hist_candles_ = cell(ns,1); end
            
            flag = false;
            for i = 1:ns
                if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
                    flag = true;
                    obj.hist_candles_{i} = histcandles;
                    break
                end
            end
            if ~flag, error('cMDEFut:loadhistcandles:instrument not found'); end
        end
        %end of loadhistcandles
        
        function histcandles = gethistcandles(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cMDEFut:gethistcandles:invalid instrument input')
            end
            
            if isempty(obj.hist_candles_), return; end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            flag = false;
            for i = 1:ns
                if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
                    flag = true;
                    histcandles = obj.hist_candles_{i};
                    break
                end
            end
            
            if ~flag, error('cMDEFut:gethistcandles:instrument not found');end
        end
        %end of gethistcandles
        
        function [ret] = initcandles(obj,instrument)
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            ds = cBloomberg;
            if nargin < 2
                for i = 1:ns
                    date2 = floor(obj.candles_{i}(1,1));
                    %intraday candles for the last 10 business dates
                    date1 = date2 - 14;
                    date2str = [datestr(date2,'yyyy-mm-dd'),' 08:59:00'];
                    date1str = [datestr(date1,'yyyy-mm-dd'),' 09:00:00'];
                    candles = ds.intradaybar(instruments{i},date1str,date2str,obj.candle_freq_(i),'trade');
                    obj.hist_candles_{i} = candles;
                    
                    %fill the live candles in case it is missing
                    t = now;
                    buckets = obj.candles_{i}(:,1);
                    idx = find(buckets<=t);
                    if isempty(idx)
                        
                    else
                        idx = idx(end);
                        candles = ds.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx)),obj.candle_freq_(i),'trade');
                        for j = 1:size(candles,1)
                            obj.candles_{i}(j,2:end) = candles(j,2:end);
                        end
                    end
                    
                end
                ret = true;
                return
            end
            
            if ~isa(instrument,'cInstrument'), error('cMDEFut:initcandles:invalid instrument input');end
            flag = false;
            for i = 1:ns
                if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
                    flag = true;
                    date2 = floor(obj.candles_{i}(1,1));
                    %intraday candles for the last 10 business dates
                    date1 = date2 - 14;
                    date2str = [datestr(date2,'yyyy-mm-dd'),' 08:59:00'];
                    date1str = [datestr(date1,'yyyy-mm-dd'),' 09:00:00'];
                    candles = ds.intradaybar(instruments{i},date1str,date2str,obj.candle_freq_(i),'trade');
                    obj.hist_candles_{i} = candles;
                    t = now;
                    buckets = obj.candles_{i}(:,1);
                    idx = find(buckets<=t);
                    if isempty(idx)
                    else
                        idx = idx(end);
                        candles = ds.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx)),obj.candle_freq_(i),'trade');
                        for j = 1:size(candles,1)
                            obj.candles_{i}(j,2:end) = candles(j,2:end);
                        end
                    end
                    ret = true;
                    break
                end
            end
            if ~flag, error('cMDEFut:initcandles:instrument not found'); end
        end
        %end of initcandles
        
    end
    
    %%
    methods
        function indicators = calc_technical_indicator(obj,name,instrument,varargin)
            switch lower(name)
                case 'william %r'
                    indicators = calc_wr_(obj,instrument,varargin{:});
                otherwise
                    error('cMDEFut:calc_technical_indicator:invalid technical indicator name')
            end
        end
        % end of calc_technical_indicators
    end
    
    %%
    
    methods
        function obj = registerinstrument(obj,instrument)
            codestr = instrument.code_ctp;
            flag = isoptchar(codestr);
            if ~flag, obj.qms_.registerinstrument(instrument);end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            % init memory candles
            if isempty(obj.candle_freq_)
                %default value of candle frequency is one minute
                obj.candle_freq_ = ones(ns,1);
            else
                ns_ = size(obj.candle_freq_,1);
                if ns_ ~= ns
                    freqs_ = ones(ns,1);
                    freqs_(1:ns_) = obj.candle_freq_;
                    %default value of candle frequency is one minute
                    freqs_(ns_+1:ns) = 1;
                    obj.candle_freq_ = freqs_;
                end  
            end
            
            if isempty(obj.candles_count_)
                obj.candles_count_ = zeros(ns,1);
            else
                ns_ = size(obj.candles_count_,1);
                if ns_ ~= ns
                    count_ = zeros(ns,1);
                    count_(1:ns_) = obj.candles_count_;
                    count_(ns_+1:ns) = 0;
                    obj.candles_count_ =  count_;
                end
            end
            
            if isempty(obj.candles_)
                obj.candles_ = cell(ns,1);
                for i = 1:ns
                    fut = instruments{i};
                    buckets = getintradaybuckets2('date',today,...
                        'frequency',[num2str(obj.candle_freq_(i)),'m'],...
                        'tradinghours',fut.trading_hours,...
                        'tradingbreak',fut.trading_break);
                    candle_ = [buckets,zeros(size(buckets,1),4)];
                    obj.candles_{i} = candle_;
                end
            else
                ns_ = size(obj.candles_,1);
                candles = cell(ns,1);
                if ns_ ~= ns
                    for i = 1:ns_, candles{i} = obj.candles_{i};end
                    for i = ns_+1:ns
                        fut = instruments{i};
                        buckets = getintradaybuckets2('date',today,...
                            'frequency',[num2str(obj.candle_freq_(i)),'m'],...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        candles{i} = [buckets,zeros(size(buckets,1),4)];
                    end
                    obj.candles_ = candles;
                end
            end
            
            %for candles4save_
            if isempty(obj.candles4save_count_)
                obj.candles4save_count_ = zeros(ns,1);
            else
                ns_ = size(obj.candles4save_count_,1);
                if ns_ ~= ns
                    count_ = zeros(ns,1);
                    count_(1:ns_) = obj.candles4save_count_;
                    count_(ns_+1:ns) = 0;
                    obj.candles4save_count_ =  count_;
                end
            end
            
            if isempty(obj.candles4save_)
                obj.candles4save_ = cell(ns,1);
                for i = 1:ns
                    fut = instruments{i};
                    buckets = getintradaybuckets2('date',today,...
                        'frequency','1m',...
                        'tradinghours',fut.trading_hours,...
                        'tradingbreak',fut.trading_break);
                    obj.candles4save_{i} = [buckets,zeros(size(buckets,1),4)];
                end
            else
                ns_ = size(obj.candles4save_,1);
                candles = cell(ns,1);
                if ns_ ~= ns
                    for i = 1:ns_, candles{i} = obj.candles4save_{i};end
                    for i = ns_+1:ns
                        fut = instruments{i};
                        buckets = getintradaybuckets2('date',today,...
                            'frequency','1m',...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        candles{i} = [buckets,zeros(size(buckets,1),4)];
                    end
                    obj.candles4save_ = candles;
                end
            end
            
            % init memory for ticks
            if isempty(obj.ticks_)
                n = 1e5;%note:this size shall be enough for day trading
                d = cell(ns,1);
                for i = 1:ns, d{i} = zeros(n,4);end
                obj.ticks_ = d;
            else
                ns_ = size(obj.ticks_,1);
                if ns_ ~= ns
                    ticks = cell(ns,1);
                    for i = 1:ns_, ticks{i} = obj.ticks_{i}; end
                    ticks{ns} = zeros(1e5,4);
                    obj.ticks_ = ticks;
                end
            end
            
            if isempty(obj.ticks_count_)
                obj.ticks_count_ = zeros(ns,1);
            else
                ns_ = size(obj.ticks_count_);
                if ns_ ~= ns
                    ticks_count = zeros(ns,1);
                    ticks_count(1:ns_,:) = obj.ticks_count_;
                    ticks_count(ns_+1:ns) = 0;
                    obj.ticks_count_ = ticks_count;
                end 
            end
            
        end
        %end of registerinstrument
        
        function [] = refresh(obj)
            if ~isempty(obj.qms_)
                obj.qms_.refresh;
                obj.saveticks2mem;
                obj.updatecandleinmem;
            end
        end
        %end of refresh
        
        function [] = start(obj)
            obj.status_ = 'working';
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
            obj.status_ = 'working';
            obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_fcn,...
                'TimerFcn', @obj.replay_timer_fcn,...
                'StopFcn',@obj.stop_timer_fcn,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,5));
            y = year(dtstr);
            m = month(dtstr);
            d = day(dtstr);
            hh = hour(dtstr);
            mm = minute(dtstr);
            ss = second(dtstr);
            startat(obj.timer_,y,m,d,hh,mm,ss);
        end
        %end of startat
        
        function [] = stop(obj)
            obj.status_ = 'sleep';
            if isempty(obj.timer_), return; else stop(obj.timer_); end
        end
        %end of stop
        
    end
    
    methods (Access = private)
        function [] = replay_timer_fcn(obj,~,event)
            if strcmpi(obj.mode_,'realtime')
                dtnum = datenum(event.Data.time);
                hh = hour(dtnum);
                mm = minute(dtnum) + hh*60;
                if (mm > 150 && mm < 540) || ...
                        (mm > 690 && mm < 780 ) || ...
                        (mm > 915 && mm < 1260)
                    %market closed for sure
                    return
                end
            end
            
            if strcmpi(obj.mode_,'realtime')
                obj.refresh;
            else
                %for replay mode
            end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            indicators = zeros(ns,1);
            for i = 1:ns
                ti = obj.calc_technical_indicator('William %R',instruments{i},'NumOfPeriods',144);
                indicators(i) = ti(end);
                fprintf('%s William %%R of %s:%4.2f\n',datestr(event.Data.time),instruments{i}.code_ctp,indicators(i));
            end
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
        
    end
    
    %% market data update
    methods (Access = private)
        
        function [] = saveticks2mem(obj)
            qs = obj.qms_.getquote;
            ns = size(obj.ticks_,1);
            for i = 1:ns
                count = obj.ticks_count_(i)+1;
                obj.ticks_{i}(count,1) = qs{i}.update_time1;
                obj.ticks_{i}(count,2) = qs{i}.bid1;
                obj.ticks_{i}(count,3) = qs{i}.ask1;
                obj.ticks_{i}(count,4) = qs{i}.last_trade;
                obj.ticks_count_(i) = count;
            end
        end
        %end of saveticks2men
        
        function [] = updatecandleinmem(obj)
            if isempty(obj.ticks_), return; end
            ns = size(obj.ticks_,1);
            count = obj.ticks_count_;
            for i = 1:ns
                buckets = obj.candles_{i}(:,1);
                buckets4save = obj.candles4save_{i}(:,1);
                t = obj.ticks_{i}(count(i),1);
                px_trade = obj.ticks_{i}(count(i),4);
                idx = buckets(1:end-1)<=t & buckets(2:end)>t;
                idx4save = buckets4save(1:end-1)<=t & buckets4save(2:end)>t;
                this_bucket = buckets(idx);
                this_bucket_save = buckets4save(idx4save);
                %
                if ~isempty(this_bucket)
                    this_count = find(buckets == this_bucket);
                    if this_count ~= obj.candles_count_(i)
                        obj.candles_count_(i) = this_count;
                        newset = true;
                    else
                        newset = false;
                    end
                    obj.candles_{i}(this_count,5) = px_trade;
                    if newset
                        obj.candles_{i}(this_count,2) = px_trade;   %px_open
                        obj.candles_{i}(this_count,3) = px_trade;   %px_high
                        obj.candles_{i}(this_count,4) = px_trade;   %px_low
                    else
                        high = obj.candles_{i}(this_count,3);
                        low = obj.candles_{i}(this_count,4);
                        if px_trade > high, obj.candles_{i}(this_count,3) = px_trade; end
                        if px_trade < low, obj.candles_{i}(this_count,4) = px_trade;end
                    end
                end
                %
                if ~isempty(this_bucket_save)
                    this_count_save = find(buckets4save == this_bucket_save);
                    if this_count_save ~= obj.candles4save_count_(i)
                        obj.candles4save_count_(i) = this_count_save;
                        newset = true;
                    else
                        newset = false;
                    end
                    obj.candles4save_{i}(this_count_save,5) = px_trade;
                    if newset
                        obj.candles4save_{i}(this_count_save,2) = px_trade;   %px_open
                        obj.candles4save_{i}(this_count_save,3) = px_trade;   %px_high
                        obj.candles4save_{i}(this_count_save,4) = px_trade;   %px_low
                    else
                        high = obj.candles4save_{i}(this_count_save,3);
                        low = obj.candles4save_{i}(this_count_save,4);
                        if px_trade > high, obj.candles4save_{i}(this_count_save,3) = px_trade; end
                        if px_trade < low, obj.candles4save_{i}(this_count_save,4) = px_trade;end
                    end
                end
                %
            end
        end
        %end of updatecandleinmem
        
    end

    
    %% techinical indicator caculation
    methods (Access = private)
        % William %R
        function indicators = calc_wr_(obj,instrument,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
            p.addParameter('NumOfPeriods',{},...
                @(x) validateattributes(x,{'numeric'},{},'','NumOfPeriods'));
            p.parse(instrument,varargin{:});
            instrument = p.Results.Instrument;
            nperiods = p.Results.NumOfPeriods;
            
            histcandles = obj.gethistcandles(instrument);
            candlesticks = obj.getcandles(instrument);
            
            highp = [histcandles(:,3);candlesticks(:,3)];
            lowp = [histcandles(:,4);candlesticks(:,4)];
            closep = [histcandles(:,5);candlesticks(:,5)];
            
            indicators = willpctr(highp,lowp,closep,nperiods);
            
        end
        %end of calc_wr_
    end
end