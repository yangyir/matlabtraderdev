classdef cSyntheticOptLeg < handle
    properties
        leg_id_@char
        underlier_@cInstrument
        
        first_trade_dt1_
        first_trade_dt2_@char
        last_trade_dt1_
        last_trade_dt2_@char
        trade_dt1_
        trade_dt2_@char
        
        refspot_@double
        type_@char
        strike_
        american_ = false
        interval_ = 1
        freq_ = 'day'
        
        notional_ = 1
        
        tau_@double
        vol_@double
        premium_@double
        delta_@double
        gamma_@double
        theta_@double
        vega_@double
        
    end
    
    methods
        function [] = set.freq_(obj,freq)
            if ~(strcmpi(freq,'day') || strcmpi(freq,'hour') || strcmpi(freq,'minute'))
                error('cSyntheticOptLeg:invalid frequency')
            end
            obj.freq_ = freq;
        end
    end
    
    methods
        function obj = fill(obj,underlier,expiry,opt_type,opt_strike,opt_notional)
            obj.underlier_ = underlier;
            
            if isnumeric(expiry) 
                obj.last_trade_dt1_ = expiry;
                obj.last_trade_dt2_ = datestr(expiry,'yyyy-mm-dd');
            else
                obj.last_trade_dt1_ = datenum(expiry);
                obj.last_trade_dt2_ = expiry;
            end
            
            obj.type_ = opt_type;
            obj.strike_ = opt_strike;
            obj.notional_ = opt_notional;
        end
        %end of fill
        
        function tau = calc_tau(obj)
            %return number in frequency, i.e. n days, n hours or n minute
            d1 = floor(obj.trade_dt1_);
            d2 = obj.last_trade_dt1_;
            bds = gendates('fromdate',d1,'todate',d2);
            nbd = length(bds);
            if strcmpi(obj.freq_,'day')
                tau = nbd;
                if ~(hour(obj.trade_dt1_)>=9 && hour(obj.trade_dt1_) <= 15) && ...
                        (d1 ~= obj.trade_dt1_)
                    %note we take the next business date after the day
                    %trading session
                    tau = tau - 1;
                end
            else
                tl = obj.underlier_.trading_length;
                %always assuming the last_trade_dt is on the close on that
                %day
                tau = (nbd-1)*tl;
                %calc the minutes remained for that trade dt
                th = regexp(obj.underlier_.trading_hours,';','split');
                trademin = hour(obj.trade_dt1_)*60+minute(obj.trade_dt1_);
                passmin = 0;
                for i = 1:length(th)
                    openstr = th{i}(1:5);
                    closestr = th{i}(end-4:end);
                    openmin = str2double(openstr(1:2))*60+...
                        str2double(openstr(end-1:end));
                    closemin = str2double(closestr(1:2))*60+...
                        str2double(closestr(end-1:end));
                    if closemin < openmin
                        %night trading session
                        if (trademin >= openmin && trademin <= 1440) 
                            passmin = passmin + trademin-openmin;
                            break
                        elseif (trademin >= 0 && trademin <= closemin)
                            passmin = passmin + (1440-openmin) + trademin;
                            break
                        end 
                    else
                        %normal trading session
                        if trademin >= openmin && trademin <= closemin
                            passmin = passmin + trademin-openmin;
                            if i == 1 && ~isempty(obj.underlier_.trading_break)
                                %break is between 10:15 and 10:30
                                if trademin >= 630
                                    passmin = passmin - 15;
                                end
                            end
                            break
                        else
                            passmin = passmin + closemin-openmin;
                            if i == 1 && ~isempty(obj.underlier_.trading_break)
                                passmin = passmin - 15;
                            end
                        end
                    end
                end
                tau = tau + tl - passmin;
                if strcmpi(obj.freq_,'hour')
                    tau = tau/60;
                end

            end

        end
        %end of calc_tau
        
        function obj = update(obj,quote)
            if ~isa(quote,'cQuoteFut')
                error('cSyntheticOptLeg:update failed with invalid quote')
            end
            
            if isempty(obj.first_trade_dt1_)
                obj.first_trade_dt1_ = quote.update_date1;
                obj.first_trade_dt2_ = quote.update_date2;
            end
            
            last_trade = quote.last_trade;
            obj.trade_dt1_ = quote.update_time1;
            obj.trade_dt2_ = quote.update_time2;
            obj.tau_ = obj.calc_tau;
            if isempty(obj.refspot_) || obj.refspot_ == 0
                obj.refspot_ = last_trade;
            end
            
            %assume zero volatility
            if ~obj.american_
                px = last_trade/obj.refspot_;
                if strcmpi(obj.freq_,'day')
                    bump = 0.005;
                else
                    bump = obj.vol_/4;
                end
                pxup = px*(1+bump);
                pxdn = px*(1-bump);
                tau = obj.tau_/obj.interval_;
                if strcmpi(obj.type_,'c')
                    obj.premium_ = blkprice(px,obj.strike_,0,tau,obj.vol_);
                    pup = blkprice(pxup,obj.strike_,0,tau,obj.vol_);
                    pdn = blkprice(pxdn,obj.strike_,0,tau,obj.vol_);
                else
                    [~,obj.premium_] = blkprice(px,obj.strike_,0,tau,obj.vol_);
                    [~,pup] = blkprice(pxup,obj.strike_,0,tau,obj.vol_);
                    [~,pdn] = blkprice(pxdn,obj.strike_,0,tau,obj.vol_);
                end
                obj.delta_ = (pup-pdn)/(pxup-pxdn);
                obj.gamma_ = (pup+pdn-2*obj.premium_)/(bump^2)*2*bump/px;
                
                obj.delta_ = obj.delta_*obj.notional_;
                obj.gamma_ = obj.gamma_*obj.notional_;
                
                taucarry = tau - 1;
                if strcmpi(obj.type_,'c')
                    pcarry = blkprice(px,obj.strike_,0,taucarry,obj.vol_);
                else
                    [~,pcarry] = blkprice(px,obj.strike_,0,taucarry,obj.vol_);
                end
                obj.theta_ = pcarry - obj.premium_;
                obj.theta_ = obj.theta_ * obj.premium_;
                
            else
                %todo
                error('not implemented')
            end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        end

    end
    
end