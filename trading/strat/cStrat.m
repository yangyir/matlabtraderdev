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
        function [] = setstoptype(obj,instrument,stoptype)
            if ~ischar(stoptype), error('cStrat:setstoptype:invalid stoptype input'); end
            if ~(strcmpi(stoptype,'rel') || strcmpi(stoptype,'abs'))
                error('cStrat:setstoptype:invalid stoptype input')
            end
            
            if isempty(obj.pnl_stop_type_), obj.pnl_stop_type_ = cell(obj.count,1);end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:setstoptype:instrument not found');end
            
            obj.pnl_stop_type_{idx} = stoptype;
            
        end
        %setstoptype
        
        function [] = setstopamount(obj,instrument,stop)
            if ~isnumeric(stop), error('cStrat:setstopamount:invalid stop input');end

            if isempty(obj.pnl_stop_), obj.pnl_stop_ = -inf*ones(obj.count,1);end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:setstopamount:instrument not found');end
            
            obj.pnl_stop_(idx) = stop;
                
        end
        %end of 'setstopamount'
        
        function [] = setlimittype(obj,instrument,limitype)
            if ~ischar(limitype), error('cStrat:setlimittype:invalid limitype input'); end
            if ~(strcmpi(limitype,'rel') || strcmpi(limitype,'abs'))
                error('cStrat:setstoptype:invalid limitype input')
            end
            
            if isempty(obj.pnl_limit_type_), obj.pnl_limit_type_ = cell(obj.count,1);end
                
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:setlimittype:instrument not found');end
            
            obj.pnl_limit_type_{idx} = limitype;
            
        end
        %setlimittype
        
        function [] = setlimitamount(obj,instrument,limit)
            if ~isnumeric(limit), error('cStrat:setlimitamount:invalid limit input'); end
            
            if isempty(obj.pnl_limit_), obj.pnl_limit_ = inf*ones(obj.count,1);end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:setlimitamount:instrument not found');end
                
            obj.pnl_limit_(idx) = limit;
                
        end
        %end of 'setlimitamount'
        
        function type_ = getstoptype(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:getstoptype:instrument not found');end
            type_ = obj.pnl_stop_type_{idx};
            
        end
        %end of 'getstoptype'
        
        function amount_ = getstopamount(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:getstoptype:instrument not found');end
            amount_ = obj.pnl_stop_(idx);

        end
        %end of 'getstoptype'
              
        function type_ = getlimittype(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:getlimittype:instrument not found');end
            type_ = obj.pnl_limit_type_{idx};
            
        end
        %end of 'getlimittype'
        
        function amount_ = getlimitamount(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:getlimitamount:instrument not found');end
            amount_ = obj.pnl_limit_(idx);
            
        end
        %end of 'getlimitamount'
        
        function [] = setbidspread(obj,instrument,bidspread)
            if ~isnumeric(bidspread), error('cStrat:setbidspread:invalid bid spread input');end
            
            if isempty(obj.bidspread_), obj.bidspread_ = zeros(obj.count,1); end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:setbidspread:instrument not found');end
            
            obj.bidspread_(idx) = bidspread;

        end
        %end of setbidspread
        
        function [] = setaskspread(obj,instrument,askspread)
            if ~isnumeric(askspread), error('cStrat:setaskspread:invalid bid spread input');end
            
            if isempty(obj.askspread_), obj.askspread_ = zeros(obj.count,1); end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:setaskspread:instrument not found');end
            
            obj.askspread_(idx) = askspread;
            
        end
        %end of setbidaskspread
        
        function bidspread = getbidspread(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:getbidspread:instrument not found');end
            bidspread = obj.bidspread_(idx);
            
        end
        %end of getbidspread
        
        function askspread = getaskspread(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag, error('cStrat:getaskspread:instrument not found');end            
            askspread = obj.askspread_(idx);

        end
        %end of getaskspread
             
        function [] = setbaseunits(obj,instrument,baseunits)
            if ~isnumeric(baseunits), error('cStrat:setbaseunits:invalid baseunits input');end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag 
                error('cStrat:setbaseunits:instrument not found')
            end
            obj.baseunits_(idx) = baseunits;
            
        end
        %end of setbaseunits
        
        function baseunits = getbaseunits(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag
                error('cStrat:getbaseunits:instrument not found')
            end
            baseunits = obj.baseunits_(idx);
            
        end
        %end of getbaseunit
        
        function [] = setmaxunits(obj,instrument,maxunits)
            if ~isnumeric(maxunits), error('cStrat:setmaxunits:invalid baseunits input');end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag
                error('cStrat:setmaxunits:instrument not found')
            end
            obj.maxunits_(idx) = maxunits;
            
        end
        %end of setmaxunits
        
        function maxunits = getmaxunits(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag
                error('cStratFut:getmaxunits:instrument not found');
            end
            maxunits = obj.maxunits_(idx);
            
        end
        %end of getmaxunits
        
        function [] = setautotradeflag(obj,instrument,autotrade)
            if ~isnumeric(autotrade), error('cStrat:setautotradeflag:invalid autotrade input');end
            if ~(autotrade == 0 || autotrade == 1),error('cStrat:setautotradeflag:invalid autotrade input');end
            
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            
            if ~flag
                error('cStrat:setautotradeflag:instrument not found')
            end
            
            obj.autotrade_(idx) = autotrade;
            
        end
        %end of setautotradeflag
        
        function autotrade = getautotradeflag(obj,instrument)
            [flag,idx] = obj.instruments_.hasinstrument(instrument);
            if ~flag
                error('cStrat:getautotradeflag:instrument not found')
            end
            autotrade = obj.autotrade_(idx);
            
        end
        %end of getautotradeflag
        
        function [] = setmdeconnection(obj,connstr)
            if ~(strcmpi(connstr,'bloomberg') || strcmpi(connstr,'ctp'))
                error('cStrat:setmdeconnection:invalid connstr input')
            end
            
            if isempty(obj.mde_fut_) 
                obj.mde_fut_ = cMDEFut;
                qms_fut_ = cQMS;
                qms_fut_.setdatasource(connstr);
                obj.mde_fut_.qms_ = qms_fut_;
            else
                obj.mde_fut_.qms_.setdatasource(connstr);
            end
            
            %mde_opt_
            if isempty(obj.mde_opt_) 
                obj.mde_opt_ = cMDEOpt; 
                qms_opt_ = cQMS;
                qms_opt_.setdatasource(connstr);
                obj.mde_opt_.qms_ = qms_opt_;
            else
                obj.mde_opt_.qms_.setdatasource(connstr);
            end
        end
        %end setmdeconnection
        
    end
    %end of set/get methods
    
    %instrument-related methods
    methods
        function [] = registerinstrument(obj,instrument)
            if ischar(instrument)
                codestr = instrument;
            elseif isa(instrument,'cInstrument')
                codestr = instrument.code_ctp;
            else
                error('cStrat:registerinstrument:invalid instrument input')
            end
            
            if isempty(obj.instruments_), obj.instruments_ = cInstrumentArray;end
            %check whether the instrument is an option or not
            [optflag,~,~,underlierstr,~] = isoptchar(codestr);
            if optflag
                if isempty(obj.underliers_), obj.underliers_ = cInstrumentArray;end
                u = cFutures(underlierstr);
                u.loadinfo([underlierstr,'_info.txt']);
                obj.underliers_.addinstrument(u);
            end
            if isa(instrument,'cInstrument')
                obj.instruments_.addinstrument(instrument);
            elseif ischar(instrument)
                if optflag
                    instrument = cOption(codestr);
                    instrument.loadinfo([codestr,'_info.txt']);
                    obj.instruments_.addinstrument(instrument);
                else
                    instrument = cFutures(codestr);
                    instrument.loadinfo([codestr,'_info.txt']);
                    obj.instruments_.addinstrument(instrument);
                end
            end
            
            %pnl_stop_type_
            if isempty(obj.pnl_stop_type_)
                obj.pnl_stop_type_ = cell(obj.count,1);
                for i = 1:obj.count, obj.pnl_stop_type_{i} = 'rel';end
            else
                if size(obj.pnl_stop_type_,1) < obj.count;
                    type_ = cell(obj.count,1);
                    type_(1:size(obj.pnl_stop_type_,1)) = obj.pnl_stop_type_;
                    type_{end} = 'rel';
                    obj.pnl_stop_type_ = type_;
                end
            end
            
            %pnl_stop_
            if isempty(obj.pnl_stop_)
                obj.pnl_stop_ = -inf*ones(obj.count,1);
            else
                if size(obj.pnl_stop_,1) < obj.count
                    obj.pnl_stop_ = [obj.pnl_stop_;-inf];
                end
            end
            
            %pnl_limit_type_
            if isempty(obj.pnl_limit_type_)
                obj.pnl_limit_type_ = cell(obj.count,1);
                for i = 1:obj.count, obj.pnl_limit_type_{i} = 'rel';end
            else
                if size(obj.pnl_limit_type_,1) < obj.count;
                    type_ = cell(obj.count,1);
                    type_(1:size(obj.pnl_limit_type_,1)) = obj.pnl_limit_type_;
                    type_{end} = 'rel';
                    obj.pnl_limit_type_ = type_;
                end
            end
            
            %pnl_limit_
            if isempty(obj.pnl_limit_)
                obj.pnl_limit_ = inf*ones(obj.count,1);
            else
                if size(obj.pnl_limit_,1) < obj.count
                    obj.pnl_limit_ = [obj.pnl_limit_;inf];
                end
            end
            
            %pnl_running_
            if isempty(obj.pnl_running_)
                obj.pnl_running_ = zeros(obj.count,1);
            else
                if size(obj.pnl_running_,1) < obj.count
                    obj.pnl_running_ = [obj.pnl_running_;0];
                end
            end
            
            %pnl_close_
            if isempty(obj.pnl_close_)
                obj.pnl_close_ = zeros(obj.count,1);
            else
                if size(obj.pnl_close_,1) < obj.count
                    obj.pnl_close_ = [obj.pnl_close_;0];
                end
            end
            
            %bidspread_
            if isempty(obj.bidspread_)
                obj.bidspread_ = zeros(obj.count,1);
            else
                if size(obj.bidspread_,1) < obj.count
                    obj.bidspread_ = [obj.bidspread_;0];
                end
            end
            
            %askspread_
            if isempty(obj.askspread_)
                obj.askspread_ = zeros(obj.count,1);
            else
                if size(obj.askspread_,1) < obj.count
                    obj.askspread_ = [obj.askspread_;0];
                end
            end
            
            %autotrade_
            if isempty(obj.autotrade_)
                obj.autotrade_ = zeros(obj.count,1);
            else
                if size(obj.autotrade_,1) < obj.count
                    obj.autotrade_ = [obj.autotrade_;0];
                end
            end
            
            %mde_fut_
            if isempty(obj.mde_fut_) 
                obj.mde_fut_ = cMDEFut;
                qms_fut_ = cQMS;
                qms_fut_.setdatasource('ctp');
                obj.mde_fut_.qms_ = qms_fut_;
            end
            
            %mde_opt_
            if isempty(obj.mde_opt_) 
                obj.mde_opt_ = cMDEOpt; 
                qms_opt_ = cQMS;
                qms_opt_.setdatasource('ctp');
                obj.mde_opt_.qms_ = qms_opt_;
            end
            
            if ~optflag
                obj.mde_fut_.registerinstrument(instrument);
            else
                obj.mde_fut_.registerinstrument(u);
                obj.mde_opt_.registerinstrument(instrument);
            end
        end
        %end of 'registerinstrument'
        
        function [] = removeinstrument(obj,instrument)

            if isempty(obj.instruments_), return; end
            
            obj.instruments_.removeinstrument(instrument);
            [optflag,~,~,underlierstr,~] = isoptchar(instrument.code_ctp);
            if optflag
                %note:we shall also remove the underlier in case all the
                %options with the instrument are gone
                list = obj.instruments_.getinstrument;
                removeunderlier = true;
                for i = 1:size(list,1)
                    codestr = list{i}.code_ctp;
                    [check,~,~,underlierstr_i,~] = isoptchar(codestr);
                    if check && strcmpi(underlierstr_i,underlierstr)
                        removeunderlier = false;
                        break
                    end
                end
                
                if removeunderlier
                    u = cFutures(underlierstr);
                    u.loadinfo([underlierstr,'_info.txt']);
                    obj.underliers_.removeinstrument(u);
                end
            end

        end
        %end of 'removeinstrument'
        
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
                tick = obj.mde_fut_.getlasttick(instrument);
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
        function [] = registercounter(obj,counter)
            if ~isa(counter,'CounterCTP'), error('cStrat:registercounter:invalid counter input');end
            obj.counter_ = counter;
            obj.entrusts_ = EntrustArray;
        end
        %end of registercounter
        
        function [] = loadportfoliofromcounter(obj)
            if isempty(obj.counter_), return; end
            obj.portfolio_ = cPortfolio;
            positions = obj.counter_.queryPositions;
            instruments = obj.instruments_.getinstrument;
            
            for i = 1:obj.count
                instrument = instruments{i};
                for j = 1:size(positions,2)
                    if strcmpi(instrument.code_ctp,positions(j).asset_code)
                        multi = instrument.contract_size;
                        if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
                            multi = multi/100;
                        end
                        
                        direction = positions(j).direction;
                        cost = positions(j).avg_price / multi;
                        volume = positions(j).total_position * direction;
                        
                        obj.portfolio_.updateinstrument(instrument,cost,volume);
                    end
                end
            end
        end
        %end of loadportfoliofromcounter
        
        function pnl = updateportfoliowithentrust(obj,e)
            pnl = 0;
            if isempty(obj.counter_), return; end
            if ~isa(e,'Entrust'), return; end
            
            ret = obj.counter_.queryEntrust(e);
            if ret
                f1 = e.is_entrust_closed;
                f2 = e.dealVolume > 0;
                [f3,idx] = obj.instruments_.hasinstrument(e.instrumentCode);
                if f1&&f2&&f3
                    instrument = obj.instruments_.getinstrument{idx};
                    t = cTransaction;
                    t.instrument_ = instrument;
                    t.price_ = e.dealAmount./e.dealVolume;
                    t.volume_ = e.dealVolume;
                    t.direction_ = e.direction;
                    t.offset_ = e.offsetFlag;
                    t.datetime1_ = e.time;
                    pnl = obj.portfolio_.updateportfolio(t);
                end
            end
        end
        %end of updateportfoliowithentrust
    
        function [] = riskmanagement(obj,dtnum)
            if isempty(obj.counter_) && ~strcmpi(obj.mode_,'debug'), return; end
            
            instruments = obj.instruments_.getinstrument;
            for i = 1:obj.count
                %firstly to check whether this is in trading hours
                ismarketopen = istrading(dtnum,instruments{i}.trading_hours,...
                    'tradingbreak',instruments{i}.trading_break);
                if ~ismarketopen, continue; end
                
                %secondly to check whether the instrument has been traded
                %and recorded in the embedded portfolio
                [isinstrumenttraded,idx] = obj.portfolio_.hasinstrument(instruments{i});
                
                if ~isinstrumenttraded, continue; end
                 
                %calculate running pnl in case the embedded porfolio has
                %got the instrument already
                
                volume = obj.portfolio_.instrument_volume(idx);
                cost = obj.portfolio_.instrument_avgcost(idx);
                obj.calcrunningpnl(instruments{i});
                
                %                     pnl_ = obj.pnl_running_(i) + obj.pnl_close_(i);
                pnl_ = obj.pnl_running_(i);
                
                multi = instruments{i}.contract_size;
                if ~isempty(strfind(instruments{i}.code_bbg,'TFC')) ||...
                        ~isempty(strfind(instruments{i}.code_bbg,'TFT'))
                    multi = multi/100;
                end
                
                margin = instruments{i}.init_margin_rate;
                if isempty(margin), margin = 0.1;end
                
                if strcmpi(obj.pnl_limit_type_{i},'rel')
                    limit_ = obj.pnl_limit_(i)*cost*abs(volume)*multi*margin;
                else
                    limit_ = obj.pnl_limit_(i);
                end
                
                if strcmpi(obj.pnl_stop_type_{i},'rel')
                    stop_ = -obj.pnl_stop_(i)*cost*abs(volume)*multi*margin;
                else
                    stop_ = -obj.pnl_stop_(i);
                end
                
                % in case the pnl has either breach the limit or
                % the stop level, we will unwind the existing
                % positions
                if pnl_ >= limit_ || pnl_ <= stop_
                    obj.unwindposition(instruments{i});
                end 
            end
            
        end
        %end of riskmangement
        
        function [] = unwindposition(obj,instrument)
            if nargin < 1, return; end
            
            %check whether the instrument has been registered with the
            %strategy
            [flag,idx_instrument] = obj.instruments_.hasinstrument(instrument);
            if ~flag, return; end
            
            %check whether the instrument has been traded already
            [flag,idx_portfolio] = obj.portfolio_.hasinstrument(instrument);
            if ~flag, return; end

            code = instrument.code_ctp;
            
            if ~strcmpi(obj.mode_,'debug')
                obj.withdrawentrusts(instrument);
            end
            
            isshfe = strcmpi(obj.portfolio_.instrument_list{idx_portfolio}.exchange,'.SHF');
            volume = obj.portfolio_.instrument_volume(idx_portfolio);
            tick = obj.mde_fut_.getlasttick(instrument);
            bid = tick(2);
            ask = tick(3);
            tick_size = obj.portfolio_.instrument_list{idx_portfolio}.tick_size;
            if volume > 0
                %place entrust with sell flag using the bid price
                price = bid - obj.bidspread_(idx_instrument)*tick_size;
            elseif volume < 0
                %place entrust with buy flag using the ask price
                price = ask + obj.askspread_(idx_instrument)*tick_size;
            end
            %note:offset = -1 indicating unwind positions
            offset = -1;
            
            if strcmpi(obj.mode_,'debug')
                %update portfolio and pnl_close_ as required in the
                %following
                %assuming the entrust is completely filled in debug mode
                t = cTransaction;
                t.instrument_ = obj.portfolio_.instrument_list{idx_portfolio};
                t.price_ = price;
                t.volume_= abs(volume);
                t.direction_ = -sign(volume);
                t.offset_ = offset;
                pnl = obj.portfolio_.updateportfolio(t);
                obj.pnl_close_(idx_instrument) = obj.pnl_close_(idx_instrument) + pnl;
                return
            end
            
            %for 'realtime' mode
            if ~isshfe
                e = Entrust;
                e.assetType = 'Future';
                e.fillEntrust(1,code,-sign(volume),price,abs(volume),offset,code);
                ret = obj.counter_.placeEntrust(e);
                if ret
                    obj.entrusts_.push(e);
%                     t = cTransaction;
%                     t.instrument_ = instrument;
%                     t.price_ = price;
%                     t.volume_ = abs(volume);
%                     t.direction_ = -sign(volume);
%                     t.offset_ = offset;
%                     t.datetime1_ = now;
%                     pnl = obj.portfolio_.updateportfolio(t);
                    pnl = updateportfoliowithentrust(obj,e);
                    obj.pnl_close_(idx_instrument) = obj.pnl_close_(idx_instrument) + pnl;
                end
            else
                volume_today = obj.portfolio_.instrument_volume_today(idx_portfolio);
                volume_before = volume - volume_today;
                if volume_today ~= 0
                    e = Entrust;
                    e.assetType = 'Future';
                    e.fillEntrust(1,code,-sign(volume_today),price,abs(volume_today),offset,code);
                    e.closetodayFlag = 1;
                    ret = obj.counter_.placeEntrust(e);
                    if ret
%                         obj.entrusts_.push(e);
%                         t = cTransaction;
%                         t.instrument_ = instrument;
%                         t.price_ = price;
%                         t.volume_ = abs(volume_today);
%                         t.direction_ = -sign(volume_today);
%                         t.offset_ = offset;
%                         t.datetime1_ = now;
%                         pnl = obj.portfolio_.updateportfolio(t);
                        pnl = updateportfoliowithentrust(obj,e);
                        obj.pnl_close_(idx_instrument) = obj.pnl_close_(idx_instrument) + pnl;
                    end 
                end
                if volume_before ~= 0
                    e = Entrust;
                    e.assetType = 'Future';
                    e.multiplier = multi;
                    e.fillEntrust(1,code,-sign(volume_before),price,abs(volume_before),offset,code);
                    ret = obj.counter_.placeEntrust(e);
                    if ret
                        obj.entrusts_.push(e);
%                         t = cTransaction;
%                         t.instrument_ = instrument;
%                         t.price_ = price;
%                         t.volume_ = abs(volume_before);
%                         t.direction_ = -sign(volume_before);
%                         t.offset_ = offset;
%                         t.datetime1_ = now;
%                         pnl = obj.portfolio_.updateportfolio(t);
                        pnl = updateportfoliowithentrust(obj,e);
                        obj.pnl_close_(idx_instrument) = obj.pnl_close_(idx_instrument) + pnl;
                    end 
                end
            end
        end
        %end of unwindpositions
        
        
        function [] = withdrawentrusts(obj,instrument)
            if ischar(instrument)
                code_ctp = instrument;
            elseif isa(instrument,'cInstrument')
                code_ctp = instrument.code_ctp;
            else
                error('cStrat:withdrawentrusts:invalid instrument input')
            end
            
            for i = 1:obj.entrusts_.count
                e = obj.entrusts_.node(i);
                if strcmpi(e.instrumentCode,code_ctp)
                    if ~e.is_entrust_filled || ~e.is_entrust_closed
                        ret = withdrawentrust(obj.counter_,e);
                        if ret
                            %the code will execute once the entrust is
                            %successfully withdrawn
                            if e.dealVolume > 0
                                %we need to update the portfolio in case
                                %the entrust is partially filled
                                [~,idx] = obj.instruments_.hasinstrument(e.instrumentCode);
                                instrument = obj.instruments_.getinstrument{idx};
                                t = cTransaction;
                                t.instrument_ = instrument;
                                t.price_ = e.dealAmount./e.dealVolume;
                                t.volume_ = e.dealVolume;
                                t.direction_ = e.direction;
                                t.offset_ = e.offsetFlag;
                                t.datetime1_ = e.time;
                                obj.portfolio_.updateportfolio(t);
                            end
                        end
                    end
                end
            end
        end
        %end of withdrawentrusts
        
        function [] = updateentrusts(obj)
            n = obj.entrusts_.count;
            for i = 1:n
                e = obj.entrusts_.node(i);
                if e.entrustStatus ~= -1
                    updateportfoliowithentrust(obj,e);
                end
            end
        end
        %end of updateentrusts
        
    end
    %end of trading-related methods
    
    %timer-related methods
    methods
        function [] = start(obj)
            obj.settimer;
            if isempty(obj.portfolio_) 
                obj.portfolio_ = cPortfolio;
            end
            start(obj.timer_);
        end
        %end of start
        
        function [] = stop(obj)
            if isempty(obj.timer_), return; else stop(obj.timer_); end
        end
        %end of stop
        
        function [] = startat(obj,dtstr)
            obj.settimer;
            y = year(dtstr);
            m = month(dtstr);
            d = day(dtstr);
            hh = hour(dtstr);
            mm = minute(dtstr);
            ss = second(dtstr);
            startat(obj.timer_,y,m,d,hh,mm,ss);
        end
        %end of startat
        
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
        autoplacenewentrusts(obj,signals)
    end
    
    %timer-related private methods
    methods (Access = private)
        function [] = settimer(obj)
            if strcmpi(obj.mode_, 'debug')
                obj.timer_interval_ = 0.005;
            end
                
            obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_fcn,...
                'TimerFcn', @obj.replay_timer_fcn,...
                'StopFcn',@obj.stop_timer_fcn,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,5));
        end
        %end of settimer
        
        function [] = replay_timer_fcn(obj,~,event)
            if strcmpi(obj.mode_,'debug')
                obj.dtcount4debug_ = obj.dtcount4debug_ + 1;
                dtnum = obj.timevec4debug_(obj.dtcount4debug_,1);
            else
                dtnum = datenum(event.Data.time);
            end
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
                if mm == 151, obj.mde_fut_.savecandles2file(dtnum); end
                
                %init the required data on 8:50
                if mm == 530
                    %todo
                end
                
                return
            end
            
            %market open refresh the market data
            if ~isempty(obj.mde_fut_), obj.mde_fut_.refresh; end
            if ~isempty(obj.mde_opt_), obj.mde_opt_.refresh; end
            
            try
                obj.updateentrusts;
            catch e
                msg = ['error:cStrat:updateentrusts:',e.message,'\n'];
                fprintf(msg);
            end
            
            try
                obj.riskmanagement(dtnum);
            catch e
                msg = ['error:cStrat:riskmanagment:',e.message,'\n'];
                fprintf(msg);
            end
            
            try
                signals = obj.gensignals;
            catch e
                msg = ['error:cStrat:gensiignals:',e.message,'\n'];
                fprintf(msg);
            end
            
            try
                obj.autoplacenewentrusts(signals);
            catch e
                msg = ['error:cStrat:autoplacenewentrusts:',e.message,'\n'];
                fprintf(msg);
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