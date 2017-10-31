classdef cStratFutMultiWR < cStrat
    
    properties
        %strategy related 
        numofperiods_@double
        tradingfreq_@double
        overbought_@double
        oversold_@double
        wr_@double                  %william%R 
        
        %timer
        timer_@timer
        timer_interval_@double = 0.5
        
        %size related
        baseunits_@double
        maxunits_@double
    
    end
    
    methods
        function obj = cStratFutMultiWR
            obj.name_ = 'multiplewr';
        end
        %end of cStratFutMultiWR
    end
    
    methods
        function [] = registerinstrument(obj,instrument)
            %registerinstrument of superclass
            registerinstrument@cStrat(obj,instrument);
            
            %numofperiods_
            if isempty(obj.numofperiods_)
                obj.numofperiods_ = 144*ones(obj.count,1); 
                params = struct('numofperiods',144);
                obj.setparameters(instrument,params);
            else
                if size(obj.numofperiods_) < obj.count
                    obj.numofperiods_ = [obj.numofperiods_;144];
                    params = struct('numofperiods',144);
                    obj.setparameters(instrument,params);
                end
            end
            
            %tradingfreq_
            if isempty(obj.tradingfreq_)
                obj.tradingfreq_ = ones(obj.count,1);
                obj.settradingfreq(instrument,1);
            else
                if size(obj.tradingfreq_) < obj.count
                    obj.tradingfreq_ = [obj.tradingfreq_;1];
                    obj.settradingfreq(instrument,1);
                end
            end
            
            %overbought_
            if isempty(obj.overbought_)
                obj.overbought_ = zeros(obj.count,1);
            else
                if size(obj.overbought_) < obj.count
                    obj.overbought_ = [obj.overbought_;0];
                end
            end
            
            %oversold_
            if isempty(obj.oversold_)
                obj.oversold_ = -100*ones(obj.count,1);
            else
                if size(obj.oversold_) < obj.count
                    obj.oversold_ = [obj.oversold_;-100];
                end
            end
            
            %william %r
            if isempty(obj.wr_)
                obj.wr_ = NaN(obj.count,1);
            else
                if size(obj.wr_) < obj.count
                    obj.wr_ = [obj.wr_;NaN];
                end
            end
            
            %baseunits
            if isempty(obj.baseunits_)
                obj.baseunits_ = ones(obj.count,1);
            else
                if size(obj.baseunits_) < obj.count
                    obj.baseunits_ = [obj.baseunits_;1];
                end
            end
            
            %maxunits
            if isempty(obj.maxunits_)
                obj.maxunits_ = 16*ones(obj.count,1);
            else
                if size(obj.maxunits_) < obj.count
                    obj.maxunits_ = [obj.maxunits_;1];
                end
            end
            
        end
        %end of registerinstrument
        
        function [] = setparameters(obj,instrument,params)
            if isempty(obj.numofperiods_), obj.numofperiods_ = 144*ones(obj.count,1); end
            
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:setparameters:invalid instrument input')
            end
            
            if ~isstruct(params)
                error('cStratFutMultiWR:setparameters:invalid params input')
            end
            
            instruments = obj.instruments_.getinstrument;
            flag = false;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    break
                end
            end
            if ~flag
                error('cStratFutMultiWR:setparameters:instrument not found')
            end
            
            propnames = fields(params);
            %default value
            wlpr = 144;
            for j = 1:size(propnames,1)
                if strcmpi(propnames{j},'numofperiods')
                    wlpr = params.(propnames{j});
                    break
                end
            end
            
            obj.numofperiods_(i) = wlpr;
            
            params_ = struct('name','WilliamR','values',{{propnames{j},wlpr}});
            obj.mde_fut_.settechnicalindicator(instrument,params_);
            
        end
        %end of setparameters
        
        function [] = settradingfreq(obj,instrument,freq)
            if isempty(obj.tradingfreq_), obj.tradingfreq_ = ones(obj.count,1);end
            
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:settradingfreq:invalid instrument input')
            end
            
            instruments = obj.instruments_.getinstrument;
            flag = false;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    obj.tradingfreq_(i) = freq;
                    break
                end
            end
            
            if ~flag
                error('cStratFutMultiWR:settradingfreq:instrument not found')
            end
            
            obj.mde_fut_.setcandlefreq(freq,instrument);
                
        end
        %end of settradingfreq
        
        function [] = setboundary(obj,instrument,overbought,oversold)
            if isempty(obj.overbought_), obj.overbought_ = zeros(obj.count,1);end
            if isempty(obj.oversold_), obj.oversold_ = -100*ones(obj.count,1);end
            
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:setboundary:invalid instrument input')
            end
            
            instruments = obj.instruments_.getinstrument;
            flag = false;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    obj.overbought_(i) = overbought;
                    obj.oversold_(i) = oversold;
                    break
                end
            end
            
            if ~flag
                error('cStratFutMultiWR:setboundary:instrument not found')
            end
        end
        %end of setboundary
        
        function [baseunits,idx] = getbaseunits(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:getbaseunits:invalid instrument input')
            end
            instruments = obj.instruments_.getinstrument;
            flag = false;
            idx = 0;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    baseunits = obj.baseunits_(i);
                    idx = i;
                    flag = true;
                    break
                end
            end
            if ~flag 
                error('cStratFutMultiWR:getbaseunits:instrument not found')
            end
        end
        %end of getbaseunit
        
        function [maxunits,idx] = getmaxunits(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:getmaxunits:invalid instrument input'); 
            end
            instruments = obj.instruments_.getinstrument;
            flag = false;
            idx = 0;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    maxunits = obj.maxunits_(i);
                    idx = i;
                    flag = true;
                    break
                end
            end
            if ~flag
                error('cStratFutMultiWR:getmaxunits:instrument not found'); 
            end
        end
        %end of getmaxunits
            
        function signals = gensignals(obj)
            signals = cell(size(obj.count,1),1);
            instruments = obj.instruments_.getinstrument;
            for i = 1:obj.count
                if obj.wr_(i) <= obj.oversold_(i)
                    signals{i} = struct('instrument',instruments{i},...
                        'direction',1);
                elseif obj.wr_(i) >= obj.overbought_(i)
                    signals{i} = struct('instrument',instruments{i},...
                        'direction',-1);
                else
                    signals{i} = struct('instrument',instruments{i},...
                        'direction',0);
                end
            end
        end
        
        function entrusts = riskmanagement(obj,counter)
            %todo:this might be able to add to the superclass
            if ~isa(counter,'CounterCTP')
                error('cStratFutMultiWR:riskmanagement:invalid counter input')
            end
            
            entrusts = EntrustArray;
            
            instruments = obj.instruments_.getinstrument;
            for i = 1:obj.count
                [flag,idx] = obj.portfolio_.hasinstrument(instruments{i});
                %calculate running pnl in case the embedded porfolio has
                %got the instrument already
                if flag
                    volume = obj.portfolio_.instrument_volume(idx);
                    cost = obj.portfolio_.instrument_avgcost(idx);
                    tick = obj.mde_fut_.getlasttick(instruments{i});
                    bid = tick(2);
                    ask = tick(3);
                    multi = instruments{i}.contract_size;
                    if strfind(instruments{i}.code_bbg,'TFC') || strfind(instruments{i}.code_bbg,'TFT')
                        multi = multi/100;
                    end
                    
                    if volume > 0
                        obj.pnl_running_(i) = (bid-cost)*volume*multi;
                    elseif volume < 0
                        obj.pnl_running_(i) = (ask-cost)*volume*multi;
                    else
                        obj.pnl_running_(i) = 0;
                    end
                    
                    pnl_ = obj.pnl_running_(i) + obj.pnl_close_(i);
                    limit_ = obj.pnl_limit_(i)*cost*abs(volume)*multi*0.1;
                    stop_ = obj.pnl_stop_(i)*cost*abs(volume)*multi*0.1;
                    
                    if pnl_ >= limit_ || pnl_ <= stop_
                        % in case the pnl has either breach the limit or
                        % the stop level, we will unwind the existing
                        % positions
                        code = instruments{i}.code_ctp;
                        offset = -1;
                        if volume > 0
                            %unwind sell entrust using the bid price
                            price = bid - obj.bidspread_(i);
                        else
                            %unwind buy entrust using the ask price
                            price = ask + obj.askspread_(i);
                        end
                        
                        e = Entrust;
                        e.assetType = 'Future';
                        e.multiplier = multi;
                        e.fillEntrust(1,code,-sign(volume),price,abs(volume),offset,code);
                        counter.placeEntrust(e);    
                        
                        %update portfolio and pnl_close_ as required in the
                        %following
                        
                        entrusts.push(e);
                        
                    end
                end
            end
                
        end
        %end of riskmangement
        
        function entrusts = placenewentrusts(obj,signals,counter)
            if ~isa(counter,'CounterCTP')
                error('cStratFutMultiWR:placenewentrusts:invalid counter input')
            end
            
            entrusts = EntrustArray;
            
            %now check the signals
            for i = 1:size(signals,1)
                signal = signals{i};
                if isempty(signal), continue; end
                
                instrument = signal.instrument;
                direction = signal.direction;
                if direction == 0, continue; end
                
                multi = instrument.contract_size;
                code = instrument.code_ctp;
                if strfind(instrument.code_bbg,'TFC') || strfind(instrument.code_bbg,'TFT')
                    multi = multi/100;
                end
                
                [flag,idx] = obj.portfolio_.hasintrument(instrument);
                if ~flag
                    volume_exist = 0;
                else
                    volume_exist = obj.portfolio_.instrument_volume(idx);
                end
                
                offset = 1;
                tick = obj.mde_fut_.getlasttick(instrument);
                bid = tick(2);
                ask = tick(3);
                
                if volume_exist == 0
                    [volume,ii] = obj.getbaseunits(instrument);
                else
                    [maxvolume,ii] = obj.getmaxunits(instrument);
                    volume = min(maxvolume-abs(volume_exist),abs(volume_exist));
                end
                    
                e = Entrust;
                e.assetType = 'Future';
                e.multiplier = multi;
                if direction < 0
                    price =  bid - obj.bidspread_(ii);
                else
                    price =  ask + obj.askspread_(ii);
                end
                
                e.fillEntrust(1,code,direction,price,abs(volume),offset,code);
                counter.placeEntrust(e);
                
                %update portfolio and pnl_close_ as required in the
                %following
                
                entrusts.push(e);
            end
                
                
                
                
                
        end
        %end of placenewentrusts
        
    end
    
    methods
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
        
        function [] = stop(obj)
            if isempty(obj.timer_), return; else stop(obj.timer_); end
        end
        
    end
    
    methods (Access = private)
        function [] = replay_timer_fcn(obj,~,event)
            dtnum = datenum(event.Data.time);
            mm = minute(dtnum) + hour(dtnum)*60;
            
            %for friday evening market
            if isholiday(floor(dtnum))
                if weekday(dtnum) == 7 && mm >= 180
                    return
                elseif weekday(dtnum) == 7 && mm < 180
                    %market might be still open
                else
                    return
                end
            end
            
            %market closed for sure
            if (mm > 150 && mm < 540) || (mm > 690 && mm < 780 ) || (mm > 915 && mm < 1260)               
                % save candles on 2:31am
                if mm == 151, obj.mde_fut_.savecandles2file; end
                
                %init the required data on 8:50
                if mm == 530
                    %todo
                end
                
                return
            end
            
            %market open refresh the market data
            obj.mde_fut_.refresh;
            
            instruments = obj.instruments_.getinstrument;
            for i = 1:obj.count
                ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
                if ~isempty(ti)
                    obj.wr_(i) = ti(end);
                end
            end
        end
        %end of replay_timer_function
        
        function [] = start_timer_fcn(obj,~,event)
            disp([datestr(event.Data.time),' ',obj.name_,' starts......']);
        end
        %end of start_timer_function
        
        function [] = stop_timer_fcn(obj,~,event)
            disp([datestr(event.Data.time),' ',obj.name_,' stops......']);
        end
        %end of stop_timer_function
        
    end
    
end

