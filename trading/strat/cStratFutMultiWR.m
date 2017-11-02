classdef cStratFutMultiWR < cStrat
    
    properties
        %strategy related 
        numofperiods_@double
        tradingfreq_@double
        overbought_@double
        oversold_@double
        wr_@double                  %william%R 
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
                    obj.maxunits_ = [obj.maxunits_;16];
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
        
        function [] = initdata(obj)
            obj.mde_fut_.initcandles;
            instruments = obj.instruments_.getinstrument;
            for i = 1:obj.count
                ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
                if ~isempty(ti)
                    obj.wr_(i) = ti(end);
                end
            end
        end
        %end of initdata
        
        function [wr,wrts] = getlastwr(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:getlastwr:invalid instrument input')
            end
            wrts = obj.mde_fut_.calc_technical_indicators(instrument);
            wr = wrts(end);
        end
        %end of getlastwr
        
        function [] = printinfo(obj)
            instruments = obj.instruments_.getinstrument;
            for i = 1:obj.count
                ticks = obj.mde_fut_.getlasttick(instruments{i});
                if ~isempty(ticks)
                    t = ticks(1);
                    fprintf('%s %s: trade:%4.1f; williamr:%4.1f\n',...
                        datestr(t,'yyyymmdd HH:MM:SS'),instruments{i}.code_ctp,ticks(end),obj.wr_(i));
                else
                    candles = obj.mde_fut_.gethistcandles(instruments{i});
                    t = candles(end,1);
                    fprintf('%s %s: trade:%4.1f; williamr:%4.1f\n',...
                        datestr(t,'yyyymmdd HH:MM:SS'),instruments{i}.code_ctp,candles(end,5),obj.wr_(i));
                end
            end
            fprintf('\n');
        end
        %end of printinfo
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = cell(size(obj.count,1),1);
            instruments = obj.instruments_.getinstrument;
            
            for i = 1:obj.count
                ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
                if ~isempty(ti)
                    obj.wr_(i) = ti(end);
                end
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
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            if isempty(obj.counter_), return; end
            
            %now check the signals
            for i = 1:size(signals,1)
                signal = signals{i};
                if isempty(signal), continue; end
                
                instrument = signal.instrument;
                direction = signal.direction;
                if direction == 0, continue; end
                
                [flag,idx] = obj.portfolio_.hasinstrument(instrument);
                if ~flag
                    volume_exist = 0;
                else
                    volume_exist = obj.portfolio_.instrument_volume(idx);
                end
                
                if volume_exist == 0
                    [volume,ii] = obj.getbaseunits(instrument);
                else
                    [maxvolume,ii] = obj.getmaxunits(instrument);
                    volume = min(maxvolume-abs(volume_exist),abs(volume_exist));
                end
                
                if ~obj.autotrade_(ii),continue;end
                    
                multi = instrument.contract_size;
                code = instrument.code_ctp;
                if isempty(strfind(instrument.code_bbg,'TFC')) || isempty(strfind(instrument.code_bbg,'TFT'))
                    multi = multi/100;
                end
                

                
                offset = 1;
                tick = obj.mde_fut_.getlasttick(instrument);
                bid = tick(2);
                ask = tick(3);
                
                %firstly to unwind all existing entrusts associated with
                %the instrument
                withdrawpendingentrusts(obj.counter_,code);
                    
                e = Entrust;
                e.assetType = 'Future';
                e.multiplier = multi;
                if direction < 0
                    price =  bid - obj.bidspread_(ii);
                else
                    price =  ask + obj.askspread_(ii);
                end
                
                e.fillEntrust(1,code,direction,price,abs(volume),offset,code);
                obj.counter_.placeEntrust(e);
                obj.entrusts_.push(e);
                                
                %update portfolio and pnl_close_ as required in the
                %following
                %assuming the entrust is completely filled
                t = cTransaction;
                t.instrument_ = instrument;
                t.price_ = price;
                t.volume_= abs(volume);
                t.direction_ = direction;
                t.offset_ = offset;
                obj.portfolio_.updateportfolio(t);
            
            end
                
        end
        %end of placenewentrusts
        
    end
    
    methods

        

        
    end
    
    methods (Access = private)

        
        
        
    end
    
end

