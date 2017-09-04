classdef cQuoteOpt < cQuoteFut
    %class of quotes for listed options
    properties
%         code_ctp
%         code_wind
%         code_bbg
        code_ctp_underlier
        code_wind_underlier
        code_bbg_underlier
%         update_date1   %last update date in number
%         update_date2   %last update date in string
%         update_time1   %last update time in number
%         update_time2   %last update time in string
%         last_trade  %last trade
%         bid   %bid_1
%         ask   %ask_1
%         bid_size  %bid_size_1
%         ask_size  %ask_size_1
        %
        last_trade_underlier
        bid_underlier
        ask_underlier
        bid_size_underlier
        ask_size_underlier
        %
        opt_american = true    %商品期权
        opt_type
        opt_strike
        opt_expiry_date1       %date in number
        opt_expiry_date2       %date in string
        opt_calendar_tau     %time to maturity in years
        opt_business_tau
        %implied vol
        impvol
        %delta
        delta
        %gamma
        gamma
        %vega
        vega
        %theta
        theta
        %riskless rate
        riskless_rate
        %init flag
        init_flag = false
    end
    
    methods
        function obj = init(obj,codestr)
            [flag,optiontype,strike,underlierstr,expiry] = isoptchar(codestr);
            if flag
                obj.code_ctp = str2ctp(codestr);
                obj.code_wind = ctp2wind(obj.code_ctp);
                obj.code_bbg = ctp2bbg(obj.code_ctp);
                %
                obj.code_ctp_underlier = str2ctp(underlierstr);
                obj.code_wind_underlier = ctp2wind(obj.code_ctp_underlier);
                obj.code_bbg_underlier = ctp2bbg(obj.code_ctp_underlier);
                
                obj.opt_type = optiontype;
                obj.opt_strike = str2double(strike);
                obj.opt_expiry_date1 = expiry;
                obj.opt_expiry_date2 = datestr(expiry,'yyyymmdd');
            
                obj.init_flag = true;
            else
                obj.init_flag = false;
            end
        end
        
        function obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_,underlier_quote_)
            if ~obj.init_flag
                obj.init(codestr);
            end
            
            update@cQuoteFut(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_);
            %note: we always use the mid price to imply the volatility
            %which shall be used for calculate delta,gamma,vega,theta...
            
            if ~isa(underlier_quote_,'cQuoteFut')
                error('cQuoteOpt:update:invalid underlier quote input')
            end
            
            obj.code_ctp_underlier = underlier_quote_.code_ctp;
            obj.code_wind_underlier = underlier_quote_.code_wind;
            obj.code_bbg_underlier = underlier_quote_.code_bbg;
            obj.last_trade_underlier = underlier_quote_.last_trade;
            obj.bid_underlier = underlier_quote_.bid1;
            obj.ask_underlier = underlier_quote_.ask1;
            obj.bid_size_underlier = underlier_quote_.bid_size1;
            obj.ask_size_underlier = underlier_quote_.ask_size1;
            
            obj.opt_calendar_tau = (obj.opt_expiry_date1 - obj.update_date1)/365;
            bds = gendates('fromdate',obj.update_date1,'todate',obj.opt_expiry_date1);
            obj.opt_business_tau = length(bds)/252;
            
            %calculate implied vols
            if obj.opt_american
                mid = 0.5*(obj.bid_underlier + obj.ask_underlier);
                midopt = 0.5*(obj.bid1 + obj.ask1);
                r = obj.riskless_rate;
                if strcmpi(obj.opt_type,'C')
                    opttype = 'call';
                else
                    opttype = 'put';
                end
                obj.impvol = bjsimpv(mid,obj.opt_strike,r,obj.update_date1,...
                    obj.opt_expiry_date1,midopt,[],r,[],opttype);
            else
                %TODO
                error('not implemeneted')
            end
            
            %calculate delta/gamma
            if obj.opt_american
                midUp = mid*(1+0.005);
                midDn = mid*(1-0.005);
                if strcmpi(obj.opt_type,'C')
                    pxUp = bjsprice(midUp,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,obj.impvol,r);
                    pxDn = bjsprice(midDn,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,obj.impvol,r);
                else
                    [~,pxUp] = bjsprice(midUp,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,obj.impvol,r);
                    [~,pxDn] = bjsprice(midDn,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,obj.impvol,r);
                end
                %note:we record the percentage level delta and gamma
                obj.delta = (pxUp - pxDn)/(midUp-midDn);
                obj.gamma = (pxUp+pxDn-obj.bid1-obj.ask1)/(0.005^2)*0.01/mid;
            else
                %TODO
                error('not implemeneted')
            end
            
            %calculate theta
            if obj.opt_american
                datecarry = businessdate(obj.update_date1);
                if strcmpi(obj.opt_type,'C')
                    pxCarry = bjsprice(mid,obj.opt_strike,r,datecarry,obj.opt_expiry_date1,obj.impvol,r);
                else
                    [~,pxCarry] = bjsprice(mid,obj.opt_strike,r,datecarry,obj.opt_expiry_date1,obj.impvol,r);
                end
                obj.theta = pxCarry - 0.5*(obj.bid1 + obj.ask1);
            else
                %TODO
                error('not implemeneted')
            end
            
            %calculate vega
            if obj.opt_american
                ivUp = obj.impvol + 0.005;
                ivDn = obj.impvol - 0.005;
                if strcmpi(obj.opt_type,'C')
                    pxVolUp = bjsprice(mid,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,ivUp,r);
                    pxVolDn = bjsprice(mid,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,ivDn,r);
                else
                    [~,pxVolUp] = bjsprice(mid,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,ivUp,r);
                    [~,pxVolDn] = bjsprice(mid,obj.opt_strike,r,obj.update_date1,obj.opt_expiry_date1,ivDn,r);
                end
                obj.vega = pxVolUp - pxVolDn;
            else
                %TODO
                error('not implemeneted')
            end
            
            
            
            
            
        end
        
    end
    
    
    
end