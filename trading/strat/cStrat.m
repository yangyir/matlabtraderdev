classdef cStrat < handle
    %base abstract class of strategy
    properties
        name_@char
        
        %trading pnl related
        pnl_stop_@double            % stop ratio as of the margin used
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
        
        %market data engine
        mde_fut_@cMDEFut;
        mde_opt_@cMDEOpt;
        
        %portfolio/book
        portfolio_@cPortfolio;
        
        %
        autotrade_@double

    end
    
    methods
        function [] = registerinstrument(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cStrat:registerinstrument:invalid instrument input')
            end
            
            if isempty(obj.instruments_), obj.instruments_ = cInstrumentArray;end
            %check whether the instrument is an option or not
            codestr = instrument.code_ctp;
            [flag,~,~,underlierstr,~] = isoptchar(codestr);
            if flag
                if isempty(obj.underliers_), obj.underliers_ = cInstrumentArray;end
                u = cFutures(underlierstr);
                u.loadinfo([underlierstr,'_info.txt']);
                obj.underliers_.addinstrument(u);
            end
            obj.instruments_.addinstrument(instrument);
            
            %pnl_stop_
            if isempty(obj.pnl_stop_)
                obj.pnl_stop_ = -inf*ones(obj.count,1);
            else
                if size(obj.pnl_stop_,1) < obj.count
                    obj.pnl_stop_ = [obj.pnl_stop_;-inf];
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
            
            if ~flag
                obj.mde_fut_.registerinstrument(instrument);
            else
                obj.mde_fut_.registerinstrument(u);
                obj.mde_opt_.registerinstrument(instrument);
            end
        end
        %end of 'registerinstrument'
        
        function obj = removeinstrument(obj,instrument)

            if isempty(obj.instruments_), return; end
            
            obj.instruments_.removeinstrument(instrument);
            [flag,~,~,underlierstr,~] = isoptchar(instrument.code_ctp);
            if flag
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
        
        function pnl = calcpnl(obj, portfolio, quotes)
            %note: the portfolio may have different instruments than the
            %strategy itself. However, compared with the embedded
            %intruments within the strategy, the portfolio itself includes
            %additional information, e.g. avgcost and volume,which is
            %essential for pnl calculation
            
            if ~isa(portfolio,'cPortfolio')
                error('cStrat:calcpnl:invalid portfolio input');
            end
            
            n = obj.count;
            %in case there is no instrument registered with the stratey,
            %the pnl shall be always report as zero
            if n == 0
                pnl = 0;
                obj.pnl_running_ = 0;
                return
            end
            
            %get the sub portfolio associated with the strategy's
            %instruments
            p = portfolio.subportfolio(obj.instruments_);
            
            obj.pnl_running_ = p.runningpnl(quotes);
            pnl = obj.pnl_running_ + obj.pnl_close_;
            
        end
        %end of calcpnl
        
        function entrusts = placenewentrusts(obj,counter,qms,portfolio,signals)
            if ~isa(counter,'CounterCTP')
                error('cStratFutSingleSyntheticOpt:placenewentrusts:invalid counter input')
            end
            
            if ~isa(portfolio,'cPortfolio')
                error('cStratFutSingleSyntheticOpt:placenewentrusts:invalid portfolio input')
            end
            
            if ~isa(qms,'cQMS')
                error('cStratFutSingleSyntheticOpt:placenewentrusts:invalid qms input')
            end
            
            entrusts = EntrustArray;
            
            for i = 1:size(signals,1)
                signal = signals{i};
                if isempty(signal), continue; end
                
                instrument = signal.instrument;
                volume = signal.volume;
                if volume == 0, continue; end
                
                [flag,idx] = portfolio.hasintrument(instrument);
                if ~flag, continue; end
                
                volume_exist = portfolio.instrument_volume(idx);
                offset2 = 0;
                volume2 = 0;
                if volume_exist == 0
                    offset = 1;
                elseif volume_exist * volume > 0
                    offset = 1;
                elseif volume_exist * volume < 0
                    offset = -1;
                    %this is the most complicated part as both open/close
                    %entrusts might be needed
                    if abs(volume) > abs(volume_exist)
                        offset2 = 1;
                        volume2 = abs(volume)-abs(volume_exist);
                        volume = abs(volume_exist);
                    end
                else
                    error('cStratFutSingleSyntheticOpt:placenewentrusts:internal error')
                end
                direction = sign(volume);
                code = instrument.code_ctp;
                
                type_ = class(instrument);
                multi = instrument.contract_size;
                if strfind(instrument.code_bbg,'TFC') || strfind(instrument.code_bbg,'TFT')
                    multi = multi/100;
                end
                
                if strcmpi(type_,'cFutures')
                    assettype_ = 'Future';
                elseif strcmpi(type_,'cOption')
                    assettype_ = 'Option';
                else
                    assettype_ = 'ETF';
                end
             
                %get the latest trade
                qms.refresh;
                q = qms.getquote(code);
                if direction > 0
                    price = q.ask1 - obj.askspread_;
                else
                    price = q.bid1 + obj.bidspread_;
                end
                
                e = Entrust;
                e.assetType = assettype_;
                e.multiplier = multi;
                e.fillEntrust(1,code,direction,price,abs(volume),offset,code);
                if offset2 ~= 0
                    e2 = Entrust;
                    e2.assetType = assettype_;
                    e2.fillEntrust(1,code,direction,price,abs(volume2),offset2,code);
                end
                
                counter.placeEntrust(e);
                if offset2 ~= 0, counter.placeEntrust(e2); end
                entrusts.push(e);
                if offset2 ~= 0, entrusts.push(e2); end
                
            end
                  
        end
        %end of placenewentrusts
        
        function indices = matchquoteindex(obj,quotes)
            list = obj.instruments_.getinstrument;
            n = obj.count;
            indices = zeros(n);
            for i = 1:n
                qidx = 0;
                for j = 1:size(quotes)
                    if strcmpi(list{i}.code_ctp,quotes{j}.code_ctp)
                        qidx = j;
                        break
                    end
                end
                if qidx == 0, error('cStrat:matchquoteindex:invalid quotes'); end
                indices(i) = qidx;
            end
        end
        %end of matchquoteindex
        
    end
        
    methods (Abstract)
        signals = gensignals(obj)
        
        
    end
end