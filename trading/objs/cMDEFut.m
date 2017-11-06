classdef cMDEFut < handle
    %Note: the class of Market Data Engine for Futures
    %1.it will pop the tick data and process it the candle container
    %jobs: from 9am to 2:30am on the next day, it keeps pop tick data while
    %it sleeps from 1:30pm until 9pm
    %jobs:it saves tick data and candle data on 2:31am in case it trades
    %during the night and it clears its meomery afterawards
    %jobs:it inits the required data on 8:50am
    
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
        candlesaveflag_@logical = false
        
        %historical data,which is used for technical indicator calculation
        hist_candles_@cell
        
        technical_indicator_autocalc_@double
        technical_indicator_table_@cell
        
        %replay related properties
        replay_date1_@double
        replay_date2_@char
        replay_datetimevec_@double
        replay_count_@double = 0
        
        %debug related properties
        %note:debug and replay mode are very similar but debug mode is much
        %faster
        debug_start_dt1_@double
        debug_start_dt2_@char
        debug_end_dt1_@double
        debug_end_dt2_@char
        debug_count_@double = 0
        debug_ticks_@double
        
        
    end
    
    properties (Access = private)
        ticks_count_@double
        candles_count_@double
        candles4save_count_@double
    end
    
    %% replay related functions
    methods
        function obj = setreplaydate(obj,datein)
            obj.mode_ = 'replay';
            if isnumeric(datein)
                obj.replay_date1_ = datein;
                obj.replay_date2_ = datestr(datein);
            elseif ischar(datein)
                obj.replay_date1_ = datenum(datein);
                obj.replay_date2_ = datein;
            end
            %
            %the replay time vector is on the same date as of the replay
            %date and it starts from 9am and ends until 2:30am on the next
            %calendar date
            dtstart = [obj.replay_date2_,' 09:00:00'];
            dtend = [datestr(obj.replay_date1_+1),' 02:30:00'];
            obj.replay_datetimevec_ = gendatetime(dtstart,dtend,struct('num',1,'str','m'));
            obj.replay_count_ = 0;
        end
        % end of setreplaydate
        
    end
    
    %% candle related methods
    methods
        function obj = setcandlefreq(obj,freq,instrument)
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            if strcmpi(obj.mode_,'realtime')
                cobdate = today;
            else
                cobdate = obj.replay_date1_;
            end
            
            if nargin < 3
                for i = 1:ns
                    if obj.candle_freq_(i) ~= freq
                        obj.candle_freq_(i) = freq;
                        fut = instruments{i};
                        buckets = getintradaybuckets2('date',cobdate,...
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
                        buckets = getintradaybuckets2('date',cobdate,...
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
            n = 0;
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
                    if ~strcmpi(obj.mode_,'debug')
                        t = now;
                        buckets = obj.candles_{i}(:,1);
                        idx = find(buckets<=t);
                        if isempty(idx)
                            %todo:here we shall return an error
                        else
                            idx = idx(end);
                            obj.candles_count_(i) = idx;
                            candles = ds.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx+1)),obj.candle_freq_(i),'trade');
                            for j = 1:size(candles,1)
                                obj.candles_{i}(j,2:end) = candles(j,2:end);
                            end
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
                        %todo:here we shall return an error
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
        
        function tick = getlasttick(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cMDEFut:getlasttick:invalid instrument input')
            end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            flag = false;
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    ticks = obj.ticks_{i};
                    if obj.ticks_count_ > 0
                        tick = ticks(obj.ticks_count_(i),:);
                    else
                        tick = [];
                    end
                    flag = true;
                    break
                end
            end
            
            if ~flag
                error('cMDEFut:getlaststick:instrument not found')
            end
        end
        %end of getlasttick
        
    end
    
    %% technical indicator interface function
    methods
        function [] = settechnicalindicator(obj,instrument,indicators)
            if ~isa(instrument,'cInstrument')
                error('cMDEFut:settechnicalindicator:invalid instrument input')
            end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            flag = false;
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    if iscell(indicators)
                        obj.technical_indicator_table_{i} = indicators;
                    else
                        obj.technical_indicator_table_{i} = {indicators};
                    end
                    break
                end
            end
            if ~flag
                error('cMDEFut:settechnicalindicator:instrument not found')
            end
            
        end
        %end of settechnicalindicator
        
        function [] = settechnicalindicatorautocalc(obj,instrument,calcflag)
            if ~isa(instrument,'cInstrument')
                error('cMDEFut:settechnicalindicatorautocalc:invalid instrument input')
            end
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            flag = false;
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    obj.technical_indicator_autocalc_(i) = calcflag;
                    break
                end
            end
            if ~flag
                error('cMDEFut:settechnicalindicatorautocalc:instrument not found')
            end
        end
        %end of settechnicalindicatorautocalc
        
        function indicators = calc_technical_indicators(obj,instrument)
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            for i = 1:ns
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    tbl = obj.technical_indicator_table_{i};
                    if isempty(tbl)
                        indicators = [];
                        return;
                    end
                    indicators = ones(size(tbl,1),1);
                    for j = 1:size(tbl,1)
                        name = tbl{j}.name;
                        val = tbl{j}.values;
                        switch lower(name)
                            case 'williamr'
                                wr = calc_wr_(obj,instrument,val{:});
                                indicators(j) = wr(end);
                            otherwise
                        end
                    end
                    break
                end
            end
            
        end
        % end of calc_technical_indicators
    end
    
    %% register functions
    methods
        function obj = registerinstrument(obj,instrument)
            codestr = instrument.code_ctp;
            flag = isoptchar(codestr);
            %first to make sure that it is not an option underlier
            if flag, return; end
            
            obj.qms_.registerinstrument(instrument);
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            
            %init memory for technical_indicator_table_
            if isempty(obj.technical_indicator_table_)
                obj.technical_indicator_table_ = cell(ns,1);
            else
                ns_ = size(obj.technical_indicator_table_,1);
                if ns_ ~= ns
                    titable = cell(ns,1);
                    for i = 1:ns_, titable{i} = obj.technical_indicator_table_{i};end
                end
            end
            
            %init of technical_indicator_autocalc_
            if isempty(obj.technical_indicator_autocalc_)
                obj.technical_indicator_autocalc_ = zeros(ns,1);
            else
                ns_ = size(obj.technical_indicator_autocalc_,1);
                if ns_ ~= ns
                    autocalc = zeros(ns,1);
                    autocalc(1:ns_) = obj.technical_indicator_autocalc_;
                    autocalc(ns_+1:ns) = 0;
                    obj.technical_indicator_autocalc_ = autocalc;
                end
            end
            
            % init of candle freq
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
            
            % init of candles_count
            if isempty(obj.candles_count_)
                %default value of candles count is zero
                obj.candles_count_ = zeros(ns,1);
            else
                ns_ = size(obj.candles_count_,1);
                if ns_ ~= ns
                    count_ = zeros(ns,1);
                    count_(1:ns_) = obj.candles_count_;
                    %default value of candles count is zero
                    count_(ns_+1:ns) = 0;
                    obj.candles_count_ =  count_;
                end
            end
            
            % init of candles
            if strcmpi(obj.mode_,'realtime')
                cobdate = today;
            else
                cobdate = obj.replay_date1_;
            end
            
            if isempty(obj.candles_)
                obj.candles_ = cell(ns,1);
                for i = 1:ns
                    fut = instruments{i};
                    buckets = getintradaybuckets2('date',cobdate,...
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
                        buckets = getintradaybuckets2('date',cobdate,...
                            'frequency',[num2str(obj.candle_freq_(i)),'m'],...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        candles{i} = [buckets,zeros(size(buckets,1),4)];
                    end
                    obj.candles_ = candles;
                end
            end
            
            %init candles4save_count_
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
            
            %init candles4save_
            if isempty(obj.candles4save_)
                obj.candles4save_ = cell(ns,1);
                for i = 1:ns
                    fut = instruments{i};
                    buckets = getintradaybuckets2('date',cobdate,...
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
                        buckets = getintradaybuckets2('date',cobdate,...
                            'frequency','1m',...
                            'tradinghours',fut.trading_hours,...
                            'tradingbreak',fut.trading_break);
                        candles{i} = [buckets,zeros(size(buckets,1),4)];
                    end
                    obj.candles4save_ = candles;
                end
            end
            
            % init ticks_
            if isempty(obj.ticks_)
                n = 1e5;%note:this size shall be enough for day trading
                d = cell(ns,1);
                for i = 1:ns, d{i} = zeros(n,7);end
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
            
            % init ticks_count_
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
                if strcmpi(obj.mode_,'realtime')
                    obj.qms_.refresh;
                elseif strcmpi(obj.mode_,'replay')
                    n = min(obj.replay_count_,size(obj.replay_datetimevec_,1));
                    tnum = obj.replay_datetimevec_(n);
                    obj.qms_.refresh(datestr(tnum));
                elseif strcmpi(obj.mode_,'debug')
                    obj.debug_count_ = obj.debug_count_ + 1;
                end
                %save ticks data into memory
                obj.saveticks2mem;
                %save candles data into memory
                obj.updatecandleinmem;
                
            end
        end
        %end of refresh
        
        function [] = savecandles2file(obj)
            if ~obj.candlesaveflag_
                fprintf('save candles on %s......\n',datestr(dtnum));
                coldefs = {'datetime','open','high','low','close'};
                dir_ = getenv('DATAPATH');
                
                instruments = obj.qms_.instruments_.getinstrument;
                ns = size(instruments,1);
                
                for i = 1:ns
                    code_ctp = instruments{i}.code_ctp;
                    bd = obj.candles4save_{i}(1,1);
                    dir_data_ = [dir_,'intradaybar\',code_ctp,'\'];
                    fn_ = [dir_data_,code_ctp,'_',datestr(bd,'yyyymmdd'),'_1m.txt'];
                    cDataFileIO.saveDataToTxtFile(fn_,obj.candles4save_{i},coldefs,'w',true);
                end
                
                obj.candlesaveflag_ = true;
                %and clear the ticks and candles from memoery
                obj.ticks_ = {};
                obj.ticks_count_ = zeros(ns,1);
                
                obj.candles_ = {};
                obj.candles4save_ = {};
                obj.candles_count_ = zeros(ns,1);
                
                if ~isempty(obj.hist_candles_), obj.hist_candles_ = {};end
                
                obj.status_ = 'sleep';
            end
        end
        
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
    
    %% timer functions
    methods (Access = private)
        function [] = replay_timer_fcn(obj,~,event)
            if strcmpi(obj.mode_,'realtime')
                dtnum = datenum(event.Data.time);
            elseif strcmpi(obj.mode_,'replay')
                obj.replay_count_ = obj.replay_count_+1;
                n = min(obj.replay_count_,size(obj.replay_datetimevec_,1));
                dtnum = obj.replay_datetimevec_(n);
                fprintf('replay time %s\n',datestr(dtnum));
            end
            
            hh = hour(dtnum);
            mm = minute(dtnum) + hh*60;
            
            %for friday evening market
            if isholiday(floor(dtnum))
                if weekday(dtnum) == 7 && mm >= 180
                    obj.status_ = 'sleep';
                    return
                elseif weekday(dtnum) == 7 && mm < 180
                    %do nothing
                else
                    obj.status_ = 'sleep';
                    return
                end
            end
            
            if (mm > 150 && mm < 540) || ...
                    (mm > 690 && mm < 780 ) || ...
                    (mm > 915 && mm < 1260)
                %market closed for sure
                
                % save candles on 2:31am
                if mm == 151
                    obj.savecandles2file;
                end
                
                %init the required data on 8:50
                if obj.candlesaveflag_ && mm == 530
                    fprintf('init candles on %s......\n',datestr(dtnum));
                    instruments = obj.qms_.instruments_.getinstrument;
                    ns = size(instruments,1);
                    for i = 1:ns
                        freq = obj.getcandlefreq(instruments{i});
                        obj.setcandlefreq(freq,instruments{i});
                    end
                    
                    obj.candlesaveflag_ = false;
                    obj.initcandles;
                    obj.status_ = 'working';
                end
                
                return
            end
            
            obj.refresh;
            
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            indicators = zeros(ns,1);
            for i = 1:ns
                if obj.technical_indicator_autocalc_(i)
                    ti = obj.calc_technical_indicators(instruments{i});
                    if ~isempty(ti)
                        indicators(i) = ti(end);
                        fprintf('%s %s of %s:%4.2f\n',datestr(event.Data.time),...
                            instruments{i}.code_ctp,...
                            obj.technical_indicator_table_{i}.name,...
                            indicators(i));
                    end
                end
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
            if ~strcmpi(obj.mode_,'debug')
                qs = obj.qms_.getquote;
                ns = size(obj.ticks_,1);
                for i = 1:ns
                    count = obj.ticks_count_(i)+1;
                    obj.ticks_{i}(count,1) = qs{i}.update_time1;
                    obj.ticks_{i}(count,2) = qs{i}.bid1;
                    obj.ticks_{i}(count,3) = qs{i}.ask1;
                    obj.ticks_{i}(count,4) = qs{i}.last_trade;
                    if ~isempty(qs{i}.yield_last_trade)
                        obj.ticks_{i}(count,5) = qs{i}.yield_last_trade;
                        obj.ticks_{i}(count,6) = qs{i}.yield_bid1;
                        obj.ticks_{i}(count,7) = qs{i}.yield_ask1;
                    end
                    obj.ticks_count_(i) = count;
                end
            else
                ns = size(obj.ticks_,1);
                if ns ~= 1
                    error('only single instrument is supported in debug mode')
                end
                count = obj.ticks_count_(1)+1;
                obj.ticks_{1}(count,1) = obj.debug_ticks_(obj.debug_count_,1);
                obj.ticks_{1}(count,2) = obj.debug_ticks_(obj.debug_count_,2);
                obj.ticks_{1}(count,3) = obj.debug_ticks_(obj.debug_count_,2);
                obj.ticks_{1}(count,4) = obj.debug_ticks_(obj.debug_count_,2);
                obj.ticks_count_(1) = count;
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
                else
                    if t >= buckets(end) && t < buckets(end)+buckets(end)-buckets(end-1)
                        this_count = size(buckets,1);
                    else
                        this_count = [];
                    end
                end
                
                if ~isempty(this_count)
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
                else
                    if t >= buckets4save(end) && t < buckets4save(end)+buckets4save(end)-buckets4save(end-1)
                        this_count_save = size(buckets4save,1);
                    else
                        this_count_save = [];
                    end
                end
                
                if ~isempty(this_count_save)
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
            p.addParameter('NumOfPeriods',144,...
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